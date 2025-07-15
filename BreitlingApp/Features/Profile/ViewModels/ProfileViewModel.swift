//
//  ProfileViewModel.swift
//  BreitlingApp
//
//  Created by Arup Sarkar (TA) on 7/13/25.
//

//
//  ProfileViewModel.swift
//  BreitlingApp
//
//  Profile View Model - Swiss precision in user management
//

import Foundation
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var registeredWatchesCount = 0
    
    private let apiService = APIService.shared
    private let coreDataManager = CoreDataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadUserData()
        setupDataObservers()
    }
    
    // MARK: - Data Loading
    
    func loadUserData() {
        isLoading = true
        
        Task {
            do {
                // Load current user
                self.currentUser = try await apiService.fetchUserProfile()
                
                // Load counts
                await loadCounts()
                
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                
                // Load from local storage as fallback
                loadLocalUserData()
            }
        }
    }
    
    private func loadLocalUserData() {
        // Load mock user for development
        currentUser = User.mockUser
        registeredWatchesCount = currentUser?.profile.previousPurchases.count ?? 0
    }
    
    private func loadCounts() async {
        do {
            // Load registered watches count
            self.registeredWatchesCount = currentUser?.profile.previousPurchases.count ?? 0
            
        } catch {
            // Use fallback counts from user profile
            self.registeredWatchesCount = currentUser?.profile.previousPurchases.count ?? 0
        }
    }
    
    // MARK: - Data Observers
    
    private func setupDataObservers() {
        // Observe wishlist changes
        NotificationCenter.default.publisher(for: .wishlistDidUpdate)
            .sink { [weak self] _ in
                Task {
                    await self?.loadCounts()
                }
            }
            .store(in: &cancellables)
        
        // Observe user profile changes
        NotificationCenter.default.publisher(for: .userProfileDidUpdate)
            .sink { [weak self] _ in
                self?.loadUserData()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - User Actions
    
    func updateUser(_ updatedUser: User) {
        Task {
            do {
                try await apiService.updateUserProfile(updatedUser)
                self.currentUser = updatedUser
                
                // Notify observers
                NotificationCenter.default.post(name: .userProfileDidUpdate, object: nil)
                
            } catch {
                self.errorMessage = "Failed to update profile: \(error.localizedDescription)"
            }
        }
    }
    
    func updatePreferences(_ preferences: UserPreferences) {
        guard var user = currentUser else { return }
        
        let updatedUser = User(
            id: user.id,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            dateJoined: user.dateJoined,
            membershipTier: user.membershipTier,
            preferences: preferences,
            profile: user.profile,
            isEmailVerified: user.isEmailVerified,
            lastLoginDate: user.lastLoginDate
        )
        
        updateUser(updatedUser)
    }
    
    func signOut() {
        Task {
            do {
                try await apiService.logout()
                
                // Clear local data
                self.currentUser = nil
                self.registeredWatchesCount = 0
                
                // Clear local storage
                coreDataManager.clearUserData()
                
                // Notify app of sign out
                NotificationCenter.default.post(name: .userDidSignOut, object: nil)
                
            } catch {
                self.errorMessage = "Failed to sign out: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Data Refresh
    
    func refreshData() {
        loadUserData()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let wishlistDidUpdate = Notification.Name("wishlistDidUpdate")
    static let userProfileDidUpdate = Notification.Name("userProfileDidUpdate")
    static let userDidSignOut = Notification.Name("userDidSignOut")
}

// MARK: - Demo User Extension

extension User {
    static let demoUser = User(
        id: "demo-user-001",
        email: "collector@breitling.com",
        firstName: "Alexander",
        lastName: "Sterling",
        dateJoined: Date().addingTimeInterval(-86400 * 365), // 1 year ago
        membershipTier: .premier,
        preferences: UserPreferences(
            preferredCollections: ["Navitimer", "Chronomat"],
            priceRange: PriceRange(min: 3000, max: 15000, currency: "USD"),
            preferredMaterials: ["stainless-steel", "gold"],
            stylePreferences: [.classic, .professional],
            notifications: NotificationPreferences.defaultSettings,
            occasionPreferences: [.business, .formal, .travel],
            seasonalPreferences: [.autumn, .winter],
            allowPersonalization: true,
            allowLocationServices: true,
            allowMarketingEmails: true
        ),
        profile: UserProfile(
            phoneNumber: "+1 (555) 123-4567",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -35, to: Date()),
            gender: .male,
            country: "United States",
            preferredLanguage: "en",
            timeZone: "America/New_York",
            interests: [.horology, .aviation, .travel],
            previousPurchases: ["navitimer-b01-chronograph-43", "chronomat-automatic-42", "superocean-heritage-57"],
            wishlistIds: ["chronomat-b01-42", "superocean-heritage-57-limited", "navitimer-gmt-48", "premier-b01-chronograph-42"],
            favoriteStoreIds: ["store-ny-madison", "store-ca-beverly-hills"]
        ),
        isEmailVerified: true,
        lastLoginDate: Date().addingTimeInterval(-3600) // 1 hour ago
    )
}
