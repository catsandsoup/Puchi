import SwiftUI
import CoreLocation
import AVKit

@MainActor
class LoveJournalViewModel: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var loveNote = ""
    @Published var currentStreak = 0
    @Published var savedNotes: [LoveNote] = []
    @Published var selectedImages: [UIImage] = []
    @Published var selectedVideos: [URL] = []
    @Published var currentLocation: LocationData?
    @Published var isCapturingLocation = false
    @Published var showSourceTypeSheet = false
    @Published var showMediaPicker = false
    @Published var selectedSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    // MARK: - User Defaults
    @AppStorage("partnerName") var storedPartnerName = ""
    @AppStorage("isFirstTimeUser") var isFirstTimeUser = true
    
    // MARK: - Private Properties
    private let locationManager = CLLocationManager()
    
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
        lastNoteDate = UserDefaults.standard.object(forKey: "lastNoteDate") as? Date
        calculateStreak()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // MARK: - Media Management
    func addImage(_ image: UIImage) {
        selectedImages.append(image)
    }
    
    func removeImage(at index: Int) {
        selectedImages.remove(at: index)
    }
    
    func addVideo(_ url: URL) {
        selectedVideos.append(url)
    }
    
    func removeVideo(at index: Int) {
        selectedVideos.remove(at: index)
    }
    
    // MARK: - Location Management
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startCapturingLocation() {
        isCapturingLocation = true
        locationManager.startUpdatingLocation()
    }
    
    func stopCapturingLocation() {
        isCapturingLocation = false
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Note Management
    func saveLoveNote() {
        guard !loveNote.isEmpty else { return }
        
        // Convert images to data
        let imageData = selectedImages.compactMap { $0.optimizedForStorage() }
        
        // Convert videos to data
        let videoData = selectedVideos.compactMap { try? Data(contentsOf: $0) }
        
        // Create media items
        var images: [MediaItem]?
        var videos: [MediaItem]?
        
        if !imageData.isEmpty {
            images = imageData.map { MediaItem(data: $0, type: .image) }
        }
        
        if !videoData.isEmpty {
            videos = videoData.map { MediaItem(data: $0, type: .video) }
        }
        
        let newNote = LoveNote(
            id: UUID(),
            text: loveNote,
            partnerName: storedPartnerName,
            date: Date(),
            noteNumber: savedNotes.count + 1,
            images: images,
            videos: videos,
            location: currentLocation
        )
        
        savedNotes.insert(newNote, at: 0)
        updateStreak(for: newNote.date)
        lastNoteDate = newNote.date
        
        // Clear the form
        loveNote = ""
        selectedImages.removeAll()
        selectedVideos.removeAll()
        currentLocation = .none
        
        saveNotes()
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
        if let encoded = try? JSONEncoder().encode(savedNotes) {
            UserDefaults.standard.set(encoded, forKey: "savedNotes")
        }
    }
    
    private func loadNotes() {
        if let savedData = UserDefaults.standard.data(forKey: "savedNotes"),
           let decodedNotes = try? JSONDecoder().decode([LoveNote].self, from: savedData) {
            savedNotes = decodedNotes.sorted(by: { $0.date > $1.date })
        }
    }
}

// MARK: - Location Manager Delegate
extension LoveJournalViewModel: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self,
                  let placemark = placemarks?.first else { return }
            
            let placeName = [placemark.name, placemark.locality, placemark.administrativeArea]
                .compactMap { $0 }
                .joined(separator: ", ")
            
            Task { @MainActor in
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
            print("Location error: \(error.localizedDescription)")
            self.isCapturingLocation = false
        }
    }
}
