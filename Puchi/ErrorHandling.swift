import Foundation
import SwiftUI
import CoreLocation

// MARK: - Error Types
enum PuchiError: LocalizedError {
    case invalidNoteData
    case mediaProcessingFailed
    case locationAccessDenied
    case storageQuotaExceeded
    case dataCorruption
    case permissionDenied(String)
    case networkUnavailable
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidNoteData:
            return "Unable to save note. Please check your input and try again."
        case .mediaProcessingFailed:
            return "Failed to process media. Please try selecting a different file."
        case .locationAccessDenied:
            return "Location access is required to tag your notes. Please enable it in Settings."
        case .storageQuotaExceeded:
            return "Storage limit reached. Please remove some media to continue."
        case .dataCorruption:
            return "Some data appears corrupted. The app will attempt to recover."
        case .permissionDenied(let permission):
            return "\(permission) permission is required for this feature. Please enable it in Settings."
        case .networkUnavailable:
            return "Network connection is required for this feature."
        case .unknownError(let message):
            return "An unexpected error occurred: \(message)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidNoteData:
            return "Make sure your note has text and try saving again."
        case .mediaProcessingFailed:
            return "Try selecting a different photo or video, or restart the app."
        case .locationAccessDenied:
            return "Go to Settings > Privacy & Security > Location Services to enable location access."
        case .storageQuotaExceeded:
            return "Delete some photos or videos from your notes to free up space."
        case .dataCorruption:
            return "The app will try to recover your data automatically."
        case .permissionDenied:
            return "Go to Settings > Privacy & Security to enable the required permission."
        case .networkUnavailable:
            return "Check your internet connection and try again."
        case .unknownError:
            return "Try restarting the app or contact support if the problem persists."
        }
    }
}

// MARK: - Error Handler
@MainActor
class ErrorHandler: ObservableObject {
    @Published var currentError: PuchiError?
    @Published var showingError = false
    
    func handle(_ error: Error) {
        let puchiError: PuchiError
        
        if let locationError = error as? CLError {
            puchiError = handleLocationError(locationError)
        } else if let puchiErr = error as? PuchiError {
            puchiError = puchiErr
        } else {
            puchiError = .unknownError(error.localizedDescription)
        }
        
        currentError = puchiError
        showingError = true
        
        // Log error for debugging (without user data)
        logError(puchiError)
    }
    
    private func handleLocationError(_ error: CLError) -> PuchiError {
        switch error.code {
        case .denied:
            return .locationAccessDenied
        case .network:
            return .networkUnavailable
        case .locationUnknown:
            return .unknownError("Unable to determine location")
        default:
            return .unknownError("Location error: \(error.localizedDescription)")
        }
    }
    
    private func logError(_ error: PuchiError) {
        print("PuchiError: \(error.localizedDescription ?? "Unknown error")")
        if let recovery = error.recoverySuggestion {
            print("Recovery: \(recovery)")
        }
    }
    
    func clearError() {
        currentError = nil
        showingError = false
    }
}

// MARK: - Data Validation
struct DataValidator {
    static func validateNote(_ note: String, partnerName: String) -> Result<Void, PuchiError> {
        guard !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .failure(.invalidNoteData)
        }
        
        guard !partnerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .failure(.invalidNoteData)
        }
        
        return .success(())
    }
    
    static func validateMediaSize(_ mediaItems: [MediaItem]) -> Result<Void, PuchiError> {
        let maxSizeInBytes = 50 * 1024 * 1024 // 50MB
        let totalSize = mediaItems.reduce(0) { $0 + $1.data.count }
        
        guard totalSize <= maxSizeInBytes else {
            return .failure(.storageQuotaExceeded)
        }
        
        return .success(())
    }
    
    static func validateMediaData(_ data: Data, type: MediaType) -> Result<Void, PuchiError> {
        guard !data.isEmpty else {
            return .failure(.mediaProcessingFailed)
        }
        
        // Basic validation based on type
        switch type {
        case .image:
            guard UIImage(data: data) != nil else {
                return .failure(.mediaProcessingFailed)
            }
        case .video:
            // Basic size check for video
            guard data.count > 1000 else { // Minimum reasonable video size
                return .failure(.mediaProcessingFailed)
            }
        }
        
        return .success(())
    }
}

// MARK: - Safe Data Operations
extension UserDefaults {
    func safeSet<T: Codable>(_ object: T, forKey key: String) -> Result<Void, PuchiError> {
        do {
            let data = try JSONEncoder().encode(object)
            set(data, forKey: key)
            return .success(())
        } catch {
            return .failure(.dataCorruption)
        }
    }
    
    func safeGet<T: Codable>(_ type: T.Type, forKey key: String) -> Result<T?, PuchiError> {
        guard let data = data(forKey: key) else {
            return .success(nil)
        }
        
        do {
            let object = try JSONDecoder().decode(type, from: data)
            return .success(object)
        } catch {
            return .failure(.dataCorruption)
        }
    }
}

// MARK: - Permission Helper
struct PermissionHelper {
    static func checkCameraPermission() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    static func checkPhotoLibraryPermission() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
    static func checkLocationPermission() -> Bool {
        let status = CLLocationManager().authorizationStatus
        return status == .authorizedWhenInUse || status == .authorizedAlways
    }
    
    static func requestCameraPermission() async -> Bool {
        return await AVCaptureDevice.requestAccess(for: .video)
    }
    
    static func requestPhotoLibraryPermission() async -> PHAuthorizationStatus {
        return await PHPhotoLibrary.requestAuthorization(for: .readWrite)
    }
}

// MARK: - Error Alert View
struct ErrorAlertView: ViewModifier {
    @ObservedObject var errorHandler: ErrorHandler
    
    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: $errorHandler.showingError) {
                Button("OK") {
                    errorHandler.clearError()
                }
                if let error = errorHandler.currentError,
                   error.recoverySuggestion != nil {
                    Button("Settings") {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                        errorHandler.clearError()
                    }
                }
            } message: {
                if let error = errorHandler.currentError {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(error.localizedDescription)
                        if let recovery = error.recoverySuggestion {
                            Text(recovery)
                                .font(.caption)
                        }
                    }
                }
            }
    }
}

extension View {
    func errorAlert(_ errorHandler: ErrorHandler) -> some View {
        modifier(ErrorAlertView(errorHandler: errorHandler))
    }
}