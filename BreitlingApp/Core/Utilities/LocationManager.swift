//
//  LocationManager.swift
//  BreitlingApp
//
//  Created by Arup Sarkar (TA) on 7/10/25.
//
//
//  Location services management for store locator functionality
//  Handles user location, store proximity, and navigation integration
//

import Foundation
import CoreLocation
import MapKit
import Combine

@MainActor
class LocationManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocationServicesEnabled: Bool = false
    @Published var nearbyStores: [Store] = []
    @Published var searchRegion: MKCoordinateRegion?
    @Published var locationError: LocationError?
    
    // MARK: - Private Properties
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var cancellables = Set<AnyCancellable>()
    
    // Configuration
    private let desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyHundredMeters
    private let distanceFilter: CLLocationDistance = 100 // Update every 100 meters
    private let maxStoreSearchRadius: CLLocationDistance = 100000 // 100km
    
    // MARK: - Location Errors
    
    enum LocationError: LocalizedError {
        case permissionDenied
        case locationUnavailable
        case networkError
        case geocodingFailed
        case storeSearchFailed
        case distanceCalculationFailed
        
        var errorDescription: String? {
            switch self {
            case .permissionDenied:
                return "Location permission denied. Please enable location services in Settings."
            case .locationUnavailable:
                return "Unable to determine your location. Please try again."
            case .networkError:
                return "Network error while searching for stores."
            case .geocodingFailed:
                return "Unable to find location for the provided address."
            case .storeSearchFailed:
                return "Failed to search nearby stores. Please try again."
            case .distanceCalculationFailed:
                return "Unable to calculate distance to stores."
            }
        }
    }
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupLocationManager()
        checkLocationServicesStatus()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = desiredAccuracy
        locationManager.distanceFilter = distanceFilter
        
        // Update authorization status
        authorizationStatus = locationManager.authorizationStatus
        isLocationServicesEnabled = CLLocationManager.locationServicesEnabled()
    }
    
    private func checkLocationServicesStatus() {
        isLocationServicesEnabled = CLLocationManager.locationServicesEnabled()
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // MARK: - Permission Management
    
    /// Request location permission with appropriate prompt
    func requestLocationPermission() {
        guard CLLocationManager.locationServicesEnabled() else {
            locationError = .locationUnavailable
            return
        }
        
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            locationError = .permissionDenied
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        @unknown default:
            locationError = .permissionDenied
        }
    }
    
    /// Check if location services are authorized and available
    var isLocationAuthorized: Bool {
        return authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }
    
    /// Check if user can be prompted for location permission
    var canRequestPermission: Bool {
        return authorizationStatus == .notDetermined
    }
    
    // MARK: - Location Updates
    
    /// Start receiving location updates
    func startLocationUpdates() {
        guard isLocationAuthorized else {
            requestLocationPermission()
            return
        }
        
        guard CLLocationManager.locationServicesEnabled() else {
            locationError = .locationUnavailable
            return
        }
        
        locationManager.startUpdatingLocation()
    }
    
    /// Stop receiving location updates
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    /// Request one-time location update
    func requestCurrentLocation() {
        guard isLocationAuthorized else {
            requestLocationPermission()
            return
        }
        
        locationManager.requestLocation()
    }
    
    // MARK: - Store Search and Distance Calculation
    
    /// Search for nearby stores using current location
    func searchNearbyStores(radius: CLLocationDistance = 25000) async {
        guard let userLocation = userLocation else {
            locationError = .locationUnavailable
            return
        }
        
        await searchNearbyStores(from: userLocation, radius: radius)
    }
    
    /// Search for nearby stores from specific location
    func searchNearbyStores(from location: CLLocation, radius: CLLocationDistance = 25000) async {
        do {
            let stores = try await APIService.shared.fetchNearbyStores(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                radius: radius / 1000 // Convert to kilometers
            )
            
            // Calculate distances and sort by proximity
            let storesWithDistance = stores.compactMap { store -> (Store, CLLocationDistance)? in
                let storeLocation = CLLocation(
                    latitude: store.coordinate.latitude,
                    longitude: store.coordinate.longitude
                )
                let distance = location.distance(from: storeLocation)
                return (store, distance)
            }
            
            // Sort by distance and update nearby stores
            let sortedStores = storesWithDistance
                .sorted { $0.1 < $1.1 }
                .map { $0.0 }
            
            await MainActor.run {
                self.nearbyStores = sortedStores
                self.updateSearchRegion(for: location, radius: radius)
            }
            
        } catch {
            await MainActor.run {
                self.locationError = .storeSearchFailed
            }
        }
    }
    
    /// Calculate distance between two coordinates
    func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }
    
    /// Calculate distance from user to store
    func distanceToStore(_ store: Store) -> CLLocationDistance? {
        guard let userLocation = userLocation else { return nil }
        
        let storeLocation = CLLocation(
            latitude: store.coordinate.latitude,
            longitude: store.coordinate.longitude
        )
        
        return userLocation.distance(from: storeLocation)
    }
    
    /// Format distance for display
    func formatDistance(_ distance: CLLocationDistance) -> String {
        let formatter = MKDistanceFormatter()
        formatter.unitStyle = .abbreviated
        return formatter.string(fromDistance: distance)
    }
    
    // MARK: - Geocoding
    
    /// Convert address to coordinates
    func geocodeAddress(_ address: String) async throws -> CLLocation {
        return try await withCheckedThrowingContinuation { continuation in
            geocoder.geocodeAddressString(address) { placemarks, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let placemark = placemarks?.first,
                      let location = placemark.location else {
                    continuation.resume(throwing: LocationError.geocodingFailed)
                    return
                }
                
                continuation.resume(returning: location)
            }
        }
    }
    
    /// Convert coordinates to address
    func reverseGeocodeLocation(_ location: CLLocation) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    continuation.resume(throwing: LocationError.geocodingFailed)
                    return
                }
                
                let address = [
                    placemark.thoroughfare,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.postalCode
                ].compactMap { $0 }.joined(separator: ", ")
                
                continuation.resume(returning: address.isEmpty ? "Unknown Location" : address)
            }
        }
    }
    
    // MARK: - Map Integration
    
    /// Update search region based on location and radius
    private func updateSearchRegion(for location: CLLocation, radius: CLLocationDistance) {
        let coordinate = location.coordinate
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: radius * 2,
            longitudinalMeters: radius * 2
        )
        searchRegion = region
    }
    
    /// Get map region that includes all nearby stores
    func getRegionForNearbyStores(padding: Double = 1.2) -> MKCoordinateRegion? {
        guard !nearbyStores.isEmpty else { return nil }
        
        var minLat = nearbyStores[0].coordinate.latitude
        var maxLat = nearbyStores[0].coordinate.latitude
        var minLon = nearbyStores[0].coordinate.longitude
        var maxLon = nearbyStores[0].coordinate.longitude
        
        for store in nearbyStores {
            minLat = min(minLat, store.coordinate.latitude)
            maxLat = max(maxLat, store.coordinate.latitude)
            minLon = min(minLon, store.coordinate.longitude)
            maxLon = max(maxLon, store.coordinate.longitude)
        }
        
        // Include user location if available
        if let userLocation = userLocation {
            minLat = min(minLat, userLocation.coordinate.latitude)
            maxLat = max(maxLat, userLocation.coordinate.latitude)
            minLon = min(minLon, userLocation.coordinate.longitude)
            maxLon = max(maxLon, userLocation.coordinate.longitude)
        }
        
        let centerLat = (minLat + maxLat) / 2
        let centerLon = (minLon + maxLon) / 2
        let latDelta = (maxLat - minLat) * padding
        let lonDelta = (maxLon - minLon) * padding
        
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        )
    }
    
    // MARK: - Navigation Integration
    
    /// Open navigation to store in Maps app
    func navigateToStore(_ store: Store) {
        let coordinate = CLLocationCoordinate2D(
            latitude: store.coordinate.latitude,
            longitude: store.coordinate.longitude
        )
        
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = store.name
        mapItem.phoneNumber = store.contact.phone
        
        let launchOptions = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ]
        
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    
    /// Get directions URL for external navigation apps
    func getDirectionsURL(to store: Store, app: NavigationApp = .appleMaps) -> URL? {
        let coordinate = store.coordinate
        
        switch app {
        case .appleMaps:
            let urlString = "http://maps.apple.com/?daddr=\(coordinate.latitude),\(coordinate.longitude)"
            return URL(string: urlString)
            
        case .googleMaps:
            let urlString = "comgooglemaps://?daddr=\(coordinate.latitude),\(coordinate.longitude)&directionsmode=driving"
            return URL(string: urlString)
            
        case .waze:
            let urlString = "waze://?ll=\(coordinate.latitude),\(coordinate.longitude)&navigate=yes"
            return URL(string: urlString)
        }
    }
    
    // MARK: - Utility Methods
    
    /// Check if a coordinate is within a reasonable distance for store search
    func isCoordinateValid(_ coordinate: CLLocationCoordinate2D) -> Bool {
        return CLLocationCoordinate2DIsValid(coordinate) &&
               coordinate.latitude != 0.0 &&
               coordinate.longitude != 0.0
    }
    
    /// Get user's country code based on location
    func getUserCountryCode() async -> String? {
        guard let userLocation = userLocation else { return nil }
        
        do {
            let placemarks: [CLPlacemark]? = try await withCheckedThrowingContinuation { continuation in
                geocoder.reverseGeocodeLocation(userLocation) { placemarks, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: placemarks)
                    }
                }
            }
            
            return placemarks?.first?.isoCountryCode
        } catch {
            return nil
        }
    }
    
    /// Clear location data and reset state
    func resetLocationData() {
        userLocation = nil
        nearbyStores = []
        searchRegion = nil
        locationError = nil
        stopLocationUpdates()
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Update user location
        userLocation = location
        locationError = nil
        
        // Auto-search for nearby stores if this is the first location update
        if nearbyStores.isEmpty {
            Task {
                await searchNearbyStores()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                locationError = .permissionDenied
            case .locationUnknown, .network:
                locationError = .locationUnavailable
            default:
                locationError = .locationUnavailable
            }
        } else {
            locationError = .locationUnavailable
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
            locationError = nil
        case .denied, .restricted:
            locationError = .permissionDenied
            stopLocationUpdates()
        case .notDetermined:
            locationError = nil
        @unknown default:
            locationError = .permissionDenied
        }
    }
}

// MARK: - Supporting Types

enum NavigationApp {
    case appleMaps
    case googleMaps
    case waze
    
    var displayName: String {
        switch self {
        case .appleMaps:
            return "Apple Maps"
        case .googleMaps:
            return "Google Maps"
        case .waze:
            return "Waze"
        }
    }
    
    var isInstalled: Bool {
        switch self {
        case .appleMaps:
            return true // Always available on iOS
        case .googleMaps:
            return UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!)
        case .waze:
            return UIApplication.shared.canOpenURL(URL(string: "waze://")!)
        }
    }
}

// MARK: - Singleton Instance

extension LocationManager {
    static let shared = LocationManager()
}
