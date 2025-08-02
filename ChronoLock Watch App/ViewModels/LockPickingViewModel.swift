import Foundation
import Combine
import WatchKit

class LockPickingViewModel: ObservableObject {
    @Published var currentChest: TreasureChest
    @Published var isUnlocking = false
    @Published var isUnlocked = false
    @Published var timeRemaining: TimeInterval = 0
    @Published var currentPin = 0
    @Published var pinHeights: [Double] = []
    @Published var pinStates: [PinState] = []
    @Published var progress: Double = 0
    @Published var heartRateEffect: HeartRateEffect = .none
    @Published var isHeartRateMonitoring = false
    
    private var correctHeights: [Double] = []
    private var timer: Timer?
    private let hapticManager = HapticManager.shared
    private let healthKitManager = HealthKitManager.shared
    private let tolerance: Double = 0.1
    private var cancellables = Set<AnyCancellable>()
    
    enum PinState {
        case locked
        case correct
        case set
    }
    
    init(chest: TreasureChest) {
        self.currentChest = chest
        setupLock()
        setupHeartRateMonitoring()
    }
    
    private func setupHeartRateMonitoring() {
        // Subscribe to heart rate updates for cursed chests
        if currentChest.isCursed {
            healthKitManager.$currentHeartRate
                .receive(on: DispatchQueue.main)
                .sink { [weak self] heartRate in
                    self?.heartRateEffect = self?.healthKitManager.getHeartRateEffect() ?? .none
                }
                .store(in: &cancellables)
            
            healthKitManager.$isMonitoring
                .receive(on: DispatchQueue.main)
                .assign(to: &$isHeartRateMonitoring)
        }
    }
    
    private func setupLock() {
        let pinCount = min(max(currentChest.difficulty, 3), 6)
        pinHeights = Array(repeating: 0.0, count: pinCount)
        pinStates = Array(repeating: .locked, count: pinCount)
        correctHeights = (0..<pinCount).map { _ in Double.random(in: 0.3...0.9) }
        
        if let timeLimit = currentChest.timeLimit {
            timeRemaining = timeLimit
        }
    }
    
