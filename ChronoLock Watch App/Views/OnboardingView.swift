import SwiftUI

struct OnboardingView: View {
    @ObservedObject var coordinator: AppCoordinator
    @State private var currentPage = 0
    @State private var crownValue: Double = 0
    
    private let pages = [
        OnboardingPage(
            title: "Welcome to ChronoLock",
            subtitle: "Master the art of time-locked treasures",
            icon: "lock.rotation",
            description: "Embark on a tactile adventure using your Apple Watch's unique capabilities."
        ),
        OnboardingPage(
            title: "Digital Crown Control",
            subtitle: "Your precision tool for lock picking",
            icon: "crown.fill",
            description: "Rotate the Digital Crown to feel the resistance and find the sweet spots in each lock."
        ),
        OnboardingPage(
            title: "Haptic Mastery",
            subtitle: "Feel your way to victory",
            icon: "hand.tap.fill",
            description: "Every lock has its own haptic signature. Learn to read the vibrations with your fingertips."
        ),
        OnboardingPage(
            title: "Resonance Engine",
            subtitle: "Passive power generation",
            icon: "bolt.fill",
            description: "Build and upgrade your mystical engine to generate Chronicle Points even when you're away."
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    pageView(pages[index], pageIndex: index)
                        .tag(index)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            bottomControls
        }
        .onTapGesture {
            nextPage()
        }
    }
    
    private func pageView(_ page: OnboardingPage, pageIndex: Int) -> some View {
        VStack(spacing: 8) {
            Spacer()
            
            if pageIndex == 1 {
                // Interactive Digital Crown demo
                VStack(spacing: 4) {
                    Image(systemName: page.icon)
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(crownValue * 36))
                        .animation(.easeInOut(duration: 0.2), value: crownValue)
                    
                    Text("Try rotating the Digital Crown")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("\(crownValue, specifier: "%.1f")")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
                .digitalCrownRotation(
                    $crownValue,
                    from: 0,
                    through: 10,
                    by: 0.1,
                    sensitivity: .medium,
                    isContinuous: false,
                    isHapticFeedbackEnabled: true
                )
            } else {
                Image(systemName: page.icon)
                    .font(.largeTitle)
                    .foregroundColor(.blue)
            }
            
            Text(page.title)
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            Text(page.subtitle)
                .font(.caption)
                .foregroundColor(.blue)
                .multilineTextAlignment(.center)
            
            Text(page.description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
            
            Spacer()
        }
    }
    
    private var bottomControls: some View {
        VStack(spacing: 4) {
            HStack {
                if currentPage > 0 {
                    Button("Back") {
                        previousPage()
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if currentPage < pages.count - 1 {
                    Button("Next") {
                        nextPage()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                } else {
                    Button("Start Adventure") {
                        coordinator.completeOnboarding()
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                }
            }
            .padding(.horizontal)
            
            Text("Tap anywhere to continue")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.bottom, 4)
    }
    
    private func nextPage() {
        if currentPage < pages.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage += 1
            }
        } else {
            coordinator.completeOnboarding()
        }
    }
    
    private func previousPage() {
        if currentPage > 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage -= 1
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let icon: String
    let description: String
}

#Preview {
    OnboardingView(coordinator: AppCoordinator())
}