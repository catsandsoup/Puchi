# Puchi - Couples Journal App

A comprehensive iOS journal app inspired by Apple Journal, built in SwiftUI with a focus on couples journaling and personal reflection.

## 🚀 Build & Development

### Prerequisites
- Xcode 16+ 
- iOS 17.6+ deployment target
- iPhone 16 iOS 18.5 Simulator (recommended for testing)

### Quick Build
```bash
./scripts/build.sh
```

### Manual Build Commands
```bash
# Clean build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild clean -project Puchi.xcodeproj -scheme Puchi

# Build for simulator
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project Puchi.xcodeproj -scheme Puchi -destination "platform=iOS Simulator,name=iPhone 16,OS=18.5" build

# Build for device (Release)
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project Puchi.xcodeproj -scheme Puchi -destination "generic/platform=iOS" -configuration Release build
```

## 📱 App Store Release Process

1. **Build & Test**: Run `./scripts/build.sh` to ensure clean builds
2. **Archive**: Product → Archive in Xcode
3. **Validate**: Use Organizer to validate the archive
4. **Distribute**: Upload to App Store Connect
5. **Review**: Submit for App Store review

## 🏗️ Architecture

- **Framework**: SwiftUI + @Observable pattern
- **Data Storage**: JSON with UserDefaults, file storage for media
- **State Management**: Centralized AppState class
- **Theme**: Pink/purple romantic aesthetic with light/dark mode

## 📂 Key Files

- `PuchiApp.swift` - Main app entry point and data models
- `TimelineView.swift` - Main journal timeline interface
- `EntryComposerView.swift` - Journal entry creation
- `SimpleRichTextEditor.swift` - Rich text formatting system

## ✨ Features

### Core Functionality
- Rich journal entries with multimedia support
- Voice recording and playback
- Photo and media attachment
- Location services with Apple Journal-style picker
- Advanced search and filtering
- Rich text formatting (Bold, Italic, Underline)

### User Experience
- Beautiful pink/beige romantic theme
- Light and dark mode support
- Smooth animations and micro-interactions
- Accessibility compliance (VoiceOver, Dynamic Type)
- Couples-focused journaling prompts

### Data & Privacy
- Local data storage with JSON persistence
- File-based storage for large media items
- Comprehensive search across all entries
- Export and sharing capabilities

## 🔧 Development Notes

- Target user: Female, 18-30, values memory safety and aesthetic polish
- Build with iPhone 16 simulator for primary testing
- Test on physical device for hardware features (Face ID, GPS, etc.)
- Follow established SwiftUI patterns and pink/beige design system

## 📋 Current Status

See `claudeacceptance.md` for detailed implementation status and acceptance criteria.

**Next Priority**: Recently Deleted View with immediate delete option for sensitive entries.

## 🐛 Troubleshooting

- **Rich Text Issues**: See `SimpleRichTextEditor.swift:4-41` for debugging guide
- **Build Failures**: Ensure Xcode Command Line Tools are installed: `xcode-select --install`
- **Simulator Issues**: Reset simulator if experiencing persistent crashes

## 📱 System Requirements

- iOS 17.6+ deployment target
- iPhone and iPod touch support
- Optimized for iOS 18.5

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

Made with ❤️ for couples everywhere
