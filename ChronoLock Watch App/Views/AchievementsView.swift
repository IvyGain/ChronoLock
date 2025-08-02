import SwiftUI

struct AchievementsView: View {
    @StateObject private var achievementManager = AchievementManager.shared
    @State private var selectedCategory: AchievementCategory = .unlocking
    @State private var showingUnlockedOnly = false
    
    var body: some View {
        VStack(spacing: 4) {
            headerView
            
            categorySelector
            
            achievementsList
        }
        .overlay(
            achievementNotifications,
            alignment: .top
        )
    }
    
    private var headerView: some View {
        VStack(spacing: 2) {
            Text("Achievements")
                .font(.headline)
                .foregroundColor(.primary)
            
            let progress = achievementManager.getAchievementProgress()
            Text("\(progress.unlocked)/\(progress.total) unlocked")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            ProgressView(value: achievementManager.getCompletionPercentage())
                .frame(width: 120)
                .scaleEffect(0.8)
        }
    }
    
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 3) {
                ForEach(AchievementCategory.allCases, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        Text(category.displayName)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(selectedCategory == category ? 
                                          Color.blue.opacity(0.2) : 
                                          Color.gray.opacity(0.1))
                                    .stroke(selectedCategory == category ? 
                                           Color.blue.opacity(0.4) : 
                                           Color.gray.opacity(0.3), 
                                           lineWidth: 1)
                            )
                            .foregroundColor(selectedCategory == category ? .blue : .secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    private var achievementsList: some View {
        ScrollView {
            LazyVStack(spacing: 3) {
                let achievements = filteredAchievements
                
                if achievements.isEmpty {
                    emptyStateView
                } else {
                    ForEach(achievements) { achievement in
                        AchievementRowView(achievement: achievement)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    private var filteredAchievements: [Achievement] {
        let categoryAchievements = achievementManager.getAchievementsByCategory(selectedCategory)
        
        if showingUnlockedOnly {
            return categoryAchievements.filter { achievement in
                achievementManager.isAchievementUnlocked(achievement.id)
            }
        } else {
            return categoryAchievements.filter { achievement in
                !achievement.isHidden || achievementManager.isAchievementUnlocked(achievement.id)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 6) {
            Image(systemName: "trophy")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("No achievements")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("Complete challenges to unlock achievements")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 20)
    }
    
    private var achievementNotifications: some View {
        VStack(spacing: 2) {
            ForEach(achievementManager.newlyUnlockedAchievements) { achievement in
                AchievementNotificationView(achievement: achievement)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: achievementManager.newlyUnlockedAchievements.count)
    }
}

struct AchievementRowView: View {
    let achievement: Achievement
    @StateObject private var achievementManager = AchievementManager.shared
    
    var body: some View {
        HStack(spacing: 8) {
            achievementIcon
            
            VStack(alignment: .leading, spacing: 1) {
                Text(achievement.title)
                    .font(.caption)
                    .foregroundColor(isUnlocked ? .primary : .secondary)
                    .lineLimit(1)
                
                Text(achievement.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack(spacing: 4) {
                    rarityBadge
                    
                    if isUnlocked, let unlockDate = achievementManager.getUnlockDate(for: achievement.id) {
                        Text(unlockDate, style: .relative)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            rewardView
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(backgroundColor)
                .stroke(borderColor, lineWidth: 1)
        )
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
    
    private var isUnlocked: Bool {
        achievementManager.isAchievementUnlocked(achievement.id)
    }
    
    private var achievementIcon: some View {
        Image(systemName: achievement.iconName)
            .font(.title3)
            .foregroundColor(isUnlocked ? rarityColor : .gray)
            .frame(width: 20)
    }
    
    private var rarityBadge: some View {
        Text(achievement.rarity.rawValue.capitalized)
            .font(.caption2)
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .background(rarityColor.opacity(0.2))
            .foregroundColor(rarityColor)
            .clipShape(Capsule())
    }
    
    private var rewardView: some View {
        VStack(spacing: 1) {
            HStack(spacing: 2) {
                Text("\(achievement.rarity.keyFragmentReward)")
                    .font(.caption2)
                    .foregroundColor(.yellow)
                Image(systemName: "key.fill")
                    .font(.caption2)
                    .foregroundColor(.yellow)
            }
            
            HStack(spacing: 2) {
                Text("\(achievement.rarity.experienceReward)")
                    .font(.caption2)
                    .foregroundColor(.blue)
                Text("XP")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
        }
    }
    
    private var rarityColor: Color {
        switch achievement.rarity {
        case .common:
            return .gray
        case .rare:
            return .blue
        case .legendary:
            return .purple
        }
    }
    
    private var backgroundColor: Color {
        if isUnlocked {
            return rarityColor.opacity(0.1)
        } else {
            return Color.gray.opacity(0.05)
        }
    }
    
    private var borderColor: Color {
        if isUnlocked {
            return rarityColor.opacity(0.3)
        } else {
            return Color.gray.opacity(0.2)
        }
    }
}

struct AchievementNotificationView: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: achievement.iconName)
                .font(.caption)
                .foregroundColor(rarityColor)
            
            VStack(alignment: .leading, spacing: 1) {
                Text("Achievement Unlocked!")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(rarityColor)
                
                Text(achievement.title)
                    .font(.caption2)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            HStack(spacing: 2) {
                Text("+\(achievement.rarity.keyFragmentReward)")
                    .font(.caption2)
                    .foregroundColor(.yellow)
                Image(systemName: "key.fill")
                    .font(.caption2)
                    .foregroundColor(.yellow)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(rarityColor.opacity(0.15))
                .stroke(rarityColor.opacity(0.4), lineWidth: 1)
        )
        .padding(.horizontal, 4)
    }
    
    private var rarityColor: Color {
        switch achievement.rarity {
        case .common:
            return .green
        case .rare:
            return .blue
        case .legendary:
            return .purple
        }
    }
}

#Preview {
    AchievementsView()
}