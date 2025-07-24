# Design Document

## Overview

The Relationship Timeline Enhancement transforms Puchi into a comprehensive relationship journey platform while preserving its elegant, romantic aesthetic. The design introduces three new core sections (Timeline, Milestones, Goals) alongside the existing Love Notes functionality, creating a cohesive ecosystem for couples to document, celebrate, and plan their relationship journey.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Puchi Enhanced App                        │
├─────────────────────────────────────────────────────────────┤
│  UI Layer (SwiftUI)                                         │
│  ├── TabView Navigation (2 tabs)                            │
│  ├── Enhanced Create Notes View                             │
│  │   ├── Smart Suggestions Component                       │
│  │   ├── Milestone Connection Indicators                   │
│  │   └── Goal Progress Prompts                             │
│  └── Enhanced Timeline View                                 │
│      ├── Timeline Spine Component                           │
│      ├── Integrated Milestone Markers                      │
│      ├── Goal Progress Overlays                            │
│      └── Advanced Search & Filter                          │
├─────────────────────────────────────────────────────────────┤
│  Business Logic Layer                                       │
│  ├── Enhanced LoveJournalViewModel                          │
│  ├── TimelineIntegrationManager                            │
│  ├── MilestoneTrackingService                              │
│  ├── GoalProgressService                                    │
│  └── NotificationManager                                    │
├─────────────────────────────────────────────────────────────┤
│  Data Layer                                                 │
│  ├── CoreData Stack (replacing UserDefaults)               │
│  ├── CloudKit Integration                                   │
│  ├── Local Backup Manager                                   │
│  └── Export/Import Manager                                  │
├─────────────────────────────────────────────────────────────┤
│  Services Layer                                             │
│  ├── Notification Service                                   │
│  ├── Search Service                                         │
│  ├── Sharing Service                                        │
│  └── Analytics Service (Privacy-focused)                   │
└─────────────────────────────────────────────────────────────┘
```

### Navigation Structure

The app will maintain its existing 2-tab structure with enhanced functionality:

1. **Create Notes** - Enhanced love note creation with smart features, milestone connections, and goal prompts
2. **View Notes** - Timeline-based note viewing with integrated milestones, goals, and advanced organization

## Components and Interfaces

### Core Data Models

```swift
// Enhanced LoveNote with integrated milestone and goal relationships
struct LoveNote: Identifiable, Codable {
    let id: UUID
    let text: String
    let partnerName: String
    let date: Date
    let noteNumber: Int
    var images: [MediaItem]?
    var videos: [MediaItem]?
    var location: LocationData?
    var tags: [String]
    var relatedMilestoneId: UUID?
    var relatedGoalId: UUID?
    var isFavorite: Bool
    var celebratesGoalCompletion: Bool
    var celebratesMilestone: Bool
}

// Milestone model (integrated into timeline)
struct Milestone: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let date: Date
    let category: MilestoneCategory
    let isCustom: Bool
    var images: [MediaItem]?
    var commemorativeNoteId: UUID?
    var notificationSettings: NotificationSettings
    var celebrationStatus: CelebrationStatus
    var timelinePosition: TimelinePosition // For timeline integration
}

// Goal model (progress tracked through timeline)
struct Goal: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let createdDate: Date
    let targetDate: Date?
    let category: GoalCategory
    let status: GoalStatus
    var progress: Double // 0.0 to 1.0
    var milestones: [GoalMilestone]
    var relatedNotes: [UUID]
    var timelineVisibility: TimelineVisibility // How it appears in timeline
}

// Unified timeline entry for integrated display
struct TimelineEntry: Identifiable {
    let id: UUID
    let date: Date
    let type: TimelineEntryType // note, milestone, goal_progress, celebration
    let primaryContent: LoveNote? // Main note content
    let milestoneContent: Milestone? // Associated milestone
    let goalContent: Goal? // Associated goal
    let importance: ImportanceLevel
    let celebrationType: CelebrationType?
}
```

### Key View Components

#### 1. Enhanced Create Notes Tab
- **Larger text input area** with improved keyboard handling
- **Smart tag suggestions** based on content analysis and recent milestones
- **Milestone connection indicators** showing relevant upcoming or recent milestones
- **Goal-related prompts** suggesting note templates based on active goals
- **Improved media handling** with better preview and organization
- **Location integration** with proper permission handling
- **Contextual suggestions** for anniversaries, goal progress, or milestone celebrations

#### 2. Enhanced View Notes Tab (Timeline-Based)
- **Timeline as primary view** replacing simple list with chronological visualization
- **Infinite scroll timeline** with lazy loading and smooth performance
- **Visual timeline spine** with connecting lines between entries
- **Integrated milestone markers** showing milestones directly on the timeline
- **Goal progress indicators** embedded within relevant time periods
- **Time period headers** (months/years) for easy navigation
- **Advanced search and filtering** with real-time results across all content
- **Smart grouping** by themes, milestones, or importance levels
- **Celebration overlays** for milestone achievements and goal completions

### User Interface Design Patterns

#### Visual Hierarchy
- **Primary Pink (#FF5A5F)** - Main actions, active states, love-related content, timeline spine
- **Secondary Pink (#FFB3B5)** - Milestone markers, celebrations, timeline highlights
- **Accent Gold (#FFD700)** - Goal progress indicators, achievements, special moments
- **Neutral Grays** - Supporting text, backgrounds, inactive states, timeline periods
- **Success Green (#4CAF50)** - Completed goals, positive progress, achievement celebrations
- **Warning Amber (#FFC107)** - Upcoming milestones, goal deadlines, gentle reminders

#### Card Design System
- **Love Note Cards** - Rounded corners, soft shadows, pink accents with milestone/goal connection indicators
- **Timeline Entry Cards** - Unified design for notes with embedded milestone and goal information
- **Milestone Markers** - Compact timeline indicators with celebration elements
- **Goal Progress Overlays** - Subtle progress indicators integrated into relevant timeline periods

#### Animation Strategy
- **Celebration animations** for milestone achievements integrated into timeline
- **Progress animations** for goal updates shown as timeline overlays
- **Timeline scroll animations** with smooth parallax effects and milestone reveals
- **Tab transition animations** maintaining context between create and view modes
- **Haptic feedback** synchronized with visual feedback across both tabs
- **Micro-interactions** for milestone connections and goal progress updates

## Data Models

### Core Data Schema

```swift
// CoreData Entities
@Model
class LoveNoteEntity {
    @Attribute(.unique) var id: UUID
    var text: String
    var date: Date
    var noteNumber: Int
    var tags: [String]
    var isFavorite: Bool
    
