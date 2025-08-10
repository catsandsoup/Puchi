//
//  LocationPickerView.swift
//  Puchi
//
//  Location picker modal matching Apple Journal design
//

import SwiftUI
import MapKit

struct LocationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var locationManager = LocationManager()
    @State private var searchText = ""
    @State private var selectedTab: LocationTab = .nearMe
    @FocusState private var isSearchFocused: Bool
    
    let onLocationSelected: (LocationInfo) -> Void
    
    enum LocationTab: String, CaseIterable {
        case nearMe = "Near Me"
        case inMyJournal = "In My Journal"
        
        var icon: String {
            switch self {
            case .nearMe: return "location"
            case .inMyJournal: return "book.closed"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with search
                VStack(spacing: 16) {
                    HStack {
                        Text("Location")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.puchiText)
                        Spacer()
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.puchiAccent)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.puchiTextSecondary)
                        
                        TextField("Search Locations", text: $searchText)
                            .focused($isSearchFocused)
                            .textFieldStyle(PlainTextFieldStyle())
                            .onSubmit {
                                locationManager.searchLocations(query: searchText)
                            }
                        
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                                locationManager.searchResults = []
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.puchiTextSecondary)
                            }
                        }
                        
                        // Voice search button (placeholder)
                        Button {
                            // Voice search functionality
                        } label: {
                            Image(systemName: "mic.fill")
                                .foregroundColor(.puchiAccent)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.puchiSurface)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    
                    // Current Location Button
                    if let currentLocationInfo = locationManager.currentLocationInfo {
                        CurrentLocationButton(
                            locationInfo: currentLocationInfo,
                            isLoading: locationManager.isLoading
                        ) {
                            onLocationSelected(currentLocationInfo)
                            dismiss()
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 16)
                .background(Color.puchiBackground)
                
                // Search Results or Tabs
                if !searchText.isEmpty && !locationManager.searchResults.isEmpty {
                    SearchResultsList()
                } else {
                    TabContent()
                }
            }
            .background(Color.puchiBackground)
            .onAppear {
                locationManager.requestLocationPermission()
            }
        }
    }
    
    @ViewBuilder
    private func SearchResultsList() -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(locationManager.searchResults) { result in
                    LocationResultRow(result: result) {
                        let locationInfo = LocationInfo(
                            name: result.name,
                            coordinate: LocationInfo.Coordinate(
                                latitude: result.coordinate.latitude,
                                longitude: result.coordinate.longitude
                            )
                        )
                        locationManager.saveLocationToFrequent(locationInfo)
                        onLocationSelected(locationInfo)
                        dismiss()
                    }
                    
                    if result.id != locationManager.searchResults.last?.id {
                        Divider()
                            .background(Color.puchiBorder)
                            .padding(.leading, 60)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    @ViewBuilder
    private func TabContent() -> some View {
        VStack(spacing: 0) {
            // Tab selector
            HStack(spacing: 0) {
                ForEach(LocationTab.allCases, id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        VStack(spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: tab.icon)
                                    .font(.system(size: 14, weight: .medium))
                                Text(tab.rawValue)
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(selectedTab == tab ? .puchiAccent : .puchiTextSecondary)
                            
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(selectedTab == tab ? .puchiAccent : .clear)
                        }
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .background(Color.puchiSurface)
            
            Divider()
                .background(Color.puchiBorder)
            
            // Tab content
            ScrollView {
                LazyVStack(spacing: 0) {
                    switch selectedTab {
                    case .nearMe:
                        NearMeContent()
                    case .inMyJournal:
                        InMyJournalContent()
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    @ViewBuilder
    private func NearMeContent() -> some View {
        if locationManager.nearbyPlaces.isEmpty {
            if locationManager.isLoading {
                LoadingView(message: "Finding nearby places...")
            } else if locationManager.currentLocation == nil {
                EmptyStateView(
                    icon: "location.slash",
                    title: "Location Not Available",
                    message: "Enable location services to see nearby places"
                )
            } else {
                EmptyStateView(
                    icon: "location",
                    title: "No Nearby Places",
                    message: "No places found in your area"
                )
            }
        } else {
            ForEach(locationManager.nearbyPlaces) { result in
                LocationResultRow(result: result) {
                    let locationInfo = LocationInfo(
                        name: result.name,
                        coordinate: LocationInfo.Coordinate(
                            latitude: result.coordinate.latitude,
                            longitude: result.coordinate.longitude
                        )
                    )
                    locationManager.saveLocationToFrequent(locationInfo)
                    onLocationSelected(locationInfo)
                    dismiss()
                }
                
                if result.id != locationManager.nearbyPlaces.last?.id {
                    Divider()
                        .background(Color.puchiBorder)
                        .padding(.leading, 60)
                }
            }
        }
    }
    
    @ViewBuilder
    private func InMyJournalContent() -> some View {
        if locationManager.frequentLocations.isEmpty {
            EmptyStateView(
                icon: "book.closed",
                title: "No Saved Locations",
                message: "Locations you use in your journal entries will appear here"
            )
        } else {
            ForEach(locationManager.frequentLocations, id: \.name) { location in
                FrequentLocationRow(location: location) {
                    onLocationSelected(location)
                    dismiss()
                }
                
                if location.name != locationManager.frequentLocations.last?.name {
                    Divider()
                        .background(Color.puchiBorder)
                        .padding(.leading, 60)
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct CurrentLocationButton: View {
    let locationInfo: LocationInfo
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.puchiAccent.opacity(0.1))
                    
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "location.fill")
                            .foregroundColor(.puchiAccent)
                            .font(.system(size: 16, weight: .medium))
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Current Location")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.puchiText)
                    Text(locationInfo.name)
                        .font(.system(size: 14))
                        .foregroundColor(.puchiTextSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.puchiSurface)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LocationResultRow: View {
    let result: LocationSearchResult
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.puchiHighlight)
                    
                    Image(systemName: result.categoryIcon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.puchiAccent)
                }
                
                // Location info
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.puchiText)
                        .lineLimit(1)
                    
                    Text(result.address)
                        .font(.system(size: 14))
                        .foregroundColor(.puchiTextSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Distance
                if let formattedDistance = result.formattedDistance {
                    Text(formattedDistance)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.puchiTextSecondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FrequentLocationRow: View {
    let location: LocationInfo
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.puchiHighlight)
                    
                    Image(systemName: "mappin")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.puchiAccent)
                }
                
                // Location info
                VStack(alignment: .leading, spacing: 4) {
                    Text(location.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.puchiText)
                        .lineLimit(1)
                    
                    if let coordinate = location.coordinate {
                        Text("\(coordinate.latitude, specifier: "%.4f"), \(coordinate.longitude, specifier: "%.4f")")
                            .font(.system(size: 14))
                            .foregroundColor(.puchiTextSecondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text(message)
                .font(.system(size: 16))
                .foregroundColor(.puchiTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 60)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundColor(.puchiTextSecondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.puchiText)
                
                Text(message)
                    .font(.system(size: 16))
                    .foregroundColor(.puchiTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
        .padding(.top, 60)
    }
}

#Preview {
    LocationPickerView { location in
        print("Selected location: \(location.name)")
    }
    .preferredColorScheme(.dark)
}