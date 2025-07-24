# Design Document

## Overview

This design transforms Puchi into a visually polished, iOS-native experience that follows Apple Human Interface Guidelines while drawing inspiration from best-in-class apps like Tinder (media selection) and Journal (text/media integration). The enhancement focuses on visual hierarchy, sophisticated color design, engaging empty states, and premium UI patterns that make the app feel native and delightful.

## Architecture

### Design System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                 Puchi Design System                         │
├─────────────────────────────────────────────────────────────┤
│  Visual Foundation Layer                                    │
│  ├── Color System (Sophisticated palette + gradients)       │
│  ├── Typography System (iOS-native font hierarchy)         │
│  ├── Spacing System (8pt grid + iOS standards)             │
│  ├── Shadow & Elevation System (iOS depth principles)      │
│  └── Animation System (iOS timing curves)                  │
├─────────────────────────────────────────────────────────────┤
│  Component Library                                         │
│  ├── Enhanced Text Input (Journal-inspired)                │
│  ├── Media Picker System (Tinder-inspired)                 │
│  ├── Card Components (iOS-native styling)                  │
│  ├── Button System (Haptic + visual feedback)              │
│  └── Empty State Components (Engaging placeholders)        │
├─────────────────────────────────────────────────────────────┤
│  Layout System                                             │
│  ├── Responsive Grid System                                │
│  ├── Safe Area Management                                  │
│  ├── Dynamic Type Support                                  │
│  └── Accessibility Integration                             │
└─────────────────────────────────────────────────────────────┘
```

## Components and Interfaces

### 1. Enhanced Color System

#### Sophisticated Color Palette
```swift
// Primary Color System - Refined Pink Palette
struct PuchiColors {
    // Primary Brand Colors
    static let primary = Color(hex: "FF6B7A")        // Warm coral pink
    static let primaryLight = Color(hex: "FFB3BA")   // Light blush
    static let primaryDark = Color(hex: "E55A6B")    // Deep rose
    
    // Complementary Colors
    static let secondary = Color(hex: "7FCDCD")      // Soft teal (complementary)
    static let accent = Color(hex: "FFD93D")         // Warm gold
    static let success = Color(hex: "6BCF7F")        // Soft green
    
    // Neutral System (iOS-aligned)
    static let background = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let tertiaryBackground = Color(.tertiarySystemBackground)
    
    // Text Colors (iOS semantic)
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.tertiaryLabel)
    
    // Gradient System
    static let primaryGradient = LinearGradient(
        colors: [primary, primaryLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [Color(.systemBackground), primaryLight.opacity(0.05)],
        startPoint: .top,
        endPoint: .bottom
    )
}
```

#### Seasonal Color Variations
```swift
enum SeasonalTheme {
    case spring, summer, autumn, winter
    
    var primaryColor: Color {
        switch self {
        case .spring: return Color(hex: "FF8FA3")  // Cherry blossom
        case .summer: return Color(hex: "FF6B7A")  // Coral sunset
        case .autumn: return Color(hex: "D4756B")  // Warm terracotta
        case .winter: return Color(hex: "B85A7A")  // Deep rose
        }
    }
    
    var backgroundGradient: LinearGradient {
        // Subtle seasonal background variations
    }
}
```

### 2. Enhanced Typography System

#### iOS-Native Typography Hierarchy
```swift
struct PuchiTypography {
    // Headlines (iOS Large Title style)
    static let largeTitle = Font.system(.largeTitle, design: .rounded, weight: .bold)
    static let title1 = Font.system(.title, design: .rounded, weight: .semibold)
    static let title2 = Font.system(.title2, design: .rounded, weight: .semibold)
    
    // Body Text (Optimized for readability)
    static let body = Font.system(.body, design: .rounded, weight: .regular)
    static let bodyEmphasized = Font.system(.body, design: .rounded, weight: .medium)
    
    // UI Elements
    static let caption = Font.system(.caption, design: .rounded, weight: .medium)
    static let footnote = Font.system(.footnote, design: .rounded, weight: .regular)
    
    // Custom Love Note Typography
    static let loveNote = Font.system(size: 17, weight: .regular, design: .rounded)
        .leading(.relaxed) // Better line spacing for readability
}
```

### 3. Enhanced Text Input System (Journal-Inspired)

#### Engaging Empty State Design
```swift
struct EnhancedNoteInput: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    @State private var showingPlaceholder = true
    
    var body: some View {
        ZStack {
            // Background with subtle texture
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    ZStack {
                        // Base background
                        PuchiColors.secondaryBackground
                        
                        // Subtle texture overlay
                        if showingPlaceholder {
                            Image("paper_texture") // Subtle paper texture
                                .resizable()
                                .opacity(0.03)
                                .blendMode(.multiply)
                        }
                        
                        // Gradient overlay for warmth
                        PuchiColors.backgroundGradient
                            .opacity(0.3)
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isFocused ? PuchiColors.primary.opacity(0.5) : Color.clear,
                            lineWidth: 2
                        )
                        .animation(.easeInOut(duration: 0.2), value: isFocused)
                )
            
            // Enhanced placeholder system
            if text.isEmpty && !isFocused {
                EngagingPlaceholder()
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
            
            // Text editor with enhanced styling
            TextEditor(text: $text)
                .focused($isFocused)
                .font(PuchiTypography.loveNote)
                .foregroundColor(PuchiColors.textPrimary)
                .scrollContentBackground(.hidden)
                .padding(20)
                .onChange(of: text) { _, newValue in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingPlaceholder = newValue.isEmpty
                    }
                }
        }
        .frame(height: 280) // Optimized height
        .shadow(
            color: PuchiColors.primary.opacity(0.1),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}

