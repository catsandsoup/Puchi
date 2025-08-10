import SwiftUI

struct RecentlyDeletedView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var showingPermanentDeleteAlert = false
    @State private var entryToDelete: LoveEntry?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if appState.recentlyDeleted.isEmpty {
                            emptyStateView
                        } else {
                            ForEach(appState.recentlyDeleted, id: \.id) { entry in
                                RecentlyDeletedEntryCard(
                                    entry: entry,
                                    onRestore: { 
                                        withAnimation(.spring()) {
                                            appState.restoreEntry(entry)
                                        }
                                    },
                                    onPermanentDelete: {
                                        entryToDelete = entry
                                        showingPermanentDeleteAlert = true
                                    }
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Recently Deleted")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.pink)
                }
            }
            .alert("Permanently Delete Entry?", isPresented: $showingPermanentDeleteAlert, presenting: entryToDelete) { entry in
                Button("Delete Forever", role: .destructive) {
                    withAnimation {
                        appState.permanentlyDeleteEntry(entry)
                    }
                    entryToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    entryToDelete = nil
                }
            } message: { entry in
                Text("This entry will be permanently deleted and cannot be recovered. This action cannot be undone.")
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "trash.circle")
                .font(.system(size: 64))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 12) {
                Text("No Recently Deleted Entries")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Deleted entries will appear here and be automatically removed after 30 days.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
    }
}

struct RecentlyDeletedEntryCard: View {
    let entry: LoveEntry
    let onRestore: () -> Void
    let onPermanentDelete: () -> Void
    
    private var daysRemaining: Int {
        guard let deletedDate = entry.deletedDate else { return 30 }
        let thirtyDaysLater = Calendar.current.date(byAdding: .day, value: 30, to: deletedDate) ?? Date()
        let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: thirtyDaysLater).day ?? 0
        return max(0, daysLeft)
    }
    
    private var deletionDateText: String {
        guard let deletedDate = entry.deletedDate else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return "Deleted \(formatter.string(from: deletedDate))"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with deletion info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.title.isEmpty ? "Untitled Entry" : entry.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(deletionDateText)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if daysRemaining > 0 {
                        Text("\(daysRemaining) days left")
                            .font(.caption)
                            .foregroundColor(.orange)
                    } else {
                        Text("Expires today")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            
            // Content preview
            if !entry.content.isEmpty {
                Text(entry.content)
                    .font(.body)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
            
            // Media indicators
            if !entry.mediaItems.isEmpty {
                HStack(spacing: 8) {
                    ForEach(entry.mediaItems.prefix(3), id: \.id) { mediaItem in
                        Image(systemName: mediaItem.type.icon)
                            .font(.caption)
                            .foregroundColor(.pink)
                    }
                    
                    if entry.mediaItems.count > 3 {
                        Text("+\(entry.mediaItems.count - 3)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: onRestore) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Restore")
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(6)
                }
                
                Button(action: onPermanentDelete) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Forever")
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(6)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}


#Preview {
    RecentlyDeletedView()
        .environment(AppState())
}