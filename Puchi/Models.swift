import SwiftUI
import CoreLocation

// MARK: - Enums
enum MilestoneCategory: String, Codable, CaseIterable {
    case anniversary = "Anniversary"
    case firstTime = "First Time"
    case achievement = "Achievement"
    case custom = "Custom"
    
    var displayName: String {
        return self.rawValue
    }
    
    var systemImage: String {
        switch self {
        case .anniversary:
            return "heart.circle.fill"
        case .firstTime:
            return "star.circle.fill"
        case .achievement:
            return "trophy.circle.fill"
        case .custom:
            return "circle.fill"
        }
    }
}

enum GoalCategory: String, Codable, CaseIterable {
    case relationship = "Relationship"
    case personalGrowth = "Personal Growth"
    case sharedExperience = "Shared Experience"
    case futurePlans = "Future Plans"
    
    var displayName: String {
        return self.rawValue
    }
    
    var systemImage: String {
        switch self {
        case .relationship:
            return "heart.fill"
        case .personalGrowth:
            return "person.fill"
        case .sharedExperience:
            return "person.2.fill"
        case .futurePlans:
            return "calendar.badge.plus"
        }
    }
}

// MARK: - Models
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
    
    var dateFormatted: String {
        date.formatted(date: .abbreviated, time: .shortened)
    }
    
    // MARK: - Initializers
    init(id: UUID = UUID(), text: String, partnerName: String, date: Date, noteNumber: Int, 
         images: [MediaItem]? = nil, videos: [MediaItem]? = nil, location: LocationData? = nil,
         tags: [String] = [], relatedMilestoneId: UUID? = nil, relatedGoalId: UUID? = nil, 
         isFavorite: Bool = false) {
        self.id = id
        self.text = text
        self.partnerName = partnerName
        self.date = date
        self.noteNumber = noteNumber
        self.images = images
        self.videos = videos
        self.location = location
        self.tags = tags
        self.relatedMilestoneId = relatedMilestoneId
        self.relatedGoalId = relatedGoalId
        self.isFavorite = isFavorite
    }
    
    // MARK: - Relationship Helpers
    var hasRelatedMilestone: Bool {
        return relatedMilestoneId != nil
    }
    
    var hasRelatedGoal: Bool {
        return relatedGoalId != nil
    }
    
    var hasRelationships: Bool {
        return hasRelatedMilestone || hasRelatedGoal
    }
    
    // MARK: - Tag Helpers
    func hasTag(_ tag: String) -> Bool {
        return tags.contains(tag.lowercased())
    }
    
    mutating func addTag(_ tag: String) {
        let normalizedTag = tag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !normalizedTag.isEmpty && !hasTag(normalizedTag) {
            tags.append(normalizedTag)
        }
    }
    
    mutating func removeTag(_ tag: String) {
        tags.removeAll { $0.lowercased() == tag.lowercased() }
    }
    
    // MARK: - Validation
    var isValid: Bool {
        return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !partnerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               noteNumber > 0
    }
    
    // MARK: - Custom Codable Implementation for Backward Compatibility
    enum CodingKeys: String, CodingKey {
        case id, text, partnerName, date, noteNumber, images, videos, location
        case tags, relatedMilestoneId, relatedGoalId, isFavorite
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        partnerName = try container.decode(String.self, forKey: .partnerName)
        date = try container.decode(Date.self, forKey: .date)
        noteNumber = try container.decode(Int.self, forKey: .noteNumber)
        images = try container.decodeIfPresent([MediaItem].self, forKey: .images)
        videos = try container.decodeIfPresent([MediaItem].self, forKey: .videos)
        location = try container.decodeIfPresent(LocationData.self, forKey: .location)
        
        // New properties with default values for backward compatibility
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        relatedMilestoneId = try container.decodeIfPresent(UUID.self, forKey: .relatedMilestoneId)
        relatedGoalId = try container.decodeIfPresent(UUID.self, forKey: .relatedGoalId)
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(partnerName, forKey: .partnerName)
        try container.encode(date, forKey: .date)
        try container.encode(noteNumber, forKey: .noteNumber)
        try container.encodeIfPresent(images, forKey: .images)
        try container.encodeIfPresent(videos, forKey: .videos)
        try container.encodeIfPresent(location, forKey: .location)
        try container.encode(tags, forKey: .tags)
        try container.encodeIfPresent(relatedMilestoneId, forKey: .relatedMilestoneId)
        try container.encodeIfPresent(relatedGoalId, forKey: .relatedGoalId)
        try container.encode(isFavorite, forKey: .isFavorite)
    }
}

struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
    let placeName: String
}

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
    
    // MARK: - Custom Codable Implementation for Backward Compatibility
    enum CodingKeys: String, CodingKey {
        case id, data, type, filename, createdDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        data = try container.decode(Data.self, forKey: .data)
        type = try container.decode(MediaType.self, forKey: .type)
        
        // New properties with default values for backward compatibility
        filename = try container.decodeIfPresent(String.self, forKey: .filename) ?? "\(type.rawValue)_\(UUID().uuidString)"
        createdDate = try container.decodeIfPresent(Date.self, forKey: .createdDate) ?? Date()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(data, forKey: .data)
        try container.encode(type, forKey: .type)
        try container.encode(filename, forKey: .filename)
        try container.encode(createdDate, forKey: .createdDate)
    }
}

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
