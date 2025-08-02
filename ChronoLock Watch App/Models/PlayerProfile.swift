import Foundation

struct PlayerProfile: Codable {
    let id = UUID()
    var level: Int = 1
    var experience: Int = 0
    var keyFragments: Int = 0
    var totalChestsUnlocked: Int = 0
    
    var lockMastery: [LockType: LockMastery] = [:]
    
    var experienceToNextLevel: Int {
        let nextLevelExp = (level * 100) + ((level - 1) * 50)
        return max(0, nextLevelExp - experience)
    }
    
    var currentLevelProgress: Double {
        let currentLevelExp = ((level - 1) * 100) + max(0, (level - 2) * 50)
        let nextLevelExp = (level * 100) + ((level - 1) * 50)
        let progressExp = experience - currentLevelExp
        let levelRange = nextLevelExp - currentLevelExp
        return levelRange > 0 ? Double(progressExp) / Double(levelRange) : 0.0
    }
    
    mutating func addExperience(_ amount: Int) {
        experience += amount
        checkLevelUp()
    }
    
    mutating func addKeyFragments(_ amount: Int) {
        keyFragments += amount
    }
    
    mutating func spendKeyFragments(_ amount: Int) -> Bool {
        guard keyFragments >= amount else { return false }
        keyFragments -= amount
        return true
    }
    
    mutating func unlockChest(_ chest: TreasureChest) {
        totalChestsUnlocked += 1
        addExperience(chest.experienceReward)
        addKeyFragments(chest.keyFragmentReward)
        
        if lockMastery[chest.lockType] == nil {
            lockMastery[chest.lockType] = LockMastery(lockType: chest.lockType)
        }
        lockMastery[chest.lockType]?.addExperience(chest.difficulty * 10)
    }
    
    private mutating func checkLevelUp() {
        let requiredExp = (level * 100) + ((level - 1) * 50)
        if experience >= requiredExp {
            level += 1
            checkLevelUp()
        }
    }
}

struct LockMastery: Codable {
    let lockType: LockType
    var level: Int = 1
    var experience: Int = 0
    var totalUnlocked: Int = 0
    
    var experienceToNextLevel: Int {
        let nextLevelExp = level * 50
        return max(0, nextLevelExp - experience)
    }
    
    var masteryBonus: Double {
        return 1.0 + (Double(level - 1) * 0.1)
    }
    
    mutating func addExperience(_ amount: Int) {
        experience += amount
        totalUnlocked += 1
        checkLevelUp()
    }
    
    private mutating func checkLevelUp() {
        let requiredExp = level * 50
        if experience >= requiredExp {
            level += 1
            checkLevelUp()
        }
    }
}