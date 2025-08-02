import WatchKit
import Foundation

enum HapticPattern: String, CaseIterable {
    case pickingResistanceLight = "haptic_picking_resistance_light"
    case pickingResistanceHeavy = "haptic_picking_resistance_heavy"
    case pickingSweetSpotPulse = "haptic_picking_sweet_spot_pulse"
    case pickingSetClickFirm = "haptic_picking_set_click_firm"
    
    case dialTickSubtle = "haptic_dial_tick_subtle"
    case dialCorrectNumberThump = "haptic_dial_correct_number_thump"
    
    case rarityCommonShortTap = "haptic_rarity_common_short_tap"
    case rarityRareDoubleTap = "haptic_rarity_rare_double_tap"
    case rarityLegendaryHeartbeat = "haptic_rarity_legendary_heartbeat"
    
    case trapNoiseSubtleStatic = "haptic_trap_noise_subtle_static"
    
    case resonanceManualClick = "haptic_resonance_manual_click"
    case resonanceOfflineReward = "haptic_resonance_offline_reward"
}

class HapticManager: ObservableObject {
    static let shared = HapticManager()
    
    private let device = WKInterfaceDevice.current()
    
    private init() {}
    
    func play(_ pattern: HapticPattern) {
        switch pattern {
        case .pickingResistanceLight:
            playLightTap()
        case .pickingResistanceHeavy:
            playHeavyTap()
        case .pickingSweetSpotPulse:
            playPulse()
        case .pickingSetClickFirm:
            playClick()
            
        case .dialTickSubtle:
            playSubtleTick()
        case .dialCorrectNumberThump:
            playSuccess()
            
        case .rarityCommonShortTap:
            playShortTap()
        case .rarityRareDoubleTap:
            playDoubleTap()
        case .rarityLegendaryHeartbeat:
            playHeartbeat()
            
        case .trapNoiseSubtleStatic:
            playStatic()
            
        case .resonanceManualClick:
            playClick()
        case .resonanceOfflineReward:
            playSuccess()
        }
    }
    
    private func playLightTap() {
        device.play(.notification)
    }
    
    private func playHeavyTap() {
        device.play(.directionUp)
    }
    
    private func playPulse() {
        device.play(.start)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.device.play(.start)
        }
    }
    
    private func playClick() {
        device.play(.click)
    }
    
    private func playSubtleTick() {
        device.play(.notification)
    }
    
    private func playSuccess() {
        device.play(.success)
    }
    
    private func playShortTap() {
        device.play(.notification)
    }
    
    private func playDoubleTap() {
        device.play(.notification)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.device.play(.notification)
        }
    }
    
    private func playHeartbeat() {
        device.play(.directionUp)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.device.play(.directionUp)
        }
    }
    
    private func playStatic() {
        device.play(.retry)
    }
}