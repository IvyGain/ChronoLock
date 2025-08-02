import Foundation

enum AchievementCategory: String, CaseIterable, Codable {
    case unlocking = "unlocking"
    case collection = "collection"
    case mastery = "mastery"
    case exploration = "exploration"
    case speed = "speed"
    case special = "special"
    
    var displayName: String {
        switch self {
        case .unlocking:
            return "Unlocking"
        case .collection:
            return "Collection"
        case .mastery:
            return "Mastery"
        case .exploration:
            return "Exploration"
        case .speed:
            return "Speed"
        case .special:
            return "Special"
        }
    }
}

enum AchievementRarity: String, CaseIterable, Codable {
    case common = "common"
    case rare = "rare"
    case legendary = "legendary"
    
    var keyFragmentReward: Int {
        switch self {
        case .common:
            return 5
        case .rare:
            return 15
        case .legendary:
            return 50
        }
    }
    
    var experienceReward: Int {
        switch self {
        case .common:
            return 25
        case .rare:
            return 75
        case .legendary:
            return 200
        }
    }
}

struct Achievement: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let category: AchievementCategory
    let rarity: AchievementRarity
    let iconName: String
    let unlockCondition: UnlockCondition
    let isHidden: Bool
    
    var isUnlocked: Bool {
        return AchievementManager.shared.isAchievementUnlocked(id)
    }
    
    var unlockedDate: Date? {
        return AchievementManager.shared.getUnlockDate(for: id)
    }
}

enum UnlockCondition: Codable, Hashable {
    case unlockChests(count: Int)
    case unlockSpecificRarity(rarity: ChestRarity, count: Int)
    case unlockSpecificLockType(lockType: LockType, count: Int)
    case reachLevel(level: Int)
    case collectKeyFragments(count: Int)
    case unlockCursedChest
    case unlockTrappedChest
    case unlockWithinTimeLimit(seconds: TimeInterval)
    case unlockConsecutiveWithoutFailure(count: Int)
    case reachMasteryLevel(lockType: LockType, level: Int)
    case unlockAllRarities
    case unlockAllLockTypes
    case earnChroniclePoints(points: Double)
    case unlockAtSpecificTime(hour: Int)
    case unlockDuringHeartRateSpike
    
    func isConditionMet(gameData: GameDataManager) -> Bool {
        switch self {
        case .unlockChests(let count):
            return gameData.playerProfile.totalChestsUnlocked >= count
            
        case .unlockSpecificRarity(let rarity, let count):
            let unlockedCount = gameData.inventory.filter { 
                $0.isUnlocked && $0.rarity == rarity 
            }.count
            return unlockedCount >= count
            
        case .unlockSpecificLockType(let lockType, let count):
            let unlockedCount = gameData.inventory.filter { 
                $0.isUnlocked && $0.lockType == lockType 
            }.count
            return unlockedCount >= count
            
        case .reachLevel(let level):
            return gameData.playerProfile.level >= level
            
        case .collectKeyFragments(let count):
            return gameData.playerProfile.keyFragments >= count
            
        case .unlockCursedChest:
            return gameData.inventory.contains { $0.isUnlocked && $0.isCursed }
            
        case .unlockTrappedChest:
            return gameData.inventory.contains { $0.isUnlocked && $0.hasTrap }
            
        case .unlockWithinTimeLimit(let seconds):
            return gameData.inventory.contains { chest in
                guard chest.isUnlocked, let timeLimit = chest.timeLimit else { return false }
                return timeLimit >= seconds
            }
            
        case .unlockConsecutiveWithoutFailure(let count):
            return gameData.playerProfile.consecutiveSuccessfulUnlocks >= count
            
        case .reachMasteryLevel(let lockType, let level):
            return gameData.playerProfile.lockMastery[lockType]?.level ?? 0 >= level
            
        case .unlockAllRarities:
            let unlockedRarities = Set(gameData.inventory.filter { $0.isUnlocked }.map { $0.rarity })
            return unlockedRarities.count == ChestRarity.allCases.count
            
        case .unlockAllLockTypes:
            let unlockedLockTypes = Set(gameData.inventory.filter { $0.isUnlocked }.map { $0.lockType })
            return unlockedLockTypes.count == LockType.allCases.count
            
        case .earnChroniclePoints(let points):
            return gameData.resonanceEngine.points >= points
            
        case .unlockAtSpecificTime(let hour):
            let calendar = Calendar.current
            let currentHour = calendar.component(.hour, from: Date())
            return currentHour == hour && gameData.playerProfile.totalChestsUnlocked > 0
            
        case .unlockDuringHeartRateSpike:
            return gameData.playerProfile.hasUnlockedDuringHeartRateSpike
        }
    }
}

