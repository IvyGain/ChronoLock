import SwiftUI
import WatchKit

struct MainView: View {
    @State private var crownValue: Double = 0.0
    
    var body: some View {
        VStack {
            Image(systemName: "lock.rotation")
                .font(.largeTitle)
                .foregroundColor(.accent)
            
            Text("ChronoLock")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Turn Crown to Begin")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(crownValue, specifier: "%.1f")")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .digitalCrownRotation(
            $crownValue,
            from: 0,
            through: 100,
            by: 1,
            sensitivity: .medium,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
        .onReceive(NotificationCenter.default.publisher(for: WKExtension.applicationDidBecomeActiveNotification)) { _ in
            // App became active
        }
    }
}

#Preview {
    MainView()
}