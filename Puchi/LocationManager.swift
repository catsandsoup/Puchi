//
//  LocationManager.swift
//  Puchi
//
//  Location services for GPS capture, reverse geocoding, and location search
//

import Foundation
import CoreLocation
import MapKit
import SwiftUI

@Observable
class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    var currentLocation: CLLocation?
    var currentPlacemark: CLPlacemark?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var isLoading = false
    var errorMessage: String?
    
    // Search results
    var searchResults: [LocationSearchResult] = []
    var nearbyPlaces: [LocationSearchResult] = []
    var frequentLocations: [LocationInfo] = []
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        loadFrequentLocations()
    }
    
    // MARK: - Location Authorization
    
    func requestLocationPermission() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            // Show settings alert
            errorMessage = "Location access denied. Please enable location services in Settings."
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        @unknown default:
            break
        }
    }
    
    // MARK: - Current Location
    
    func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestLocationPermission()
            return
        }
        
        isLoading = true
        errorMessage = nil
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        isLoading = false
    }
    
    private func reverseGeocodeLocation(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to get location name: \(error.localizedDescription)"
                } else if let placemark = placemarks?.first {
                    self?.currentPlacemark = placemark
                }
                self?.isLoading = false
            }
        }
    }
    
    // MARK: - Location Search
    
    func searchLocations(query: String) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        // Use current location for more relevant results
        if let currentLocation = currentLocation {
            request.region = MKCoordinateRegion(
                center: currentLocation.coordinate,
                latitudinalMeters: 10000, // 10km radius
                longitudinalMeters: 10000
            )
        }
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Search failed: \(error.localizedDescription)"
                    self?.searchResults = []
                } else if let response = response {
                    self?.searchResults = response.mapItems.map { mapItem in
                        LocationSearchResult(
                            name: mapItem.name ?? "Unknown Location",
                            address: self?.formatAddress(from: mapItem.placemark) ?? "",
                            coordinate: mapItem.placemark.coordinate,
                            category: mapItem.pointOfInterestCategory?.rawValue ?? "location",
                            distance: self?.calculateDistance(to: mapItem.placemark.coordinate)
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Nearby Places
    
    func findNearbyPlaces() {
        guard let currentLocation = currentLocation else {
            errorMessage = "Current location not available"
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "points of interest"
        request.region = MKCoordinateRegion(
            center: currentLocation.coordinate,
            latitudinalMeters: 2000, // 2km radius for nearby places
            longitudinalMeters: 2000
        )
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            DispatchQueue.main.async {
                if let response = response {
                    self?.nearbyPlaces = response.mapItems.compactMap { mapItem in
                        guard let name = mapItem.name,
                              let distance = self?.calculateDistance(to: mapItem.placemark.coordinate),
                              distance < 1000 // Only include places within 1km
                        else { return nil }
                        
                        return LocationSearchResult(
                            name: name,
                            address: self?.formatAddress(from: mapItem.placemark) ?? "",
                            coordinate: mapItem.placemark.coordinate,
                            category: mapItem.pointOfInterestCategory?.rawValue ?? "location",
                            distance: distance
                        )
                    }.sorted { $0.distance ?? 0 < $1.distance ?? 0 }
                }
            }
        }
    }
    
    // MARK: - Frequent Locations
    
    func saveLocationToFrequent(_ location: LocationInfo) {
        // Add to frequent locations if not already there
        if !frequentLocations.contains(where: { $0.name == location.name }) {
            frequentLocations.append(location)
            // Keep only last 10 frequent locations
            if frequentLocations.count > 10 {
                frequentLocations = Array(frequentLocations.suffix(10))
            }
            saveFrequentLocations()
        }
    }
    
    private func loadFrequentLocations() {
        if let data = UserDefaults.standard.data(forKey: "frequent_locations") {
            do {
                frequentLocations = try JSONDecoder().decode([LocationInfo].self, from: data)
            } catch {
                print("Failed to load frequent locations: \(error)")
                frequentLocations = []
            }
        }
    }
    
    private func saveFrequentLocations() {
        do {
            let data = try JSONEncoder().encode(frequentLocations)
            UserDefaults.standard.set(data, forKey: "frequent_locations")
        } catch {
            print("Failed to save frequent locations: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    private func calculateDistance(to coordinate: CLLocationCoordinate2D) -> Double? {
        guard let currentLocation = currentLocation else { return nil }
        let targetLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return currentLocation.distance(from: targetLocation)
    }
    
    private func formatAddress(from placemark: CLPlacemark) -> String {
        var components: [String] = []
        
        if let thoroughfare = placemark.thoroughfare {
            components.append(thoroughfare)
        }
        if let locality = placemark.locality {
            components.append(locality)
        }
        
        return components.joined(separator: ", ")
    }
    
    // MARK: - Current Location Info
    
    var currentLocationInfo: LocationInfo? {
        guard let currentLocation = currentLocation,
              let placemark = currentPlacemark else { return nil }
        
        let name = placemark.name ?? 
                   placemark.thoroughfare ?? 
                   placemark.locality ?? 
                   "Current Location"
        
        let address = formatAddress(from: placemark)
        
        return LocationInfo(
            name: name,
            coordinate: LocationInfo.Coordinate(
                latitude: currentLocation.coordinate.latitude,
                longitude: currentLocation.coordinate.longitude
            )
        )
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentLocation = location
        stopLocationUpdates()
        reverseGeocodeLocation(location)
        
        // Find nearby places when we get a location
        findNearbyPlaces()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.errorMessage = "Location error: \(error.localizedDescription)"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
            
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.startLocationUpdates()
            case .denied, .restricted:
                self.errorMessage = "Location access denied. Please enable location services in Settings."
            case .notDetermined:
                break
            @unknown default:
                break
            }
        }
    }
}

// MARK: - Supporting Models

struct LocationSearchResult: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let category: String
    let distance: Double? // Distance in meters from current location
    
    var formattedDistance: String? {
        guard let distance = distance else { return nil }
        
        if distance < 1000 {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
    
    var categoryIcon: String {
        switch category {
        case let cat where cat.contains("restaurant") || cat.contains("food"):
            return "fork.knife"
        case let cat where cat.contains("shop") || cat.contains("store"):
            return "bag"
        case let cat where cat.contains("gas"):
            return "car"
        case let cat where cat.contains("hospital") || cat.contains("pharmacy"):
            return "cross"
        case let cat where cat.contains("school") || cat.contains("university"):
            return "graduationcap"
        case let cat where cat.contains("park"):
            return "tree"
        case let cat where cat.contains("bank") || cat.contains("atm"):
            return "creditcard"
        default:
            return "mappin"
        }
    }
}