import SwiftUI
import CoreLocation
import AVKit

// MARK: - Core Application States (Steve Jobs Simplification)
enum AppState {
    case creating    // User is writing/editing their love note
    case saving     // Note is being saved (brief moment)
    case browsing   // User is viewing timeline
}

@MainActor
class LoveJournalViewModel: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var loveNote = "" {
        didSet {
            autoSaveDraft()
        }
    }
    @Published var currentStreak = 0
    @Published var savedNotes: [LoveNote] = []
    @Published var hasDraft = false
    
    // MARK: - Media Manager
    @Published var mediaManager = MediaManager()
    @Published var currentLocation: LocationData?
    @Published var isCapturingLocation = false
    @Published var locationProgress: Double = 0.0
    @Published var showSourceTypeSheet = false
    @Published var showMediaPicker = false
    @Published var selectedSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    // MARK: - Error Handling  
    @Published var errorHandler = ErrorHandler()
    @Published var isProcessing = false
    
    // MARK: - Confirmation Dialogs
    @Published var showingDiscardDraftConfirmation = false
    
    // MARK: - User Defaults
    @AppStorage("partnerName") var storedPartnerName = ""
    @AppStorage("isFirstTimeUser") var isFirstTimeUser = true
    @AppStorage("hasSeenMediaHint") var hasSeenMediaHint = false
    @AppStorage("hasSeenLocationHint") var hasSeenLocationHint = false
    
    // MARK: - Private Properties
    private let locationManager = CLLocationManager()
    private var locationTimeout: Timer?
    private var locationProgressTimer: Timer?
    private var draftSaveTimer: Timer?
    
    private var lastNoteDate: Date? {
        didSet {
            if let date = lastNoteDate {
                UserDefaults.standard.set(date, forKey: "lastNoteDate")
            }
        }
    }
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        loadNotes()
        loadDraft()
        lastNoteDate = UserDefaults.standard.object(forKey: "lastNoteDate") as? Date
        calculateStreak()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // MARK: - Media Management
    func addMediaItems(_ items: [MediaItem]) { mediaManager.addMedia(items) }
    func removeMediaItem(at index: Int) { mediaManager.removeMedia(at: index) }
    func clearAllMedia() { mediaManager.clearAllMedia() }
    
    // MARK: - Location Management
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startCapturingLocation() {
        print("🔍 Starting location capture - current state: \(isCapturingLocation)")
        
        // Reset state if we're stuck in capturing mode
        if isCapturingLocation {
            stopCapturingLocation()
        }
        
        // First check if location services are enabled on the device
        guard CLLocationManager.locationServicesEnabled() else {
            errorHandler.handle(PuchiError.unknownError("Location services are disabled on this device. Please enable them in Settings > Privacy & Security > Location Services."))
            return
        }
        
        let authStatus = locationManager.authorizationStatus
        print("🔍 Location authorization status: \(authStatus.rawValue)")
        
        switch authStatus {
        case .notDetermined:
            // Set up capturing state before requesting permission
            isCapturingLocation = true
            locationProgress = 0.0
            startLocationProgress()
            requestLocationPermission()
            
            // Set a shorter timeout for permission request
            locationTimeout = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { [weak self] _ in
                Task { @MainActor in
                    if self?.locationManager.authorizationStatus == .notDetermined {
                        self?.stopCapturingLocation()
                        self?.errorHandler.handle(PuchiError.locationAccessDenied)
                    }
                }
            }
        case .denied, .restricted:
            errorHandler.handle(PuchiError.locationAccessDenied)
            return
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationCapture()
        @unknown default:
            errorHandler.handle(PuchiError.unknownError("Unknown location authorization status"))
            return
        }
    }
    
    private func startLocationCapture() {
        isCapturingLocation = true
        locationProgress = 0.0
        
        // Configure location manager for better accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        locationManager.startUpdatingLocation()
        
        // Start progress animation
        startLocationProgress()
        
        // Set timeout for location capture (longer for actual location fetching)
        locationTimeout = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.stopCapturingLocation()
                self?.errorHandler.handleWithRetry(
                    PuchiError.unknownError("Location request timed out. This may be due to poor GPS signal. Try moving to an area with better sky visibility."),
                    retryAction: {
                        self?.startCapturingLocation()
                    }
                )
            }
        }
    }
    
    func stopCapturingLocation() {
        isCapturingLocation = false
        locationProgress = 0.0
        locationManager.stopUpdatingLocation()
        
        // Clean up all timers
        locationTimeout?.invalidate()
        locationProgressTimer?.invalidate()
        locationTimeout = nil
        locationProgressTimer = nil
    }
    
    private func startLocationProgress() {
        locationProgressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, self.isCapturingLocation else { return }
                
                self.locationProgress += 0.1 / 30.0 // Progress over 30 seconds
                if self.locationProgress >= 1.0 {
                    self.locationProgress = 1.0
                    self.locationProgressTimer?.invalidate()
                }
            }
        }
    }
    
    func removeLocation() {
        currentLocation = nil
        stopCapturingLocation()
    }
    
    // MARK: - Note Management
    func saveLoveNote() {
        isProcessing = true
        
        // Validate input
        let validationResult = DataValidator.validateNote(loveNote, partnerName: storedPartnerName)
        switch validationResult {
        case .failure(let error):
            errorHandler.handle(error)
            isProcessing = false
            return
        case .success:
            break
        }
        
        // Validate media size
        let allMedia = mediaManager.getImages() + mediaManager.getVideos()
        let mediaSizeResult = DataValidator.validateMediaSize(allMedia)
        switch mediaSizeResult {
        case .failure(let error):
            errorHandler.handle(error)
            isProcessing = false
            return
        case .success:
            break
        }
        
        // Use MediaManager's media items directly
        let imageItems = mediaManager.getImages()
        let videoItems = mediaManager.getVideos()
        
        let newNote = LoveNote(
            id: UUID(),
            text: loveNote,
            partnerName: storedPartnerName,
            date: Date(),
            noteNumber: savedNotes.count + 1,
            images: imageItems.isEmpty ? nil : imageItems,
            videos: videoItems.isEmpty ? nil : videoItems,
            location: currentLocation,
            tags: [],
            relatedMilestoneId: nil,
            relatedGoalId: nil,
            isFavorite: false
        )
        
        savedNotes.insert(newNote, at: 0)
        updateStreak(for: newNote.date)
        lastNoteDate = newNote.date
        
        // Clear the form and draft
        loveNote = ""
        clearAllMedia()
        currentLocation = .none
        clearDraft()
        
        saveNotes()
        isProcessing = false
    }
    
    func deleteNote(at indexSet: IndexSet) {
        savedNotes.remove(atOffsets: indexSet)
        saveNotes()
        calculateStreak()
    }
    
    // MARK: - Private Helper Methods
    private func calculateStreak() {
        guard let lastDate = lastNoteDate else {
            currentStreak = 0
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDate(lastDate, inSameDayAs: now) {
            return
        }
        
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        if calendar.isDate(lastDate, inSameDayAs: yesterday) {
            currentStreak += 1
        } else {
            currentStreak = 0
        }
    }
    
    private func updateStreak(for noteDate: Date) {
        let calendar = Calendar.current
        
        if let lastDate = lastNoteDate {
            if calendar.isDate(lastDate, inSameDayAs: noteDate) {
                return
            }
            
            let yesterday = calendar.date(byAdding: .day, value: -1, to: noteDate)!
            if calendar.isDate(lastDate, inSameDayAs: yesterday) {
                currentStreak += 1
            } else {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }
    }
    
    private func saveNotes() {
        let result = UserDefaults.standard.safeSet(savedNotes, forKey: "savedNotes")
        switch result {
        case .failure(let error):
            errorHandler.handle(error)
        case .success:
            break
        }
    }
    
    private func loadNotes() {
        let result = UserDefaults.standard.safeGet([LoveNote].self, forKey: "savedNotes")
        switch result {
        case .success(let notes):
            if let notes = notes {
                savedNotes = notes.sorted(by: { $0.date > $1.date })
            }
        case .failure(let error):
            errorHandler.handle(error)
            // Try to recover by clearing corrupted data
            UserDefaults.standard.removeObject(forKey: "savedNotes")
            savedNotes = []
        }
    }
    
    // MARK: - Draft Management
    private func autoSaveDraft() {
        // Debounce the save operation
        draftSaveTimer?.invalidate()
        draftSaveTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.saveDraft()
            }
        }
    }
    
    private func saveDraft() {
        if !loveNote.isEmpty || !mediaManager.selectedMedia.isEmpty || currentLocation != nil {
            let draftData = DraftData(
                text: loveNote,
                mediaData: mediaManager.selectedMedia,
                location: currentLocation,
                timestamp: Date()
            )
            
            if let encoded = try? JSONEncoder().encode(draftData) {
                UserDefaults.standard.set(encoded, forKey: "draftNote")
                hasDraft = true
            }
        } else {
            clearDraft()
        }
    }
    
    private func loadDraft() {
        guard let data = UserDefaults.standard.data(forKey: "draftNote"),
              let draftData = try? JSONDecoder().decode(DraftData.self, from: data) else {
            hasDraft = false
            return
        }
        
        // Only load draft if it's recent (within 24 hours)
        let hoursSinceDraft = Date().timeIntervalSince(draftData.timestamp) / 3600
        if hoursSinceDraft < 24 {
            loveNote = draftData.text
            mediaManager.selectedMedia = draftData.mediaData
            currentLocation = draftData.location
            hasDraft = true
        } else {
            clearDraft()
        }
    }
    
    func clearDraft() {
        UserDefaults.standard.removeObject(forKey: "draftNote")
        hasDraft = false
        draftSaveTimer?.invalidate()
    }
    
    func requestDiscardDraft() {
        // Show confirmation if there's meaningful content
        if !loveNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
           !mediaManager.selectedMedia.isEmpty || 
           currentLocation != nil {
            showingDiscardDraftConfirmation = true
        } else {
            discardDraft()
        }
    }
    
    func discardDraft() {
        loveNote = ""
        clearAllMedia()
        currentLocation = nil
        clearDraft()
    }
}

