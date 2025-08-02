import SwiftUI
import WatchKit

struct MainView: View {
    @StateObject private var coordinator = AppCoordinator()
    
    var body: some View {
        Group {
            if coordinator.showOnboarding {
                OnboardingView(coordinator: coordinator)
            } else {
                TabView(selection: $coordinator.currentTab) {
                    ChestInventoryView()
                        .tag(AppCoordinator.AppTab.inventory)
                    
                    ResonanceEngineView()
                        .tag(AppCoordinator.AppTab.resonance)
                    
                    ProfileView()
                        .tag(AppCoordinator.AppTab.profile)
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: WKExtension.applicationDidBecomeActiveNotification)) { _ in
            // App became active - calculate offline rewards if needed
            _ = GameDataManager.shared.calculateOfflineRewards()
        }
    }
}

#Preview {
    MainView()
}