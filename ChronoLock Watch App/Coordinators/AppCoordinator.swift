import SwiftUI
import Combine

class AppCoordinator: ObservableObject {
    @Published var currentTab: AppTab = .inventory
    @Published var showOnboarding = false
    
    private var cancellables = Set<AnyCancellable>()
    
    enum AppTab: String, CaseIterable {
        case inventory = "Inventory"
        case discovery = "Discovery"
        case resonance = "Resonance"
        case achievements = "Achievements"
        case profile = "Profile"
        
        var systemImage: String {
            switch self {
            case .inventory:
                return "shippingbox.fill"
            case .discovery:
                return "location.fill"
            case .resonance:
                return "bolt.fill"
            case .achievements:
                return "trophy.fill"
            case .profile:
                return "person.fill"
            }
        }
    }
    
    init() {
        checkOnboardingStatus()
    }
    
    private func checkOnboardingStatus() {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        showOnboarding = !hasCompletedOnboarding
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        showOnboarding = false
    }
    
    func switchToTab(_ tab: AppTab) {
        currentTab = tab
    }
}