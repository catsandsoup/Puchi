//
//  PuchiApp.swift
//  Puchi
//
//  Created by Monty Giovenco on 26/1/2025.
//

import SwiftUI

@main
struct PuchiApp: App {
    @State private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            if appState.partnerName.isEmpty {
                OnboardingView()
            } else {
                TimelineView()
            }
        }
        .environment(appState)
    }
}

// MARK: - Comprehensive Observable State
@Observable
class AppState {
    // Partner info
    var partnerName: String = ""
    var partnerPhotoData: Data? = nil
    
    // Core data
    var entries: [LoveEntry] = []
    var recentlyDeleted: [LoveEntry] = []
    var suggestions: [JournalSuggestion] = []
    
    // UI state
    var isComposingEntry = false
    var editingEntry: LoveEntry? = nil
    var searchText = ""
    var selectedFilter: EntryFilter = .all
    var sortOption: EntrySortOption = .entryDate
    var sortAscending = false
    var showingInsights = false
    var showingSearch = false
    var showingFilters = false
    
    // Settings
    var dailyReminderEnabled = false
    var reminderTime = Date()
    var biometricAuthEnabled = false
    var journalingGoal = 3 // entries per week
    
    init() {
        loadPersistedData()
        generateSuggestions()
    }
    
    // MARK: - Entry Management Actions
    func addEntry(_ entry: LoveEntry) {
        entries.insert(entry, at: 0) // Newest first like Journal
        generateSuggestions()
        saveData()
    }
    
