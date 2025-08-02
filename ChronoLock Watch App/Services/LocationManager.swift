import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    
    @Published var isAuthorized = false
    @Published var currentLocation: CLLocation?
    @Published var nearbyChests: [LocationBasedChest] = []
    @Published var isMonitoring = false
    
    private let locationManager = CLLocationManager()
    private var discoveredChestLocations: Set<String> = []
    
    override init() {
        super.init()
        setupLocationManager()
        loadDiscoveredChestLocations()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10.0 // 10 meters
        
        checkAuthorizationStatus()
    }
    
    private func loadDiscoveredChestLocations() {
        if let data = UserDefaults.standard.data(forKey: "discoveredChestLocations"),
           let locations = try? JSONDecoder().decode(Set<String>.self, from: data) {
            discoveredChestLocations = locations
        }
    }
    
    private func saveDiscoveredChestLocations() {
        if let data = try? JSONEncoder().encode(discoveredChestLocations) {
            UserDefaults.standard.set(data, forKey: "discoveredChestLocations")
        }
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func checkAuthorizationStatus() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isAuthorized = true
        case .denied, .restricted:
            isAuthorized = false
        case .notDetermined:
            isAuthorized = false
        @unknown default:
            isAuthorized = false
        }
    }
    
    func startLocationMonitoring() {
        guard isAuthorized else {
            print("Location access not authorized")
            return
        }
        
        guard !isMonitoring else {
            print("Location monitoring already active")
            return
        }
        
        locationManager.startUpdatingLocation()
        isMonitoring = true
        
        print("Started location monitoring")
    }
    
    func stopLocationMonitoring() {
        locationManager.stopUpdatingLocation()
        isMonitoring = false
        nearbyChests = []
        
        print("Stopped location monitoring")
    }
    
    private func checkForNearbyChests(at location: CLLocation) {
        nearbyChests = []
        
        // Generate location-based chests around interesting coordinates
        let interestingLocations = generateInterestingLocations(near: location)
        
        for (index, interestingLocation) in interestingLocations.enumerated() {
            let distance = location.distance(from: interestingLocation.location)
            
            if distance <= interestingLocation.discoveryRadius {
                let chestId = "\(interestingLocation.name)_\(index)"
                
                // Only show each chest once
                if !discoveredChestLocations.contains(chestId) {
                    let locationChest = LocationBasedChest(
                        id: chestId,
                        name: interestingLocation.name,
                        location: interestingLocation.location,
                        chest: generateChestForLocation(interestingLocation),
                        discoveryRadius: interestingLocation.discoveryRadius,
                        isDiscovered: false
                    )
                    
                    nearbyChests.append(locationChest)
                }
            }
        }
    }
    
    func discoverChest(_ locationChest: LocationBasedChest) -> TreasureChest {
        discoveredChestLocations.insert(locationChest.id)
        saveDiscoveredChestLocations()
        
        // Remove from nearby chests
        nearbyChests.removeAll { $0.id == locationChest.id }
        
        // Add to inventory
        GameDataManager.shared.addChest(locationChest.chest)
        
        print("Discovered chest: \(locationChest.name)")
        
        return locationChest.chest
    }
    
    private func generateInterestingLocations(near location: CLLocation) -> [InterestingLocation] {
        // Generate fictional interesting locations around the user's current position
        // In a real app, you might use a places API or predefined locations
        
        let baseLocations = [
            ("Ancient Ruins", 50.0),
            ("Hidden Grove", 30.0),
            ("Forgotten Cemetery", 40.0),
            ("Mystical Spring", 25.0),
            ("Abandoned Tower", 60.0),
            ("Secret Cave", 35.0),
            ("Lost Temple", 70.0),
            ("Enchanted Oak", 20.0)
        ]
        
        return baseLocations.enumerated().compactMap { index, data in
            let (name, radius) = data
            
            // Generate location within 500m radius of user
            let randomDistance = Double.random(in: 100...500)
            let randomBearing = Double.random(in: 0...360) * .pi / 180
            
            let deltaLatitude = randomDistance * cos(randomBearing) / 111111.0
            let deltaLongitude = randomDistance * sin(randomBearing) / (111111.0 * cos(location.coordinate.latitude * .pi / 180))
            
            let interestingLocation = CLLocation(
                latitude: location.coordinate.latitude + deltaLatitude,
                longitude: location.coordinate.longitude + deltaLongitude
            )
            
            return InterestingLocation(
                name: name,
                location: interestingLocation,
                discoveryRadius: radius
            )
        }
    }
    
    private func generateChestForLocation(_ location: InterestingLocation) -> TreasureChest {
        // Generate chest based on location characteristics
        let rarities: [ChestRarity] = [.common, .common, .rare, .legendary]
        let lockTypes: [LockType] = [.pinTumbler, .dialCombination, .rotaryPuzzle]
        
        let rarity = rarities.randomElement() ?? .common
        let lockType = lockTypes.randomElement() ?? .pinTumbler
        let difficulty = Int.random(in: 1...8)
        
        // Special locations might have cursed or trapped chests
        let isCursed = location.name.contains("Cemetery") || location.name.contains("Ancient") && Bool.random()
        let hasTrap = difficulty > 5 && Bool.random()
        let timeLimit: TimeInterval? = (isCursed || hasTrap) ? Double.random(in: 20...60) : nil
        
        return TreasureChest(
            name: "\(location.name) Treasure",
            rarity: rarity,
            lockType: lockType,
            difficulty: difficulty,
            hasTrap: hasTrap,
            isCursed: isCursed,
            timeLimit: timeLimit
        )
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentLocation = location
        checkForNearbyChests(at: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkAuthorizationStatus()
        
        if isAuthorized && !isMonitoring {
            startLocationMonitoring()
        } else if !isAuthorized && isMonitoring {
            stopLocationMonitoring()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error)")
    }
}

struct LocationBasedChest: Identifiable {
    let id: String
    let name: String
    let location: CLLocation
    let chest: TreasureChest
    let discoveryRadius: Double
    let isDiscovered: Bool
}

struct InterestingLocation {
    let name: String
    let location: CLLocation
    let discoveryRadius: Double
}