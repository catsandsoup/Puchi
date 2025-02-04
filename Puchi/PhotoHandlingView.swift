//
//  PhotoHandlingView.swift
//  Puchi
//
//  Created by Monty Giovenco on 1/2/2025.
//

import SwiftUI
import PhotosUI

struct PhotoHandlingView: View {
    @Binding var selectedPhoto: PhotosPickerItem?
    @Binding var partnerImageData: Data?
    @Binding var isImageLoading: Bool
    @Binding var showImageError: Bool
    @Binding var showPhotoConfirmation: Bool
    @State private var tempUIImage: UIImage?
    
    var body: some View {
        EmptyView()
            .onChange(of: selectedPhoto) { oldItem, newItem in
                Task {
                    await handlePhotoSelection(newItem)
                }
            }
            .alert("Image Error", isPresented: $showImageError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("There was an error loading your image. Please try again.")
            }
            .alert("Confirm Photo", isPresented: $showPhotoConfirmation) {
                Button("Use Photo") {
                    saveSelectedPhoto()
                }
                Button("Cancel", role: .cancel) {
                    cancelPhotoSelection()
                }
            } message: {
                Text("Would you like to use this photo?")
            }
    }
    
    // MARK: - Private Methods
    private func handlePhotoSelection(_ item: PhotosPickerItem?) async {
        isImageLoading = true
        do {
            if let data = try await item?.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    tempUIImage = uiImage
                    showPhotoConfirmation = true
                } else {
                    showImageError = true
                }
            } else {
                if item != nil {
                    showImageError = true
                }
            }
        } catch {
            showImageError = true
        }
        isImageLoading = false
    }
    
    private func saveSelectedPhoto() {
        if let uiImage = tempUIImage,
           let optimizedData = uiImage.optimizedForStorage() {
            UserDefaults.standard.set(optimizedData, forKey: "partnerImageData")
            withAnimation {
                partnerImageData = optimizedData
            }
        }
        clearPhotoSelection()
    }
    
    private func cancelPhotoSelection() {
        clearPhotoSelection()
    }
    
    private func clearPhotoSelection() {
        selectedPhoto = nil
        tempUIImage = nil
    }
}

#Preview {
    PhotoHandlingView(
        selectedPhoto: .constant(nil),
        partnerImageData: .constant(nil),
        isImageLoading: .constant(false),
        showImageError: .constant(false),
        showPhotoConfirmation: .constant(false)
    )
}
