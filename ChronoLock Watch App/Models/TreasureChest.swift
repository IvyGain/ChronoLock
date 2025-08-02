import Foundation

enum ChestRarity: String, CaseIterable, Codable {
    case common = "common"
    case rare = "rare"
    case legendary = "legendary"
    
    var description: String {
        switch self {
        case .common: return "Common"
        case .rare: return "Rare"
        case .legendary: return "Legendary"
        }
    }
}

enum LockType: String, CaseIterable, Codable {
    case pinTumbler = "pin_tumbler"
    case dialCombination = "dial_combination"
    case rotaryPuzzle = "rotary_puzzle"
    
    var description: String {
        switch self {
        case .pinTumbler: return "Pin Tumbler"
        case .dialCombination: return "Dial Combination"
        case .rotaryPuzzle: return "Rotary Puzzle"
        }
    }
}

struct TreasureChest: Identifiable, Codable {
    let id = UUID()
    let name: String
    let rarity: ChestRarity
    let lockType: LockType
    let difficulty: Int
    let hasTrap: Bool
    let isCursed: Bool
    let timeLimit: TimeInterval?
    let keyFragmentReward: Int
    let experienceReward: Int
    
    var isUnlocked: Bool = false
    var unlockTime: Date?
    
    init(
        name: String,
        rarity: ChestRarity,
        lockType: LockType,
        difficulty: Int,
        hasTrap: Bool = false,
        isCursed: Bool = false,
        timeLimit: TimeInterval? = nil
    ) {
        self.name = name
        self.rarity = rarity
        self.lockType = lockType
        self.difficulty = difficulty
        self.hasTrap = hasTrap
        self.isCursed = isCursed
        self.timeLimit = timeLimit
        
        self.keyFragmentReward = Self.calculateKeyFragmentReward(rarity: rarity, difficulty: difficulty)
        self.experienceReward = Self.calculateExperienceReward(rarity: rarity, difficulty: difficulty)
    }
    
    private static func calculateKeyFragmentReward(rarity: ChestRarity, difficulty: Int) -> Int {
        let baseReward: Int
        switch rarity {
        case .common: baseReward = 1
        case .rare: baseReward = 3
        case .legendary: baseReward = 10
        }
        return baseReward + (difficulty / 2)
    }
    
    private static func calculateExperienceReward(rarity: ChestRarity, difficulty: Int) -> Int {
        let baseReward: Int
        switch rarity {
        case .common: baseReward = 10
        case .rare: baseReward = 25
        case .legendary: baseReward = 100
        }
        return baseReward + (difficulty * 5)
    }
}