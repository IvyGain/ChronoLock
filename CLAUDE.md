# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ChronoLock is an Apple Watch tactile adventure game where players are lockpickers solving time-locked treasure chests using Apple Watch hardware features. The game leverages Digital Crown input, haptic feedback, heart rate monitoring, and location services for immersive gameplay.

## Development Commands

### Building and Running
```bash
# Build the project (requires Xcode)
xcodebuild -project ChronoLock.xcodeproj -scheme "ChronoLock Watch App" -configuration Debug

# Run on simulator (from Xcode)
# Product → Run or Cmd+R

# Clean build
xcodebuild clean -project ChronoLock.xcodeproj
```

### Git Workflow
```bash
# Commit changes with conventional commits format
git commit -m "feat: implement new lock picking mechanism"
git commit -m "fix: resolve heart rate monitoring crash"
git commit -m "docs: update CLAUDE.md with build instructions"

# Push changes (automatic for this project)
git push origin main
```

## Architecture

### MVVM-C Pattern
The project follows Model-View-ViewModel-Coordinator architecture:

- **Models** (`ChronoLock Watch App/Models/`): Game data structures
  - `TreasureChest`: Core game object with lock types, rarity, difficulty
  - `PlayerProfile`: Player progression, experience, lock mastery
  - `ResonanceEngine`: Idle game mechanics and upgrades

- **Views** (`ChronoLock Watch App/Views/`): SwiftUI interface components
  - Each view focuses on single purpose (Iceberg Model UX philosophy)
  - Heavy use of Digital Crown `.digitalCrownRotation()` API
  - Haptic-first design with visual feedback as secondary

- **ViewModels** (`ChronoLock Watch App/ViewModels/`): Business logic
  - `LockPickingViewModel`: Pin tumbler lock mechanics with heart rate integration
  - `DialLockViewModel`: Combination dial lock mechanics
  - `ResonanceEngineViewModel`: Idle game progression

- **Coordinators** (`ChronoLock Watch App/Coordinators/`): Navigation flow
  - `AppCoordinator`: Manages tab navigation and onboarding state

- **Services** (`ChronoLock Watch App/Services/`): System integrations
  - `GameDataManager`: Centralized data persistence with App Group sharing
  - `HapticManager`: 100+ custom haptic patterns
  - `HealthKitManager`: Real-time heart rate monitoring for cursed chests
  - `LocationManager`: Location-based treasure discovery

### Key Design Patterns

1. **Haptic-First Design**: All interactions have tactile feedback before visual
2. **Single Purpose Screens**: Each view serves one specific game function
3. **Progressive System Unlocking**: Features unlock based on player progression
4. **Heart Rate Integration**: Cursed chests use biometric data for dynamic difficulty

### Data Persistence Strategy

```swift
// App Group sharing between iOS and watchOS targets
UserDefaults(suiteName: "group.com.chronolock.shared")

// Light data: PlayerProfile, ResonanceEngine, Settings (UserDefaults)
// Heavy data: Inventory array (JSON files in Documents)
```

## Hardware Integration

### Digital Crown Implementation
```swift
// High sensitivity for pin picking
.digitalCrownRotation($crownValue, sensitivity: .high, isContinuous: true)

// Medium sensitivity for dial combinations
.digitalCrownRotation($crownValue, sensitivity: .medium, isContinuous: false)
```

### Haptic Feedback System
- Custom haptic patterns defined in `HapticManager`
- Resistance simulation through varied haptic intensity
- Material feedback (wood, metal, stone) through haptic signatures

### HealthKit Integration
- Real-time heart rate monitoring during cursed chest gameplay
- Heart rate thresholds affect lock picking difficulty:
  - 80-100 BPM: Mild jitter effects
  - 100-120 BPM: Moderate precision reduction
  - 120+ BPM: Severe difficulty spike

### CoreLocation Features
- Background location monitoring for treasure discovery
- Procedural generation of "interesting locations" around user
- Privacy-first approach: no data leaves device

## Game Mechanics

### Lock Types
1. **Pin Tumbler**: Digital Crown adjusts pin heights to shear line
2. **Dial Combination**: Rotate through number sequences
3. **Rotary Puzzle**: (Planned) Complex multi-step puzzles

### Progression Systems
- **Experience & Levels**: Traditional RPG progression
- **Lock Mastery**: Specialization in specific lock types
- **Key Fragments**: Currency from successful unlocks
- **Chronicle Points**: Idle game currency from Resonance Engine

### Idle Game Component
The Resonance Engine provides:
- Manual resonance via Digital Crown rotation
- Passive generation through "tuning forks"
- Exponential upgrade costs with compounding returns

## Important Implementation Notes

### Entitlements Required
```xml
<!-- HealthKit for heart rate monitoring -->
<key>com.apple.developer.healthkit</key>
<true/>

<!-- Location for treasure discovery -->
<key>com.apple.developer.location.when-in-use</key>
<true/>

<!-- App Group for data sharing -->
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.chronolock.shared</string>
</array>
```

### Performance Considerations
- Heart rate monitoring should be stopped when not needed
- Location monitoring runs in background but respects battery life
- Haptic feedback timing is critical for tactile immersion
- Auto-save game state on every change to prevent data loss

### Testing Strategy
- Focus on haptic feedback timing and intensity
- Test heart rate integration with simulated data
- Verify offline reward calculations for idle game
- Test permission flows for HealthKit and CoreLocation

## Serena MCP Integration

The project uses Serena MCP server for enhanced code analysis:
- Configuration in `.serena/project.yml`
- TypeScript language server as closest match for Swift
- Enhanced semantic search and editing capabilities