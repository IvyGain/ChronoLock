import SwiftUI

struct ProfileView: View {
    @StateObject private var gameData = GameDataManager.shared
    @State private var showAudioSettings = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                headerView
                
                statsCards
                
                masterySection
                
                settingsSection
            }
            .padding(.horizontal, 4)
        }
        .sheet(isPresented: $showAudioSettings) {
            AudioSettingsView()
        }
    }
    
    private var settingsSection: some View {
        VStack(spacing: 4) {
            Text("Settings")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Button(action: {
                showAudioSettings = true
            }) {
                HStack {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text("Audio Settings")
                        .font(.caption)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.blue.opacity(0.05))
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 2) {
            Image(systemName: "person.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.blue)
            
            Text("Lockmaster")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 1) {
                Text("Level \(gameData.playerProfile.level)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                ProgressView(value: gameData.playerProfile.currentLevelProgress)
                    .frame(width: 100)
                    .scaleEffect(0.8)
                
                Text("\(gameData.playerProfile.experienceToNextLevel) XP to next level")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var statsCards: some View {
        VStack(spacing: 3) {
            HStack(spacing: 3) {
                statCard(
                    title: "Experience",
                    value: "\(gameData.playerProfile.experience)",
                    icon: "star.fill",
                    color: .blue
                )
                
                statCard(
                    title: "Key Fragments",
                    value: "\(gameData.playerProfile.keyFragments)",
                    icon: "key.fill",
                    color: .yellow
                )
            }
            
            HStack(spacing: 3) {
                statCard(
                    title: "Chests Unlocked",
                    value: "\(gameData.playerProfile.totalChestsUnlocked)",
                    icon: "lock.open.fill",
                    color: .green
                )
                
                statCard(
                    title: "Chronicle Points",
                    value: formatNumber(gameData.resonanceEngine.points),
                    icon: "bolt.fill",
                    color: .purple
                )
            }
        }
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(color.opacity(0.1))
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var masterySection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Lock Mastery")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            if gameData.playerProfile.lockMastery.isEmpty {
                Text("Unlock your first chest to see mastery progress")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 3) {
                    ForEach(Array(gameData.playerProfile.lockMastery.keys), id: \.self) { lockType in
                        if let mastery = gameData.playerProfile.lockMastery[lockType] {
                            masteryRow(lockType: lockType, mastery: mastery)
                        }
                    }
                }
            }
        }
    }
    
    private func masteryRow(lockType: LockType, mastery: LockMastery) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(lockType.description)
                    .font(.caption)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("Level \(mastery.level)")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
            
            HStack {
                ProgressView(value: Double(mastery.experience), total: Double(mastery.level * 50))
                    .frame(height: 4)
                    .scaleEffect(0.8, anchor: .leading)
                
                Spacer()
                
                Text("\(mastery.totalUnlocked)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Text("Bonus: +\(Int((mastery.masteryBonus - 1.0) * 100))%")
                .font(.caption2)
                .foregroundColor(.green)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.blue.opacity(0.05))
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func formatNumber(_ number: Double) -> String {
        if number >= 1_000_000 {
            return String(format: "%.1fM", number / 1_000_000)
        } else if number >= 1_000 {
            return String(format: "%.1fK", number / 1_000)
        } else {
            return String(format: "%.0f", number)
        }
    }
}

#Preview {
    ProfileView()
}