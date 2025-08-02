import SwiftUI

struct AudioSettingsView: View {
    @StateObject private var audioManager = AudioManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                headerView
                
                toggleSection
                
                volumeSection
                
                testSection
                
                Spacer()
                
                doneButton
            }
            .padding(.horizontal, 4)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 2) {
            Text("Audio Settings")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Configure sound and music")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private var toggleSection: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Enable Audio")
                    .font(.caption)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Toggle("", isOn: $audioManager.isAudioEnabled)
                    .scaleEffect(0.8)
            }
            
            if !audioManager.isAudioEnabled {
                Text("Audio is disabled. Haptic feedback will still work.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.gray.opacity(0.1))
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var volumeSection: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Master Volume")
                    .font(.caption)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(Int(audioManager.masterVolume * 100))%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Slider(value: $audioManager.masterVolume, in: 0...1, step: 0.1)
                .disabled(!audioManager.isAudioEnabled)
                .accentColor(.blue)
                .scaleEffect(0.9)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.gray.opacity(0.1))
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var testSection: some View {
        VStack(spacing: 4) {
            Text("Test Sounds")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 3) {
                ForEach(AudioEffect.allCases.prefix(6), id: \.self) { effect in
                    Button(action: {
                        audioManager.playSound(effect, volume: 0.7)
                    }) {
                        Text(effect.description)
                            .font(.caption2)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .clipShape(Capsule())
                    }
                    .disabled(!audioManager.isAudioEnabled)
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.gray.opacity(0.1))
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var doneButton: some View {
        Button("Done") {
            dismiss()
        }
        .font(.caption)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.green.opacity(0.2))
        .foregroundColor(.green)
        .clipShape(Capsule())
    }
}

#Preview {
    AudioSettingsView()
}