    func updateEntry(_ entry: LoveEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            generateSuggestions()
            saveData()
        }
    }
    
    func deleteEntry(_ entry: LoveEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            var deletedEntry = entries[index]
            deletedEntry.isDeleted = true
            deletedEntry.deletedDate = Date()
            
            entries.remove(at: index)
            recentlyDeleted.insert(deletedEntry, at: 0)
            
            // Auto-delete after 30 days
            cleanupOldDeletedEntries()
            saveData()
        }
    }
    
    func restoreEntry(_ entry: LoveEntry) {
        if let index = recentlyDeleted.firstIndex(where: { $0.id == entry.id }) {
            var restoredEntry = recentlyDeleted[index]
            restoredEntry.isDeleted = false
            restoredEntry.deletedDate = nil
            
            recentlyDeleted.remove(at: index)
            entries.insert(restoredEntry, at: 0)
            saveData()
        }
    }
    
    func permanentlyDeleteEntry(_ entry: LoveEntry) {
        recentlyDeleted.removeAll { $0.id == entry.id }
        saveData()
    }
    
    func toggleBookmark(_ entry: LoveEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index].isBookmarked.toggle()
            saveData()
        }
    }
    
    func startEditingEntry(_ entry: LoveEntry) {
        editingEntry = entry
        isComposingEntry = true
    }
    
    func cancelEditing() {
        editingEntry = nil
    }
    
    // MARK: - Filtering & Searching
    var filteredEntries: [LoveEntry] {
        var filtered = entries
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { entry in
                entry.title.localizedCaseInsensitiveContains(searchText) ||
                entry.content.localizedCaseInsensitiveContains(searchText) ||
                entry.tags.contains { $0.localizedCaseInsensitiveContains(searchText) } ||
                entry.location?.name.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
        
        // Apply category filter
        switch selectedFilter {
        case .all:
            break
        case .bookmarked:
            filtered = filtered.filter { $0.isBookmarked }
        case .photos:
            filtered = filtered.filter { !$0.mediaItems.filter { $0.type == .photo }.isEmpty }
        case .videos:
            filtered = filtered.filter { !$0.mediaItems.filter { $0.type == .video }.isEmpty }
        case .voice:
            filtered = filtered.filter { !$0.mediaItems.filter { $0.type == .voice }.isEmpty }
        case .locations:
            filtered = filtered.filter { $0.location != nil }
        case .thisWeek:
            let weekAgo = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
            filtered = filtered.filter { $0.date >= weekAgo }
        case .thisMonth:
            let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            filtered = filtered.filter { $0.date >= monthAgo }
        }
        
        // Apply sorting
        switch sortOption {
        case .entryDate:
            filtered = filtered.sorted { sortAscending ? $0.date < $1.date : $0.date > $1.date }
        case .creationDate:
            filtered = filtered.sorted { sortAscending ? $0.date < $1.date : $0.date > $1.date }
        case .title:
            filtered = filtered.sorted { sortAscending ? $0.title < $1.title : $0.title > $1.title }
        case .wordCount:
            filtered = filtered.sorted { sortAscending ? $0.wordCount < $1.wordCount : $0.wordCount > $1.wordCount }
        }
        
        return filtered
    }
    
    // MARK: - Insights & Analytics
    var insights: JournalInsights {
        let activeEntries = entries
        let totalEntries = activeEntries.count
        let totalWords = activeEntries.reduce(0) { $0 + $1.wordCount }
        let averageWords = totalEntries > 0 ? totalWords / totalEntries : 0
        
        let mediaItems = activeEntries.flatMap { $0.mediaItems }
        let totalPhotos = mediaItems.filter { $0.type == .photo }.count
        let totalVoiceNotes = mediaItems.filter { $0.type == .voice }.count
        let totalVideos = mediaItems.filter { $0.type == .video }.count
        
        // Calculate streaks
        let (currentStreak, longestStreak) = calculateStreaks()
        
        // This week/month counts
        let weekAgo = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
        let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        let entriesThisWeek = activeEntries.filter { $0.date >= weekAgo }.count
        let entriesThisMonth = activeEntries.filter { $0.date >= monthAgo }.count
        
        // Top moods and tags
        let allMoods = activeEntries.compactMap { $0.mood }
        let moodCounts = Dictionary(grouping: allMoods) { $0 }.mapValues { $0.count }
        let topMoods = moodCounts.sorted { $0.value > $1.value }.prefix(3).map { $0.key }
        
        let allTags = activeEntries.flatMap { $0.tags }
        let tagCounts = Dictionary(grouping: allTags) { $0 }.mapValues { $0.count }
        let topTags = tagCounts.sorted { $0.value > $1.value }.prefix(5).map { $0.key }
        
        // Favorite locations
        let allLocations = activeEntries.compactMap { $0.location?.name }
        let locationCounts = Dictionary(grouping: allLocations) { $0 }.mapValues { $0.count }
        let favoriteLocations = locationCounts.sorted { $0.value > $1.value }.prefix(3).map { $0.key }
        
        // Journaling days
        let journalingDays = Array(Set(activeEntries.map { Calendar.current.startOfDay(for: $0.date) }))
        
        return JournalInsights(
            totalEntries: totalEntries,
            totalWords: totalWords,
            averageWordsPerEntry: averageWords,
            totalPhotos: totalPhotos,
            totalVoiceNotes: totalVoiceNotes,
            totalVideos: totalVideos,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            entriesThisWeek: entriesThisWeek,
            entriesThisMonth: entriesThisMonth,
            topMoods: Array(topMoods),
            topTags: Array(topTags),
            favoriteLocations: Array(favoriteLocations),
            journalingDays: journalingDays.sorted(),
            firstEntryDate: activeEntries.last?.date
        )
    }
    
    private func calculateStreaks() -> (current: Int, longest: Int) {
        let sortedDates = Set(entries.map { Calendar.current.startOfDay(for: $0.date) }).sorted()
        guard !sortedDates.isEmpty else { return (0, 0) }
        
        var currentStreak = 0
        var longestStreak = 0
        var tempStreak = 1
        
        // Check if today is part of the current streak
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        if sortedDates.contains(today) || sortedDates.contains(yesterday) {
            currentStreak = 1
            
            // Count backwards from today/yesterday
            var checkDate = sortedDates.contains(today) ? today : yesterday
            while let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: checkDate),
                  sortedDates.contains(previousDay) {
                currentStreak += 1
                checkDate = previousDay
            }
        }
        
        // Calculate longest streak
        for i in 1..<sortedDates.count {
            let currentDate = sortedDates[i]
            let previousDate = sortedDates[i-1]
            
            if Calendar.current.dateComponents([.day], from: previousDate, to: currentDate).day == 1 {
                tempStreak += 1
            } else {
                longestStreak = max(longestStreak, tempStreak)
                tempStreak = 1
            }
        }
        longestStreak = max(longestStreak, tempStreak)
        
        return (currentStreak, longestStreak)
    }
    
    // MARK: - Suggestions
    func generateSuggestions() {
        suggestions = []
        
        // General love prompts
        let generalPrompts = [
            JournalSuggestion(title: "Today's Highlight", prompt: "What was the best part of your day with \(partnerName)?", type: .general, relevantData: nil),
            JournalSuggestion(title: "Gratitude Moment", prompt: "What are you most grateful for about \(partnerName) today?", type: .general, relevantData: nil),
            JournalSuggestion(title: "Perfect Memory", prompt: "Describe a perfect moment you shared recently", type: .general, relevantData: nil),
            JournalSuggestion(title: "Future Dreams", prompt: "What are you looking forward to doing together?", type: .general, relevantData: nil)
        ]
        
        // Date-based suggestions
        let calendar = Calendar.current
        if calendar.isDateInWeekend(Date()) {
            suggestions.append(JournalSuggestion(
                title: "Weekend Adventures",
                prompt: "How are you spending this beautiful weekend together?",
                type: .date,
                relevantData: "Weekend"
            ))
        }
        
        // Add 2-3 random general suggestions
        suggestions.append(contentsOf: Array(generalPrompts.shuffled().prefix(3)))
    }
    
    // MARK: - Cleanup
    private func cleanupOldDeletedEntries() {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        recentlyDeleted.removeAll { entry in
            if let deletedDate = entry.deletedDate {
                return deletedDate < thirtyDaysAgo
            }
            return false
        }
    }
    
    // MARK: - Persistence
    private func loadPersistedData() {
        // Load basic data
        partnerName = UserDefaults.standard.string(forKey: "partnerName") ?? ""
        partnerPhotoData = UserDefaults.standard.data(forKey: "partnerPhotoData")
        
        // Load entries
        if let data = UserDefaults.standard.data(forKey: "loveEntries"),
           let decoded = try? JSONDecoder().decode([LoveEntry].self, from: data) {
            entries = decoded
        }
        
        // Load recently deleted
        if let data = UserDefaults.standard.data(forKey: "recentlyDeleted"),
           let decoded = try? JSONDecoder().decode([LoveEntry].self, from: data) {
            recentlyDeleted = decoded
        }
        
        // Load settings
        dailyReminderEnabled = UserDefaults.standard.bool(forKey: "dailyReminderEnabled")
        biometricAuthEnabled = UserDefaults.standard.bool(forKey: "biometricAuthEnabled")
        journalingGoal = UserDefaults.standard.integer(forKey: "journalingGoal")
        if journalingGoal == 0 { journalingGoal = 3 } // Default
        
        if let timeData = UserDefaults.standard.data(forKey: "reminderTime"),
           let time = try? JSONDecoder().decode(Date.self, from: timeData) {
            reminderTime = time
        }
        
        // Load UI preferences
        if let filterRaw = UserDefaults.standard.string(forKey: "selectedFilter"),
           let filter = EntryFilter(rawValue: filterRaw) {
            selectedFilter = filter
        }
        
        if let sortRaw = UserDefaults.standard.string(forKey: "sortOption"),
           let sort = EntrySortOption(rawValue: sortRaw) {
            sortOption = sort
        }
        
        sortAscending = UserDefaults.standard.bool(forKey: "sortAscending")
        
        // Cleanup old deleted entries
        cleanupOldDeletedEntries()
    }
    
    private func saveData() {
        // Save basic data
        UserDefaults.standard.set(partnerName, forKey: "partnerName")
        UserDefaults.standard.set(partnerPhotoData, forKey: "partnerPhotoData")
        
        // Save entries
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: "loveEntries")
        }
        
        // Save recently deleted
        if let encoded = try? JSONEncoder().encode(recentlyDeleted) {
            UserDefaults.standard.set(encoded, forKey: "recentlyDeleted")
        }
        
        // Save settings
        UserDefaults.standard.set(dailyReminderEnabled, forKey: "dailyReminderEnabled")
        UserDefaults.standard.set(biometricAuthEnabled, forKey: "biometricAuthEnabled")
        UserDefaults.standard.set(journalingGoal, forKey: "journalingGoal")
        
        if let timeData = try? JSONEncoder().encode(reminderTime) {
            UserDefaults.standard.set(timeData, forKey: "reminderTime")
        }
        
        // Save UI preferences
        UserDefaults.standard.set(selectedFilter.rawValue, forKey: "selectedFilter")
        UserDefaults.standard.set(sortOption.rawValue, forKey: "sortOption")
        UserDefaults.standard.set(sortAscending, forKey: "sortAscending")
    }
    
    func resetAllData() {
        entries = []
        recentlyDeleted = []
        partnerName = ""
        partnerPhotoData = nil
        
        // Reset settings to defaults
        dailyReminderEnabled = false
        biometricAuthEnabled = false
        journalingGoal = 3
        reminderTime = Date()
        selectedFilter = .all
        sortOption = .entryDate
        sortAscending = false
        
        // Clear UserDefaults
        let keys = ["partnerName", "partnerPhotoData", "loveEntries", "recentlyDeleted",
                   "dailyReminderEnabled", "biometricAuthEnabled", "journalingGoal",
                   "reminderTime", "selectedFilter", "sortOption", "sortAscending"]
        
        keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
        
        generateSuggestions()
    }
}