    func startUnlocking() {
        guard !isUnlocking else { return }
        
        isUnlocking = true
        
        // Start heart rate monitoring for cursed chests
        if currentChest.isCursed && healthKitManager.isAuthorized {
            healthKitManager.startHeartRateMonitoring()
        }
        
        if currentChest.timeLimit != nil {
            startTimer()
        }
        
        hapticManager.play(.pickingResistanceLight)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.timeRemaining -= 0.1
            
            if self.timeRemaining <= 0 {
                self.failUnlock()
            } else if self.timeRemaining <= 5.0 {
                if Int(self.timeRemaining * 10) % 10 == 0 {
                    self.hapticManager.play(.trapNoiseSubtleStatic)
                }
            }
        }
    }
    
    func updatePinHeight(delta: Double) {
        guard isUnlocking, currentPin < pinHeights.count else { return }
        
        // Apply heart rate effects for cursed chests
        var adjustedDelta = delta
        if currentChest.isCursed {
            adjustedDelta = applyHeartRateEffect(to: delta)
        }
        
        let oldHeight = pinHeights[currentPin]
        pinHeights[currentPin] = max(0, min(1.0, pinHeights[currentPin] + adjustedDelta))
        
        let correctHeight = correctHeights[currentPin]
        let distance = abs(pinHeights[currentPin] - correctHeight)
        
        // Adjust tolerance based on heart rate for cursed chests
        var adjustedTolerance = tolerance
        if currentChest.isCursed {
            adjustedTolerance = adjustToleranceForHeartRate()
        }
        
        if distance < adjustedTolerance {
            if pinStates[currentPin] != .correct {
                pinStates[currentPin] = .correct
                hapticManager.play(.pickingSweetSpotPulse)
            }
        } else {
            if pinStates[currentPin] == .correct {
                pinStates[currentPin] = .locked
                hapticManager.play(.pickingResistanceLight)
            }
        }
        
        let resistance = calculateResistance(height: pinHeights[currentPin], correctHeight: correctHeight)
        playResistanceHaptic(resistance: resistance)
        
        updateProgress()
    }
    
    private func applyHeartRateEffect(to delta: Double) -> Double {
        switch heartRateEffect {
        case .none:
            return delta
        case .mild:
            // Slightly jittery movement
            let noise = Double.random(in: -0.02...0.02)
            return delta + noise
        case .moderate:
            // More erratic movement with reduced precision
            let noise = Double.random(in: -0.05...0.05)
            let dampening = Double.random(in: 0.7...1.3)
            return (delta * dampening) + noise
        case .severe:
            // Highly unstable movement
            let noise = Double.random(in: -0.1...0.1)
            let dampening = Double.random(in: 0.5...1.5)
            return (delta * dampening) + noise
        }
    }
    
    private func adjustToleranceForHeartRate() -> Double {
        switch heartRateEffect {
        case .none:
            return tolerance
        case .mild:
            return tolerance * 0.9  // Slightly harder
        case .moderate:
            return tolerance * 0.7  // Moderately harder
        case .severe:
            return tolerance * 0.5  // Much harder
        }
    }
    
    private func calculateResistance(height: Double, correctHeight: Double) -> Double {
        let distance = abs(height - correctHeight)
        return max(0.1, min(1.0, distance * 2))
    }
    
    private func playResistanceHaptic(resistance: Double) {
        if resistance < 0.3 {
            hapticManager.play(.pickingResistanceLight)
        } else {
            hapticManager.play(.pickingResistanceHeavy)
        }
    }
    
    func setPinAndMoveNext() {
        guard isUnlocking, currentPin < pinHeights.count else { return }
        guard pinStates[currentPin] == .correct else {
            hapticManager.play(.trapNoiseSubtleStatic)
            return
        }
        
        pinStates[currentPin] = .set
        hapticManager.play(.pickingSetClickFirm)
        
        if currentPin < pinHeights.count - 1 {
            currentPin += 1
            hapticManager.play(.pickingResistanceLight)
        } else {
            completeUnlock()
        }
        
        updateProgress()
    }
    
    func moveToPreviousPin() {
        guard isUnlocking, currentPin > 0 else { return }
        
        if pinStates[currentPin - 1] == .set {
            pinStates[currentPin - 1] = .correct
        }
        
        currentPin -= 1
        hapticManager.play(.pickingResistanceLight)
        updateProgress()
    }
    
    private func updateProgress() {
        let setPins = pinStates.filter { $0 == .set }.count
        progress = Double(setPins) / Double(pinStates.count)
    }
    
    private func completeUnlock() {
        timer?.invalidate()
        timer = nil
        
        // Stop heart rate monitoring
        if currentChest.isCursed {
            healthKitManager.stopHeartRateMonitoring()
        }
        
        isUnlocking = false
        isUnlocked = true
        
        hapticManager.play(.rarityCommonShortTap)
        
        GameDataManager.shared.unlockChest(currentChest)
    }
    
    private func failUnlock() {
        timer?.invalidate()
        timer = nil
        
        // Stop heart rate monitoring
        if currentChest.isCursed {
            healthKitManager.stopHeartRateMonitoring()
        }
        
        isUnlocking = false
        
        pinHeights = Array(repeating: 0.0, count: pinHeights.count)
        pinStates = Array(repeating: .locked, count: pinStates.count)
        currentPin = 0
        progress = 0
        heartRateEffect = .none
        
        if currentChest.timeLimit != nil {
            timeRemaining = currentChest.timeLimit!
        }
        
        hapticManager.play(.trapNoiseSubtleStatic)
    }
    
    func resetLock() {
        timer?.invalidate()
        timer = nil
        
        // Stop heart rate monitoring
        if currentChest.isCursed {
            healthKitManager.stopHeartRateMonitoring()
        }
        
        isUnlocking = false
        isUnlocked = false
        currentPin = 0
        progress = 0
        heartRateEffect = .none
        
        setupLock()
    }
    
    deinit {
        timer?.invalidate()
    }
}