struct EngagingPlaceholder: View {
    private let placeholderExamples = [
        "I love how you make me laugh every morning...",
        "Thank you for being my safe space...",
        "Your smile is my favorite part of every day...",
        "I'm grateful for the way you...",
        "You make ordinary moments feel magical..."
    ]
    
    @State private var currentExample = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Main placeholder text
            Text("Write something sweet for your love...")
                .font(PuchiTypography.body)
                .foregroundColor(PuchiColors.textTertiary)
            
            // Rotating example
            Text(placeholderExamples[currentExample])
                .font(PuchiTypography.loveNote)
                .foregroundColor(PuchiColors.primary.opacity(0.6))
                .italic()
                .transition(.opacity.combined(with: .slide))
            
            Spacer()
            
            // Writing tip
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(PuchiColors.accent)
                Text("Tip: Share a specific moment or feeling")
                    .font(PuchiTypography.caption)
                    .foregroundColor(PuchiColors.textSecondary)
            }
        }
        .padding(20)
        .onAppear {
            startExampleRotation()
        }
    }
    
    private func startExampleRotation() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentExample = (currentExample + 1) % placeholderExamples.count
            }
        }
    }
}
```

### 4. Tinder-Inspired Media Picker System

#### Enhanced Media Selection Interface
```swift
struct TinderInspiredMediaPicker: View {
    @Binding var selectedMedia: [MediaItem]
    @State private var showingPicker = false
    @State private var pickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        VStack(spacing: 16) {
            // Media selection buttons with Tinder-style design
            HStack(spacing: 20) {
                MediaActionButton(
                    icon: "photo.on.rectangle.angled",
                    title: "Photos",
                    color: PuchiColors.primary
                ) {
                    pickerSourceType = .photoLibrary
                    showingPicker = true
                }
                
                MediaActionButton(
                    icon: "camera.fill",
                    title: "Camera",
                    color: PuchiColors.secondary
                ) {
                    pickerSourceType = .camera
                    showingPicker = true
                }
                
                MediaActionButton(
                    icon: "video.fill",
                    title: "Video",
                    color: PuchiColors.accent
                ) {
                    // Video selection logic
                }
            }
            
            // Selected media preview grid
            if !selectedMedia.isEmpty {
                MediaPreviewGrid(
                    mediaItems: $selectedMedia,
                    onReorder: reorderMedia,
                    onRemove: removeMedia
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showingPicker) {
            EnhancedMediaPickerSheet(
                sourceType: pickerSourceType,
                selectedMedia: $selectedMedia
            )
        }
    }
}

struct MediaActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.impact(.medium)
            action()
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(PuchiTypography.caption)
                    .foregroundColor(PuchiColors.textSecondary)
            }
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: 0) { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }
    }
}
```

#### Media Preview Grid with Reordering
```swift
struct MediaPreviewGrid: View {
    @Binding var mediaItems: [MediaItem]
    let onReorder: (IndexSet, Int) -> Void
    let onRemove: (Int) -> Void
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(mediaItems.enumerated()), id: \.offset) { index, item in
                MediaPreviewCard(
                    mediaItem: item,
                    index: index,
                    onRemove: { onRemove(index) }
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 4)
    }
}

struct MediaPreviewCard: View {
    let mediaItem: MediaItem
    let index: Int
    let onRemove: () -> Void
    
    var body: some View {
        ZStack {
            // Media content
            AsyncImage(data: mediaItem.data) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(PuchiColors.tertiaryBackground)
                    .overlay(
                        ProgressView()
                            .tint(PuchiColors.primary)
                    )
            }
            .frame(height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Remove button (Tinder-style)
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        HapticManager.impact(.light)
                        withAnimation(.spring(response: 0.3)) {
                            onRemove()
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.6))
                                    .frame(width: 24, height: 24)
                            )
                    }
                    .padding(8)
                }
                Spacer()
            }
            
            // Media type indicator
            if mediaItem.type == .video {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.6))
                                    .frame(width: 20, height: 20)
                            )
                        Spacer()
                    }
                    .padding(8)
                }
            }
        }
        .shadow(
            color: Color.black.opacity(0.1),
            radius: 4,
            x: 0,
            y: 2
        )
    }
}
```

### 5. Enhanced Visual Hierarchy System

#### Card-Based Layout with Proper Depth
```swift
struct EnhancedCard: View {
    let content: AnyView
    let elevation: CardElevation
    
