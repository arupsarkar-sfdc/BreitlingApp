//
//  BoutiqueLocatorViewModel.swift
//  BreitlingApp
//
//  Supporting ViewModel for BoutiqueLocatorView
//

import Foundation
import Combine
import CoreLocation

@MainActor
class BoutiqueLocatorViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var stores: [Store] = []
    @Published var filteredStores: [Store] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedFilter: StoreFilter = .all
    
    // MARK: - Private Properties
    private let apiService = APIService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Store Filter Enum
    enum StoreFilter {
        case all
        case dealers
        case service
        case nearby
    }
    
    // MARK: - Initialization
    init() {
        setupBindings()
    }
    
    // MARK: - Public Methods
    func loadStores() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Use the correct API method from APIService
                let fetchedStores = try await apiService.fetchStoreLocations()
                await MainActor.run {
                    self.stores = fetchedStores
                    self.applyCurrentFilter()
                    self.isLoading = false
                }
            } catch {
                // For development, use mock data if API fails
                await MainActor.run {
                    self.stores = Store.mockStores
                    self.applyCurrentFilter()
                    self.isLoading = false
                    // Uncomment this line if you want to show errors in development
                    // self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func searchStores(query: String) {
        guard !query.isEmpty else {
            applyCurrentFilter()
            return
        }
        
        let searchResults = stores.filter { store in
            store.name.localizedCaseInsensitiveContains(query) ||
            store.address.street.localizedCaseInsensitiveContains(query) ||
            store.address.city.localizedCaseInsensitiveContains(query) ||
            store.address.state.localizedCaseInsensitiveContains(query)
        }
        
        filteredStores = searchResults
    }
    
    func setFilter(for title: String) {
        switch title {
        case "All Boutiques":
            selectedFilter = .all
        case "Authorized Dealers":
            selectedFilter = .dealers
        case "Service Centers":
            selectedFilter = .service
        case "Nearby":
            selectedFilter = .nearby
        default:
            selectedFilter = .all
        }
        
        applyCurrentFilter()
    }
    
    func resetSearch() {
        applyCurrentFilter()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Any additional bindings can be added here
    }
    
    private func applyCurrentFilter() {
        switch selectedFilter {
        case .all:
            filteredStores = stores
        case .dealers:
            filteredStores = stores.filter { store in
                store.storeType == .authorizedDealer
            }
        case .service:
            filteredStores = stores.filter { store in
                store.services.contains(.repairService) || store.services.contains(.watchmaking)
            }
        case .nearby:
            filteredStores = stores.filter { store in
                (store.distanceFromUser ?? Double.infinity) <= 25000.0 // 25km in meters
            }
        }
    }
}
