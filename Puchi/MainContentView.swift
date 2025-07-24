import SwiftUI
import PhotosUI
import AVKit
import CoreLocation

struct MainContent: View {
    let partnerName: String
    @ObservedObject var viewModel: LoveJournalViewModel
    @Binding var partnerImageData: Data?
    @Binding var selectedPhoto: PhotosPickerItem?
    @FocusState var isTextFieldFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Partner Header
                PartnerHeaderView(
                    partnerName: partnerName,
                    partnerImageData: partnerImageData,
                    selectedPhoto: $selectedPhoto
                )
                
                // Streak Card
                StreakCardView(streakCount: viewModel.currentStreak)
                    .transition(.scale)
                
                // Love Note Section - Increased size to reduce white space
                VStack(alignment: .leading, spacing: 16) {
                    Text("Today's Love Note")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.puchiPrimary)
                    
                    // Note Input - Seamless text input like Tinder
                    NoteEntryView(
                        text: $viewModel.loveNote,
                        isFocused: _isTextFieldFocused,
                        placeholder: "Write something sweet for \(partnerName)..."
                    )
                    .frame(maxWidth: .infinity)
                    
                    // Media Preview Grid
                    if !viewModel.mediaManager.selectedMedia.isEmpty {
                        MediaPreviewGrid(
                            mediaItems: viewModel.mediaManager.selectedMedia,
                            onRemove: { index in
                                HapticManager.light()
                                viewModel.removeMediaItem(at: index)
                            }
                        )
                    }
                    
                    // Action Buttons - Properly centered with improved layout
                    HStack {
                        Spacer()
                        
                        HStack(spacing: 40) {
                            // Add Media Button
                            Button(action: {
                                HapticManager.medium()
                                viewModel.showSourceTypeSheet = true
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "photo.fill")
                                        .font(.system(size: 20, weight: .medium))
                                    Text("Media")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                }
                            }
                            .buttonStyle(ScaleButtonStyle())
                            .foregroundColor(.puchiPrimary)
                            
                            // Add Location Button
                            Button(action: {
                                HapticManager.medium()
                                if viewModel.currentLocation == nil {
                                    viewModel.requestLocationPermission()
                                    viewModel.startCapturingLocation()
                                } else {
                                    viewModel.removeLocation()
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: viewModel.currentLocation == nil ? "location" : "location.fill")
                                        .font(.system(size: 20, weight: .medium))
                                    Text(viewModel.currentLocation == nil ? "Location" : "Remove")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                }
                            }
                            .buttonStyle(ScaleButtonStyle())
                            .foregroundColor(viewModel.currentLocation == nil ? .puchiPrimary : .red)
                        }
                        
                        Spacer()
                    }
                    
                    // Location Label
                    if let location = viewModel.currentLocation {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.puchiPrimary)
                            Text(location.placeName)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.textSecondary)
                            Spacer()
                            Button("Remove") {
                                HapticManager.light()
                                viewModel.removeLocation()
                            }
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.red)
                        }
                        .padding(.horizontal)
                        .transition(.opacity)
                    }
                    
                    // Save Button
                    Button(action: {
                        HapticManager.success()
                        withAnimation(PuchiAnimation.spring) {
                            viewModel.saveLoveNote()
                        }
                    }) {
                        Label("Save This Moment", systemImage: "heart.fill")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                viewModel.loveNote.isEmpty ?
                                Color.puchiPrimary.opacity(0.6) :
                                Color.puchiPrimary
                            )
                            .cornerRadius(16)
                    }
                    .buttonStyle(PressableButtonStyle())
                    .disabled(viewModel.loveNote.isEmpty)
                }
                .padding(20) // Increased padding for better spacing
                .background(
                    RoundedRectangle(cornerRadius: 20) // Slightly more rounded corners
                        .fill(Color.background)
                        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
                )
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 20)
        }
        .background(Color.puchiBackground)
        .contentShape(Rectangle())
        .onTapGesture {
            isTextFieldFocused = false
        }
        .gesture(
            DragGesture()
                .onChanged { _ in
                    isTextFieldFocused = false
                }
        )
        .onAppear {
            // Ensure keyboard dismisses when view appears
            isTextFieldFocused = false
        }
        .sheet(isPresented: $viewModel.showSourceTypeSheet) {
            MediaPicker(
                sourceType: viewModel.selectedSourceType,
                allowsMultipleSelection: true,
                onMediaSelected: { mediaItems in
                    viewModel.addMediaItems(mediaItems)
                }
            )
        }
    }
}
// MARK: - Media Preview Components
struct MediaPreviewGrid: View {
    let mediaItems: [MediaItem]
    let onRemove: (Int) -> Void
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(mediaItems.enumerated()), id: \.element.id) { index, item in
                MediaPreviewCard(
                    mediaItem: item,
                    onRemove: { onRemove(index) }
                )
            }
        }
        .padding(.horizontal, 16)
    }
}

struct MediaPreviewCard: View {
    let mediaItem: MediaItem
    let onRemove: () -> Void
    
    var body: some View {
        ZStack {
            // Media content
            Group {
                switch mediaItem.type {
                case .image:
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
                case .video:
                    VideoThumbnailView(data: mediaItem.data)
                        .overlay(
                            Image(systemName: "play.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .shadow(radius: 2)
                        )
                }
            }
            .frame(height: 100)
            .clipped()
            .cornerRadius(8)
            
            // Remove button
            VStack {
                HStack {
                    Spacer()
                    Button(action: onRemove) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding(4)
                }
                Spacer()
            }
            
            // Media type indicator
            VStack {
                Spacer()
                HStack {
                    Image(systemName: mediaItem.type.systemImage)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(4)
                    Spacer()
                }
                .padding(4)
            }
        }
    }
}

struct VideoThumbnailView: View {
    let data: Data
    @State private var thumbnail: UIImage?
    
    var body: some View {
        Group {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "video")
                            .foregroundColor(.gray)
                    )
            }
        }
        .onAppear {
            generateThumbnail()
        }
    }
    
    private func generateThumbnail() {
        Task {
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mp4")
            
            do {
                try data.write(to: tempURL)
                let asset = AVAsset(url: tempURL)
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                imageGenerator.appliesPreferredTrackTransform = true
                
                let time = CMTime(seconds: 1, preferredTimescale: 60)
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                
                await MainActor.run {
                    self.thumbnail = UIImage(cgImage: cgImage)
                }
                
                try? FileManager.default.removeItem(at: tempURL)
            } catch {
                print("Failed to generate video thumbnail: \(error)")
                try? FileManager.default.removeItem(at: tempURL)
            }
        }
    }
}