// MARK: - Comprehensive Journal Models
struct LoveEntry: Identifiable, Codable {
    let id: UUID
    var title: String = ""
    var content: String = ""
    var richTextData: Data? = nil // Store NSAttributedString as Data
    var date: Date = Date()
    var mediaItems: [MediaItem] = []
    var location: LocationInfo? = nil
    var mood: Mood? = nil
    var weather: String? = nil
    var tags: [String] = []
    var isBookmarked: Bool = false
    var isDeleted: Bool = false
    var deletedDate: Date? = nil
    var wordCount: Int { content.split(separator: " ").count }
    
    // Simplified AttributedString property (temporarily disabled for stability)
    var attributedContent: AttributedString {
        get {
            // Return simple AttributedString for now to prevent crashes
            return AttributedString(content)
        }
        set {
            // Store as plain text temporarily
            content = String(newValue.characters)
        }
    }
    
    var isEmpty: Bool {
        title.isEmpty && content.isEmpty && mediaItems.isEmpty
    }
    
    init(title: String = "", content: String = "", date: Date = Date(), mediaItems: [MediaItem] = [], location: LocationInfo? = nil, mood: Mood? = nil, weather: String? = nil, tags: [String] = []) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.date = date
        self.mediaItems = mediaItems
        self.location = location
        self.mood = mood
        self.weather = weather
        self.tags = tags
    }
}

