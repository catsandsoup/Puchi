import SwiftUI

struct SearchView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @FocusState private var searchFocused: Bool
    @State private var showingFilters = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    SearchBarView()
                    
                    // Filter chips
                    FilterChipsView()
                    
                    // Results
                    SearchResultsView()
                }
            }
            .navigationTitle("Search Memories")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        appState.searchText = ""
                        dismiss()
                    }
                    .foregroundColor(.pink)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showingFilters = true
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(.pink)
                    }
                }
            }
        }
        .onAppear {
            searchFocused = true
        }
        .sheet(isPresented: $showingFilters) {
            FilterAndSortView()
        }
    }
}

struct SearchBarView: View {
    @Environment(AppState.self) private var appState
    @FocusState private var searchFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search memories...", text: Bindable(appState).searchText)
                    .focused($searchFocused)
                    .foregroundColor(.white)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !appState.searchText.isEmpty {
                    Button(action: {
                        appState.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6).opacity(0.2))
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                searchFocused = true
            }
        }
    }
}

struct FilterChipsView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(EntryFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        filter: filter,
                        isSelected: appState.selectedFilter == filter
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if appState.selectedFilter == filter {
                                appState.selectedFilter = .all
                            } else {
                                appState.selectedFilter = filter
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
    }
}

struct FilterChip: View {
    let filter: EntryFilter
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: filter.icon)
                    .font(.caption)
                Text(filter.rawValue)
                    .font(.subheadline)
            }
            .foregroundColor(isSelected ? .white : .gray)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Group {
                    if isSelected {
                        Capsule()
                            .fill(LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing))
                    } else {
                        Capsule()
                            .fill(Color.clear)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SearchResultsView: View {
    @Environment(AppState.self) private var appState
    
    private var filteredEntries: [LoveEntry] {
        appState.filteredEntries
    }
    
    private var groupedResults: [(key: String, value: [LoveEntry])] {
        let grouped = Dictionary(grouping: filteredEntries) { entry in
            DateFormatter.dateHeader.string(from: entry.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if appState.searchText.isEmpty && appState.selectedFilter == .all {
                    // Empty state
                    SearchEmptyStateView()
                } else if filteredEntries.isEmpty {
                    // No results
                    NoResultsView()
                } else {
                    // Results header
                    SearchResultsHeaderView(count: filteredEntries.count)
                    
                    // Grouped results
                    ForEach(groupedResults, id: \.key) { dateGroup in
                        VStack(alignment: .leading, spacing: 12) {
                            // Date header
                            HStack {
                                Text(dateGroup.key)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.horizontal, 4)
                            
                            // Entry cards
                            ForEach(dateGroup.value) { entry in
                                SearchResultCard(entry: entry)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
    }
}

struct SearchEmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("Search Your Love Story")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Find memories by content, location, or tags")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

struct NoResultsView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("No Memories Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                if !appState.searchText.isEmpty {
                    Text("Try searching for different keywords")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                } else {
                    Text("No memories match the selected filter")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            }
            
            Button("Clear Filters") {
                withAnimation {
                    appState.searchText = ""
                    appState.selectedFilter = .all
                }
            }
            .foregroundColor(.pink)
            .padding(.top, 8)
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

struct SearchResultsHeaderView: View {
    let count: Int
    @Environment(AppState.self) private var appState
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(count) \(count == 1 ? "memory" : "memories") found")
                    .font(.headline)
                    .foregroundColor(.white)
                
                if !appState.searchText.isEmpty {
                    Text("for \"\(appState.searchText)\"")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Sort indicator
            HStack(spacing: 4) {
                Image(systemName: appState.sortAscending ? "arrow.up" : "arrow.down")
                    .font(.caption)
                Text(appState.sortOption.rawValue)
                    .font(.caption)
            }
            .foregroundColor(.gray)
        }
        .padding(.horizontal, 4)
    }
}

struct SearchResultCard: View {
    @Environment(AppState.self) private var appState
    let entry: LoveEntry
    
    var body: some View {
        Button(action: {
            appState.startEditingEntry(entry)
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Title with search highlight
                if !entry.title.isEmpty {
                    HighlightedText(
                        text: entry.title,
                        searchText: appState.searchText
                    )
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Content preview with search highlight
                if !entry.content.isEmpty {
                    HighlightedText(
                        text: String(entry.content.prefix(200)),
                        searchText: appState.searchText
                    )
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(3)
                }
                
                // Media preview
                if !entry.mediaItems.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(entry.mediaItems.prefix(3)) { item in
                                SearchMediaPreview(mediaItem: item)
                            }
                            
                            if entry.mediaItems.count > 3 {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 60, height: 60)
                                    
                                    Text("+\(entry.mediaItems.count - 3)")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.horizontal, 2)
                    }
                }
                
                // Metadata
                HStack(spacing: 12) {
                    // Date
                    Text(DateFormatter.timeOnly.string(from: entry.date))
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    // Location
                    if let location = entry.location?.name {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.caption)
                            Text(location)
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                    }
                    
                    // Mood
                    if let mood = entry.mood {
                        Text(mood.emoji)
                            .font(.caption)
                    }
                    
                    // Bookmark indicator
                    if entry.isBookmarked {
                        Image(systemName: "bookmark.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                    
                    Spacer()
                    
                    // Word count
                    if entry.wordCount > 0 {
                        Text("\(entry.wordCount) words")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6).opacity(0.1))
                    .stroke(Color(.systemGray5).opacity(0.2), lineWidth: 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SearchMediaPreview: View {
    let mediaItem: MediaItem
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 60)
            
            switch mediaItem.type {
            case .photo:
                if let image = UIImage(data: mediaItem.data) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipped()
                        .cornerRadius(8)
                }
            case .voice:
                VStack(spacing: 2) {
                    Image(systemName: "waveform")
                        .foregroundColor(.pink)
                        .font(.caption)
                    Text("Voice")
                        .font(.caption2)
                        .foregroundColor(.pink)
                }
            case .video:
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
    }
}

struct HighlightedText: View {
    let text: String
    let searchText: String
    
    private var attributedText: AttributedString {
        if searchText.isEmpty {
            // FIXED: Use themed AttributedString to prevent invisible text
            return SimpleRichTextEditor.createThemedAttributedString(from: text)
        }
        
        let parts = text.components(separatedBy: searchText)
        if parts.count > 1 {
            let nsString = NSMutableAttributedString(string: text)
            // LANDMARK: Ensure base text has proper theme color
            let fullRange = NSRange(location: 0, length: nsString.length)
            nsString.addAttribute(.foregroundColor, value: UIColor(Color.puchiText), range: fullRange)
            
            let range = NSString(string: text).range(of: searchText, options: .caseInsensitive)
            if range.location != NSNotFound {
                nsString.addAttribute(.backgroundColor, value: UIColor.systemPink, range: range)
                nsString.addAttribute(.foregroundColor, value: UIColor.white, range: range)
            }
            return AttributedString(nsString)
        } else {
            // FIXED: Use themed AttributedString to prevent invisible text
            return SimpleRichTextEditor.createThemedAttributedString(from: text)
        }
    }
    
    var body: some View {
        Text(attributedText)
            .foregroundColor(.white)
    }
}

#Preview {
    SearchView()
        .environment(AppState())
        .preferredColorScheme(.dark)
}