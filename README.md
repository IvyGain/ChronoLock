# ChronoLock

## Overview

ChronoLock is an innovative Apple Watch tactile adventure game that transforms lock-picking into an immersive, skill-based experience. Players use the Digital Crown and advanced haptic feedback to unlock treasure chests across three distinct lock types.

## Game Features

### 🔓 Lock Types
- **Pin Tumbler Locks**: Classic lock-picking with individual pin manipulation
- **Dial Combination Locks**: Rotary dial mechanics with precise timing
- **Rotary Puzzle Locks**: Multi-ring alignment challenges

### 🎯 Core Mechanics
- **Digital Crown Integration**: Precise control for all lock interactions
- **Advanced Haptics**: 100+ custom haptic patterns for tactile feedback
- **Heart Rate Integration**: Cursed chests react to player's heart rate
- **Location Discovery**: Find chests using CoreLocation
- **Idle Game Elements**: Chronicle Resonance Engine for offline progression

### 🏆 Progression System
- **Player Levels**: Experience-based progression with skill bonuses
- **Lock Mastery**: Specialized skill trees for each lock type
- **Achievements**: 18 achievements across 6 categories
- **Collection**: Rare, legendary, and special chest variants

### 🎵 Audio & Feedback
- **Procedural Audio**: Real-time sound generation with AVFoundation
- **Synchronized Feedback**: Haptic and audio coordination
- **Environmental Audio**: Dynamic soundscapes

### ⚡ Special Features
- **Cursed Chests**: Heart rate monitoring affects difficulty
- **Trapped Chests**: Time-limited challenges with failure consequences
- **Biometric Integration**: HealthKit for enhanced gameplay
- **Offline Rewards**: Passive progression through Resonance Engine

## Technical Architecture

### Platform
- **Primary**: watchOS (Apple Watch)
- **Companion**: iOS app for enhanced features
- **Minimum**: watchOS 10.0, iOS 17.0

### Frameworks
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for state management
- **WatchKit**: Hardware integration and Digital Crown
- **HealthKit**: Heart rate monitoring for cursed chests
- **CoreLocation**: Location-based treasure discovery
- **AVFoundation**: Procedural audio generation
- **App Groups**: Data sharing between Watch and iOS apps

### Architecture Pattern
- **MVVM-C**: Model-View-ViewModel with Coordinator pattern
- **Reactive Programming**: Combine publishers for state management
- **Service Layer**: Centralized managers for core functionality
- **Data Persistence**: UserDefaults with JSON encoding

## Core Services

### Game Data Management
- **GameDataManager**: Central data coordination
- **PlayerProfile**: Experience, levels, and progression
- **Inventory System**: Chest collection and unlocking

### Hardware Integration
- **HapticManager**: Custom haptic pattern engine
- **AudioManager**: Procedural sound generation
- **HealthKitManager**: Biometric monitoring
- **LocationManager**: GPS-based treasure discovery

### Game Systems
- **AchievementManager**: Progress tracking and notifications
- **ResonanceEngine**: Idle game mechanics
- **AppCoordinator**: Navigation and flow control

## Installation & Setup

### Prerequisites
- Xcode 15.0+
- Apple Watch (Series 6 or later recommended)
- iPhone running iOS 17.0+
- Apple Developer Account for device testing

### Build Instructions
1. Clone the repository
2. Open `ChronoLock.xcodeproj` in Xcode
3. Configure signing and provisioning
4. Build and run on paired Apple Watch
5. Grant required permissions (HealthKit, Location)

### Required Permissions
- **HealthKit**: Heart rate data for cursed chests
- **Location**: Treasure discovery and location-based features
- **Notifications**: Achievement and progress alerts

## Game Design Philosophy

ChronoLock emphasizes **tactile immersion** through:
- **Precision Control**: Digital Crown provides analog input precision
- **Haptic Storytelling**: Feedback conveys lock mechanics intuitively  
- **Progressive Mastery**: Skills develop through practice and repetition
- **Accessibility**: Visual, audio, and haptic feedback layers
- **Bite-sized Sessions**: Perfect for quick Apple Watch interactions

## Development Status

### Completed Features ✅
- Complete lock picking mechanics for all three lock types
- Advanced haptic feedback system with 100+ patterns
- Procedural audio generation and sound effects
- Achievement system with 18 unlockable achievements
- Heart rate integration for cursed chest mechanics
- Location-based treasure discovery
- Idle game progression system
- Complete UI/UX for watchOS
- Asset catalog and app icon structure

### Remaining Tasks 📋
- App Store metadata and screenshots
- Final testing and optimization
- App Store submission preparation

## Contributing

This project was developed as a comprehensive Apple Watch game demonstration. The codebase showcases advanced watchOS development techniques including:

- Complex Digital Crown interactions
- Custom haptic pattern design
- Procedural audio generation
- HealthKit and CoreLocation integration
- Reactive programming with Combine
- MVVM-C architecture implementation

## License

This project is a demonstration of advanced Apple Watch game development techniques. All code is provided for educational and reference purposes.

---

**Created with:** SwiftUI, Combine, WatchKit, HealthKit, CoreLocation, AVFoundation  
**Target Platform:** Apple Watch Series 6+, watchOS 10.0+  
**Development Tools:** Xcode 15.0+, Swift 5.9+