struct MediaItem: Identifiable, Codable {
    let id: UUID
    private var fileURL: URL?
    private var _data: Data?
    let type: MediaType
    let caption: String?
    let dateAdded: Date
    
    // Data property with file-based storage for large items
    var data: Data {
        get {
            // For small items (photos), return stored data directly
            if let _data = _data {
                return _data
            }
            
            // For large items (voice/video), read from file
            if let fileURL = fileURL,
               let fileData = try? Data(contentsOf: fileURL) {
                return fileData
            }
            
            return Data()
        }
        set {
            // Store small items directly, large items as files
            if newValue.count < 1_000_000 { // 1MB threshold
                _data = newValue
                fileURL = nil
            } else {
                // Store as file for large items
                let fileName = "\(id.uuidString).\(type == .voice ? "m4a" : "dat")"
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let mediaURL = documentsURL.appendingPathComponent("Media")
                
                // Create Media directory if needed
                try? FileManager.default.createDirectory(at: mediaURL, withIntermediateDirectories: true)
                
                let fileURL = mediaURL.appendingPathComponent(fileName)
                
                do {
                    try newValue.write(to: fileURL)
                    self.fileURL = fileURL
                    self._data = nil
                } catch {
                    print("Failed to write media file: \(error)")
                    // Fallback to in-memory storage
                    self._data = newValue
                    self.fileURL = nil
                }
            }
        }
    }
    
