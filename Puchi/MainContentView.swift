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
    
    // MARK: - Computed Properties
    private var locationButtonText: String {
        if viewModel.isCapturingLocation {
            return "Finding..."
        } else if viewModel.currentLocation != nil {
            return "Added"
        } else {
            return "Location"
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                noteCreationSection
            }
            .padding(.bottom, 32)
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
            isTextFieldFocused = false
        }
        .mediaPickerDialog(viewModel: viewModel)
        .errorAlert(viewModel.errorHandler)
        .discardAlert(isPresented: $viewModel.showingDiscardDraftConfirmation, onDiscard: {
            viewModel.discardDraft()
        })
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            PartnerHeaderView(
                partnerName: partnerName,
                partnerImageData: partnerImageData,
                selectedPhoto: $selectedPhoto
            )
            
            if viewModel.currentStreak > 0 {
                StreakCardView(streakCount: viewModel.currentStreak)
            }
        }
    }
    
    // MARK: - Note Creation Section
    private var noteCreationSection: some View {
        VStack(spacing: 20) {
            // Text Input Area
            NoteEntryView(
                text: $viewModel.loveNote,
                isFocused: _isTextFieldFocused,
                placeholder: "Write a love note to \(partnerName)..."
            )
            
            // Media & Location Controls
            mediaControlsSection
            
            // Media Preview
            if !viewModel.mediaManager.selectedMedia.isEmpty {
                MediaPreviewGrid(
                    mediaItems: viewModel.mediaManager.selectedMedia,
                    onRemove: { index in
                        viewModel.removeMediaItem(at: index)
                    }
                )
            }
            
            // Location Display
            if let location = viewModel.currentLocation {
                locationDisplaySection(location)
            }
            
            // Save Button
            saveButtonSection
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Media Controls Section
    private var mediaControlsSection: some View {
        HStack(spacing: 16) {
            // Photo/Video Button
            DebouncedButton(debounceTime: 0.5) {
                HapticManager.light()
                viewModel.showSourceTypeSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "camera.fill")
                    Text("Add Media")
                    if viewModel.mediaManager.hasMedia {
                        Text("(\(viewModel.mediaManager.mediaCount))")
                            .font(.system(size: 14, weight: .medium))
                    }
                }
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.puchiPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 4)
            }
            .buttonStyle(ScaleButtonStyle())
            
            // Location Button
            Button {
                HapticManager.light()
                print("🔍 Location button tapped - isCapturingLocation: \(viewModel.isCapturingLocation)")
                if viewModel.currentLocation != nil {
                    viewModel.removeLocation()
                } else {
                    viewModel.startCapturingLocation()
                }
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isCapturingLocation {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.puchiPrimary)
                    } else {
                        Image(systemName: viewModel.currentLocation != nil ? "location.fill" : "location")
                    }
                    
                    Text(locationButtonText)
                }
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(viewModel.currentLocation != nil ? .white : .puchiPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(viewModel.currentLocation != nil ? Color.puchiPrimary : Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 4)
                .opacity(viewModel.isCapturingLocation ? 0.8 : 1.0)
            }
            .buttonStyle(ScaleButtonStyle())
            .disabled(viewModel.isCapturingLocation)
        }
    }
    
    // MARK: - Location Display Section
    private func locationDisplaySection(_ location: LocationData) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "location.fill")
                .foregroundColor(.puchiPrimary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Location")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                
                Text(location.placeName)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
            
            Button(action: {
                viewModel.removeLocation()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Save Button Section
    private var saveButtonSection: some View {
        DebouncedButton(debounceTime: 1.0) {
            HapticManager.medium()
            viewModel.saveLoveNote()
        } label: {
            HStack(spacing: 12) {
                if viewModel.isProcessing {
                    ProgressView()
                        .scaleEffect(0.9)
                        .tint(.white)
                } else {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 18))
                }
                
                Text(viewModel.isProcessing ? "Saving..." : "Save Love Note")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [Color.puchiPrimary, Color.puchiSecondary],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color.puchiPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(viewModel.loveNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isProcessing)
        .opacity((viewModel.loveNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isProcessing) ? 0.6 : 1.0)
        .padding(.horizontal, 16)
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
                            .font(.title2) // Slightly larger icon
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28) // Ensure minimum touch target
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                            .contentShape(Circle()) // Expand tap area
                    }
                    .buttonStyle(ScaleButtonStyle(scale: 0.9))
                    .padding(6) // Increased padding for easier tapping
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

// MARK: - View Modifier Extensions
extension View {
    func mediaPickerDialog(viewModel: LoveJournalViewModel) -> some View {
        self.confirmationDialog("Add Media", isPresented: Binding(
            get: { viewModel.showSourceTypeSheet },
            set: { viewModel.showSourceTypeSheet = $0 }
        ), titleVisibility: .visible) {
            Button("Camera") {
                viewModel.selectedSourceType = .camera
                viewModel.showMediaPicker = true
                viewModel.showSourceTypeSheet = false
            }
            
            Button("Photo Library") {
                viewModel.selectedSourceType = .photoLibrary
                viewModel.showMediaPicker = true
                viewModel.showSourceTypeSheet = false
            }
            
            Button("Cancel", role: .cancel) {
                viewModel.showSourceTypeSheet = false
            }
        } message: {
            Text("Choose how you'd like to add photos or videos to your love note")
        }
        .sheet(isPresented: Binding(
            get: { viewModel.showMediaPicker },
            set: { viewModel.showMediaPicker = $0 }
        )) {
            MediaPicker(
                sourceType: viewModel.selectedSourceType,
                onMediaSelected: { mediaItems in
                    viewModel.addMediaItems(mediaItems)
                    viewModel.showMediaPicker = false
                }
            )
        }
    }
    
    func discardAlert(isPresented: Binding<Bool>, onDiscard: @escaping () -> Void) -> some View {
        self.alert("Discard Draft?", isPresented: isPresented) {
            Button("Discard", role: .destructive) {
                onDiscard()
            }
            
            Button("Keep Editing", role: .cancel) { }
        } message: {
            Text("Are you sure you want to discard your current draft? This action cannot be undone.")
        }
    }
}