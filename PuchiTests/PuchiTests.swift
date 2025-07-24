//
//  PuchiTests.swift
//  PuchiTests
//
//  Created by Monty Giovenco on 26/1/2025.
//

import Testing
@testable import Puchi

struct PuchiTests {

    // MARK: - Enhanced LoveNote Model Tests
    
    @Test func testLoveNoteInitialization() async throws {
        let note = LoveNote(
            text: "Test note",
            partnerName: "Test Partner",
            date: Date(),
            noteNumber: 1,
            tags: ["test", "love"],
            relatedMilestoneId: UUID(),
            relatedGoalId: UUID(),
            isFavorite: true
        )
        
        #expect(note.text == "Test note")
        #expect(note.partnerName == "Test Partner")
        #expect(note.noteNumber == 1)
        #expect(note.tags == ["test", "love"])
        #expect(note.relatedMilestoneId != nil)
        #expect(note.relatedGoalId != nil)
        #expect(note.isFavorite == true)
    }
    
    @Test func testLoveNoteDefaultValues() async throws {
        let note = LoveNote(
            text: "Test note",
            partnerName: "Test Partner",
            date: Date(),
            noteNumber: 1
        )
        
        #expect(note.tags.isEmpty)
        #expect(note.relatedMilestoneId == nil)
        #expect(note.relatedGoalId == nil)
        #expect(note.isFavorite == false)
    }
    
    @Test func testLoveNoteRelationshipHelpers() async throws {
        let milestoneId = UUID()
        let goalId = UUID()
        
        var note = LoveNote(
            text: "Test note",
            partnerName: "Test Partner",
            date: Date(),
            noteNumber: 1
        )
        
        // Test initial state
        #expect(!note.hasRelatedMilestone)
        #expect(!note.hasRelatedGoal)
        #expect(!note.hasRelationships)
        
        // Test with milestone
        note.relatedMilestoneId = milestoneId
        #expect(note.hasRelatedMilestone)
        #expect(!note.hasRelatedGoal)
        #expect(note.hasRelationships)
        
        // Test with goal
        note.relatedGoalId = goalId
        #expect(note.hasRelatedMilestone)
        #expect(note.hasRelatedGoal)
        #expect(note.hasRelationships)
        
        // Test with only goal
        note.relatedMilestoneId = nil
        #expect(!note.hasRelatedMilestone)
        #expect(note.hasRelatedGoal)
        #expect(note.hasRelationships)
    }
    
    @Test func testLoveNoteTagHelpers() async throws {
        var note = LoveNote(
            text: "Test note",
            partnerName: "Test Partner",
            date: Date(),
            noteNumber: 1
        )
        
        // Test adding tags
        note.addTag("Love")
        note.addTag("HAPPINESS")
        note.addTag("  gratitude  ")
        
        #expect(note.tags.contains("love"))
        #expect(note.tags.contains("happiness"))
        #expect(note.tags.contains("gratitude"))
        
        // Test hasTag (case insensitive)
        #expect(note.hasTag("LOVE"))
        #expect(note.hasTag("Happiness"))
        #expect(note.hasTag("gratitude"))
        #expect(!note.hasTag("sadness"))
        
        // Test duplicate prevention
        note.addTag("love")
        #expect(note.tags.filter { $0 == "love" }.count == 1)
        
        // Test empty tag prevention
        note.addTag("")
        note.addTag("   ")
        #expect(!note.tags.contains(""))
        
        // Test removing tags
        note.removeTag("LOVE")
        #expect(!note.hasTag("love"))
        #expect(note.hasTag("happiness"))
    }
    