    init(data: Data, type: MediaType, caption: String? = nil) {
        self.id = UUID()
        self.type = type
        self.caption = caption
        self.dateAdded = Date()
        self._data = nil
        self.fileURL = nil
        
        // Use the data setter to handle storage logic
        self.data = data
    }
    
    // Custom coding to handle file references
    private enum CodingKeys: String, CodingKey {
        case id, fileURL, _data, type, caption, dateAdded
    }
    
    // Cleanup method for file-based media
    func cleanup() {
        if let fileURL = fileURL {
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
    
    enum MediaType: String, Codable, CaseIterable {
        case photo, voice, video
        
        var icon: String {
            switch self {
            case .photo: return "photo"
            case .voice: return "waveform"
            case .video: return "video"
            }
        }
    }
}

struct LocationInfo: Codable {
    let name: String
    let coordinate: Coordinate?
    
    struct Coordinate: Codable {
        let latitude: Double
        let longitude: Double
    }
}

enum Mood: String, Codable, CaseIterable {
    case amazing = "amazing"
    case happy = "happy"
    case content = "content"
    case neutral = "neutral"
    case sad = "sad"
    case romantic = "romantic"
    case grateful = "grateful"
    
    var emoji: String {
        switch self {
        case .amazing: return "🤩"
        case .happy: return "😊"
        case .content: return "😌"
        case .neutral: return "😐"
        case .sad: return "😢"
        case .romantic: return "😍"
        case .grateful: return "🥰"
        }
    }
    
    var color: String {
        switch self {
        case .amazing: return "yellow"
        case .happy: return "orange"
        case .content: return "green"
        case .neutral: return "gray"
        case .sad: return "blue"
        case .romantic: return "pink"
        case .grateful: return "purple"
        }
    }
}

// MARK: - Journal Suggestions
struct JournalSuggestion: Identifiable {
    let id = UUID()
    let title: String
    let prompt: String
    let type: SuggestionType
    let relevantData: String?
    
    enum SuggestionType: String, CaseIterable {
        case photo = "photo"
        case location = "location"
        case date = "date"
        case weather = "weather"
        case general = "general"
        
        var icon: String {
            switch self {
            case .photo: return "photo"
            case .location: return "location"
            case .date: return "calendar"
            case .weather: return "cloud.sun"
            case .general: return "heart"
            }
        }
    }
}

// MARK: - Insights & Statistics
struct JournalInsights {
    let totalEntries: Int
    let totalWords: Int
    let averageWordsPerEntry: Int
    let totalPhotos: Int
    let totalVoiceNotes: Int
    let totalVideos: Int
    let currentStreak: Int
    let longestStreak: Int
    let entriesThisWeek: Int
    let entriesThisMonth: Int
    let topMoods: [Mood]
    let topTags: [String]
    let favoriteLocations: [String]
    let journalingDays: [Date]
    let firstEntryDate: Date?
}

// MARK: - Filter & Sort Options
enum EntryFilter: String, CaseIterable {
    case all = "All"
    case bookmarked = "Bookmarked"
    case photos = "Photos"
    case videos = "Videos"
    case voice = "Voice Notes"
    case locations = "Places"
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    
    var icon: String {
        switch self {
        case .all: return "doc.text"
        case .bookmarked: return "bookmark.fill"
        case .photos: return "photo"
        case .videos: return "video"
        case .voice: return "waveform"
        case .locations: return "location"
        case .thisWeek: return "calendar"
        case .thisMonth: return "calendar.badge.clock"
        }
    }
}

enum EntrySortOption: String, CaseIterable {
    case entryDate = "Entry Date"
    case creationDate = "Creation Date"
    case title = "Title"
    case wordCount = "Word Count"
    
    var icon: String {
        switch self {
        case .entryDate: return "calendar"
        case .creationDate: return "clock"
        case .title: return "textformat.abc"
        case .wordCount: return "text.word.spacing"
        }
    }
}
