import SwiftUI

struct ResonanceEngineView: View {
    @StateObject private var viewModel = ResonanceEngineViewModel()
    @StateObject private var audioManager = AudioManager.shared
    @State private var crownRotation: Double = 0
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            manualResonanceView
                .tag(0)
            
            upgradesView
                .tag(1)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .sheet(isPresented: $viewModel.showOfflineRewards) {
            offlineRewardsSheet
        }
        .onAppear {
            audioManager.playAmbientLoop(.resonanceHum)
        }
        .onDisappear {
            audioManager.stopAmbientLoop(.resonanceHum)
        }
    }
    
    private var manualResonanceView: some View {
        VStack(spacing: 6) {
            headerView
            
            resonanceVisualization
                .digitalCrownRotation(
                    $crownRotation,
                    from: -10,
                    through: 10,
                    by: 0.1,
                    sensitivity: .high,
                    isContinuous: true,
                    isHapticFeedbackEnabled: false
                ) { delta in
                    if abs(delta) > 0.2 {
                        viewModel.performManualResonance()
                    }
                }
            
            statsView
            
            manualControls
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 1) {
            Text("Resonance Engine")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Chronicle Points: \(viewModel.formattedPoints)")
                .font(.caption)
                .foregroundColor(.blue)
        }
    }
    
    private var resonanceVisualization: some View {
        VStack(spacing: 4) {
            // Central resonance core
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [.blue.opacity(0.8), .blue.opacity(0.2)]),
                            center: .center,
                            startRadius: 10,
                            endRadius: 40
                        )
                    )
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(Color.blue, lineWidth: 2)
                    )
                
                // Rotating energy rings
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        .frame(width: CGFloat(90 + index * 15), height: CGFloat(90 + index * 15))
                        .rotationEffect(.degrees(Double(index * 120) + crownRotation * 10))
                        .animation(.linear(duration: 2), value: crownRotation)
                }
                
                // Core symbol
                Image(systemName: "bolt.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            Text("Turn Crown to Generate")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private var statsView: some View {
        VStack(spacing: 2) {
            HStack {
                Text("Manual:")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(viewModel.formattedPointsPerRotation)/turn")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
            
            HStack {
                Text("Auto:")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(viewModel.formattedPointsPerSecond)/sec")
                    .font(.caption2)
                    .foregroundColor(.green)
            }
        }
    }
    
    private var manualControls: some View {
        VStack(spacing: 3) {
            Button(action: {
                viewModel.performManualResonance()
            }) {
                HStack {
                    Image(systemName: "hand.tap.fill")
                        .font(.caption)
                    Text("Manual Resonance")
                        .font(.caption)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.2))
                .foregroundColor(.blue)
                .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())
            
            Text("Swipe for Upgrades →")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private var upgradesView: some View {
        ScrollView {
            VStack(spacing: 4) {
                Text("Upgrades")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Chronicle Points: \(viewModel.formattedPoints)")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Divider()
                
                upgradeCard(
                    title: "Hand Crank",
                    subtitle: "Level \(viewModel.engine.handCrankLevel)",
                    description: "Increases manual resonance power",
                    cost: viewModel.formattedHandCrankCost,
                    canAfford: viewModel.engine.points >= viewModel.engine.handCrankUpgradeCost(),
                    action: viewModel.upgradeHandCrank
                )
                
                upgradeCard(
                    title: "Tuning Fork",
                    subtitle: "\(viewModel.engine.tuningForks) owned",
                    description: "Generates passive points",
                    cost: viewModel.formattedTuningForkCost,
                    canAfford: viewModel.engine.points >= viewModel.engine.tuningForkCost(),
                    action: viewModel.buyTuningFork
                )
                
                upgradeCard(
                    title: "Amplifier",
                    subtitle: "Level \(viewModel.engine.amplifierLevel)",
                    description: "Multiplies tuning fork output",
                    cost: viewModel.formattedAmplifierCost,
                    canAfford: viewModel.engine.points >= viewModel.engine.amplifierUpgradeCost(),
                    action: viewModel.upgradeAmplifier
                )
            }
            .padding(.horizontal, 4)
        }
    }
    
    private func upgradeCard(
        title: String,
        subtitle: String,
        description: String,
        cost: String,
        canAfford: Bool,
        action: @escaping () -> Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    _ = action()
                }) {
                    Text(cost)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(canAfford ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                        .foregroundColor(canAfford ? .green : .gray)
                        .clipShape(Capsule())
                }
                .disabled(!canAfford)
                .buttonStyle(PlainButtonStyle())
            }
            
            Text(description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.gray.opacity(0.1))
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var offlineRewardsSheet: some View {
        VStack(spacing: 8) {
            Image(systemName: "clock.fill")
                .font(.largeTitle)
                .foregroundColor(.green)
            
            Text("Welcome Back!")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("While you were away, the Resonance Engine generated:")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack {
                Text(viewModel.formattedOfflineRewards)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("Chronicle Points")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            Button("Collect") {
                viewModel.dismissOfflineRewards()
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
}

#Preview {
    ResonanceEngineView()
}