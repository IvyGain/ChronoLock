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
    
    private var correctHeights: [Double] = []
    private var timer: Timer?
    private let hapticManager = HapticManager.shared
    private let tolerance: Double = 0.1
    
    enum PinState {
        case locked
        case correct
        case set
    }
    
    init(chest: TreasureChest) {
        self.currentChest = chest
        setupLock()
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
        
        let oldHeight = pinHeights[currentPin]
        pinHeights[currentPin] = max(0, min(1.0, pinHeights[currentPin] + delta))
        
        let correctHeight = correctHeights[currentPin]
        let distance = abs(pinHeights[currentPin] - correctHeight)
        
        if distance < tolerance {
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
        
        isUnlocking = false
        isUnlocked = true
        
        hapticManager.play(.rarityCommonShortTap)
        
        GameDataManager.shared.unlockChest(currentChest)
    }
    
    private func failUnlock() {
        timer?.invalidate()
        timer = nil
        
        isUnlocking = false
        
        pinHeights = Array(repeating: 0.0, count: pinHeights.count)
        pinStates = Array(repeating: .locked, count: pinStates.count)
        currentPin = 0
        progress = 0
        
        if currentChest.timeLimit != nil {
            timeRemaining = currentChest.timeLimit!
        }
        
        hapticManager.play(.trapNoiseSubtleStatic)
    }
    
    func resetLock() {
        timer?.invalidate()
        timer = nil
        
        isUnlocking = false
        isUnlocked = false
        currentPin = 0
        progress = 0
        
        setupLock()
    }
    
    deinit {
        timer?.invalidate()
    }
}