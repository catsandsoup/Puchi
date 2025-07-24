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
│  ├── TabView Navigation (4 tabs)                            │
│  ├── Timeline View                                          │
│  ├── Milestones View                                        │
│  ├── Goals View                                             │
│  └── Enhanced Love Notes View                               │
├─────────────────────────────────────────────────────────────┤
│  Business Logic Layer                                       │
│  ├── TimelineViewModel                                      │
│  ├── MilestonesViewModel                                    │
│  ├── GoalsViewModel                                         │
│  ├── Enhanced LoveJournalViewModel                          │
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

The app will transition from a 2-tab to a 4-tab structure:

1. **Timeline** - Chronological view of all relationship content
2. **Notes** - Enhanced love note creation (existing functionality)
3. **Milestones** - Milestone tracking and celebration
4. **Goals** - Relationship goal setting and progress

## Components and Interfaces

### Core Data Models

```swift
// Enhanced LoveNote with relationships
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
}

// New Milestone model
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
}

// New Goal model
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
}

// Timeline entry wrapper
struct TimelineEntry: Identifiable {
    let id: UUID
    let date: Date
    let type: TimelineEntryType
    let content: TimelineContent
    let importance: ImportanceLevel
}
```

### Key View Components

#### 1. Timeline View
- **Infinite scroll timeline** with lazy loading
- **Visual timeline spine** with connecting lines
- **Entry cards** with type-specific styling
- **Time period headers** (months/years)
- **Filter and search bar** at top
- **Zoom controls** for different time scales

#### 2. Enhanced Notes View
- **Larger text input area** (addressing current UI issue)
- **Smart tag suggestions** based on content analysis
- **Milestone/goal connection indicators**
- **Template suggestions** based on context
- **Improved media handling** with better preview

#### 3. Milestones View
- **Upcoming milestones carousel** at top
- **Calendar integration** with milestone markers
- **Category-based organization** (Anniversary, First Times, Achievements, Custom)
- **Celebration center** for completed milestones
- **Quick milestone creation** with templates

#### 4. Goals View
- **Active goals dashboard** with progress rings
- **Goal categories** (Relationship, Personal Growth, Shared Experiences, Future Plans)
- **Progress tracking interface** with visual indicators
- **Achievement celebrations** when goals are completed
- **Goal templates** for common relationship objectives

### User Interface Design Patterns

#### Visual Hierarchy
- **Primary Pink (#FF5A5F)** - Main actions, active states, love-related content
- **Secondary Pink (#FFB3B5)** - Milestones, celebrations, highlights
- **Accent Gold (#FFD700)** - Goals, achievements, special moments
- **Neutral Grays** - Supporting text, backgrounds, inactive states
- **Success Green (#4CAF50)** - Completed goals, positive progress
- **Warning Amber (#FFC107)** - Upcoming deadlines, attention needed

#### Card Design System
- **Love Note Cards** - Rounded corners, soft shadows, pink accents
- **Milestone Cards** - Elevated design with celebration elements
- **Goal Cards** - Progress indicators, achievement badges
- **Timeline Cards** - Compact design with connection lines

#### Animation Strategy
- **Celebration animations** for milestone achievements
- **Progress animations** for goal updates
- **Timeline scroll animations** with parallax effects
- **Haptic feedback** synchronized with visual feedback
- **Micro-interactions** for all user actions

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