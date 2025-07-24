import SwiftUI
import UIKit
import AVFoundation

@MainActor
class MediaManager: ObservableObject {
    @Published var selectedMedia: [MediaItem] = []
    @Published var isShowingPicker = false
    @Published var isProcessing = false
    
    // MARK: - Media Management
    
    func addMedia(_ items: [MediaItem]) {
        selectedMedia.append(contentsOf: items)
    }
    
    func addImage(_ image: UIImage, filename: String = "") {
        guard let data = image.optimizedForStorage() else { return }
        let mediaItem = MediaItem(data: data, type: .image, filename: filename)
        selectedMedia.append(mediaItem)
    }
    
    func addVideo(from url: URL, filename: String = "") {
        do {
            let data = try Data(contentsOf: url)
            let mediaItem = MediaItem(data: data, type: .video, filename: filename)
            selectedMedia.append(mediaItem)
        } catch {
            print("Failed to add video: \(error.localizedDescription)")
        }
    }
    
    func removeMedia(at index: Int) {
        guard index >= 0 && index < selectedMedia.count else { return }
        selectedMedia.remove(at: index)
    }
    
    func removeMedia(withId id: UUID) {
        selectedMedia.removeAll { $0.id == id }
    }
    
    func clearAllMedia() {
        selectedMedia.removeAll()
    }
    
    // MARK: - Media Processing
    
    func processImages(_ images: [UIImage]) async {
        isProcessing = true
        defer { isProcessing = false }
        
        for image in images {
            addImage(image)
        }
    }
    
    func processVideos(_ urls: [URL]) async {
        isProcessing = true
        defer { isProcessing = false }
        
        for url in urls {
            addVideo(from: url)
        }
    }
    
    // MARK: - Utility Methods
    
    var hasMedia: Bool {
        return !selectedMedia.isEmpty
    }
    
    var mediaCount: Int {
        return selectedMedia.count
    }
    
    var imageCount: Int {
        return selectedMedia.filter { $0.type == .image }.count
    }
    
    var videoCount: Int {
        return selectedMedia.filter { $0.type == .video }.count
    }
    
    func getMediaItems(of type: MediaType) -> [MediaItem] {
        return selectedMedia.filter { $0.type == type }
    }
    
    // MARK: - Data Conversion
    
    func getImages() -> [MediaItem] {
        return getMediaItems(of: .image)
    }
    
    func getVideos() -> [MediaItem] {
        return getMediaItems(of: .video)
    }
    
    // MARK: - Validation
    
    func validateMediaSize() -> Bool {
        let maxSizeInBytes = 50 * 1024 * 1024 // 50MB limit
        let totalSize = selectedMedia.reduce(0) { $0 + $1.data.count }
        return totalSize <= maxSizeInBytes
    }
    
    func getMediaSizeInMB() -> Double {
        let totalBytes = selectedMedia.reduce(0) { $0 + $1.data.count }
        return Double(totalBytes) / (1024 * 1024)
    }
}

// MARK: - Media Processing Extensions

extension MediaManager {
    
    /// Compress video data for storage efficiency
    func compressVideo(data: Data) async -> Data? {
        // Create temporary file
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp4")
        
        do {
            try data.write(to: tempURL)
            
            let asset = AVAsset(url: tempURL)
            
            guard let exportSession = AVAssetExportSession(
                asset: asset,
                presetName: AVAssetExportPresetMediumQuality
            ) else {
                try? FileManager.default.removeItem(at: tempURL)
                return nil
            }
            
            let outputURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mp4")
            
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .mp4
            
            await exportSession.export()
            
            let compressedData = try Data(contentsOf: outputURL)
            
            // Clean up temporary files
            try? FileManager.default.removeItem(at: tempURL)
            try? FileManager.default.removeItem(at: outputURL)
            
            return compressedData
        } catch {
            print("Video compression failed: \(error.localizedDescription)")
            try? FileManager.default.removeItem(at: tempURL)
            return nil
        }
    }
}