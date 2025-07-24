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
                
                // Love Note Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Today's Love Note")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.puchiPrimary)
                    
                    // Note Input - Increased size to reduce white space
                    NoteEntryView(
                        text: $viewModel.loveNote,
                        isFocused: _isTextFieldFocused,
                        placeholder: "Write something sweet for \(partnerName)..."
                    )
                    .puchiInput()
                    .frame(maxWidth: .infinity)
                    .frame(height: 350) // Increased from 300 to 350 to reduce white space
                    
                    // Media Preview
                    if !viewModel.selectedImages.isEmpty || !viewModel.selectedVideos.isEmpty {
                        MediaPreviewView(
                            mediaItem: MediaItem(
                                data: viewModel.selectedImages.first?.jpegData(compressionQuality: 0.8) ?? Data(),
                                type: .image
                            )
                        )
                    }
                    
                    // Action Buttons - Centered with improved layout
                    HStack {
                        Spacer()
                        
                        HStack(spacing: 32) {
                            // Add Media Button
                            Button(action: {
                                HapticManager.medium()
                                viewModel.showSourceTypeSheet = true
                            }) {
                                Label("Add Media", systemImage: "photo.fill")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .buttonStyle(ScaleButtonStyle())
                            
                            // Add Location Button
                            Button(action: {
                                HapticManager.medium()
                                viewModel.requestLocationPermission()
                                viewModel.startCapturingLocation()
                            }) {
                                Label(
                                    viewModel.currentLocation == nil ? "Add Location" : "Location Added",
                                    systemImage: viewModel.currentLocation == nil ? "location" : "location.fill"
                                )
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                        
                        Spacer()
                    }
                    .foregroundColor(.puchiPrimary)
                    
                    // Location Label
                    if let location = viewModel.currentLocation {
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
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.background)
                        .shadow(color: .black.opacity(0.05), radius: 10)
                )
                .padding(.horizontal)
            }
            .padding(.bottom, 20)
        }
        .background(Color.puchiBackground)
        .onTapGesture {
            isTextFieldFocused = false
        }
        .gesture(
            DragGesture()
                .onChanged { _ in
                    isTextFieldFocused = false
                }
        )
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
