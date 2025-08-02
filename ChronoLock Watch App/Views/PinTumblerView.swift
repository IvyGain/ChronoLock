import SwiftUI
import WatchKit

struct PinTumblerView: View {
    @StateObject private var viewModel: LockPickingViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(chest: TreasureChest) {
        self._viewModel = StateObject(wrappedValue: LockPickingViewModel(chest: chest))
    }
    
    var body: some View {
        VStack(spacing: 4) {
            if viewModel.isUnlocked {
                unlockedView
            } else {
                lockPickingView
            }
        }
        .navigationBarHidden(true)
        .onTapGesture(count: 2) {
            if !viewModel.isUnlocked {
                viewModel.setPinAndMoveNext()
            }
        }
        .onTapGesture(count: 1) {
            if !viewModel.isUnlocking && !viewModel.isUnlocked {
                viewModel.startUnlocking()
            }
        }
    }
    
    private var lockPickingView: some View {
        VStack(spacing: 2) {
            headerView
            
            pinVisualizationView
                .digitalCrownRotation(
                    .constant(0),
                    from: -1,
                    through: 1,
                    by: 0.01,
                    sensitivity: .high,
                    isContinuous: true,
                    isHapticFeedbackEnabled: false
                ) { delta in
                    viewModel.updatePinHeight(delta: delta)
                }
            
            controlsView
            
            if viewModel.currentChest.timeLimit != nil {
                timerView
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 1) {
            Text(viewModel.currentChest.name)
                .font(.caption2)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            if viewModel.currentChest.isCursed && viewModel.isHeartRateMonitoring {
                HStack(spacing: 2) {
                    Image(systemName: "heart.fill")
                        .font(.caption2)
                        .foregroundColor(Color(
                            red: viewModel.heartRateEffect.color.red,
                            green: viewModel.heartRateEffect.color.green,
                            blue: viewModel.heartRateEffect.color.blue
                        ))
                    Text(viewModel.heartRateEffect.description)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else if viewModel.isUnlocking {
                Text("Pin \(viewModel.currentPin + 1)/\(viewModel.pinHeights.count)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                Text("Tap to Start")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var pinVisualizationView: some View {
        HStack(spacing: 2) {
            ForEach(0..<viewModel.pinHeights.count, id: \.self) { index in
                VStack(spacing: 1) {
                    // Shear line indicator
                    Rectangle()
                        .fill(Color.yellow)
                        .frame(width: 20, height: 1)
                    
                    // Pin cylinder
                    ZStack(alignment: .bottom) {
                        // Cylinder background
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 20, height: 60)
                        
                        // Pin
                        Rectangle()
                            .fill(pinColor(for: index))
                            .frame(width: 16, height: max(4, viewModel.pinHeights[index] * 56))
                    }
                }
                .scaleEffect(index == viewModel.currentPin ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: viewModel.currentPin)
            }
        }
    }
    
    private func pinColor(for index: Int) -> Color {
        if index < viewModel.pinStates.count {
            switch viewModel.pinStates[index] {
            case .locked:
                return index == viewModel.currentPin ? .blue : .gray
            case .correct:
                return .green
            case .set:
                return .yellow
            }
        }
        return .gray
    }
    
    private var controlsView: some View {
        HStack {
            Button(action: viewModel.moveToPreviousPin) {
                Image(systemName: "chevron.left")
                    .font(.caption)
            }
            .disabled(viewModel.currentPin == 0 || !viewModel.isUnlocking)
            
            Spacer()
            
            ProgressView(value: viewModel.progress)
                .frame(width: 60)
                .scaleEffect(0.7)
            
            Spacer()
            
            Button(action: viewModel.setPinAndMoveNext) {
                Image(systemName: "checkmark")
                    .font(.caption)
            }
            .disabled(!viewModel.isUnlocking || viewModel.pinStates[safe: viewModel.currentPin] != .correct)
        }
        .frame(height: 20)
    }
    
    private var timerView: some View {
        HStack {
            Image(systemName: "timer")
                .font(.caption2)
                .foregroundColor(viewModel.timeRemaining <= 5 ? .red : .secondary)
            
            Text(String(format: "%.1f", viewModel.timeRemaining))
                .font(.caption2)
                .foregroundColor(viewModel.timeRemaining <= 5 ? .red : .secondary)
        }
    }
    
    private var unlockedView: some View {
        VStack(spacing: 8) {
            Image(systemName: "lock.open.fill")
                .font(.title)
                .foregroundColor(.green)
            
            Text("Unlocked!")
                .font(.headline)
                .foregroundColor(.green)
            
            Text(viewModel.currentChest.name)
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(spacing: 2) {
                Text("Rewards:")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("\(viewModel.currentChest.keyFragmentReward)")
                        .foregroundColor(.yellow)
                    Image(systemName: "key.fill")
                        .foregroundColor(.yellow)
                    
                    Text("\(viewModel.currentChest.experienceReward)")
                        .foregroundColor(.blue)
                    Text("XP")
                        .foregroundColor(.blue)
                }
                .font(.caption2)
            }
            
            Button("Continue") {
                dismiss()
            }
            .font(.caption)
        }
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    PinTumblerView(chest: TreasureChest(
        name: "Test Chest",
        rarity: .common,
        lockType: .pinTumbler,
        difficulty: 3
    ))
}