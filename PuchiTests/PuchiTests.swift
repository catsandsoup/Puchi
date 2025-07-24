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

}
