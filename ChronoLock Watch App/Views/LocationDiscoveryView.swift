import SwiftUI
import CoreLocation

struct LocationDiscoveryView: View {
    @StateObject private var locationManager = LocationManager.shared
    @State private var showLocationPermission = false
    @State private var discoveredChest: TreasureChest?
    @State private var showChestDiscovery = false
    
    var body: some View {
        VStack(spacing: 6) {
            headerView
            
            if locationManager.isAuthorized {
                if locationManager.isMonitoring {
                    activeDiscoveryView
                } else {
                    inactiveView
                }
            } else {
                permissionView
            }
        }
        .sheet(isPresented: $showLocationPermission) {
            LocationPermissionView()
        }
        .sheet(isPresented: $showChestDiscovery) {
            if let chest = discoveredChest {
                ChestDiscoverySheet(chest: chest)
            }
        }
        .onAppear {
            if locationManager.isAuthorized && !locationManager.isMonitoring {
                locationManager.startLocationMonitoring()
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 2) {
            Text("Treasure Hunt")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let location = locationManager.currentLocation {
                Text("Location: \(location.coordinate.latitude, specifier: "%.3f"), \(location.coordinate.longitude, specifier: "%.3f")")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                Text("Finding your location...")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var activeDiscoveryView: some View {
        VStack(spacing: 4) {
            if locationManager.nearbyChests.isEmpty {
                VStack(spacing: 4) {
                    Image(systemName: "location")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("Scanning for treasures...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Walk around to discover hidden chests")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            } else {
                ScrollView {
                    VStack(spacing: 3) {
                        Text("Nearby Treasures")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        ForEach(locationManager.nearbyChests) { locationChest in
                            NearbyChestRow(locationChest: locationChest) {
                                discoverChest(locationChest)
                            }
                        }
                    }
                }
            }
            
            Button(action: {
                locationManager.stopLocationMonitoring()
            }) {
                HStack {
                    Image(systemName: "location.slash")
                        .font(.caption)
                    Text("Stop Scanning")
                        .font(.caption)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.2))
                .foregroundColor(.red)
                .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var inactiveView: some View {
        VStack(spacing: 6) {
            Image(systemName: "location.circle")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Location Discovery Inactive")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button(action: {
                locationManager.startLocationMonitoring()
            }) {
                HStack {
                    Image(systemName: "location")
                        .font(.caption)
                    Text("Start Scanning")
                        .font(.caption)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.2))
                .foregroundColor(.blue)
                .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var permissionView: some View {
        VStack(spacing: 6) {
            Image(systemName: "location.slash")
                .font(.title2)
                .foregroundColor(.orange)
            
            Text("Location Access Required")
                .font(.caption)
                .foregroundColor(.primary)
            
            Text("Enable location access to discover treasures around you")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                showLocationPermission = true
            }) {
                HStack {
                    Image(systemName: "gear")
                        .font(.caption)
                    Text("Grant Permission")
                        .font(.caption)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.2))
                .foregroundColor(.orange)
                .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private func discoverChest(_ locationChest: LocationBasedChest) {
        let chest = locationManager.discoverChest(locationChest)
        discoveredChest = chest
        showChestDiscovery = true
        
        // Play haptic feedback
        HapticManager.shared.play(.resonanceOfflineReward)
    }
}

struct NearbyChestRow: View {
    let locationChest: LocationBasedChest
    let onDiscover: () -> Void
    
    private var distance: Double {
        if let userLocation = LocationManager.shared.currentLocation {
            return userLocation.distance(from: locationChest.location)
        }
        return 0
    }
    
    var body: some View {
        HStack(spacing: 6) {
            VStack(alignment: .leading, spacing: 1) {
                Text(locationChest.name)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Text(locationChest.chest.rarity.description)
                        .font(.caption2)
                        .padding(.horizontal, 3)
                        .padding(.vertical, 1)
                        .background(rarityColor.opacity(0.2))
                        .foregroundColor(rarityColor)
                        .clipShape(Capsule())
                    
                    Text("\(Int(distance))m away")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: onDiscover) {
                Image(systemName: "plus.circle.fill")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(rarityColor.opacity(0.05))
                .stroke(rarityColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var rarityColor: Color {
        switch locationChest.chest.rarity {
        case .common:
            return .gray
        case .rare:
            return .blue
        case .legendary:
            return .purple
        }
    }
}

struct ChestDiscoverySheet: View {
    let chest: TreasureChest
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "shippingbox.fill")
                .font(.largeTitle)
                .foregroundColor(rarityColor)
            
            Text("Treasure Discovered!")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(chest.name)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 2) {
                HStack {
                    Text("Rarity:")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(chest.rarity.description)
                        .font(.caption2)
                        .foregroundColor(rarityColor)
                }
                
                HStack {
                    Text("Lock Type:")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(chest.lockType.description)
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Text("Difficulty:")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Level \(chest.difficulty)")
                        .font(.caption2)
                        .foregroundColor(.primary)
                }
            }
            
            if chest.isCursed || chest.hasTrap {
                VStack(spacing: 2) {
                    if chest.isCursed {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                            Text("Cursed - Heart rate affects difficulty")
                                .foregroundColor(.red)
                        }
                        .font(.caption2)
                    }
                    
                    if chest.hasTrap {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Trapped - Handle with care")
                                .foregroundColor(.orange)
                        }
                        .font(.caption2)
                    }
                }
            }
            
            Button("Continue") {
                dismiss()
            }
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.green.opacity(0.2))
            .foregroundColor(.green)
            .clipShape(Capsule())
        }
        .padding()
    }
    
    private var rarityColor: Color {
        switch chest.rarity {
        case .common:
            return .gray
        case .rare:
            return .blue
        case .legendary:
            return .purple
        }
    }
}

#Preview {
    LocationDiscoveryView()
}