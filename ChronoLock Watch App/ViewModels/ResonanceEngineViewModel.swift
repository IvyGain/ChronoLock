import Foundation
import Combine
import WatchKit

class ResonanceEngineViewModel: ObservableObject {
    @Published var engine: ResonanceEngine
    @Published var offlineRewards: Double = 0
    @Published var showOfflineRewards = false
    
    private var timer: Timer?
    private let hapticManager = HapticManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.engine = GameDataManager.shared.resonanceEngine
        
        // Subscribe to changes from GameDataManager
        GameDataManager.shared.$resonanceEngine
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newEngine in
                self?.engine = newEngine
            }
            .store(in: &cancellables)
        
        calculateOfflineRewards()
        startPeriodicUpdates()
    }
    
    private func calculateOfflineRewards() {
        let rewards = GameDataManager.shared.calculateOfflineRewards()
        
        if rewards > 0 {
            offlineRewards = rewards
            showOfflineRewards = true
        }
    }
    
    private func startPeriodicUpdates() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateAutoPoints()
        }
    }
    
    private func updateAutoPoints() {
        let pointsPerSecond = engine.autoPointsPerSecond
        if pointsPerSecond > 0 {
            GameDataManager.shared.resonanceEngine.points += pointsPerSecond
        }
    }
    
    func performManualResonance() {
        hapticManager.play(.resonanceManualClick)
        GameDataManager.shared.resonanceEngine.performManualResonance()
    }
    
    func upgradeHandCrank() -> Bool {
        let success = GameDataManager.shared.resonanceEngine.upgradeHandCrank()
        if success {
            hapticManager.play(.resonanceOfflineReward)
        } else {
            hapticManager.play(.trapNoiseSubtleStatic)
        }
        return success
    }
    
    func buyTuningFork() -> Bool {
        let success = GameDataManager.shared.resonanceEngine.buyTuningFork()
        if success {
            hapticManager.play(.resonanceOfflineReward)
        } else {
            hapticManager.play(.trapNoiseSubtleStatic)
        }
        return success
    }
    
    func upgradeAmplifier() -> Bool {
        let success = GameDataManager.shared.resonanceEngine.upgradeAmplifier()
        if success {
            hapticManager.play(.resonanceOfflineReward)
        } else {
            hapticManager.play(.trapNoiseSubtleStatic)
        }
        return success
    }
    
    func dismissOfflineRewards() {
        showOfflineRewards = false
        hapticManager.play(.resonanceOfflineReward)
    }
    
    var formattedPoints: String {
        formatNumber(engine.points)
    }
    
    var formattedPointsPerRotation: String {
        formatNumber(engine.manualPointsPerRotation)
    }
    
    var formattedPointsPerSecond: String {
        formatNumber(engine.autoPointsPerSecond)
    }
    
    var formattedHandCrankCost: String {
        formatNumber(engine.handCrankUpgradeCost())
    }
    
    var formattedTuningForkCost: String {
        formatNumber(engine.tuningForkCost())
    }
    
    var formattedAmplifierCost: String {
        formatNumber(engine.amplifierUpgradeCost())
    }
    
    var formattedOfflineRewards: String {
        formatNumber(offlineRewards)
    }
    
    private func formatNumber(_ number: Double) -> String {
        if number >= 1_000_000_000 {
            return String(format: "%.2fB", number / 1_000_000_000)
        } else if number >= 1_000_000 {
            return String(format: "%.2fM", number / 1_000_000)
        } else if number >= 1_000 {
            return String(format: "%.2fK", number / 1_000)
        } else {
            return String(format: "%.0f", number)
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}