    var body: some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(PuchiColors.secondaryBackground)
                    .shadow(
                        color: elevation.shadowColor,
                        radius: elevation.shadowRadius,
                        x: 0,
                        y: elevation.shadowOffset
                    )
            )
    }
}

enum CardElevation {
    case low, medium, high
    
    var shadowColor: Color {
        switch self {
        case .low: return Color.black.opacity(0.05)
        case .medium: return Color.black.opacity(0.1)
        case .high: return Color.black.opacity(0.15)
        }
    }
    
    var shadowRadius: CGFloat {
        switch self {
        case .low: return 4
        case .medium: return 8
        case .high: return 16
        }
    }
    
    var shadowOffset: CGFloat {
        switch self {
        case .low: return 2
        case .medium: return 4
        case .high: return 8
        }
    }
}
```

### 6. iOS-Native Animation System

#### Standard iOS Timing Curves
```swift
struct PuchiAnimations {
    // iOS standard timing curves
    static let easeInOut = Animation.timingCurve(0.25, 0.1, 0.25, 1.0, duration: 0.3)
    static let spring = Animation.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)
    static let gentle = Animation.easeInOut(duration: 0.2)
    
    // Custom animations for specific interactions
    static let cardAppear = Animation.spring(response: 0.6, dampingFraction: 0.8)
    static let buttonPress = Animation.easeInOut(duration: 0.1)
    static let pageTransition = Animation.timingCurve(0.2, 0.0, 0.2, 1.0, duration: 0.4)
}

// Haptic feedback system
class HapticManager {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}
```

## User Interface Design Patterns

### Visual Design Principles

#### 1. Depth and Elevation
- **Card System**: Three-tier elevation system (low/medium/high)
- **Shadow Strategy**: Subtle shadows that enhance depth without overwhelming
- **Layering**: Clear visual hierarchy through proper z-index management

#### 2. Color Psychology Implementation
- **Primary Actions**: Warm coral pink for love-related actions
- **Secondary Actions**: Soft teal for supportive actions
- **Success States**: Gentle green for positive feedback
- **Warning States**: Warm amber for gentle alerts

#### 3. Typography Hierarchy
- **Large Title**: Partner name and main headings
- **Title 1**: Section headers (Today's Love Note)
- **Body**: Main content and input text
- **Caption**: Supporting information and hints

### Interaction Patterns

#### 1. Button Interactions
```swift
struct EnhancedButton: View {
    let title: String
    let style: ButtonStyle
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.impact(.medium)
            action()
        }) {
            Text(title)
                .font(style.font)
                .foregroundColor(style.textColor)
                .frame(maxWidth: .infinity)
                .frame(height: style.height)
                .background(style.background)
                .cornerRadius(style.cornerRadius)
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(PuchiAnimations.buttonPress, value: isPressed)
        .onLongPressGesture(minimumDuration: 0) { pressing in
            isPressed = pressing
        }
    }
}
```

#### 2. Micro-Interactions
- **Focus States**: Subtle border animations for text inputs
- **Loading States**: Elegant progress indicators
- **Success Feedback**: Satisfying completion animations
- **Error States**: Gentle shake animations for invalid inputs

## Accessibility Integration

### iOS Accessibility Standards
```swift
extension View {
    func puchiAccessibility(
        label: String,
        hint: String? = nil,
        value: String? = nil,
        traits: AccessibilityTraits = []
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityValue(value ?? "")
            .accessibilityAddTraits(traits)
    }
}
```

### Dynamic Type Support
- **Scalable Typography**: All text scales with iOS Dynamic Type
- **Flexible Layouts**: Layouts adapt to larger text sizes
- **Minimum Touch Targets**: 44pt minimum for all interactive elements

## Performance Optimization

### Efficient Rendering
- **Lazy Loading**: Media previews load on demand
- **View Recycling**: Efficient list and grid rendering
- **Animation Optimization**: 60fps animations with proper timing
- **Memory Management**: Proper cleanup of media resources

### Battery Efficiency
- **Reduced Motion**: Respect iOS reduce motion settings
- **Efficient Animations**: Use Core Animation for smooth performance
- **Background Processing**: Minimal background activity

## Implementation Guidelines

### Code Organization
```swift
// Design System Structure
PuchiDesignSystem/
├── Colors/
│   ├── PuchiColors.swift
│   └── SeasonalThemes.swift
├── Typography/
│   └── PuchiTypography.swift
├── Components/
│   ├── Cards/
│   ├── Buttons/
│   ├── TextInput/
│   └── MediaPicker/
├── Animations/
│   └── PuchiAnimations.swift
└── Extensions/
    ├── View+Accessibility.swift
    └── View+Styling.swift
```

### Quality Assurance
- **Design Review**: Regular design system consistency checks
- **Accessibility Testing**: VoiceOver and accessibility testing
- **Performance Testing**: Animation smoothness and memory usage
- **Device Testing**: Testing across different iOS devices and sizes