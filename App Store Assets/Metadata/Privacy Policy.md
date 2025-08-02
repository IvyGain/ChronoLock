# ChronoLock Privacy Policy

**Effective Date:** [Current Date]
**Last Updated:** [Current Date]

## Overview

ChronoLock ("we," "our," or "the app") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our Apple Watch game application.

## Information We Collect

### Health Data
- **Heart Rate Information**: ChronoLock accesses your heart rate data through HealthKit to provide enhanced gameplay features for "cursed chests."
- **Usage**: Heart rate data is used exclusively to modify game difficulty in real-time and is never transmitted or stored outside your device.
- **Control**: You can disable heart rate monitoring at any time through the app settings or HealthKit permissions.

### Location Data
- **GPS Coordinates**: ChronoLock uses your location to discover nearby treasure chests and provide location-based gameplay.
- **Usage**: Location data is used to place virtual treasure chests in your real-world environment and track discovery progress.
- **Storage**: Location data is processed locally and only general area information is stored for gameplay purposes.

### Game Progress Data
- **Player Profile**: Experience points, levels, achievements, and game progression
- **Inventory**: Collected treasure chests and unlocked items
- **Settings**: User preferences and game configuration
- **Storage**: All game data is stored locally on your device and optionally synced via iCloud

## How We Use Your Information

### Gameplay Enhancement
- Heart rate data modifies difficulty for cursed chest challenges
- Location data enables treasure discovery and exploration features
- Game progress data maintains your advancement and achievements

### Performance Optimization
- Anonymous usage patterns help improve game balance and performance
- Crash reports and performance metrics (no personal data included)

## Data Sharing and Disclosure

### Third Parties
- **We do not sell, trade, or share your personal information with third parties**
- **We do not use third-party analytics or advertising services**
- **All data processing occurs locally on your device**

### Apple Services
- Game progress may be synced via iCloud if you choose to enable this feature
- Health and location data remain private to your device and are not synced

## Data Security

### Technical Safeguards
- All sensitive data is encrypted using iOS security frameworks
- Health data is accessed through Apple's secure HealthKit framework
- Location data is processed using Apple's CoreLocation privacy protections
- No personal data is transmitted over the internet

### Access Controls
- You control all permissions for health and location data access
- Permissions can be revoked at any time through iOS Settings
- Game data is sandboxed and isolated from other applications

## Your Rights and Choices

### Data Control
- **Access**: View all your game data through the app interface
- **Correction**: Modify or reset your game progress at any time
- **Deletion**: Delete all game data by uninstalling the application
- **Portability**: Export game progress through iCloud backup

### Permission Management
- **Health Data**: Disable heart rate monitoring in HealthKit settings
- **Location Data**: Revoke location permissions in iOS Privacy settings
- **iCloud Sync**: Control game data syncing through iCloud settings

## Children's Privacy

ChronoLock is rated 9+ and may be used by children. We do not knowingly collect personal information from children under 13. If we discover that a child under 13 has provided us with personal information, we will delete such information immediately.

## Changes to This Policy

We may update this Privacy Policy periodically. When we make changes:
- The updated policy will be posted within the app
- The "Last Updated" date will be revised
- Significant changes will be highlighted in app update notes

## Contact Information

If you have questions about this Privacy Policy or our privacy practices:

- **GitHub Issues**: https://github.com/IvyGain/ChronoLock/issues
- **Project Repository**: https://github.com/IvyGain/ChronoLock

## Compliance

This privacy policy complies with:
- Apple App Store Review Guidelines
- iOS Privacy Requirements
- HealthKit Privacy Guidelines
- CoreLocation Privacy Best Practices
- General Data Protection Regulation (GDPR) principles
- California Consumer Privacy Act (CCPA) requirements

## Technical Implementation

### HealthKit Integration
```swift
// Heart rate data is accessed read-only and processed locally
let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)
// Data is never stored permanently or transmitted
```

### Location Privacy
```swift
// Location access is purpose-limited and privacy-preserving
manager.requestWhenInUseAuthorization()
// Only general vicinity is used for gameplay features
```

### Data Minimization
- We collect only the minimum data necessary for gameplay features
- All processing occurs on-device to maximize privacy
- No personal identifiers or tracking mechanisms are implemented

---

**Your privacy is important to us. ChronoLock is designed with privacy-by-design principles, ensuring your personal information remains secure and under your control.**