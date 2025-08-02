import SwiftUI
import WatchKit

struct DialCombinationView: View {
    @StateObject private var viewModel: DialLockViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var crownRotation: Double = 0
    
    init(chest: TreasureChest) {
        self._viewModel = StateObject(wrappedValue: DialLockViewModel(chest: chest))
    }
    
    var body: some View {
        VStack(spacing: 4) {
            if viewModel.isUnlocked {
                unlockedView
            } else {
                dialLockView
            }
        }
        .navigationBarHidden(true)
        .onTapGesture(count: 2) {
            if !viewModel.isUnlocked {
                viewModel.confirmCurrentDial()
            }
        }
        .onTapGesture(count: 1) {
            if !viewModel.isUnlocking && !viewModel.isUnlocked {
                viewModel.startUnlocking()
            }
        }
    }
    
    private var dialLockView: some View {
        VStack(spacing: 2) {
            headerView
            
            dialsVisualizationView
                .digitalCrownRotation(
                    $crownRotation,
                    from: -10,
                    through: 10,
                    by: 0.1,
                    sensitivity: .medium,
                    isContinuous: true,
                    isHapticFeedbackEnabled: false
                ) { delta in
                    viewModel.rotateDial(delta: delta)
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
            
            if viewModel.isUnlocking {
                Text("Dial \(viewModel.currentDialIndex + 1)/\(viewModel.dialValues.count)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                Text("Tap to Start")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var dialsVisualizationView: some View {
        HStack(spacing: 3) {
            ForEach(0..<viewModel.dialValues.count, id: \.self) { index in
                VStack(spacing: 1) {
                    // Dial wheel
                    ZStack {
                        Circle()
                            .fill(dialBackgroundColor(for: index))
                            .frame(width: 35, height: 35)
                            .overlay(
                                Circle()
                                    .stroke(dialBorderColor(for: index), lineWidth: 2)
                            )
                        
                        // Current number
                        Text("\(viewModel.dialValues[index])")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(dialTextColor(for: index))
                        
                        // Indicator mark at top
                        Rectangle()
                            .fill(Color.yellow)
                            .frame(width: 2, height: 6)
                            .offset(y: -17)
                    }
                    .scaleEffect(index == viewModel.currentDialIndex ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.currentDialIndex)
                    
                    // State indicator
                    Circle()
                        .fill(stateIndicatorColor(for: index))
                        .frame(width: 6, height: 6)
                }
            }
        }
    }
    
    private func dialBackgroundColor(for index: Int) -> Color {
        if index < viewModel.dialStates.count {
            switch viewModel.dialStates[index] {
            case .locked:
                return index == viewModel.currentDialIndex ? .blue.opacity(0.3) : .gray.opacity(0.2)
            case .correct:
                return .green.opacity(0.3)
            case .set:
                return .yellow.opacity(0.3)
            }
        }
        return .gray.opacity(0.2)
    }
    
    private func dialBorderColor(for index: Int) -> Color {
        if index < viewModel.dialStates.count {
            switch viewModel.dialStates[index] {
            case .locked:
                return index == viewModel.currentDialIndex ? .blue : .gray
            case .correct:
                return .green
            case .set:
                return .yellow
            }
        }
        return .gray
    }
    
    private func dialTextColor(for index: Int) -> Color {
        if index < viewModel.dialStates.count {
            switch viewModel.dialStates[index] {
            case .locked:
                return index == viewModel.currentDialIndex ? .blue : .primary
            case .correct:
                return .green
            case .set:
                return .orange
            }
        }
        return .primary
    }
    
    private func stateIndicatorColor(for index: Int) -> Color {
        if index < viewModel.dialStates.count {
            switch viewModel.dialStates[index] {
            case .locked:
                return .gray
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
            Button(action: viewModel.moveToPreviousDial) {
                Image(systemName: "chevron.left")
                    .font(.caption)
            }
            .disabled(viewModel.currentDialIndex == 0 || !viewModel.isUnlocking)
            
            Button(action: viewModel.resetCurrentDial) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.caption)
            }
            .disabled(!viewModel.isUnlocking)
            
            Spacer()
            
            ProgressView(value: viewModel.progress)
                .frame(width: 50)
                .scaleEffect(0.7)
            
            Spacer()
            
            Button(action: viewModel.confirmCurrentDial) {
                Image(systemName: "checkmark")
                    .font(.caption)
            }
            .disabled(!viewModel.isUnlocking || 
                     viewModel.currentDialIndex >= viewModel.dialStates.count ||
                     viewModel.dialStates[viewModel.currentDialIndex] != .correct)
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
            
            Text("Combination Cracked!")
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

#Preview {
    DialCombinationView(chest: TreasureChest(
        name: "Safe Combination",
        rarity: .rare,
        lockType: .dialCombination,
        difficulty: 4
    ))
}