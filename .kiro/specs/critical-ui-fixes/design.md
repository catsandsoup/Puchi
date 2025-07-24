# Design Document

## Overview

This design addresses critical usability issues in the Puchi app that are preventing users from having a smooth experience. The fixes focus on immediate UI/UX problems including location management, media handling, navigation, layout optimization, and essential app management features. The design maintains the existing romantic aesthetic while solving fundamental interaction problems.

## Architecture

### Current Architecture Analysis

The app currently uses:
- **SwiftUI** for UI with TabView-based navigation
- **LoveJournalViewModel** as the main data controller
- **UserDefaults** for data persistence
- **CoreLocation** for location services
- **UIImagePickerController** wrapped in UIViewControllerRepresentable for media

### Enhanced Architecture for Fixes

```
┌─────────────────────────────────────────────────────────────┐
│                    Enhanced Puchi App                       │
├─────────────────────────────────────────────────────────────┤
│  UI Layer (SwiftUI) - Enhanced                              │
│  ├── MainTabView (Enhanced with gesture navigation)         │
│  ├── MainContent (Fixed layout and media handling)          │
│  ├── Enhanced MediaPicker (Multiple selection support)      │
│  ├── Enhanced LocationButton (Removable location)           │
│  ├── Accessible SettingsView (From main interface)          │
│  └── Responsive Layout System (No scrolling required)       │
├─────────────────────────────────────────────────────────────┤
│  Enhanced Business Logic Layer                              │
│  ├── Enhanced LoveJournalViewModel (Multi-media support)    │
│  ├── LocationManager (Enhanced with removal capability)     │
│  ├── MediaManager (Multiple items, video support)           │
│  ├── SettingsManager (App reset, partner name changes)     │
│  └── NavigationManager (Gesture-based navigation)           │
├─────────────────────────────────────────────────────────────┤
│  Enhanced Services Layer                                    │
│  ├── Enhanced Media Service (Multiple selection, video)     │
│  ├── Enhanced Location Service (Add/remove capability)      │
│  ├── Settings Service (Reset functionality)                │
│  └── Error Handling Service (Graceful degradation)         │
└─────────────────────────────────────────────────────────────┘
```

## Components and Interfaces

### 1. Enhanced Location Management

#### Current Issue
- Location button shows "Added" state but cannot be removed
- No visual feedback for location removal
- Location persists even when user wants to remove it

#### Design Solution
```swift
// Enhanced LocationButton with removal capability
struct EnhancedLocationButton: View {
    @Binding var currentLocation: LocationData?
    let onLocationRequest: () -> Void
    let onLocationRemove: () -> Void
    
    var body: some View {
        Button(action: {
            if currentLocation == nil {
                onLocationRequest()
            } else {
                // Show removal confirmation or directly remove
                onLocationRemove()
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: currentLocation == nil ? "location" : "location.fill")
                    .font(.system(size: 20, weight: .medium))
                Text(currentLocation == nil ? "Location" : "Remove")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .foregroundColor(currentLocation == nil ? .puchiPrimary : .red)
    }
}

// Enhanced location display with removal option
struct LocationDisplayView: View {
    let location: LocationData
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "location.fill")
                .foregroundColor(.puchiPrimary)
            Text(location.placeName)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.textSecondary)
            Spacer()
            Button("Remove", action: onRemove)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.red)
        }
        .padding(.horizontal)
        .transition(.opacity)
    }
}
```

### 2. Enhanced Media Management

#### Current Issue
- Only single image selection supported
- No video support in practice
- No way to remove selected media
- Poor media preview system

#### Design Solution
```swift
// Enhanced MediaManager for multiple items
class MediaManager: ObservableObject {
    @Published var selectedMedia: [MediaItem] = []
    @Published var isShowingPicker = false
    
    func addMedia(_ items: [MediaItem]) {
        selectedMedia.append(contentsOf: items)
    }
    
    func removeMedia(at index: Int) {
        selectedMedia.remove(at: index)
    }
    
    func clearAllMedia() {
        selectedMedia.removeAll()
    }
}

// Enhanced MediaPicker with multiple selection
struct EnhancedMediaPicker: UIViewControllerRepresentable {
    @Binding var selectedMedia: [MediaItem]
    let allowsMultipleSelection: Bool
    let mediaTypes: [String] // ["public.image", "public.movie"]
    
    // Implementation supports PHPickerViewController for multiple selection
    // and UIImagePickerController for camera capture
}

// Enhanced MediaPreview with removal capability
struct MediaPreviewGrid: View {
    @Binding var mediaItems: [MediaItem]
    let onRemove: (Int) -> Void
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
            ForEach(Array(mediaItems.enumerated()), id: \.offset) { index, item in
                MediaPreviewCard(
                    mediaItem: item,
                    onRemove: { onRemove(index) }
                )
            }
        }
    }
}
```

