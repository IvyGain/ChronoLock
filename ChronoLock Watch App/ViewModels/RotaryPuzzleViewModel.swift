import Foundation
import Combine
import WatchKit

class RotaryPuzzleViewModel: ObservableObject {
    @Published var currentChest: TreasureChest
    @Published var isUnlocking = false
    @Published var isUnlocked = false
    @Published var timeRemaining: TimeInterval = 0
    @Published var currentRingIndex = 0
    @Published var ringRotations: [Double] = []
    @Published var ringStates: [RingState] = []
    @Published var progress: Double = 0
    @Published var heartRateEffect: HeartRateEffect = .none
    @Published var isHeartRateMonitoring = false
    
    private var correctRotations: [Double] = []
    private var timer: Timer?
    private let hapticManager = HapticManager.shared
    private let healthKitManager = HealthKitManager.shared
    private let ringCount: Int
    private let tolerance: Double = 0.05
    private var cancellables = Set<AnyCancellable>()
    
    enum RingState {
        case locked
        case aligned
        case locked_in
    }
    
    init(chest: TreasureChest) {
        self.currentChest = chest
        self.ringCount = min(max(currentChest.difficulty, 3), 5)
        setupPuzzle()
        setupHeartRateMonitoring()
    }
    
    private func setupHeartRateMonitoring() {
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
    
    private func setupPuzzle() {
        ringRotations = Array(repeating: 0.0, count: ringCount)
        ringStates = Array(repeating: .locked, count: ringCount)
        
        // Generate target rotations (0.0 to 1.0, representing full rotation)
        correctRotations = (0..<ringCount).map { index in
            // Outer rings have simpler patterns, inner rings more complex
            let complexity = Double(index + 1) / Double(ringCount)
            return Double.random(in: 0.1...(0.9 * complexity))
        }
        
        if let timeLimit = currentChest.timeLimit {
            timeRemaining = timeLimit
        }
    }
    
    func startUnlocking() {
        guard !isUnlocking else { return }
        
        isUnlocking = true
        
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
    
    func rotateRing(delta: Double) {
        guard isUnlocking, currentRingIndex < ringCount else { return }
        
        var adjustedDelta = delta
        if currentChest.isCursed {
            adjustedDelta = applyHeartRateEffect(to: delta)
        }
        
        let oldRotation = ringRotations[currentRingIndex]
        ringRotations[currentRingIndex] = fmod(ringRotations[currentRingIndex] + adjustedDelta + 1.0, 1.0)
        
        let targetRotation = correctRotations[currentRingIndex]
        let distance = min(
            abs(ringRotations[currentRingIndex] - targetRotation),
            1.0 - abs(ringRotations[currentRingIndex] - targetRotation)
        )
        
        var adjustedTolerance = tolerance
        if currentChest.isCursed {
            adjustedTolerance = adjustToleranceForHeartRate()
        }
        
        if distance < adjustedTolerance {
            if ringStates[currentRingIndex] != .aligned {
                ringStates[currentRingIndex] = .aligned
                hapticManager.play(.pickingSweetSpotPulse)
            }
        } else {
            if ringStates[currentRingIndex] == .aligned {
                ringStates[currentRingIndex] = .locked
                hapticManager.play(.pickingResistanceLight)
            }
        }
        
        let resistance = calculateResistance(
            rotation: ringRotations[currentRingIndex],
            target: targetRotation
        )
        playResistanceHaptic(resistance: resistance)
        
        updateProgress()
    }
    
    private func applyHeartRateEffect(to delta: Double) -> Double {
        switch heartRateEffect {
        case .none:
            return delta
        case .mild:
            let noise = Double.random(in: -0.01...0.01)
            return delta + noise
        case .moderate:
            let noise = Double.random(in: -0.02...0.02)
            let dampening = Double.random(in: 0.8...1.2)
            return (delta * dampening) + noise
        case .severe:
            let noise = Double.random(in: -0.05...0.05)
            let dampening = Double.random(in: 0.6...1.4)
            return (delta * dampening) + noise
        }
    }
    
    private func adjustToleranceForHeartRate() -> Double {
        switch heartRateEffect {
        case .none:
            return tolerance
        case .mild:
            return tolerance * 0.9
        case .moderate:
            return tolerance * 0.7
        case .severe:
            return tolerance * 0.5
        }
    }
    
    private func calculateResistance(rotation: Double, target: Double) -> Double {
        let distance = min(
            abs(rotation - target),
            1.0 - abs(rotation - target)
        )
        return max(0.1, min(1.0, distance * 4))
    }
    
    private func playResistanceHaptic(resistance: Double) {
        if resistance < 0.3 {
            hapticManager.play(.pickingResistanceLight)
        } else {
            hapticManager.play(.pickingResistanceHeavy)
        }
    }
    
    func lockInCurrentRing() {
        guard isUnlocking, currentRingIndex < ringCount else { return }
        guard ringStates[currentRingIndex] == .aligned else {
            hapticManager.play(.trapNoiseSubtleStatic)
            return
        }
        
        ringStates[currentRingIndex] = .locked_in
        hapticManager.play(.pickingSetClickFirm)
        
        if currentRingIndex < ringCount - 1 {
            currentRingIndex += 1
            hapticManager.play(.pickingResistanceLight)
        } else {
            completeUnlock()
        }
        
        updateProgress()
    }
    
    func moveToPreviousRing() {
        guard isUnlocking, currentRingIndex > 0 else { return }
        
        if ringStates[currentRingIndex - 1] == .locked_in {
            ringStates[currentRingIndex - 1] = .aligned
        }
        
        currentRingIndex -= 1
        hapticManager.play(.pickingResistanceLight)
        updateProgress()
    }
    
    func resetCurrentRing() {
        guard isUnlocking, currentRingIndex < ringCount else { return }
        
        ringRotations[currentRingIndex] = 0.0
        ringStates[currentRingIndex] = .locked
        hapticManager.play(.pickingResistanceLight)
        
        updateProgress()
    }
    
    private func updateProgress() {
        let lockedInRings = ringStates.filter { $0 == .locked_in }.count
        progress = Double(lockedInRings) / Double(ringCount)
    }
    
    private func completeUnlock() {
        timer?.invalidate()
        timer = nil
        
        if currentChest.isCursed {
            healthKitManager.stopHeartRateMonitoring()
        }
        
        isUnlocking = false
        isUnlocked = true
        
        hapticManager.play(.rarityLegendaryHeartbeat)
        
        GameDataManager.shared.unlockChest(currentChest)
    }
    
    private func failUnlock() {
        timer?.invalidate()
        timer = nil
        
        if currentChest.isCursed {
            healthKitManager.stopHeartRateMonitoring()
        }
        
        isUnlocking = false
        
        ringRotations = Array(repeating: 0.0, count: ringCount)
        ringStates = Array(repeating: .locked, count: ringCount)
        currentRingIndex = 0
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
        
        if currentChest.isCursed {
            healthKitManager.stopHeartRateMonitoring()
        }
        
        isUnlocking = false
        isUnlocked = false
        currentRingIndex = 0
        progress = 0
        heartRateEffect = .none
        
        setupPuzzle()
    }
    
    deinit {
        timer?.invalidate()
    }
}