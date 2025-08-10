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
    @State private var showingSearch = false
    @State private var showingFilters = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Warm background using new color system
                Color.puchiBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search/Filter Toolbar
                    if !appState.entries.isEmpty {
                        SearchFilterToolbar(showingSearch: $showingSearch, showingFilters: $showingFilters)
                    }
                    
                    // Content
                    if filteredEntries.isEmpty {
                        if appState.entries.isEmpty {
                            EmptyTimelineView()
                        } else {
                            EmptySearchView()
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(groupedFilteredEntries, id: \.key) { dateGroup in
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
                    .foregroundColor(.puchiAccent)
                }
            }
            .sheet(isPresented: Bindable(appState).isComposingEntry) {
                EntryComposerView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingSearch) {
                SearchView()
            }
            .sheet(isPresented: $showingFilters) {
                FilterAndSortView()
            }
        }
    }
    
    // Filtered entries based on search and filter criteria
    private var filteredEntries: [LoveEntry] {
        var entries = appState.entries
        
        // Apply search filter
        if !appState.searchText.isEmpty {
            entries = entries.filter { entry in
                entry.title.localizedCaseInsensitiveContains(appState.searchText) ||
                String(entry.attributedContent.characters).localizedCaseInsensitiveContains(appState.searchText) ||
                entry.tags.contains { $0.localizedCaseInsensitiveContains(appState.searchText) }
            }
        }
        
        // Apply other filters based on appState filter properties
        switch appState.selectedFilter {
        case .photos:
            entries = entries.filter { $0.mediaItems.contains { $0.type == .photo } }
        case .videos:
            entries = entries.filter { $0.mediaItems.contains { $0.type == .video } }
        case .voice:
            entries = entries.filter { $0.mediaItems.contains { $0.type == .voice } }
        case .locations:
            entries = entries.filter { $0.location != nil }
        case .bookmarked:
            entries = entries.filter { $0.isBookmarked }
        case .thisWeek:
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            entries = entries.filter { $0.date >= weekAgo }
        case .thisMonth:
            let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            entries = entries.filter { $0.date >= monthAgo }
        case .all:
            break // No additional filtering
        }
        
        // Apply sorting
        switch appState.sortOption {
        case .entryDate:
            entries.sort { $0.date > $1.date }
        case .creationDate:
            entries.sort { $0.date > $1.date } // For now, same as entryDate
        case .title:
            entries.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .wordCount:
            entries.sort { String($0.attributedContent.characters).count > String($1.attributedContent.characters).count }
        }
        
        return entries
    }
    
    // Group filtered entries by date like Journal app
    private var groupedFilteredEntries: [(key: String, value: [LoveEntry])] {
        let grouped = Dictionary(grouping: filteredEntries) { entry in
            DateFormatter.dateHeader.string(from: entry.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }
}

// MARK: - Supporting Views

struct SearchFilterToolbar: View {
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme
    @Binding var showingSearch: Bool
    @Binding var showingFilters: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Search button
            Button {
                showingSearch = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .medium))
                    
                    if !appState.searchText.isEmpty {
                        Text("'\(appState.searchText)'")
                            .font(.system(size: 14, weight: .medium))
                            .lineLimit(1)
                    } else {
                        Text("Search memories...")
                            .font(.system(size: 14))
                    }
                }
                .foregroundColor(appState.searchText.isEmpty ? .puchiTextSecondary : .puchiAccent)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.puchiSurface)
                .cornerRadius(20)
            }
            
            Spacer()
            
            // Filter button
            Button {
                showingFilters = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 16, weight: .medium))
                    
                    if hasActiveFilters {
                        Circle()
                            .fill(Color.puchiAccent)
                            .frame(width: 6, height: 6)
                    }
                }
                .foregroundColor(hasActiveFilters ? .puchiAccent : .puchiTextSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.puchiSurface)
                .cornerRadius(20)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.puchiBackground)
    }
    
    private var hasActiveFilters: Bool {
        return appState.selectedFilter != .all
    }
}

struct EmptySearchView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: 64))
                .foregroundColor(.puchiTextSecondary)
            
            VStack(spacing: 8) {
                Text("No Results Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.puchiText)
                
                if !appState.searchText.isEmpty {
                    Text("No memories found for '\(appState.searchText)'")
                        .font(.body)
                        .foregroundColor(.puchiTextSecondary)
                        .multilineTextAlignment(.center)
                } else {
                    Text("Try adjusting your filters")
                        .font(.body)
                        .foregroundColor(.puchiTextSecondary)
                        .multilineTextAlignment(.center)
                }
                
                Button {
                    appState.searchText = ""
                    appState.selectedFilter = .all
                } label: {
                    Text("Clear Search & Filters")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.puchiAccent)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.puchiAccent.opacity(0.1))
                        .cornerRadius(20)
                }
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
    }
}
struct EmptyTimelineView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 64))
                .foregroundColor(.puchiTextSecondary)
            
            VStack(spacing: 8) {
                Text("Your Love Story Starts Here")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.puchiText)
                
                Text("Capture beautiful moments with \(appState.partnerName)")
                    .font(.body)
                    .foregroundColor(.puchiTextSecondary)
                    .multilineTextAlignment(.center)
                
                Text("Tap + to create your first memory")
                    .font(.caption)
                    .foregroundColor(.puchiTextSecondary.opacity(0.7))
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
                .foregroundColor(.puchiText)
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
                        .foregroundColor(.puchiButtonText)
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(Color.puchiGradient)
                                .shadow(color: .puchiAccent.opacity(0.3), radius: 8, x: 0, y: 4)
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