### 3. Responsive Layout System

#### Current Issue
- Save button gets pushed below fold on smaller screens
- Requires scrolling to access essential controls
- Poor keyboard handling

#### Design Solution
```swift
// Enhanced MainContent with responsive layout
struct ResponsiveMainContent: View {
    // ... existing properties
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Fixed header section
                HeaderSection()
                    .frame(height: geometry.size.height * 0.25)
                
                // Flexible content area
                ScrollView {
                    ContentSection()
                        .frame(minHeight: geometry.size.height * 0.6)
                }
                
                // Fixed bottom controls
                BottomControlsSection()
                    .frame(height: 120)
                    .background(Color.puchiBackground)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

// Keyboard-aware layout adjustments
struct KeyboardAwareModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                    keyboardHeight = keyboardFrame.cgRectValue.height
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                keyboardHeight = 0
            }
    }
}
```

### 4. Enhanced Navigation System

#### Current Issue
- No swipe navigation between tabs
- Users expect gesture-based navigation
- Tab indicators not visible

#### Design Solution
```swift
// Enhanced MainTabView with gesture navigation
struct EnhancedMainTabView: View {
    @Binding var currentPage: Int
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Page 0: Note Creation
                MainContent(...)
                    .frame(width: geometry.size.width)
                
                // Page 1: Timeline/History
                TimelinePage(...)
                    .frame(width: geometry.size.width)
            }
            .offset(x: -CGFloat(currentPage) * geometry.size.width + dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.x
                    }
                    .onEnded { value in
                        let threshold = geometry.size.width * 0.25
                        
                        if value.translation.x > threshold && currentPage > 0 {
                            withAnimation(.spring()) {
                                currentPage -= 1
                            }
                        } else if value.translation.x < -threshold && currentPage < 1 {
                            withAnimation(.spring()) {
                                currentPage += 1
                            }
                        }
                        
                        withAnimation(.spring()) {
                            dragOffset = 0
                        }
                    }
            )
        }
        .overlay(
            // Page indicators
            PageIndicatorView(currentPage: currentPage, totalPages: 2),
            alignment: .bottom
        )
    }
}

// Custom page indicator
struct PageIndicatorView: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.puchiPrimary : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.bottom, 20)
    }
}
```

### 5. Enhanced Settings Integration

#### Current Issue
- Settings not easily accessible from main interface
- No clear way to access app management features
- Settings view exists but not integrated into main flow

#### Design Solution
```swift
// Settings button integration in main interface
struct MainContentWithSettings: View {
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            MainContent(...)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.puchiPrimary)
                        }
                    }
                }
                .sheet(isPresented: $showingSettings) {
                    EnhancedSettingsView()
                }
        }
    }
}

// Enhanced SettingsView with better reset functionality
struct EnhancedSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: LoveJournalViewModel
    
    var body: some View {
        NavigationStack {
            SettingsContent(viewModel: viewModel)
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
        }
    }
}
```

## Data Models

### Enhanced Media Handling
```swift
// Enhanced MediaItem with better type support
struct MediaItem: Codable, Identifiable {
    let id: UUID
    let data: Data
    let type: MediaType
    let filename: String
    let createdDate: Date
    
    init(data: Data, type: MediaType, filename: String = "") {
        self.id = UUID()
        self.data = data
        self.type = type
        self.filename = filename.isEmpty ? "\(type.rawValue)_\(UUID().uuidString)" : filename
        self.createdDate = Date()
    }
}

// Enhanced MediaType with video support
enum MediaType: String, Codable, CaseIterable {
    case image = "image"
    case video = "video"
    
    var systemImage: String {
        switch self {
        case .image: return "photo.fill"
        case .video: return "video.fill"
        }
    }
    
    var fileExtension: String {
        switch self {
        case .image: return "jpg"
        case .video: return "mp4"
        }
    }
}
```

### Enhanced LoveNote Model
```swift
// Enhanced LoveNote with better media support
extension LoveNote {
    var allMediaItems: [MediaItem] {
        var items: [MediaItem] = []
        if let images = images { items.append(contentsOf: images) }
        if let videos = videos { items.append(contentsOf: videos) }
        return items.sorted { $0.createdDate < $1.createdDate }
    }
    
    var hasMedia: Bool {
        return !(images?.isEmpty ?? true) || !(videos?.isEmpty ?? true)
    }
    
    var mediaCount: Int {
        return (images?.count ?? 0) + (videos?.count ?? 0)
    }
}
```

