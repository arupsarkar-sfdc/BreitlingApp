//
//  BoutiqueLocatorView.swift
//  BreitlingApp
//
//  Created on Phase 3 - Priority 5
//  Luxury store locator with MapKit integration
//

import SwiftUI
import MapKit
import Combine

struct BoutiqueLocatorView: View {
    // MARK: - Properties
    @StateObject private var locationManager = LocationManager()
    @StateObject private var viewModel = BoutiqueLocatorViewModel()
    
    // MARK: - State Variables
    @State private var searchText = ""
    @State private var showingStoreDetail = false
    @State private var selectedStore: Store?
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), // NYC default
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var showingList = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                BreitlingColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search header will go here
                    searchHeaderSection
                    
                    // Map and list toggle will go here
                    mapListToggleSection
                    
                    // Main content area
                    if showingList {
                        storeListView
                    } else {
                        mapView
                    }
                }
            }
            .navigationTitle("Boutiques")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - View Components
    private var searchHeaderSection: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(BreitlingColors.secondaryText)
                    .font(.system(size: 16, weight: .medium))
                
                TextField("Search boutiques or city", text: $searchText)
                    .font(BreitlingFonts.body)
                    .foregroundColor(BreitlingColors.primaryText)
                    .onSubmit {
                        searchForStores()
                    }
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        viewModel.resetSearch()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(BreitlingColors.secondaryText)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(BreitlingColors.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(BreitlingColors.border, lineWidth: 1)
            )
            
            // Quick filter buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    quickFilterButton("All Boutiques", isSelected: viewModel.selectedFilter == .all)
                    quickFilterButton("Authorized Dealers", isSelected: viewModel.selectedFilter == .dealers)
                    quickFilterButton("Service Centers", isSelected: viewModel.selectedFilter == .service)
                    quickFilterButton("Nearby", isSelected: viewModel.selectedFilter == .nearby)
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(BreitlingColors.background)
    }
    
    private func quickFilterButton(_ title: String, isSelected: Bool) -> some View {
        Button {
            viewModel.setFilter(for: title)
        } label: {
            Text(title)
                .font(BreitlingFonts.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? BreitlingColors.background : BreitlingColors.primaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? BreitlingColors.navyBlue : BreitlingColors.cardBackground)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(BreitlingColors.border, lineWidth: isSelected ? 0 : 1)
                )
        }
    }
    
    private func searchForStores() {
        viewModel.searchStores(query: searchText)
    }
    
    private var mapListToggleSection: some View {
        HStack {
            // Results count
            if !viewModel.filteredStores.isEmpty {
                Text("\(viewModel.filteredStores.count) boutiques found")
                    .font(BreitlingFonts.caption)
                    .foregroundColor(BreitlingColors.secondaryText)
            }
            
            Spacer()
            
            // Map/List toggle
            HStack(spacing: 0) {
                toggleButton("Map", icon: "map", isSelected: !showingList) {
                    showingList = false
                }
                
                toggleButton("List", icon: "list.bullet", isSelected: showingList) {
                    showingList = true
                }
            }
            .background(BreitlingColors.cardBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(BreitlingColors.border, lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }
    
    private func toggleButton(_ title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                Text(title)
                    .font(BreitlingFonts.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? BreitlingColors.background : BreitlingColors.primaryText)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? BreitlingColors.navyBlue : Color.clear)
            .cornerRadius(6)
        }
    }
    
    
    // MARK: - Map View
    @ViewBuilder
    private var mapView: some View {
        Map(coordinateRegion: $mapRegion, annotationItems: viewModel.filteredStores) { store in
            MapAnnotation(coordinate: CLLocationCoordinate2D(
                latitude: store.coordinate.latitude,
                longitude: store.coordinate.longitude
            )) {
                storeMapPin(for: store)
            }
        }
        .onAppear {
            locationManager.requestLocationPermission()
            setupInitialRegion()
        }
        .onChange(of: locationManager.userLocation) { _, _ in
            updateMapRegion()
        }
        .onChange(of: viewModel.filteredStores) { _, _ in
            adjustMapToShowStores()
        }
    }
    
    // MARK: - List View
    @ViewBuilder
    private var storeListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.filteredStores) { store in
                    storeListCard(for: store)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    private func storeListCard(for store: Store) -> some View {
        Button {
            selectedStore = store
            showingStoreDetail = true
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                // Store header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(store.name)
                            .font(BreitlingFonts.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(BreitlingColors.primaryText)
                        
                        Text(store.storeType.displayName)
                            .font(BreitlingFonts.caption)
                            .foregroundColor(BreitlingColors.navyBlue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(BreitlingColors.navyBlue.opacity(0.1))
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                    
                    if let distance = store.distanceFromUser {
                        Text("\(String(format: "%.1f", distance/1000)) km")
                            .font(BreitlingFonts.caption)
                            .foregroundColor(BreitlingColors.secondaryText)
                    }
                }
                
                // Address
                Text(store.formattedAddress)
                    .font(BreitlingFonts.body)
                    .foregroundColor(BreitlingColors.secondaryText)
                    .multilineTextAlignment(.leading)
                
                // Services and hours
                HStack {
                    // Services
                    if !store.services.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "wrench.and.screwdriver")
                                .font(.system(size: 12))
                            Text("\(store.services.count) services")
                                .font(BreitlingFonts.caption)
                        }
                        .foregroundColor(BreitlingColors.secondaryText)
                    }
                    
                    Spacer()
                    
                    // Hours status
                    HStack(spacing: 4) {
                        Circle()
                            .fill(store.isOpen ? Color.green : Color.red)
                            .frame(width: 6, height: 6)
                        Text(store.isOpen ? "Open" : "Closed")
                            .font(BreitlingFonts.caption)
                            .foregroundColor(store.isOpen ? Color.green : Color.red)
                    }
                }
                
                // Action buttons
                HStack(spacing: 12) {
                    actionButton("Call", icon: "phone", action: { callStore(store) })
                    actionButton("Directions", icon: "arrow.triangle.turn.up.right.diamond", action: { getDirections(to: store) })
                    actionButton("Book", icon: "calendar", action: { bookAppointment(at: store) })
                }
            }
            .padding(16)
            .background(BreitlingColors.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(BreitlingColors.border, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func actionButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                Text(title)
                    .font(BreitlingFonts.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(BreitlingColors.navyBlue)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(BreitlingColors.navyBlue.opacity(0.1))
            .cornerRadius(6)
        }
    }
    
    private func storeMapPin(for store: Store) -> some View {
        Button {
            selectedStore = store
            showingStoreDetail = true
        } label: {
            VStack(spacing: 4) {
                // Pin icon
                ZStack {
                    Circle()
                        .fill(BreitlingColors.navyBlue)
                        .frame(width: 32, height: 32)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    Image(systemName: "house.fill")
                        .foregroundColor(BreitlingColors.background)
                        .font(.system(size: 14, weight: .bold))
                }
                
                // Store name label
                Text(store.name)
                    .font(BreitlingFonts.caption)
                    .fontWeight(.medium)
                    .foregroundColor(BreitlingColors.primaryText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(BreitlingColors.background)
                    .cornerRadius(6)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func setupInitialRegion() {
        if let userLocation = locationManager.userLocation {
            mapRegion = MKCoordinateRegion(
                center: userLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
        viewModel.loadStores()
    }
    
    private func updateMapRegion() {
        guard let userLocation = locationManager.userLocation else { return }
        withAnimation(.easeInOut(duration: 1.0)) {
            mapRegion.center = userLocation.coordinate
        }
    }
    
    private func adjustMapToShowStores() {
        guard !viewModel.filteredStores.isEmpty else { return }
        
        let coordinates = viewModel.filteredStores.map {
            CLLocationCoordinate2D(
                latitude: $0.coordinate.latitude,
                longitude: $0.coordinate.longitude
            )
        }
        
        let latitudes = coordinates.map { $0.latitude }
        let longitudes = coordinates.map { $0.longitude }
        
        guard let minLat = latitudes.min(),
              let maxLat = latitudes.max(),
              let minLon = longitudes.min(),
              let maxLon = longitudes.max() else { return }
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.2, 0.01),
            longitudeDelta: max((maxLon - minLon) * 1.2, 0.01)
        )
        
        withAnimation(.easeInOut(duration: 1.0)) {
            mapRegion = MKCoordinateRegion(center: center, span: span)
        }
    }
    
    // MARK: - Action Functions
    private func callStore(_ store: Store) {
        if let phoneURL = URL(string: "tel:\(store.contact.phone)") {
            UIApplication.shared.open(phoneURL)
        }
    }
    
    private func getDirections(to store: Store) {
        let coordinate = CLLocationCoordinate2D(
            latitude: store.coordinate.latitude,
            longitude: store.coordinate.longitude
        )
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = store.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
    }
    
    private func bookAppointment(at store: Store) {
        // This will integrate with your appointment booking system
        // For now, we'll set the selected store and show detail
        selectedStore = store
        showingStoreDetail = true
    }
}


#Preview {
    BoutiqueLocatorView()
}
