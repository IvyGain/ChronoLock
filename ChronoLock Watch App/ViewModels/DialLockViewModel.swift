import Foundation
import Combine
import WatchKit

class DialLockViewModel: ObservableObject {
    @Published var currentChest: TreasureChest
    @Published var isUnlocking = false
    @Published var isUnlocked = false
    @Published var timeRemaining: TimeInterval = 0
    @Published var currentDialIndex = 0
    @Published var dialValues: [Int] = []
    @Published var dialStates: [DialState] = []
    @Published var progress: Double = 0
    
    private var correctCombination: [Int] = []
    private var timer: Timer?
    private let hapticManager = HapticManager.shared
    private let dialCount: Int
    
    enum DialState {
        case locked
        case correct
        case set
    }
    
    init(chest: TreasureChest) {
        self.currentChest = chest
        self.dialCount = min(max(currentChest.difficulty, 3), 6)
        setupDials()
    }
    
    private func setupDials() {
        dialValues = Array(repeating: 0, count: dialCount)
        dialStates = Array(repeating: .locked, count: dialCount)
        correctCombination = (0..<dialCount).map { _ in Int.random(in: 0...9) }
        
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
        
        hapticManager.play(.dialTickSubtle)
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
    
    func rotateDial(delta: Double) {
        guard isUnlocking, currentDialIndex < dialCount else { return }
        
        let rotationThreshold: Double = 0.3
        
        if abs(delta) >= rotationThreshold {
            let direction = delta > 0 ? 1 : -1
            let oldValue = dialValues[currentDialIndex]
            
            dialValues[currentDialIndex] = (dialValues[currentDialIndex] + direction + 10) % 10
            
            if oldValue != dialValues[currentDialIndex] {
                hapticManager.play(.dialTickSubtle)
                
                checkDialCorrectness()
            }
        }
    }
    
    private func checkDialCorrectness() {
        guard currentDialIndex < dialCount else { return }
        
        let correctValue = correctCombination[currentDialIndex]
        let currentValue = dialValues[currentDialIndex]
        
        if currentValue == correctValue {
            if dialStates[currentDialIndex] != .correct {
                dialStates[currentDialIndex] = .correct
                hapticManager.play(.dialCorrectNumberThump)
            }
        } else {
            if dialStates[currentDialIndex] == .correct {
                dialStates[currentDialIndex] = .locked
            }
        }
        
        updateProgress()
    }
    
    func confirmCurrentDial() {
        guard isUnlocking, currentDialIndex < dialCount else { return }
        guard dialStates[currentDialIndex] == .correct else {
            hapticManager.play(.trapNoiseSubtleStatic)
            return
        }
        
        dialStates[currentDialIndex] = .set
        hapticManager.play(.pickingSetClickFirm)
        
        if currentDialIndex < dialCount - 1 {
            currentDialIndex += 1
            hapticManager.play(.dialTickSubtle)
        } else {
            completeUnlock()
        }
        
        updateProgress()
    }
    
    func moveToPreviousDial() {
        guard isUnlocking, currentDialIndex > 0 else { return }
        
        if dialStates[currentDialIndex - 1] == .set {
            dialStates[currentDialIndex - 1] = .correct
        }
        
        currentDialIndex -= 1
        hapticManager.play(.dialTickSubtle)
        updateProgress()
    }
    
    func resetCurrentDial() {
        guard isUnlocking, currentDialIndex < dialCount else { return }
        
        dialValues[currentDialIndex] = 0
        dialStates[currentDialIndex] = .locked
        hapticManager.play(.dialTickSubtle)
        
        updateProgress()
    }
    
    private func updateProgress() {
        let setDials = dialStates.filter { $0 == .set }.count
        progress = Double(setDials) / Double(dialCount)
    }
    
    private func completeUnlock() {
        timer?.invalidate()
        timer = nil
        
        isUnlocking = false
        isUnlocked = true
        
        hapticManager.play(.rarityRareDoubleTap)
        
        GameDataManager.shared.unlockChest(currentChest)
    }
    
    private func failUnlock() {
        timer?.invalidate()
        timer = nil
        
        isUnlocking = false
        
        dialValues = Array(repeating: 0, count: dialCount)
        dialStates = Array(repeating: .locked, count: dialCount)
        currentDialIndex = 0
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
        currentDialIndex = 0
        progress = 0
        
        setupDials()
    }
    
    deinit {
        timer?.invalidate()
    }
}