extension Achievement {
    static let allAchievements: [Achievement] = [
        // Unlocking Achievements
        Achievement(
            id: "first_unlock",
            title: "First Steps",
            description: "Unlock your first treasure chest",
            category: .unlocking,
            rarity: .common,
            iconName: "lock.open.fill",
            unlockCondition: .unlockChests(count: 1),
            isHidden: false
        ),
        
        Achievement(
            id: "novice_lockpicker",
            title: "Novice Lockpicker",
            description: "Unlock 5 treasure chests",
            category: .unlocking,
            rarity: .common,
            iconName: "key.fill",
            unlockCondition: .unlockChests(count: 5),
            isHidden: false
        ),
        
        Achievement(
            id: "apprentice_lockpicker",
            title: "Apprentice Lockpicker",
            description: "Unlock 25 treasure chests",
            category: .unlocking,
            rarity: .rare,
            iconName: "key.horizontal.fill",
            unlockCondition: .unlockChests(count: 25),
            isHidden: false
        ),
        
        Achievement(
            id: "master_lockpicker",
            title: "Master Lockpicker",
            description: "Unlock 100 treasure chests",
            category: .unlocking,
            rarity: .legendary,
            iconName: "crown.fill",
            unlockCondition: .unlockChests(count: 100),
            isHidden: false
        ),
        
        // Collection Achievements
        Achievement(
            id: "rare_collector",
            title: "Rare Collector",
            description: "Unlock 3 rare chests",
            category: .collection,
            rarity: .rare,
            iconName: "sparkles",
            unlockCondition: .unlockSpecificRarity(rarity: .rare, count: 3),
            isHidden: false
        ),
        
        Achievement(
            id: "legend_hunter",
            title: "Legend Hunter",
            description: "Unlock a legendary chest",
            category: .collection,
            rarity: .legendary,
            iconName: "star.fill",
            unlockCondition: .unlockSpecificRarity(rarity: .legendary, count: 1),
            isHidden: false
        ),
        
        Achievement(
            id: "complete_collection",
            title: "Complete Collection",
            description: "Unlock chests of all rarities",
            category: .collection,
            rarity: .legendary,
            iconName: "trophy.fill",
            unlockCondition: .unlockAllRarities,
            isHidden: false
        ),
        
        // Mastery Achievements
        Achievement(
            id: "pin_tumbler_specialist",
            title: "Pin Tumbler Specialist",
            description: "Unlock 10 pin tumbler locks",
            category: .mastery,
            rarity: .rare,
            iconName: "rectangle.stack.fill",
            unlockCondition: .unlockSpecificLockType(lockType: .pinTumbler, count: 10),
            isHidden: false
        ),
        
        Achievement(
            id: "combination_expert",
            title: "Combination Expert",
            description: "Unlock 10 dial combination locks",
            category: .mastery,
            rarity: .rare,
            iconName: "dial.max.fill",
            unlockCondition: .unlockSpecificLockType(lockType: .dialCombination, count: 10),
            isHidden: false
        ),
        
        Achievement(
            id: "rotary_master",
            title: "Rotary Master",
            description: "Unlock 10 rotary puzzle locks",
            category: .mastery,
            rarity: .rare,
            iconName: "gear.circle.fill",
            unlockCondition: .unlockSpecificLockType(lockType: .rotaryPuzzle, count: 10),
            isHidden: false
        ),
        
        Achievement(
            id: "lock_master",
            title: "Lock Master",
            description: "Unlock all types of locks",
            category: .mastery,
            rarity: .legendary,
            iconName: "shield.checkered",
            unlockCondition: .unlockAllLockTypes,
            isHidden: false
        ),
        
        // Speed Achievements
        Achievement(
            id: "speed_demon",
            title: "Speed Demon",
            description: "Unlock a chest with 10+ seconds remaining",
            category: .speed,
            rarity: .rare,
            iconName: "bolt.fill",
            unlockCondition: .unlockWithinTimeLimit(seconds: 10),
            isHidden: false
        ),
        
        Achievement(
            id: "unstoppable",
            title: "Unstoppable",
            description: "Unlock 5 chests without failing",
            category: .speed,
            rarity: .rare,
            iconName: "flame.fill",
            unlockCondition: .unlockConsecutiveWithoutFailure(count: 5),
            isHidden: false
        ),
        
        // Special Achievements
        Achievement(
            id: "curse_breaker",
            title: "Curse Breaker",
            description: "Unlock a cursed chest",
            category: .special,
            rarity: .legendary,
            iconName: "heart.slash.fill",
            unlockCondition: .unlockCursedChest,
            isHidden: false
        ),
        
        Achievement(
            id: "trap_disarmer",
            title: "Trap Disarmer",
            description: "Unlock a trapped chest",
            category: .special,
            rarity: .rare,
            iconName: "exclamationmark.triangle.fill",
            unlockCondition: .unlockTrappedChest,
            isHidden: false
        ),
        
        Achievement(
            id: "night_owl",
            title: "Night Owl",
            description: "Unlock a chest at midnight",
            category: .special,
            rarity: .rare,
            iconName: "moon.fill",
            unlockCondition: .unlockAtSpecificTime(hour: 0),
            isHidden: true
        ),
        
        Achievement(
            id: "adrenaline_junkie",
            title: "Adrenaline Junkie",
            description: "Unlock a chest during high heart rate",
            category: .special,
            rarity: .legendary,
            iconName: "heart.circle.fill",
            unlockCondition: .unlockDuringHeartRateSpike,
            isHidden: true
        ),
        
        // Chronicle Points Achievement
        Achievement(
            id: "chronicle_collector",
            title: "Chronicle Collector",
            description: "Earn 1000 Chronicle Points",
            category: .exploration,
            rarity: .rare,
            iconName: "scroll.fill",
            unlockCondition: .earnChroniclePoints(points: 1000),
            isHidden: false
        )
    ]
}