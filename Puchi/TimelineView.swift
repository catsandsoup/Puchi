//
//  TimelineView.swift
//  Puchi
//
//  Clean Journal-style timeline view
//

import SwiftUI

struct TimelineView: View {
    @Environment(AppState.self) private var appState
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Journal-style dark background
                Color.black.ignoresSafeArea()
                
                if appState.entries.isEmpty {
                    EmptyTimelineView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(groupedEntries, id: \.key) { dateGroup in
                                VStack(alignment: .leading, spacing: 12) {
                                    // Date header like Journal
                                    DateHeaderView(date: dateGroup.key)
                                    
                                    // Entry cards
                                    ForEach(dateGroup.value) { entry in
                                        EntryCardView(entry: entry)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 100) // Space for FAB
                    }
                }
                
                // Journal-style FAB
                FloatingActionButton {
                    appState.isComposingEntry = true
                }
            }
            .navigationTitle("💕 \(appState.partnerName.isEmpty ? "Puchi" : appState.partnerName)")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Settings") {
                        showingSettings = true
                    }
                    .foregroundColor(.pink)
                }
            }
            .sheet(isPresented: Bindable(appState).isComposingEntry) {
                EntryComposerView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
    
    // Group entries by date like Journal app
    private var groupedEntries: [(key: String, value: [LoveEntry])] {
        let grouped = Dictionary(grouping: appState.entries) { entry in
            DateFormatter.dateHeader.string(from: entry.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }
}

// MARK: - Supporting Views
struct EmptyTimelineView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 64))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("Your Love Story Starts Here")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Capture beautiful moments with \(appState.partnerName)")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                Text("Tap + to create your first memory")
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.7))
            }
        }
        .padding(.horizontal, 32)
    }
}

struct DateHeaderView: View {
    let date: String
    
    var body: some View {
        HStack {
            Text(date)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}

struct FloatingActionButton: View {
    let action: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: action) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(LinearGradient(
                                    colors: [.pink, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .shadow(color: .pink.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                }
                .padding(.trailing, 24)
                .padding(.bottom, 32)
            }
        }
    }
}

// MARK: - Extensions
extension DateFormatter {
    static let dateHeader: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }()
}