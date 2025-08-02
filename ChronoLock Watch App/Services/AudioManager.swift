import Foundation
import AVFoundation
import Combine

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    @Published var isAudioEnabled = true
    @Published var masterVolume: Float = 0.7
    @Published var isPlaying = false
    
    private var audioEngine: AVAudioEngine
    private var playerNodes: [String: AVAudioPlayerNode] = [:]
    private var audioBuffers: [String: AVAudioPCMBuffer] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        self.audioEngine = AVAudioEngine()
        setupAudioSession()
        setupAudioEngine()
        loadSoundEffects()
        
        // Subscribe to settings changes
        $isAudioEnabled
            .sink { [weak self] enabled in
                if !enabled {
                    self?.stopAllSounds()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func setupAudioEngine() {
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    private func loadSoundEffects() {
        // Generate procedural audio buffers for various sound effects
        generateLockClickSound()
        generateMetalScrapeSound()
        generateSuccessChimeSound()
        generateFailureSound()
        generateHeartbeatSound()
        generateResonanceHumSound()
        generateAmbientSound()
    }
    
    private func generateLockClickSound() {
        let sampleRate = 44100.0
        let duration = 0.1
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: audioEngine.outputNode.outputFormat(forBus: 0), frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        
        let channels = Int(buffer.format.channelCount)
        
        for frame in 0..<Int(frameCount) {
            let time = Double(frame) / sampleRate
            let frequency = 800.0 + (400.0 * exp(-time * 20)) // Click with quick decay
            let amplitude = Float(0.3 * exp(-time * 15)) // Quick volume decay
            let sample = amplitude * sin(2.0 * .pi * frequency * time)
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = sample
            }
        }
        
        audioBuffers["lock_click"] = buffer
    }
    
    private func generateMetalScrapeSound() {
        let sampleRate = 44100.0
        let duration = 0.3
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: audioEngine.outputNode.outputFormat(forBus: 0), frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        
        let channels = Int(buffer.format.channelCount)
        
        for frame in 0..<Int(frameCount) {
            let time = Double(frame) / sampleRate
            // Metallic scraping sound with noise and harmonics
            let baseFreq = 150.0 + sin(time * 50) * 30
            let noise = Double.random(in: -0.1...0.1)
            let harmonic1 = sin(2.0 * .pi * baseFreq * time)
            let harmonic2 = sin(2.0 * .pi * baseFreq * 1.5 * time) * 0.3
            let harmonic3 = sin(2.0 * .pi * baseFreq * 2.0 * time) * 0.2
            
            let amplitude = Float(0.2 * (1 - time / duration))
            let sample = amplitude * Float(harmonic1 + harmonic2 + harmonic3 + noise)
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = sample
            }
        }
        
        audioBuffers["metal_scrape"] = buffer
    }
    
    private func generateSuccessChimeSound() {
        let sampleRate = 44100.0
        let duration = 0.8
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: audioEngine.outputNode.outputFormat(forBus: 0), frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        
        let channels = Int(buffer.format.channelCount)
        let notes = [523.25, 659.25, 783.99] // C5, E5, G5 chord
        
        for frame in 0..<Int(frameCount) {
            let time = Double(frame) / sampleRate
            let envelope = Float(exp(-time * 1.5)) // Gradual decay
            
            var sample: Float = 0
            for (index, frequency) in notes.enumerated() {
                let noteAmplitude = 0.3 / Float(notes.count)
                let phase = 2.0 * .pi * frequency * time
                sample += noteAmplitude * sin(phase)
            }
            
            sample *= envelope
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = sample
            }
        }
        
        audioBuffers["success_chime"] = buffer
    }
    
    private func generateFailureSound() {
        let sampleRate = 44100.0
        let duration = 0.5
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: audioEngine.outputNode.outputFormat(forBus: 0), frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        
        let channels = Int(buffer.format.channelCount)
        
        for frame in 0..<Int(frameCount) {
            let time = Double(frame) / sampleRate
            // Descending tone to indicate failure
            let frequency = 300.0 - (time * 200.0) // Descending from 300Hz to 100Hz
            let amplitude = Float(0.4 * (1 - time / duration))
            let sample = amplitude * sin(2.0 * .pi * frequency * time)
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = sample
            }
        }
        
        audioBuffers["failure_sound"] = buffer
    }
    
    private func generateHeartbeatSound() {
        let sampleRate = 44100.0
        let duration = 1.0
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: audioEngine.outputNode.outputFormat(forBus: 0), frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        
        let channels = Int(buffer.format.channelCount)
        
        for frame in 0..<Int(frameCount) {
            let time = Double(frame) / sampleRate
            var sample: Float = 0
            
            // First heartbeat (lub)
            if time < 0.15 {
                let beatTime = time / 0.15
                let frequency = 60.0 + (40.0 * exp(-beatTime * 8))
                let amplitude = Float(0.5 * exp(-beatTime * 6))
                sample = amplitude * sin(2.0 * .pi * frequency * beatTime)
            }
            // Second heartbeat (dub)
            else if time > 0.3 && time < 0.45 {
                let beatTime = (time - 0.3) / 0.15
                let frequency = 45.0 + (30.0 * exp(-beatTime * 8))
                let amplitude = Float(0.4 * exp(-beatTime * 6))
                sample = amplitude * sin(2.0 * .pi * frequency * beatTime)
            }
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = sample
            }
        }
        
        audioBuffers["heartbeat"] = buffer
    }
    
    private func generateResonanceHumSound() {
        let sampleRate = 44100.0
        let duration = 2.0
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: audioEngine.outputNode.outputFormat(forBus: 0), frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        
        let channels = Int(buffer.format.channelCount)
        
        for frame in 0..<Int(frameCount) {
            let time = Double(frame) / sampleRate
            // Mysterious resonance hum with beating frequencies
            let baseFreq = 110.0
            let modulationFreq = 0.5
            let modulation = sin(2.0 * .pi * modulationFreq * time)
            let frequency = baseFreq + (modulation * 5.0)
            
            let amplitude = Float(0.3 * (0.5 + 0.5 * modulation))
            let sample = amplitude * sin(2.0 * .pi * frequency * time)
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = sample
            }
        }
        
        audioBuffers["resonance_hum"] = buffer
    }
    
    private func generateAmbientSound() {
        let sampleRate = 44100.0
        let duration = 5.0
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: audioEngine.outputNode.outputFormat(forBus: 0), frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        
        let channels = Int(buffer.format.channelCount)
        
        for frame in 0..<Int(frameCount) {
            let time = Double(frame) / sampleRate
            // Subtle ambient atmosphere
            let lowFreq = 40.0 + sin(time * 0.3) * 10.0
            let midFreq = 200.0 + sin(time * 0.7) * 20.0
            
            let lowTone = 0.1 * sin(2.0 * .pi * lowFreq * time)
            let midTone = 0.05 * sin(2.0 * .pi * midFreq * time)
            let noise = Double.random(in: -0.02...0.02)
            
            let sample = Float(lowTone + midTone + noise)
            
            for channel in 0..<channels {
                buffer.floatChannelData?[channel][frame] = sample
            }
        }
        
        audioBuffers["ambient"] = buffer
    }
    
    func playSound(_ soundName: AudioEffect, volume: Float = 1.0) {
        guard isAudioEnabled, let buffer = audioBuffers[soundName.rawValue] else { return }
        
        let playerNode = AVAudioPlayerNode()
        playerNodes[soundName.rawValue] = playerNode
        
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.outputNode, format: buffer.format)
        
        playerNode.volume = masterVolume * volume
        playerNode.scheduleBuffer(buffer, at: nil, options: []) {
            DispatchQueue.main.async {
                self.audioEngine.detach(playerNode)
                self.playerNodes.removeValue(forKey: soundName.rawValue)
            }
        }
        
        do {
            try audioEngine.start()
            playerNode.play()
        } catch {
            print("Failed to play sound: \(error)")
        }
    }
    
    func playAmbientLoop(_ soundName: AudioEffect) {
        guard isAudioEnabled, let buffer = audioBuffers[soundName.rawValue] else { return }
        
        let playerNode = AVAudioPlayerNode()
        playerNodes["\(soundName.rawValue)_loop"] = playerNode
        
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.outputNode, format: buffer.format)
        
        playerNode.volume = masterVolume * 0.3
        playerNode.scheduleBuffer(buffer, at: nil, options: [.loops])
        
        do {
            try audioEngine.start()
            playerNode.play()
            isPlaying = true
        } catch {
            print("Failed to play ambient loop: \(error)")
        }
    }
    
    func stopAmbientLoop(_ soundName: AudioEffect) {
        let loopKey = "\(soundName.rawValue)_loop"
        if let playerNode = playerNodes[loopKey] {
            playerNode.stop()
            audioEngine.detach(playerNode)
            playerNodes.removeValue(forKey: loopKey)
            isPlaying = false
        }
    }
    
    func stopAllSounds() {
        for (_, playerNode) in playerNodes {
            playerNode.stop()
            audioEngine.detach(playerNode)
        }
        playerNodes.removeAll()
        isPlaying = false
    }
    
    func setMasterVolume(_ volume: Float) {
        masterVolume = max(0.0, min(1.0, volume))
        
        // Update volume for currently playing nodes
        for (_, playerNode) in playerNodes {
            playerNode.volume = masterVolume
        }
    }
}

enum AudioEffect: String, CaseIterable {
    case lockClick = "lock_click"
    case metalScrape = "metal_scrape"
    case successChime = "success_chime"
    case failureSound = "failure_sound"
    case heartbeat = "heartbeat"
    case resonanceHum = "resonance_hum"
    case ambient = "ambient"
    
    var description: String {
        switch self {
        case .lockClick:
            return "Lock Click"
        case .metalScrape:
            return "Metal Scrape"
        case .successChime:
            return "Success Chime"
        case .failureSound:
            return "Failure Sound"
        case .heartbeat:
            return "Heartbeat"
        case .resonanceHum:
            return "Resonance Hum"
        case .ambient:
            return "Ambient"
        }
    }
}