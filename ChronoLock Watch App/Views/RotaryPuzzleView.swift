import SwiftUI
import WatchKit

struct RotaryPuzzleView: View {
    @StateObject private var viewModel: RotaryPuzzleViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var crownRotation: Double = 0
    
    init(chest: TreasureChest) {
        self._viewModel = StateObject(wrappedValue: RotaryPuzzleViewModel(chest: chest))
    }
    
    var body: some View {
        VStack(spacing: 4) {
            if viewModel.isUnlocked {
                unlockedView
            } else {
                puzzleView
            }
        }
        .navigationBarHidden(true)
        .onTapGesture(count: 2) {
            if !viewModel.isUnlocked {
                viewModel.lockInCurrentRing()
            }
        }
        .onTapGesture(count: 1) {
            if !viewModel.isUnlocking && !viewModel.isUnlocked {
                viewModel.startUnlocking()
            }
        }
    }
    
    private var puzzleView: some View {
        VStack(spacing: 2) {
            headerView
            
            rotaryRingsView
                .digitalCrownRotation(
                    $crownRotation,
                    from: -1,
                    through: 1,
                    by: 0.01,
                    sensitivity: .high,
                    isContinuous: true,
                    isHapticFeedbackEnabled: false
                ) { delta in
                    viewModel.rotateRing(delta: delta)
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
                Text("Ring \(viewModel.currentRingIndex + 1)/\(viewModel.ringRotations.count)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                Text("Tap to Start")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var rotaryRingsView: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                .frame(width: 120, height: 120)
            
            // Rotary rings
            ForEach(0..<viewModel.ringRotations.count, id: \.self) { index in
                let ringRadius = 60.0 - Double(index * 12)
                let ringWidth = 8.0
                
                ZStack {
                    // Ring base
                    Circle()
                        .stroke(ringBaseColor(for: index), lineWidth: ringWidth)
                        .frame(width: ringRadius * 2, height: ringRadius * 2)
                        .opacity(0.3)
                    
                    // Ring segments
                    RingSegmentView(
                        radius: ringRadius,
                        rotation: viewModel.ringRotations[index],
                        state: viewModel.ringStates[safe: index] ?? .locked,
                        isActive: index == viewModel.currentRingIndex,
                        segmentCount: index + 3
                    )
                }
                .scaleEffect(index == viewModel.currentRingIndex ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: viewModel.currentRingIndex)
            }
            
            // Center indicator
            Circle()
                .fill(viewModel.isUnlocking ? .blue : .gray)
                .frame(width: 8, height: 8)
        }
    }
    
    private func ringBaseColor(for index: Int) -> Color {
        if index < viewModel.ringStates.count {
            switch viewModel.ringStates[index] {
            case .locked:
                return index == viewModel.currentRingIndex ? .blue : .gray
            case .aligned:
                return .green
            case .locked_in:
                return .yellow
            }
        }
        return .gray
    }
    
    private var controlsView: some View {
        HStack {
            Button(action: viewModel.moveToPreviousRing) {
                Image(systemName: "chevron.left")
                    .font(.caption)
            }
            .disabled(viewModel.currentRingIndex == 0 || !viewModel.isUnlocking)
            
            Button(action: viewModel.resetCurrentRing) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.caption)
            }
            .disabled(!viewModel.isUnlocking)
            
            Spacer()
            
            ProgressView(value: viewModel.progress)
                .frame(width: 50)
                .scaleEffect(0.7)
            
            Spacer()
            
            Button(action: viewModel.lockInCurrentRing) {
                Image(systemName: "lock.fill")
                    .font(.caption)
            }
            .disabled(!viewModel.isUnlocking || 
                     viewModel.currentRingIndex >= viewModel.ringStates.count ||
                     viewModel.ringStates[viewModel.currentRingIndex] != .aligned)
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
            Image(systemName: "lock.open.rotation")
                .font(.title)
                .foregroundColor(.green)
            
            Text("Puzzle Solved!")
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

struct RingSegmentView: View {
    let radius: Double
    let rotation: Double
    let state: RotaryPuzzleViewModel.RingState
    let isActive: Bool
    let segmentCount: Int
    
    var body: some View {
        ZStack {
            ForEach(0..<segmentCount, id: \.self) { segment in
                let angle = (Double(segment) / Double(segmentCount)) * 360.0
                let segmentRotation = rotation * 360.0
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(segmentColor)
                    .frame(width: 3, height: 12)
                    .offset(y: -radius + 6)
                    .rotationEffect(.degrees(angle + segmentRotation))
            }
            
            // Alignment indicator
            if isActive {
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.red)
                    .frame(width: 2, height: 8)
                    .offset(y: -radius - 12)
            }
        }
    }
    
    private var segmentColor: Color {
        switch state {
        case .locked:
            return isActive ? .blue.opacity(0.8) : .gray.opacity(0.6)
        case .aligned:
            return .green.opacity(0.9)
        case .locked_in:
            return .yellow.opacity(0.9)
        }
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    RotaryPuzzleView(chest: TreasureChest(
        name: "Ancient Mechanism",
        rarity: .legendary,
        lockType: .rotaryPuzzle,
        difficulty: 6
    ))
}