    @Test func testLoveNoteValidation() async throws {
        // Valid note
        let validNote = LoveNote(
            text: "Valid note text",
            partnerName: "Valid Partner",
            date: Date(),
            noteNumber: 1
        )
        #expect(validNote.isValid)
        
        // Invalid note - empty text
        let invalidTextNote = LoveNote(
            text: "   ",
            partnerName: "Valid Partner",
            date: Date(),
            noteNumber: 1
        )
        #expect(!invalidTextNote.isValid)
        
        // Invalid note - empty partner name
        let invalidPartnerNote = LoveNote(
            text: "Valid text",
            partnerName: "",
            date: Date(),
            noteNumber: 1
        )
        #expect(!invalidPartnerNote.isValid)
        
        // Invalid note - zero note number
        let invalidNumberNote = LoveNote(
            text: "Valid text",
            partnerName: "Valid Partner",
            date: Date(),
            noteNumber: 0
        )
        #expect(!invalidNumberNote.isValid)
    }
    
    // MARK: - Enum Tests
    
    @Test func testMilestoneCategoryEnum() async throws {
        // Test all cases exist
        let allCases = MilestoneCategory.allCases
        #expect(allCases.count == 4)
        #expect(allCases.contains(.anniversary))
        #expect(allCases.contains(.firstTime))
        #expect(allCases.contains(.achievement))
        #expect(allCases.contains(.custom))
        
        // Test display names
        #expect(MilestoneCategory.anniversary.displayName == "Anniversary")
        #expect(MilestoneCategory.firstTime.displayName == "First Time")
        #expect(MilestoneCategory.achievement.displayName == "Achievement")
        #expect(MilestoneCategory.custom.displayName == "Custom")
        
        // Test system images
        #expect(MilestoneCategory.anniversary.systemImage == "heart.circle.fill")
        #expect(MilestoneCategory.firstTime.systemImage == "star.circle.fill")
        #expect(MilestoneCategory.achievement.systemImage == "trophy.circle.fill")
        #expect(MilestoneCategory.custom.systemImage == "circle.fill")
        
        // Test codable
        let category = MilestoneCategory.anniversary
        let encoded = try JSONEncoder().encode(category)
        let decoded = try JSONDecoder().decode(MilestoneCategory.self, from: encoded)
        #expect(decoded == category)
    }
    
    @Test func testGoalCategoryEnum() async throws {
        // Test all cases exist
        let allCases = GoalCategory.allCases
        #expect(allCases.count == 4)
        #expect(allCases.contains(.relationship))
        #expect(allCases.contains(.personalGrowth))
        #expect(allCases.contains(.sharedExperience))
        #expect(allCases.contains(.futurePlans))
        
        // Test display names
        #expect(GoalCategory.relationship.displayName == "Relationship")
        #expect(GoalCategory.personalGrowth.displayName == "Personal Growth")
        #expect(GoalCategory.sharedExperience.displayName == "Shared Experience")
        #expect(GoalCategory.futurePlans.displayName == "Future Plans")
        
        // Test system images
        #expect(GoalCategory.relationship.systemImage == "heart.fill")
        #expect(GoalCategory.personalGrowth.systemImage == "person.fill")
        #expect(GoalCategory.sharedExperience.systemImage == "person.2.fill")
        #expect(GoalCategory.futurePlans.systemImage == "calendar.badge.plus")
        
        // Test codable
        let category = GoalCategory.relationship
        let encoded = try JSONEncoder().encode(category)
        let decoded = try JSONDecoder().decode(GoalCategory.self, from: encoded)
        #expect(decoded == category)
    }
    
    @Test func testLoveNoteCodable() async throws {
        let originalNote = LoveNote(
            text: "Test note",
            partnerName: "Test Partner",
            date: Date(),
            noteNumber: 1,
            tags: ["test", "love"],
            relatedMilestoneId: UUID(),
            relatedGoalId: UUID(),
            isFavorite: true
        )
        
        // Test encoding and decoding
        let encoded = try JSONEncoder().encode(originalNote)
        let decodedNote = try JSONDecoder().decode(LoveNote.self, from: encoded)
        
        #expect(decodedNote.id == originalNote.id)
        #expect(decodedNote.text == originalNote.text)
        #expect(decodedNote.partnerName == originalNote.partnerName)
        #expect(decodedNote.noteNumber == originalNote.noteNumber)
        #expect(decodedNote.tags == originalNote.tags)
        #expect(decodedNote.relatedMilestoneId == originalNote.relatedMilestoneId)
        #expect(decodedNote.relatedGoalId == originalNote.relatedGoalId)
        #expect(decodedNote.isFavorite == originalNote.isFavorite)
    }
    
