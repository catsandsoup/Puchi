//
//  MediaPicker.swift
//  Puchi
//
//  Created by Monty Giovenco on 29/1/2025.
//

import SwiftUI
import UIKit
import AVFoundation
import Photos
import PhotosUI

// Enhanced MediaPicker with multiple selection support
struct MediaPicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let allowsMultipleSelection: Bool
    let onMediaSelected: ([MediaItem]) -> Void
    @Environment(\.presentationMode) private var presentationMode
    
    init(sourceType: UIImagePickerController.SourceType, 
         allowsMultipleSelection: Bool = true,
         onMediaSelected: @escaping ([MediaItem]) -> Void) {
        self.sourceType = sourceType
        self.allowsMultipleSelection = allowsMultipleSelection
        self.onMediaSelected = onMediaSelected
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        if sourceType == .camera {
            // Use UIImagePickerController for camera
            let picker = UIImagePickerController()
            picker.sourceType = sourceType
            picker.delegate = context.coordinator
            picker.mediaTypes = ["public.image", "public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = false
            return picker
        } else {
            // Use PHPickerViewController for photo library with multiple selection
            var configuration = PHPickerConfiguration()
            configuration.filter = .any(of: [.images, .videos])
            configuration.selectionLimit = allowsMultipleSelection ? 0 : 1 // 0 means no limit
            
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = context.coordinator
            return picker
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
        let parent: MediaPicker
        
        init(_ parent: MediaPicker) {
            self.parent = parent
        }
        
        // MARK: - UIImagePickerController Delegate (for camera)
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            var mediaItems: [MediaItem] = []
            
            if let image = info[.originalImage] as? UIImage,
               let data = image.optimizedForStorage() {
                let mediaItem = MediaItem(data: data, type: .image, filename: "camera_image_\(UUID().uuidString).jpg")
                mediaItems.append(mediaItem)
            } else if let videoURL = info[.mediaURL] as? URL {
                do {
                    let data = try Data(contentsOf: videoURL)
                    let mediaItem = MediaItem(data: data, type: .video, filename: "camera_video_\(UUID().uuidString).mp4")
                    mediaItems.append(mediaItem)
                } catch {
                    print("Failed to load video data: \(error)")
                }
            }
            
            parent.onMediaSelected(mediaItems)
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        // MARK: - PHPickerViewController Delegate (for photo library)
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard !results.isEmpty else { return }
            
            Task {
                var mediaItems: [MediaItem] = []
                
                for result in results {
                    if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                        // Handle image
                        if let data = try? await loadImageData(from: result.itemProvider) {
                            let filename = "library_image_\(UUID().uuidString).jpg"
                            let mediaItem = MediaItem(data: data, type: .image, filename: filename)
                            mediaItems.append(mediaItem)
                        }
                    } else if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                        // Handle video
                        if let data = try? await loadVideoData(from: result.itemProvider) {
                            let filename = "library_video_\(UUID().uuidString).mp4"
                            let mediaItem = MediaItem(data: data, type: .video, filename: filename)
                            mediaItems.append(mediaItem)
                        }
                    }
                }
                
                await MainActor.run {
                    parent.onMediaSelected(mediaItems)
                }
            }
        }
        
        // MARK: - Helper Methods
        private func loadImageData(from itemProvider: NSItemProvider) async throws -> Data? {
            return try await withCheckedThrowingContinuation { continuation in
                itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    guard let image = object as? UIImage,
                          let data = image.optimizedForStorage() else {
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    continuation.resume(returning: data)
                }
            }
        }
        
        private func loadVideoData(from itemProvider: NSItemProvider) async throws -> Data? {
            return try await withCheckedThrowingContinuation { continuation in
                itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    guard let url = url else {
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    do {
                        // Compress video before converting to data
                        Task {
                            let compressedData = await self.compressVideo(at: url)
                            continuation.resume(returning: compressedData)
                        }
                    }
                }
            }
        }
        
        private func compressVideo(at url: URL) async -> Data? {
            let asset = AVAsset(url: url)
            
            guard let exportSession = AVAssetExportSession(
                asset: asset,
                presetName: AVAssetExportPresetMediumQuality
            ) else {
                return try? Data(contentsOf: url)
            }
            
            let outputURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mp4")
            
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .mp4
            
            await exportSession.export()
            
            defer {
                try? FileManager.default.removeItem(at: outputURL)
            }
            
            return try? Data(contentsOf: outputURL)
        }
    }
}

