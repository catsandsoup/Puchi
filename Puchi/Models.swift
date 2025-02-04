import SwiftUI
import CoreLocation

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
    
    var dateFormatted: String {
        date.formatted(date: .abbreviated, time: .shortened)
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
    
    init(data: Data, type: MediaType) {
        self.id = UUID()
        self.data = data
        self.type = type
    }
}

enum MediaType: String, Codable {
    case image
    case video
}
