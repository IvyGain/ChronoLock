import Foundation
import Combine

class GameDataManager: ObservableObject {
    static let shared = GameDataManager()
    
    @Published var playerProfile: PlayerProfile
    @Published var resonanceEngine: ResonanceEngine
    @Published var inventory: [TreasureChest] = []
    
    private let userDefaults = UserDefaults.standard
    
    private init() {
        self.playerProfile = GameDataManager.loadPlayerProfile()
        self.resonanceEngine = GameDataManager.loadResonanceEngine()
        self.inventory = GameDataManager.loadInventory()
        
        setupAutoSave()
    }
    
    private func setupAutoSave() {
        $playerProfile
            .sink { [weak self] profile in
                self?.savePlayerProfile(profile)
            }
            .store(in: &cancellables)
        
        $resonanceEngine
            .sink { [weak self] engine in
                self?.saveResonanceEngine(engine)
            }
            .store(in: &cancellables)
        
        $inventory
            .sink { [weak self] inventory in
                self?.saveInventory(inventory)
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private static func loadPlayerProfile() -> PlayerProfile {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.data(forKey: "playerProfile"),
              let profile = try? JSONDecoder().decode(PlayerProfile.self, from: data) else {
            return PlayerProfile()
        }
        return profile
    }
    
    private func savePlayerProfile(_ profile: PlayerProfile) {
        guard let data = try? JSONEncoder().encode(profile) else { return }
        userDefaults.set(data, forKey: "playerProfile")
    }
    
    private static func loadResonanceEngine() -> ResonanceEngine {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.data(forKey: "resonanceEngine"),
              let engine = try? JSONDecoder().decode(ResonanceEngine.self, from: data) else {
            return ResonanceEngine()
        }
        return engine
    }
    
    private func saveResonanceEngine(_ engine: ResonanceEngine) {
        guard let data = try? JSONEncoder().encode(engine) else { return }
        userDefaults.set(data, forKey: "resonanceEngine")
    }
    
    private static func loadInventory() -> [TreasureChest] {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.data(forKey: "inventory"),
              let inventory = try? JSONDecoder().decode([TreasureChest].self, from: data) else {
            return Self.generateStarterChests()
        }
        return inventory
    }
    
    private func saveInventory(_ inventory: [TreasureChest]) {
        guard let data = try? JSONEncoder().encode(inventory) else { return }
        userDefaults.set(data, forKey: "inventory")
    }
    
    private static func generateStarterChests() -> [TreasureChest] {
        return [
            TreasureChest(
                name: "Weathered Wooden Box",
                rarity: .common,
                lockType: .pinTumbler,
                difficulty: 1
            ),
            TreasureChest(
                name: "Iron Strongbox",
                rarity: .common,
                lockType: .dialCombination,
                difficulty: 2
            ),
            TreasureChest(
                name: "Mysterious Ancient Coffer",
                rarity: .rare,
                lockType: .rotaryPuzzle,
                difficulty: 5,
                hasTrap: true
            ),
            TreasureChest(
                name: "Cursed Soulbound Chest",
                rarity: .legendary,
                lockType: .pinTumbler,
                difficulty: 4,
                hasTrap: false,
                isCursed: true,
                timeLimit: 30.0
            ),
            TreasureChest(
                name: "Heart of Darkness Vault",
                rarity: .legendary,
                lockType: .dialCombination,
                difficulty: 6,
                hasTrap: true,
                isCursed: true,
                timeLimit: 45.0
            )
        ]
    }
    
    func addChest(_ chest: TreasureChest) {
        inventory.append(chest)
    }
    
    func unlockChest(_ chest: TreasureChest) {
        guard let index = inventory.firstIndex(where: { $0.id == chest.id }) else { return }
        
        inventory[index].isUnlocked = true
        inventory[index].unlockTime = Date()
        
        playerProfile.unlockChest(chest)
        
        // Trigger achievement check
        AchievementManager.shared.checkAllAchievements()
    }
    
    func addExperience(_ amount: Int) {
        playerProfile.addExperience(amount)
    }
    
    func addKeyFragments(_ amount: Int) {
        playerProfile.addKeyFragments(amount)
    }
    
    func savePlayerProfile() {
        savePlayerProfile(playerProfile)
    }
    
    func calculateOfflineRewards() -> Double {
        let offlineRewards = resonanceEngine.calculateOfflineRewards()
        return offlineRewards
    }
}