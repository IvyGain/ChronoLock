import Foundation

struct ResonanceEngine: Codable {
    var points: Double = 0.0
    var handCrankLevel: Int = 1
    var tuningForks: Int = 0
    var amplifierLevel: Int = 1
    
    var lastOfflineCalculation: Date = Date()
    
    private let manualBase: Double = 1.0
    private let manualExponent: Double = 1.08
    private let autoBase: Double = 0.5
    private let autoExponent: Double = 1.12
    private let costBase: Double = 50.0
    private let costExponent: Double = 1.15
    
    var manualPointsPerRotation: Double {
        return manualBase * pow(manualExponent, Double(handCrankLevel))
    }
    
    var autoPointsPerSecond: Double {
        return Double(tuningForks) * autoBase * pow(autoExponent, Double(amplifierLevel))
    }
    
    func handCrankUpgradeCost() -> Double {
        return costBase * pow(costExponent, Double(handCrankLevel))
    }
    
    func tuningForkCost() -> Double {
        return costBase * 2.0 * pow(costExponent, Double(tuningForks))
    }
    
    func amplifierUpgradeCost() -> Double {
        return costBase * 1.5 * pow(costExponent, Double(amplifierLevel))
    }
    
    mutating func performManualResonance() {
        points += manualPointsPerRotation
    }
    
    mutating func calculateOfflineRewards() -> Double {
        let now = Date()
        let timeDifference = now.timeIntervalSince(lastOfflineCalculation)
        let offlinePoints = autoPointsPerSecond * timeDifference
        
        points += offlinePoints
        lastOfflineCalculation = now
        
        return offlinePoints
    }
    
    mutating func upgradeHandCrank() -> Bool {
        let cost = handCrankUpgradeCost()
        guard points >= cost else { return false }
        
        points -= cost
        handCrankLevel += 1
        return true
    }
    
    mutating func buyTuningFork() -> Bool {
        let cost = tuningForkCost()
        guard points >= cost else { return false }
        
        points -= cost
        tuningForks += 1
        return true
    }
    
    mutating func upgradeAmplifier() -> Bool {
        let cost = amplifierUpgradeCost()
        guard points >= cost else { return false }
        
        points -= cost
        amplifierLevel += 1
        return true
    }
}