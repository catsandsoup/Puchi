//
//  TimelineView.swift
//  Puchi
//
//  Timeline view components for relationship timeline enhancement
//

import SwiftUI

// MARK: - Timeline Entry Card
struct TimelineEntryCard: View {
    let note: LoveNote
    let onDelete: () -> Void
    
    @State private var showActionSheet = false
    @State private var isPressed = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline spine connector
            VStack {
                Circle()
                    .fill(Color.puchiPrimary)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(Color.background, lineWidth: 2)
                    )
                
                Rectangle()
                    .fill(Color.puchiPrimary.opacity(0.3))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
            .frame(width: 12)
            
            // Note content
            VStack(alignment: .leading, spacing: 0) {
                // Image section if available
                if let images = note.images, !images.isEmpty,
                   let firstImage = images.first,
                   let uiImage = UIImage(data: firstImage.data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .transition(.opacity.combined(with: .scale))
                }
                
                // Content section
                VStack(alignment: .leading, spacing: 12) {
                    // Note header
                    HStack {
                        Text("Love Note #\(note.noteNumber)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.puchiPrimary)
                        
                        Spacer()
                        
                        // More actions button
                        Button(action: {
                            HapticManager.light()
                            showActionSheet = true
                        }) {
                            Image(systemName: "ellipsis.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.puchiPrimary.opacity(0.8))
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                    
                    // Note text
                    Text(note.text)
                        .font(.system(size: 15, design: .rounded))
                        .lineSpacing(3)
                        .lineLimit(4)
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    // Footer info
                    HStack(spacing: 8) {
                        // Date
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 11))
                            Text(note.dateFormatted)
                        }
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.textSecondary)
                        
                        // Location if available
                        if let location = note.location {
                            HStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 11))
                                Text(location.placeName)
                            }
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(.textSecondary)
                        }
                    }
                }
                .padding(16)
            }
            .background(Color.background)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: .black.opacity(0.05),
                radius: 6,
                x: 0,
                y: isPressed ? 1 : 3
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .onTapGesture {
            withAnimation(PuchiAnimation.spring) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(PuchiAnimation.spring) {
                    isPressed = false
                }
            }
            HapticManager.light()
        }
        .confirmationDialog("Note Actions", isPresented: $showActionSheet) {
            Button("Share") {
                HapticManager.medium()
                shareNote()
            }
            
            Button("Delete", role: .destructive) {
                HapticManager.error()
                // Additional confirmation for destructive action
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(PuchiAnimation.spring) {
                        onDelete()
                    }
                }
            }
            
            Button("Cancel", role: .cancel) {
                HapticManager.light()
            }
        }
    }
    
    // Share functionality
    private func shareNote() {
        let shareText = """
        Love Note #\(note.noteNumber)
        
        \(note.text)
        
        Written on \(note.date.formatted())
        """
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootVC = window.rootViewController else { return }
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let presentationController = activityVC.popoverPresentationController {
            presentationController.sourceView = window
            // Prevent NaN by ensuring non-zero frame dimensions
            let safeX = window.frame.width > 0 ? window.frame.width / 2 : 0
            let safeY = window.frame.height > 0 ? window.frame.height / 2 : 0
            presentationController.sourceRect = CGRect(x: safeX,
                                                     y: safeY,
                                                     width: 0,
                                                     height: 0)
            presentationController.permittedArrowDirections = []
        }
        
        rootVC.present(activityVC, animated: true)
    }
}

// MARK: - Time Period Header
struct TimePeriodHeader: View {
    let date: Date
    
    private var monthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    var body: some View {
        HStack {
            Text(monthYear)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.puchiPrimary)
            
            Spacer()
            
            Rectangle()
                .fill(Color.puchiPrimary.opacity(0.3))
                .frame(height: 1)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
// MARK: - Timeline Data Processing
extension Array where Element == LoveNote {
    /// Groups notes by month/year for timeline display
    func groupedByMonth() -> [(Date, [LoveNote])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: self) { note in
            calendar.dateInterval(of: .month, for: note.date)?.start ?? note.date
        }
        
        return grouped.sorted { $0.key > $1.key } // Most recent first
    }
}

// MARK: - Main Timeline View
struct TimelineView: View {
    let notes: [LoveNote]
    @StateObject var viewModel: LoveJournalViewModel
    
    private var groupedNotes: [(Date, [LoveNote])] {
        notes.groupedByMonth()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            if notes.isEmpty {
                // Empty state with navigation hint
                VStack(spacing: 20) {
                    Spacer()
                    Spacer()
                    
                    Image(systemName: "heart.text.square")
                        .font(.system(size: 60))
                        .foregroundColor(.puchiPrimary.opacity(0.6))
                    
                    Text("Your love story awaits")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.puchiPrimary)
                    
                    // Navigation hint for empty timeline
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.puchiPrimary)
                        Text("Swipe back to write your first note")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.puchiPrimary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.puchiPrimary.opacity(0.1))
                            .overlay(
                                Capsule()
                                    .stroke(Color.puchiPrimary.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.top, 8)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Timeline content with infinite scroll
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(groupedNotes, id: \.0) { monthDate, monthNotes in
                            // Time period header
                            TimePeriodHeader(date: monthDate)
                                .padding(.top, groupedNotes.first?.0 == monthDate ? 16 : 24)
                            
                            // Notes for this month
                            ForEach(monthNotes.sorted(by: { $0.date > $1.date })) { note in
                                NavigationLink(destination: DetailedNoteView(note: note)) {
                                    TimelineEntryCard(note: note) {
                                        if let index = notes.firstIndex(where: { $0.id == note.id }) {
                                            viewModel.deleteNote(at: IndexSet([index]))
                                        }
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal, 16)
                                .padding(.bottom, 16)
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .trailing)),
                                    removal: .opacity.combined(with: .move(edge: .leading))
                                ))
                            }
                        }
                        
                        // Bottom spacing
                        Color.clear
                            .frame(height: 20)
                    }
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: notes.count)
            }
        }
        .background(Color.puchiBackground)
        .contentShape(Rectangle())
        .onTapGesture {
            // Dismiss any active keyboard when tapping in the timeline view
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

// MARK: - Preview
#Preview {
    let sampleNotes = [
        LoveNote(
            text: "You make every day brighter with your smile. I love how you laugh at my silly jokes and make even the mundane moments feel special.",
            partnerName: "Sarah",
            date: Date(),
            noteNumber: 3,
            location: LocationData(latitude: 0, longitude: 0, placeName: "Home"),
            tags: ["smile", "happiness"],
            isFavorite: true
        ),
        LoveNote(
            text: "Thank you for being my rock today. Your support means everything to me.",
            partnerName: "Sarah",
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            noteNumber: 2,
            tags: ["support", "gratitude"]
        ),
        LoveNote(
            text: "First note in our love story! Here's to many more beautiful moments together.",
            partnerName: "Sarah",
            date: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(),
            noteNumber: 1,
            tags: ["first", "beginning"]
        )
    ]
    
    TimelineView(notes: sampleNotes, viewModel: LoveJournalViewModel())
}