    @Test func testLoveNoteBackwardCompatibility() async throws {
        // Simulate old JSON format without new properties
        let oldFormatJSON = """
        {
            "id": "123e4567-e89b-12d3-a456-426614174000",
            "text": "Old format note",
            "partnerName": "Test Partner",
            "date": 694224000,
            "noteNumber": 1,
            "images": null,
            "videos": null,
            "location": null
        }
        """
        
        let jsonData = oldFormatJSON.data(using: .utf8)!
        let decodedNote = try JSONDecoder().decode(LoveNote.self, from: jsonData)
        
        // Verify old properties are preserved
        #expect(decodedNote.text == "Old format note")
        #expect(decodedNote.partnerName == "Test Partner")
        #expect(decodedNote.noteNumber == 1)
        
        // Verify new properties have default values
        #expect(decodedNote.tags.isEmpty)
        #expect(decodedNote.relatedMilestoneId == nil)
        #expect(decodedNote.relatedGoalId == nil)
        #expect(decodedNote.isFavorite == false)
        
        // Verify the note is still valid
        #expect(decodedNote.isValid)
    }
    
    @Test func testTimelineDataProcessing() async throws {
        let calendar = Calendar.current
        let now = Date()
        
        // Create test notes across different months
        let testNotes = [
            LoveNote(
                text: "Recent note",
                partnerName: "Test",
                date: now,
                noteNumber: 3,
                tags: ["recent", "test"]
            ),
            LoveNote(
                text: "Last month note",
                partnerName: "Test",
                date: calendar.date(byAdding: .month, value: -1, to: now) ?? now,
                noteNumber: 2,
                tags: ["past", "test"]
            ),
            LoveNote(
                text: "Same month note",
                partnerName: "Test",
                date: calendar.date(byAdding: .day, value: -5, to: now) ?? now,
                noteNumber: 4,
                tags: ["same-month", "test"]
            )
        ]
        
        let grouped = testNotes.groupedByMonth()
        
        // Verify we have 2 groups (2 different months - current and last month)
        #expect(grouped.count == 2, "Expected 2 groups, got \(grouped.count)")
        
        // Verify groups are sorted by date (most recent first)
        for i in 0..<(grouped.count - 1) {
            #expect(grouped[i].0 >= grouped[i + 1].0, "Groups should be sorted by date (most recent first)")
        }
        
        // Verify the current month group has 2 notes
        let currentMonthGroup = grouped.first { group in
            calendar.isDate(group.0, equalTo: now, toGranularity: .month)
        }
        #expect(currentMonthGroup?.1.count == 2, "Current month should have 2 notes")
    }
    
    // MARK: - Location Management Tests
    
    @Test func testLocationRemoval() async throws {
        let viewModel = LoveJournalViewModel()
        
        // Set up a location
        let testLocation = LocationData(
            latitude: 37.7749,
            longitude: -122.4194,
            placeName: "San Francisco, CA"
        )
        viewModel.currentLocation = testLocation
        
        // Verify location is set
        #expect(viewModel.currentLocation != nil)
        #expect(viewModel.currentLocation?.placeName == "San Francisco, CA")
        
        // Remove location
        viewModel.removeLocation()
        
        // Verify location is removed
        #expect(viewModel.currentLocation == nil)
        #expect(!viewModel.isCapturingLocation)
    }
    