// MARK: - Draft Data Structure
struct DraftData: Codable {
    let text: String
    let mediaData: [MediaItem]
    let location: LocationData?
    let timestamp: Date
}

// MARK: - Location Manager Delegate
extension LoveJournalViewModel: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Validate location accuracy - reject if accuracy is poor
        guard location.horizontalAccuracy <= 100 && location.horizontalAccuracy > 0 else {
            // Continue waiting for better accuracy, don't return yet
            return
        }
        
        // Stop location updates immediately after getting good accuracy
        manager.stopUpdatingLocation()
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            Task { @MainActor in
                guard let self = self else { return }
                
                if let error = error {
                    // Handle reverse geocoding failure gracefully
                    print("Reverse geocoding failed: \(error.localizedDescription)")
                    
                    // Still save location with coordinates only
                    let coordinate = String(format: "%.4f, %.4f", location.coordinate.latitude, location.coordinate.longitude)
                    self.currentLocation = LocationData(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude,
                        placeName: "Location (\(coordinate))"
                    )
                    self.stopCapturingLocation()
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    // Fallback to coordinates if no placemark
                    let coordinate = String(format: "%.4f, %.4f", location.coordinate.latitude, location.coordinate.longitude)
                    self.currentLocation = LocationData(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude,
                        placeName: "Location (\(coordinate))"
                    )
                    self.stopCapturingLocation()
                    return
                }
                
                // Build place name with fallbacks
                var placeNameComponents: [String] = []
                
                if let name = placemark.name, !name.isEmpty {
                    placeNameComponents.append(name)
                }
                if let locality = placemark.locality, !locality.isEmpty {
                    placeNameComponents.append(locality)
                }
                if let adminArea = placemark.administrativeArea, !adminArea.isEmpty {
                    placeNameComponents.append(adminArea)
                }
                
                let placeName = placeNameComponents.isEmpty ? 
                    String(format: "%.4f, %.4f", location.coordinate.latitude, location.coordinate.longitude) :
                    placeNameComponents.joined(separator: ", ")
                
                self.currentLocation = LocationData(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    placeName: placeName
                )
                self.stopCapturingLocation()
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.stopCapturingLocation()
            
            // Provide more specific error messages based on error type
            let locationError: PuchiError
            
            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    locationError = .locationAccessDenied
                case .network:
                    locationError = .unknownError("Location services require a network connection. Please check your internet connection and try again.")
                case .locationUnknown:
                    locationError = .unknownError("Unable to determine your location. This may be due to poor GPS signal. Try moving to an open area with clear sky visibility.")
                case .headingFailure:
                    locationError = .unknownError("Location services are temporarily unavailable. Please try again.")
                default:
                    locationError = .unknownError("Location error: \(error.localizedDescription)")
                }
            } else {
                locationError = .unknownError("Location error: \(error.localizedDescription)")
            }
            
            self.errorHandler.handleWithRetry(locationError, retryAction: {
                self.startCapturingLocation()
            })
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                // If we were waiting for permission, start location capture
                if self.isCapturingLocation {
                    // Clear the permission timeout since we got authorization
                    self.locationTimeout?.invalidate()
                    self.startLocationCapture()
                }
            case .denied, .restricted:
                // User denied permission, stop any ongoing capture
                self.stopCapturingLocation()
                if self.isCapturingLocation {
                    self.errorHandler.handle(PuchiError.locationAccessDenied)
                }
            case .notDetermined:
                // Still waiting for user response, don't do anything
                break
            @unknown default:
                self.stopCapturingLocation()
                self.errorHandler.handle(PuchiError.unknownError("Unknown location authorization status"))
            }
        }
    }
}
