//
//  TimelineDataProcessing.swift
//  Puchi
//
//  Unit tests for timeline data processing logic
//

import Foundation

// MARK: - Timeline Data Processing Tests
extension Array where Element == LoveNote {
    /// Test function to verify timeline grouping works correctly
    static func testTimelineGrouping() -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        // Create test notes across different months
        let testNotes = [
            LoveNote(
                id: UUID(),
                text: "Recent note",
                partnerName: "Test",
                date: now,
                noteNumber: 3,
                images: nil,
                videos: nil,
                location: nil
            ),
            LoveNote(
                id: UUID(),
                text: "Last month note",
                partnerName: "Test",
                date: calendar.date(byAdding: .month, value: -1, to: now) ?? now,
                noteNumber: 2,
                images: nil,
                videos: nil,
                location: nil
            ),
            LoveNote(
                id: UUID(),
                text: "Two months ago note",
                partnerName: "Test",
                date: calendar.date(byAdding: .month, value: -2, to: now) ?? now,
                noteNumber: 1,
                images: nil,
                videos: nil,
                location: nil
            )
        ]
        
        let grouped = testNotes.groupedByMonth()
        
        // Verify we have 3 groups (3 different months)
        guard grouped.count == 3 else {
            print("Timeline grouping test failed: Expected 3 groups, got \(grouped.count)")
            return false
        }
        
        // Verify groups are sorted by date (most recent first)
        for i in 0..<(grouped.count - 1) {
            if grouped[i].0 < grouped[i + 1].0 {
                print("Timeline grouping test failed: Groups not sorted correctly")
                return false
            }
        }
        
        print("Timeline grouping test passed!")
        return true
    }
}