    // Relationships
    @Relationship var milestone: MilestoneEntity?
    @Relationship var goal: GoalEntity?
    @Relationship var mediaItems: [MediaItemEntity]
}

@Model
class MilestoneEntity {
    @Attribute(.unique) var id: UUID
    var title: String
    var description: String
    var date: Date
    var category: String
    var isCustom: Bool
    var celebrationStatus: String
    
    // Relationships
    @Relationship var commemorativeNote: LoveNoteEntity?
    @Relationship var mediaItems: [MediaItemEntity]
}

@Model
class GoalEntity {
    @Attribute(.unique) var id: UUID
    var title: String
    var description: String
    var createdDate: Date
    var targetDate: Date?
    var status: String
    var progress: Double
    
    // Relationships
    @Relationship var relatedNotes: [LoveNoteEntity]
    @Relationship var milestones: [GoalMilestoneEntity]
}
```

### CloudKit Integration
- **Private database** for user data security
- **Automatic sync** with conflict resolution
- **Offline-first approach** with local caching
- **Incremental sync** for performance optimization

## Error Handling

### Error Categories
1. **Network Errors** - CloudKit sync failures, connectivity issues
2. **Data Errors** - Corruption, migration failures, validation errors
3. **Permission Errors** - Location, notifications, photo access
4. **Storage Errors** - Disk space, backup failures
5. **User Input Errors** - Invalid dates, empty required fields

### Error Recovery Strategies
- **Graceful degradation** - App functions offline when sync fails
- **Automatic retry** with exponential backoff for network operations
- **User-friendly error messages** with actionable solutions
- **Data recovery options** from local backups
- **Error reporting** (privacy-compliant) for debugging

## Testing Strategy

### Unit Testing
- **ViewModel logic** testing with mock data
- **Data model validation** and relationships
- **Business logic** for streaks, milestones, goals
- **Date calculations** and timeline generation
- **Search and filtering** functionality

### Integration Testing
- **CoreData operations** with real database
- **CloudKit sync** scenarios and conflict resolution
- **Notification scheduling** and delivery
- **Export/import** functionality
- **Cross-view navigation** and state management

### UI Testing
- **Navigation flows** between all tabs
- **Timeline scrolling** and performance
- **Form validation** and error states
- **Accessibility** compliance testing
- **Device rotation** and size adaptation

### Performance Testing
- **Large dataset handling** (1000+ entries)
- **Memory usage** during timeline scrolling
- **Battery impact** of background sync
- **App launch time** with existing data
- **Animation smoothness** under load

## Security Considerations

### Data Protection
- **End-to-end encryption** for CloudKit data
- **Local data encryption** using iOS keychain
- **Secure deletion** of sensitive content
- **Privacy-first design** with minimal data collection
- **User consent** for all data usage

### Access Control
- **Biometric authentication** for app access (optional)
- **Secure sharing** with privacy controls
- **Data export** with user verification
- **Account recovery** without data loss
- **Multi-device** secure synchronization

## Accessibility

### VoiceOver Support
- **Semantic labels** for all UI elements
- **Navigation hints** for complex interactions
- **Content descriptions** for images and media
- **Action descriptions** for buttons and gestures
- **Reading order** optimization for screen readers

### Visual Accessibility
- **Dynamic Type** support for text scaling
- **High contrast** mode compatibility
- **Color blind** friendly design choices
- **Reduced motion** options for animations
- **Focus indicators** for keyboard navigation

## Performance Optimization

### Memory Management
- **Lazy loading** for timeline entries
- **Image caching** with automatic cleanup
- **View recycling** for large lists
- **Background processing** for data operations
- **Memory warnings** handling

### Battery Optimization
- **Efficient sync** scheduling
- **Background app refresh** optimization
- **Location services** minimal usage
- **Animation optimization** for 60fps
- **Network request** batching and caching