## Error Handling

### Location Error Handling
```swift
enum LocationError: LocalizedError {
    case permissionDenied
    case locationUnavailable
    case geocodingFailed
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location access denied. Please enable location services in Settings."
        case .locationUnavailable:
            return "Unable to determine current location. Please try again."
        case .geocodingFailed:
            return "Unable to determine location name. Location coordinates saved."
        }
    }
}
```

### Media Error Handling
```swift
enum MediaError: LocalizedError {
    case selectionCancelled
    case compressionFailed
    case unsupportedFormat
    case storageFull
    
    var errorDescription: String? {
        switch self {
        case .selectionCancelled:
            return "Media selection was cancelled."
        case .compressionFailed:
            return "Failed to process selected media. Please try again."
        case .unsupportedFormat:
            return "Selected media format is not supported."
        case .storageFull:
            return "Not enough storage space for selected media."
        }
    }
}
```

## User Interface Design Patterns

### Visual Feedback System
- **Location States**: Clear visual distinction between "add", "added", and "remove" states
- **Media States**: Visual indicators for different media types and removal options
- **Navigation Feedback**: Smooth animations and haptic feedback for swipe gestures
- **Loading States**: Appropriate loading indicators for async operations

### Interaction Patterns
- **Tap to Toggle**: Location button toggles between add/remove functionality
- **Long Press Options**: Alternative interaction for advanced options
- **Swipe Navigation**: Horizontal swipes for page navigation
- **Pull to Refresh**: Standard iOS patterns where applicable

### Accessibility Enhancements
- **VoiceOver Labels**: Clear descriptions for all interactive elements
- **Dynamic Type**: Support for larger text sizes
- **High Contrast**: Ensure visibility in accessibility modes
- **Haptic Feedback**: Consistent haptic responses for interactions

## Performance Considerations

### Media Optimization
- **Image Compression**: Automatic compression for storage efficiency
- **Video Compression**: Appropriate quality settings for mobile storage
- **Lazy Loading**: Load media previews on demand
- **Memory Management**: Proper cleanup of media resources

### Layout Performance
- **Responsive Design**: Efficient layout calculations
- **Gesture Recognition**: Optimized gesture handling
- **Animation Performance**: 60fps animations with proper timing
- **Memory Usage**: Efficient view recycling and cleanup

## Security and Privacy

### Media Privacy
- **Local Storage**: All media stored locally on device
- **Permission Handling**: Proper photo library and camera permissions
- **Data Cleanup**: Secure deletion when removing media

### Location Privacy
- **Minimal Data**: Only store necessary location information
- **User Control**: Easy removal of location data
- **Permission Respect**: Honor user location preferences

## Testing Strategy

### Unit Testing
- **Media Management**: Test multiple media selection and removal
- **Location Services**: Test location add/remove functionality
- **Settings Management**: Test app reset and partner name changes
- **Navigation Logic**: Test gesture-based navigation

### UI Testing
- **Responsive Layout**: Test on different screen sizes
- **Gesture Navigation**: Test swipe interactions
- **Media Selection**: Test photo and video selection flows
- **Settings Integration**: Test settings access and functionality

### Integration Testing
- **End-to-End Flows**: Complete note creation with media and location
- **Error Scenarios**: Test error handling and recovery
- **Performance Testing**: Test with multiple media items
- **Accessibility Testing**: Test with assistive technologies

## Implementation Priority

### Phase 1: Critical Fixes
1. **Location Removal**: Fix location button to allow removal
2. **Layout Responsiveness**: Ensure save button is always accessible
3. **Settings Access**: Add settings button to main interface

### Phase 2: Enhanced Media
1. **Multiple Media Selection**: Support multiple photos and videos
2. **Media Preview Grid**: Show all selected media with removal options
3. **Video Support**: Proper video handling and compression

### Phase 3: Navigation Enhancement
1. **Swipe Navigation**: Implement gesture-based page switching
2. **Page Indicators**: Add visual navigation feedback
3. **Animation Polish**: Smooth transitions and haptic feedback

### Phase 4: Polish and Testing
1. **Error Handling**: Comprehensive error states and recovery
2. **Performance Optimization**: Memory and battery efficiency
3. **Accessibility**: Full VoiceOver and accessibility support
4. **Testing**: Comprehensive test coverage