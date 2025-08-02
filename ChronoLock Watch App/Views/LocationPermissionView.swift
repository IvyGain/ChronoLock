import SwiftUI

struct LocationPermissionView: View {
    @StateObject private var locationManager = LocationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "location.fill")
                .font(.largeTitle)
                .foregroundColor(.blue)
            
            Text("Location Access")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("ChronoLock uses your location to discover treasure chests hidden around the world.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 4) {
                featureRow(
                    icon: "shippingbox.fill",
                    title: "Treasure Discovery",
                    description: "Find hidden chests at interesting locations"
                )
                
                featureRow(
                    icon: "map.fill",
                    title: "Location-Based Gameplay",
                    description: "Your real-world exploration unlocks game content"
                )
                
                featureRow(
                    icon: "lock.shield.fill",
                    title: "Privacy Focused",
                    description: "Location data is only used for treasure discovery"
                )
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Button(action: requestPermission) {
                    HStack {
                        Image(systemName: "location.fill")
                        Text("Allow Location Access")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .clipShape(Capsule())
                }
                
                Button("Skip for Now") {
                    dismiss()
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .onChange(of: locationManager.isAuthorized) { isAuthorized in
            if isAuthorized {
                dismiss()
            }
        }
    }
    
    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.blue)
                .frame(width: 16)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
    }
    
    private func requestPermission() {
        locationManager.requestLocationPermission()
    }
}

#Preview {
    LocationPermissionView()
}