    @Test func testLocationRemovalWhenNoLocation() async throws {
        let viewModel = LoveJournalViewModel()
        
        // Ensure no location is set initially
        #expect(viewModel.currentLocation == nil)
        
        // Try to remove location when none exists (should not crash)
        viewModel.removeLocation()
        
        // Verify still no location
        #expect(viewModel.currentLocation == nil)
        #expect(!viewModel.isCapturingLocation)
    }
    
    @Test func testSaveNoteWithoutLocationAfterRemoval() async throws {
        let viewModel = LoveJournalViewModel()
        viewModel.storedPartnerName = "Test Partner"
        
        // Set up a location
        let testLocation = LocationData(
            latitude: 37.7749,
            longitude: -122.4194,
            placeName: "San Francisco, CA"
        )
        viewModel.currentLocation = testLocation
        
        // Set note text
        viewModel.loveNote = "Test note with location"
        
        // Remove location before saving
        viewModel.removeLocation()
        
        // Save the note
        viewModel.saveLoveNote()
        
        // Verify the saved note has no location
        #expect(!viewModel.savedNotes.isEmpty)
        let savedNote = viewModel.savedNotes.first!
        #expect(savedNote.location == nil)
        #expect(savedNote.text == "Test note with location")
    }
    
    // MARK: - MediaManager Tests
    
    @Test func testMediaManagerInitialization() async throws {
        let mediaManager = MediaManager()
        
        #expect(mediaManager.selectedMedia.isEmpty)
        #expect(!mediaManager.hasMedia)
        #expect(mediaManager.mediaCount == 0)
        #expect(mediaManager.imageCount == 0)
        #expect(mediaManager.videoCount == 0)
        #expect(!mediaManager.isProcessing)
        #expect(!mediaManager.isShowingPicker)
    }
    
    @Test func testMediaManagerAddMedia() async throws {
        let mediaManager = MediaManager()
        
        // Create test media items
        let imageData = Data([1, 2, 3, 4]) // Mock image data
        let videoData = Data([5, 6, 7, 8]) // Mock video data
        
        let imageItem = MediaItem(data: imageData, type: .image, filename: "test_image.jpg")
        let videoItem = MediaItem(data: videoData, type: .video, filename: "test_video.mp4")
        
        // Add media items
        mediaManager.addMedia([imageItem, videoItem])
        
        #expect(mediaManager.mediaCount == 2)
        #expect(mediaManager.imageCount == 1)
        #expect(mediaManager.videoCount == 1)
        #expect(mediaManager.hasMedia)
        
        // Verify specific items
        let images = mediaManager.getImages()
        let videos = mediaManager.getVideos()
        
        #expect(images.count == 1)
        #expect(videos.count == 1)
        #expect(images.first?.filename == "test_image.jpg")
        #expect(videos.first?.filename == "test_video.mp4")
    }
    
    @Test func testMediaManagerRemoveMedia() async throws {
        let mediaManager = MediaManager()
        
        // Add test media
        let imageData = Data([1, 2, 3, 4])
        let imageItem = MediaItem(data: imageData, type: .image, filename: "test.jpg")
        mediaManager.addMedia([imageItem])
        
        #expect(mediaManager.mediaCount == 1)
        
        // Remove by index
        mediaManager.removeMedia(at: 0)
        #expect(mediaManager.mediaCount == 0)
        #expect(!mediaManager.hasMedia)
        
        // Add again and remove by ID
        mediaManager.addMedia([imageItem])
        #expect(mediaManager.mediaCount == 1)
        
        mediaManager.removeMedia(withId: imageItem.id)
        #expect(mediaManager.mediaCount == 0)
    }
    
    @Test func testMediaManagerClearAllMedia() async throws {
        let mediaManager = MediaManager()
        
        // Add multiple media items
        let items = [
            MediaItem(data: Data([1, 2, 3]), type: .image),
            MediaItem(data: Data([4, 5, 6]), type: .video),
            MediaItem(data: Data([7, 8, 9]), type: .image)
        ]
        
        mediaManager.addMedia(items)
        #expect(mediaManager.mediaCount == 3)
        
        // Clear all media
        mediaManager.clearAllMedia()
        #expect(mediaManager.mediaCount == 0)
        #expect(!mediaManager.hasMedia)
        #expect(mediaManager.selectedMedia.isEmpty)
    }
    
