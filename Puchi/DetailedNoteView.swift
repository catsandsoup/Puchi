import SwiftUI
import Photos
import AVKit

struct DetailedNoteView: View {
    let note: LoveNote
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Section
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Love Note #\(note.noteNumber)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.puchiPrimary)
                        
                        Text(note.dateFormatted)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.textSecondary)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .transition(.opacity)
                
                // Media Grid Section
                if let images = note.images, !images.isEmpty {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(images) { mediaItem in
                            if let uiImage = UIImage(data: mediaItem.data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .scale))
                }
                
                // Videos Grid Section
                if let videos = note.videos, !videos.isEmpty {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(videos) { mediaItem in
                            if let url = URL(dataRepresentation: mediaItem.data, relativeTo: nil) {
                                VideoPlayer(player: AVPlayer(url: url))
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .scale))
                }
                
                // Note Text Section
                Text(note.text)
                    .font(.system(size: 16, design: .rounded))
                    .lineSpacing(8)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .puchiCard()
                    .padding(.horizontal)
                    .transition(.opacity)
                
                // Location Section
                if let location = note.location {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.puchiPrimary)
                        Text(location.placeName)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.horizontal)
                    .transition(.opacity)
                }
            }
            .padding(.vertical)
        }
        .background(Color.puchiBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    HapticManager.light()
                    withAnimation(PuchiAnimation.easeOut) {
                        dismiss()
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.puchiPrimary)
                        .font(.system(size: 24))
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }
}
