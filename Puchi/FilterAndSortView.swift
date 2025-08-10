import SwiftUI

struct FilterAndSortView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Filter Section
                        FilterSectionView()
                        
                        // Sort Section
                        SortSectionView()
                        
                        // Reset Section
                        ResetSectionView()
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Filter & Sort")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.pink)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.pink)
                }
            }
        }
    }
}

struct FilterSectionView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .foregroundColor(.pink)
                Text("Filter Memories")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(EntryFilter.allCases, id: \.self) { filter in
                    FilterOptionView(
                        filter: filter,
                        isSelected: appState.selectedFilter == filter
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            appState.selectedFilter = filter
                        }
                    }
                }
            }
        }
    }
}

struct FilterOptionView: View {
    let filter: EntryFilter
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: filter.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .gray)
                
                Text(filter.rawValue)
                    .font(.subheadline)
                    .foregroundColor(isSelected ? .white : .gray)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.clear)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SortSectionView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "arrow.up.arrow.down")
                    .foregroundColor(.pink)
                Text("Sort Memories")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            // Sort options
            VStack(spacing: 12) {
                ForEach(EntrySortOption.allCases, id: \.self) { sortOption in
                    SortOptionView(
                        sortOption: sortOption,
                        isSelected: appState.sortOption == sortOption,
                        isAscending: appState.sortAscending
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if appState.sortOption == sortOption {
                                // Toggle direction if same option
                                appState.sortAscending.toggle()
                            } else {
                                // Select new option with default direction
                                appState.sortOption = sortOption
                                appState.sortAscending = false
                            }
                        }
                    }
                }
            }
        }
    }
}

struct SortOptionView: View {
    let sortOption: EntrySortOption
    let isSelected: Bool
    let isAscending: Bool
    let action: () -> Void
    
    private var directionText: String {
        switch sortOption {
        case .entryDate, .creationDate:
            return isAscending ? "Oldest First" : "Newest First"
        case .title:
            return isAscending ? "A to Z" : "Z to A"
        case .wordCount:
            return isAscending ? "Shortest First" : "Longest First"
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: sortOption.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .pink : .gray)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(sortOption.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? .white : .gray)
                    
                    if isSelected {
                        Text(directionText)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    HStack(spacing: 4) {
                        Image(systemName: isAscending ? "arrow.up" : "arrow.down")
                            .font(.caption)
                            .foregroundColor(.pink)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.pink)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.pink.opacity(0.1) : Color.clear)
                    .stroke(isSelected ? Color.pink.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ResetSectionView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Button(action: resetFiltersAndSort) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.orange)
                    Text("Reset to Default")
                        .foregroundColor(.orange)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.orange.opacity(0.1))
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
            }
            
            Text("This will reset filters to 'All' and sorting to 'Newest First'")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }
    
    private func resetFiltersAndSort() {
        withAnimation(.easeInOut(duration: 0.3)) {
            appState.selectedFilter = .all
            appState.sortOption = .entryDate
            appState.sortAscending = false
        }
        
        // Auto-dismiss after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
}

#Preview {
    FilterAndSortView()
        .environment(AppState())
        .preferredColorScheme(.dark)
}