import Foundation
import Combine
import WatchKit

class AchievementManager: ObservableObject {
    static let shared = AchievementManager()
    
    @Published var unlockedAchievements: Set<String> = []
    @Published var newlyUnlockedAchievements: [Achievement] = []
    
    private var unlockDates: [String: Date] = [:]
    private let hapticManager = HapticManager.shared
    private let audioManager = AudioManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    private let userDefaults = UserDefaults.standard
    private let unlockedAchievementsKey = "UnlockedAchievements"
    private let unlockDatesKey = "AchievementUnlockDates"
    
    private init() {
        loadAchievements()
        setupGameDataObservation()
    }
    
    private func loadAchievements() {
        if let data = userDefaults.data(forKey: unlockedAchievementsKey),
           let achievements = try? JSONDecoder().decode(Set<String>.self, from: data) {
            unlockedAchievements = achievements
        }
        
        if let data = userDefaults.data(forKey: unlockDatesKey),
           let dates = try? JSONDecoder().decode([String: Date].self, from: data) {
            unlockDates = dates
        }
    }
    
    private func saveAchievements() {
        if let data = try? JSONEncoder().encode(unlockedAchievements) {
            userDefaults.set(data, forKey: unlockedAchievementsKey)
        }
        
        if let data = try? JSONEncoder().encode(unlockDates) {
            userDefaults.set(data, forKey: unlockDatesKey)
        }
    }
    
    private func setupGameDataObservation() {
        let gameData = GameDataManager.shared
        
        // Monitor player profile changes
        gameData.$playerProfile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.checkAllAchievements()
            }
            .store(in: &cancellables)
        
        // Monitor inventory changes
        gameData.$inventory
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.checkAllAchievements()
            }
            .store(in: &cancellables)
        
        // Monitor resonance engine changes
        gameData.resonanceEngine.$points
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.checkAllAchievements()
            }
            .store(in: &cancellables)
    }
    
    func checkAllAchievements() {
        let gameData = GameDataManager.shared
        
        for achievement in Achievement.allAchievements {
            if !unlockedAchievements.contains(achievement.id) &&
               achievement.unlockCondition.isConditionMet(gameData: gameData) {
                unlockAchievement(achievement)
            }
        }
    }
    
    private func unlockAchievement(_ achievement: Achievement) {
        guard !unlockedAchievements.contains(achievement.id) else { return }
        
        unlockedAchievements.insert(achievement.id)
        unlockDates[achievement.id] = Date()
        newlyUnlockedAchievements.append(achievement)
        
        // Award rewards
        let gameData = GameDataManager.shared
        gameData.addKeyFragments(achievement.rarity.keyFragmentReward)
        gameData.addExperience(achievement.rarity.experienceReward)
        
        // Play feedback
        playUnlockFeedback(for: achievement)
        
        // Save progress
        saveAchievements()
        
        // Clear notification after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.newlyUnlockedAchievements.removeAll { $0.id == achievement.id }
        }
    }
    
    private func playUnlockFeedback(for achievement: Achievement) {
        switch achievement.rarity {
        case .common:
            hapticManager.play(.achievementCommonPop)
            audioManager.playSound(.successChime, volume: 0.7)
            
        case .rare:
            hapticManager.play(.achievementRareFlourish)
            audioManager.playSound(.successChime, volume: 0.8)
            
        case .legendary:
            hapticManager.play(.achievementLegendaryFanfare)
            audioManager.playSound(.successChime, volume: 1.0)
        }
    }
    
    // MARK: - Public Interface
    
    func isAchievementUnlocked(_ achievementId: String) -> Bool {
        return unlockedAchievements.contains(achievementId)
    }
    
    func getUnlockDate(for achievementId: String) -> Date? {
        return unlockDates[achievementId]
    }
    
    func getAchievementsByCategory(_ category: AchievementCategory) -> [Achievement] {
        return Achievement.allAchievements.filter { $0.category == category }
    }
    
    func getUnlockedAchievements() -> [Achievement] {
        return Achievement.allAchievements.filter { isAchievementUnlocked($0.id) }
            .sorted { first, second in
                guard let firstDate = getUnlockDate(for: first.id),
                      let secondDate = getUnlockDate(for: second.id) else {
                    return false
                }
                return firstDate > secondDate
            }
    }
    
    func getLockedAchievements() -> [Achievement] {
        return Achievement.allAchievements.filter { !isAchievementUnlocked($0.id) && !$0.isHidden }
    }
    
    func getAchievementProgress() -> (unlocked: Int, total: Int) {
        let unlockedCount = unlockedAchievements.count
        let totalCount = Achievement.allAchievements.count
        return (unlocked: unlockedCount, total: totalCount)
    }
    
    func getCompletionPercentage() -> Double {
        let progress = getAchievementProgress()
        guard progress.total > 0 else { return 0.0 }
        return Double(progress.unlocked) / Double(progress.total)
    }
    
    // MARK: - Manual Triggers (for special achievements)
    
    func checkTimeBasedAchievements() {
        checkAllAchievements()
    }
    
    func triggerHeartRateUnlock() {
        let gameData = GameDataManager.shared
        gameData.playerProfile.hasUnlockedDuringHeartRateSpike = true
        gameData.savePlayerProfile()
        checkAllAchievements()
    }
    
    func resetAllAchievements() {
        unlockedAchievements.removeAll()
        unlockDates.removeAll()
        newlyUnlockedAchievements.removeAll()
        saveAchievements()
    }
}