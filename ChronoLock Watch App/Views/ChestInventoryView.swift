import SwiftUI

struct ChestInventoryView: View {
    @StateObject private var gameData = GameDataManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            availableChestsView
                .tag(0)
            
            unlockedChestsView
                .tag(1)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
    
    private var availableChestsView: some View {
        NavigationStack {
            VStack(spacing: 4) {
                headerView(title: "Available Chests", 
                          subtitle: "\(availableChests.count) chests")
                
                if availableChests.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 3) {
                            ForEach(availableChests) { chest in
                                ChestRowView(chest: chest, isUnlocked: false)
                            }
                        }
                        .padding(.horizontal, 2)
                    }
                }
            }
        }
    }
    
    private var unlockedChestsView: some View {
        NavigationStack {
            VStack(spacing: 4) {
                headerView(title: "Collection", 
                          subtitle: "\(unlockedChests.count) unlocked")
                
                if unlockedChests.isEmpty {
                    VStack {
                        Image(systemName: "lock.open")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("No unlocked chests")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 3) {
                            ForEach(unlockedChests) { chest in
                                ChestRowView(chest: chest, isUnlocked: true)
                            }
                        }
                        .padding(.horizontal, 2)
                    }
                }
            }
        }
    }
    
    private func headerView(title: String, subtitle: String) -> some View {
        VStack(spacing: 1) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "cube.box")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("No chests available")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("Explore the world to find treasure chests")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var availableChests: [TreasureChest] {
        gameData.inventory.filter { !$0.isUnlocked }
    }
    
    private var unlockedChests: [TreasureChest] {
        gameData.inventory.filter { $0.isUnlocked }
            .sorted { chest1, chest2 in
                guard let time1 = chest1.unlockTime,
                      let time2 = chest2.unlockTime else {
                    return chest1.unlockTime != nil
                }
                return time1 > time2
            }
    }
}

struct ChestRowView: View {
    let chest: TreasureChest
    let isUnlocked: Bool
    
    var body: some View {
        NavigationLink(destination: destinationView) {
            HStack(spacing: 8) {
                chestIcon
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(chest.name)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        rarityBadge
                        lockTypeBadge
                        difficultyBadge
                    }
                    
                    if isUnlocked, let unlockTime = chest.unlockTime {
                        Text(unlockTime, style: .relative)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if !isUnlocked {
                    VStack(spacing: 1) {
                        if chest.hasTrap {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                        
                        if chest.isCursed {
                            Image(systemName: "heart.fill")
                                .font(.caption2)
                                .foregroundColor(.red)
                        }
                        
                        if chest.timeLimit != nil {
                            Image(systemName: "timer")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                        }
                    }
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(backgroundColor)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var chestIcon: some View {
        Image(systemName: isUnlocked ? "lock.open.fill" : "lock.fill")
            .font(.title3)
            .foregroundColor(isUnlocked ? .green : rarityColor)
            .frame(width: 20)
    }
    
    private var destinationView: some View {
        Group {
            if isUnlocked {
                ChestDetailView(chest: chest)
            } else {
                switch chest.lockType {
                case .pinTumbler:
                    PinTumblerView(chest: chest)
                case .dialCombination:
                    DialCombinationView(chest: chest)
                case .rotaryPuzzle:
                    // TODO: Implement RotaryPuzzleView
                    PinTumblerView(chest: chest)
                }
            }
        }
    }
    
    private var rarityBadge: some View {
        Text(chest.rarity.description)
            .font(.caption2)
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .background(rarityColor.opacity(0.2))
            .foregroundColor(rarityColor)
            .clipShape(Capsule())
    }
    
    private var lockTypeBadge: some View {
        Text(chest.lockType.description)
            .font(.caption2)
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .background(Color.blue.opacity(0.2))
            .foregroundColor(.blue)
            .clipShape(Capsule())
    }
    
    private var difficultyBadge: some View {
        Text("L\(chest.difficulty)")
            .font(.caption2)
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .background(Color.gray.opacity(0.2))
            .foregroundColor(.gray)
            .clipShape(Capsule())
    }
    
    private var rarityColor: Color {
        switch chest.rarity {
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
            return .green.opacity(0.1)
        } else {
            return rarityColor.opacity(0.05)
        }
    }
    
    private var borderColor: Color {
        if isUnlocked {
            return .green.opacity(0.3)
        } else {
            return rarityColor.opacity(0.3)
        }
    }
}

struct ChestDetailView: View {
    let chest: TreasureChest
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "lock.open.fill")
                .font(.largeTitle)
                .foregroundColor(.green)
            
            Text(chest.name)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 4) {
                HStack {
                    Text("Rarity:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(chest.rarity.description)
                        .foregroundColor(rarityColor)
                }
                
                HStack {
                    Text("Lock Type:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(chest.lockType.description)
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Text("Difficulty:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Level \(chest.difficulty)")
                        .foregroundColor(.primary)
                }
                
                if let unlockTime = chest.unlockTime {
                    HStack {
                        Text("Unlocked:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(unlockTime, style: .date)
                            .foregroundColor(.primary)
                    }
                }
            }
            .font(.caption)
            
            Divider()
            
            VStack(spacing: 4) {
                Text("Rewards Earned")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    HStack {
                        Image(systemName: "key.fill")
                            .foregroundColor(.yellow)
                        Text("\(chest.keyFragmentReward)")
                            .foregroundColor(.yellow)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text("\(chest.experienceReward)")
                            .foregroundColor(.blue)
                        Text("XP")
                            .foregroundColor(.blue)
                    }
                }
                .font(.caption)
            }
            
            Button("Close") {
                dismiss()
            }
            .font(.caption)
        }
        .padding()
    }
    
    private var rarityColor: Color {
        switch chest.rarity {
        case .common:
            return .gray
        case .rare:
            return .blue
        case .legendary:
            return .purple
        }
    }
}

#Preview {
    ChestInventoryView()
}