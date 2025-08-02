import Foundation
import HealthKit
import Combine

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    @Published var isAuthorized = false
    @Published var currentHeartRate: Double = 0
    @Published var isMonitoring = false
    
    private let healthStore = HKHealthStore()
    private var heartRateQuery: HKAnchoredObjectQuery?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        checkAuthorizationStatus()
    }
    
    func requestAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return false
        }
        
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let typesToRead: Set<HKQuantityType> = [heartRateType]
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            
            await MainActor.run {
                checkAuthorizationStatus()
            }
            
            return isAuthorized
        } catch {
            print("HealthKit authorization failed: \(error)")
            return false
        }
    }
    
    private func checkAuthorizationStatus() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let status = healthStore.authorizationStatus(for: heartRateType)
        
        isAuthorized = status == .sharingAuthorized
    }
    
    func startHeartRateMonitoring() {
        guard isAuthorized else {
            print("HealthKit not authorized for heart rate monitoring")
            return
        }
        
        guard !isMonitoring else {
            print("Heart rate monitoring already active")
            return
        }
        
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        
        // Create predicate for recent heart rate data (last 10 seconds)
        let predicate = HKQuery.predicateForSamples(
            withStart: Date().addingTimeInterval(-10),
            end: nil,
            options: .strictStartDate
        )
        
        // Create anchored object query for real-time updates
        heartRateQuery = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: predicate,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] query, samples, deletedObjects, newAnchor, error in
            
            if let error = error {
                print("Heart rate query error: \(error)")
                return
            }
            
            self?.processHeartRateSamples(samples)
        }
        
        // Set update handler for ongoing monitoring
        heartRateQuery?.updateHandler = { [weak self] query, samples, deletedObjects, newAnchor, error in
            if let error = error {
                print("Heart rate update error: \(error)")
                return
            }
            
            self?.processHeartRateSamples(samples)
        }
        
        healthStore.execute(heartRateQuery!)
        isMonitoring = true
        
        print("Started heart rate monitoring")
    }
    
    func stopHeartRateMonitoring() {
        guard let query = heartRateQuery else { return }
        
        healthStore.stop(query)
        heartRateQuery = nil
        isMonitoring = false
        
        DispatchQueue.main.async {
            self.currentHeartRate = 0
        }
        
        print("Stopped heart rate monitoring")
    }
    
    private func processHeartRateSamples(_ samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else { return }
        
        // Get the most recent heart rate sample
        if let latestSample = heartRateSamples.sorted(by: { $0.startDate > $1.startDate }).first {
            let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
            let heartRate = latestSample.quantity.doubleValue(for: heartRateUnit)
            
            DispatchQueue.main.async {
                self.currentHeartRate = heartRate
            }
            
            print("Heart rate updated: \(heartRate) BPM")
        }
    }
    
    func getHeartRateEffect() -> HeartRateEffect {
        guard isMonitoring && currentHeartRate > 0 else {
            return .none
        }
        
        if currentHeartRate >= 120 {
            return .severe
        } else if currentHeartRate >= 100 {
            return .moderate
        } else if currentHeartRate >= 80 {
            return .mild
        } else {
            return .none
        }
    }
    
    func getHeartRateIntensity() -> Double {
        // Normalize heart rate to 0.0-1.0 range for gameplay effects
        let normalizedRate = max(0, min(200, currentHeartRate)) / 200.0
        return normalizedRate
    }
}

enum HeartRateEffect {
    case none
    case mild
    case moderate
    case severe
    
    var description: String {
        switch self {
        case .none:
            return "Calm"
        case .mild:
            return "Elevated"
        case .moderate:
            return "High"
        case .severe:
            return "Critical"
        }
    }
    
    var color: (red: Double, green: Double, blue: Double) {
        switch self {
        case .none:
            return (0.3, 0.8, 0.3)  // Green
        case .mild:
            return (0.8, 0.8, 0.3)  // Yellow
        case .moderate:
            return (0.8, 0.5, 0.3)  // Orange
        case .severe:
            return (0.8, 0.3, 0.3)  // Red
        }
    }
}