    @Test func testMediaManagerValidation() async throws {
        let mediaManager = MediaManager()
        
        // Test with small media (should pass validation)
        let smallData = Data(repeating: 0, count: 1024) // 1KB
        let smallItem = MediaItem(data: smallData, type: .image)
        mediaManager.addMedia([smallItem])
        
        #expect(mediaManager.validateMediaSize())
        #expect(mediaManager.getMediaSizeInMB() < 1.0)
        
        // Test media size calculation
        let sizeInMB = mediaManager.getMediaSizeInMB()
        #expect(sizeInMB > 0)
    }
    
    @Test func testMediaManagerFilterByType() async throws {
        let mediaManager = MediaManager()
        
        // Add mixed media types
        let items = [
            MediaItem(data: Data([1]), type: .image, filename: "image1.jpg"),
            MediaItem(data: Data([2]), type: .video, filename: "video1.mp4"),
            MediaItem(data: Data([3]), type: .image, filename: "image2.jpg"),
            MediaItem(data: Data([4]), type: .video, filename: "video2.mp4"),
            MediaItem(data: Data([5]), type: .image, filename: "image3.jpg")
        ]
        
        mediaManager.addMedia(items)
        
        #expect(mediaManager.mediaCount == 5)
        #expect(mediaManager.imageCount == 3)
        #expect(mediaManager.videoCount == 2)
        
        let images = mediaManager.getImages()
        let videos = mediaManager.getVideos()
        
        #expect(images.count == 3)
        #expect(videos.count == 2)
        
        // Verify all images are actually images
        for image in images {
            #expect(image.type == .image)
        }
        
        // Verify all videos are actually videos
        for video in videos {
            #expect(video.type == .video)
        }
    }
    
    // MARK: - Enhanced MediaItem Tests
    
    @Test func testEnhancedMediaItemInitialization() async throws {
        let data = Data([1, 2, 3, 4])
        
        // Test with custom filename
        let customItem = MediaItem(data: data, type: .image, filename: "custom_image.jpg")
        #expect(customItem.filename == "custom_image.jpg")
        #expect(customItem.type == .image)
        #expect(customItem.data == data)
        #expect(customItem.createdDate <= Date())
        
        // Test with auto-generated filename
        let autoItem = MediaItem(data: data, type: .video)
        #expect(autoItem.filename.hasPrefix("video_"))
        #expect(autoItem.type == .video)
    }
    
    @Test func testMediaItemBackwardCompatibility() async throws {
        // Test that old MediaItem format can still be decoded
        let oldFormatJSON = """
        {
            "id": "123e4567-e89b-12d3-a456-426614174000",
            "data": "AQIDBA==",
            "type": "image"
        }
        """
        
        let jsonData = oldFormatJSON.data(using: .utf8)!
        let decodedItem = try JSONDecoder().decode(MediaItem.self, from: jsonData)
        
        #expect(decodedItem.type == .image)
        #expect(decodedItem.data == Data([1, 2, 3, 4]))
        #expect(decodedItem.filename.hasPrefix("image_"))
        #expect(decodedItem.createdDate <= Date())
    }
    
    @Test func testMediaTypeEnhancements() async throws {
        // Test system images
        #expect(MediaType.image.systemImage == "photo.fill")
        #expect(MediaType.video.systemImage == "video.fill")
        
        // Test file extensions
        #expect(MediaType.image.fileExtension == "jpg")
        #expect(MediaType.video.fileExtension == "mp4")
        
        // Test all cases
        let allCases = MediaType.allCases
        #expect(allCases.count == 2)
        #expect(allCases.contains(.image))
        #expect(allCases.contains(.video))
    }

}
