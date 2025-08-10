import SwiftUI

struct EntryCardView: View {
    @Environment(AppState.self) private var appState
    let entry: LoveEntry
    @State private var showingDeleteAlert = false
    
    var body: some View {
        Button(action: {
            // Edit entry action
            appState.startEditingEntry(entry)
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Title (if exists)
                if !entry.title.isEmpty {
                    Text(entry.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Content (with rich text support)
                if !entry.content.isEmpty {
                    Text(entry.attributedContent)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Media grid (Journal-style)
                if !entry.mediaItems.isEmpty {
                    MediaGridView(mediaItems: entry.mediaItems)
                }
                
                // Metadata footer
                HStack(spacing: 12) {
                    Text(DateFormatter.timeOnly.string(from: entry.date))
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if let location = entry.location {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.caption)
                            Text(location.name)
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                    }
                    
                    Spacer()
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
        .contextMenu {
            Button(action: {
                // Edit action
                appState.startEditingEntry(entry)
            }) {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(role: .destructive, action: {
                showingDeleteAlert = true
            }) {
                Label("Delete", systemImage: "trash")
            }
        }
        .alert("Delete Memory?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                withAnimation(.easeInOut) {
                    appState.deleteEntry(entry)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This memory will be moved to Recently Deleted where you can recover it for 30 days.")
        }
    }
}

struct MediaGridView: View {
    let mediaItems: [MediaItem]
    private let spacing: CGFloat = 4
    
    var body: some View {
        if mediaItems.count == 1 {
            // Single large media like Journal
            MediaItemView(mediaItem: mediaItems[0])
                .aspectRatio(16/9, contentMode: .fit)
                .cornerRadius(8)
        } else {
            // Grid for multiple items
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: spacing),
                GridItem(.flexible(), spacing: spacing)
            ], spacing: spacing) {
                ForEach(mediaItems) { item in
                    MediaItemView(mediaItem: item)
                        .aspectRatio(1, contentMode: .fill)
                        .cornerRadius(8)
                        .clipped()
                }
            }
        }
    }
}

struct MediaItemView: View {
    let mediaItem: MediaItem
    
    var body: some View {
        ZStack {
            switch mediaItem.type {
            case .photo:
                if let image = UIImage(data: mediaItem.data) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
            case .voice:
                Rectangle()
                    .fill(Color.pink.opacity(0.2))
                    .overlay(
                        VStack(spacing: 4) {
                            Image(systemName: "waveform")
                                .foregroundColor(.pink)
                            Text("Voice Note")
                                .font(.caption2)
                                .foregroundColor(.pink)
                        }
                    )
            case .video:
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.6))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "play.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                        }
                    )
            }
        }
    }
}

extension DateFormatter {
    static let timeOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        EntryCardView(entry: LoveEntry(
            title: "Perfect Morning",
            content: "Woke up to the most beautiful sunrise with you by my side. These are the moments I treasure most.",
            date: Date(),
            mediaItems: [],
            location: LocationInfo(name: "Our Bedroom", coordinate: nil)
        ))
        .padding()
    }
    .environment(AppState())
    .preferredColorScheme(.dark)
}