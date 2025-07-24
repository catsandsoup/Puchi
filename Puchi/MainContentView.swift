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
                    
                    // Media Preview
                    if !viewModel.selectedImages.isEmpty || !viewModel.selectedVideos.isEmpty {
                        MediaPreviewView(
                            mediaItem: MediaItem(
                                data: viewModel.selectedImages.first?.jpegData(compressionQuality: 0.8) ?? Data(),
                                type: .image
                            )
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
                onImageSelected: { image in
                    viewModel.addImage(image)
                },
                onVideoSelected: { url in
                    viewModel.addVideo(url)
                }
            )
        }
    }
}
