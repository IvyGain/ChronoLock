import SwiftUI

struct HealthKitPermissionView: View {
    @StateObject private var healthKit = HealthKitManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var isRequesting = false
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "heart.fill")
                .font(.largeTitle)
                .foregroundColor(.red)
            
            Text("Heart Rate Access")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("ChronoLock uses your heart rate to create immersive gameplay with cursed treasure chests.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 4) {
                featureRow(
                    icon: "bolt.heart.fill",
                    title: "Curse Effects",
                    description: "Higher heart rate makes lock picking more challenging"
                )
                
                featureRow(
                    icon: "gamecontroller.fill",
                    title: "Dynamic Difficulty",
                    description: "Gameplay adapts to your stress level"
                )
                
                featureRow(
                    icon: "lock.shield.fill",
                    title: "Privacy First",
                    description: "Heart rate data stays on your device"
                )
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Button(action: requestPermission) {
                    HStack {
                        if isRequesting {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "heart.fill")
                        }
                        Text(isRequesting ? "Requesting..." : "Allow Heart Rate")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red.opacity(0.2))
                    .foregroundColor(.red)
                    .clipShape(Capsule())
                }
                .disabled(isRequesting)
                
                Button("Skip for Now") {
                    dismiss()
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .onChange(of: healthKit.isAuthorized) { isAuthorized in
            if isAuthorized {
                dismiss()
            }
        }
    }
    
    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.red)
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
        isRequesting = true
        
        Task {
            let granted = await healthKit.requestAuthorization()
            
            await MainActor.run {
                isRequesting = false
                
                if granted {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    HealthKitPermissionView()
}