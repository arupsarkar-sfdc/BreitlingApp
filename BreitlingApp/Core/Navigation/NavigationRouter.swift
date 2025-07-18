//
//  NavigationRouter.swift
//  BreitlingApp
//
//  Created by Arup Sarkar (TA) on 7/10/25.
//

//
//  NavigationRouter.swift
//  BreitlingApp
//
//  Centralized navigation management for luxury app experience
//  Handles deep linking and navigation state management
//

import SwiftUI

@Observable
class NavigationRouter {
    var path = NavigationPath()
    
    // MARK: - Navigation Methods
    
    /// Navigate to a specific destination
    func navigate(to destination: AppDestination) {
        path.append(destination)
    }
    
    /// Navigate back one level
    func navigateBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    /// Navigate to root (clear all navigation)
    func navigateToRoot() {
        path.removeLast(path.count)
    }
    
    /// Navigate back multiple levels
    func navigateBack(levels: Int) {
        let levelsToRemove = min(levels, path.count)
        path.removeLast(levelsToRemove)
    }
    
    /// Replace current destination with new one
    func replace(with destination: AppDestination) {
        if !path.isEmpty {
            path.removeLast()
        }
        path.append(destination)
    }
    
    // MARK: - Convenience Navigation Methods
    
    /// Navigate to product detail
    func showProduct(_ productId: String) {
        navigate(to: .productDetail(productId: productId))
    }
    
    /// Navigate to collection detail
    func showCollection(_ collectionId: String) {
        navigate(to: .collectionDetail(collectionId: collectionId))
    }
    
    /// Navigate to boutique detail
    func showBoutique(_ storeId: String) {
        navigate(to: .boutiqueDetail(storeId: storeId))
    }
    
    /// Navigate to watch configurator
    func showWatchConfigurator(for productId: String) {
        navigate(to: .watchConfigurator(productId: productId))
    }
    
    /// Navigate to AR try-on
    func showARTryOn(for productId: String) {
        navigate(to: .arTryOn(productId: productId))
    }
    
    /// Navigate to appointment booking
    func showAppointmentBooking(for storeId: String) {
        navigate(to: .appointmentBooking(storeId: storeId))
    }
    
    /// Navigate to user's orders
    func showOrderHistory() {
        navigate(to: .orderHistory)
    }
    
    /// Navigate to specific order
    func showOrder(_ orderId: String) {
        navigate(to: .orderDetail(orderId: orderId))
    }
    
    /// Navigate to wishlist detail
    func showWishlist(_ wishlistId: String) {
        navigate(to: .wishlistDetail(wishlistId: wishlistId))
    }
    
    /// Navigate to user settings
    func showSettings() {
        navigate(to: .settings)
    }
    
    // MARK: - Deep Linking Support
    
    /// Handle deep link URL
    func handleDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let host = components.host else { return }
        
        switch host {
        case "product":
            if let productId = components.queryItems?.first(where: { $0.name == "id" })?.value {
                showProduct(productId)
            }
            
        case "collection":
            if let collectionId = components.queryItems?.first(where: { $0.name == "id" })?.value {
                showCollection(collectionId)
            }
            
        case "boutique":
            if let storeId = components.queryItems?.first(where: { $0.name == "id" })?.value {
                showBoutique(storeId)
            }
            
        case "ar":
            if let productId = components.queryItems?.first(where: { $0.name == "product" })?.value {
                showARTryOn(for: productId)
            }
            
        case "configurator":
            if let productId = components.queryItems?.first(where: { $0.name == "product" })?.value {
                showWatchConfigurator(for: productId)
            }
            
        case "appointment":
            if let storeId = components.queryItems?.first(where: { $0.name == "store" })?.value {
                showAppointmentBooking(for: storeId)
            }
            
        case "orders":
            showOrderHistory()
            
        case "order":
            if let orderId = components.queryItems?.first(where: { $0.name == "id" })?.value {
                showOrder(orderId)
            }
            
        case "wishlist":
            if let wishlistId = components.queryItems?.first(where: { $0.name == "id" })?.value {
                showWishlist(wishlistId)
            }
            
        case "settings":
            showSettings()
            
        default:
            // Unknown deep link, navigate to root
            navigateToRoot()
        }
        
        func showBoutique(_ id: String) {
            navigate(to: .boutiqueDetail(storeId: id))
        }

        func bookAppointment(at id: String) {
            navigate(to: .appointmentBooking(storeId: id))
        }
    }
    
    // MARK: - Navigation State
    
    /// Check if we can navigate back
    var canGoBack: Bool {
        !path.isEmpty
    }
    
    /// Get current navigation depth
    var navigationDepth: Int {
        path.count
    }
    
    /// Check if at root level
    var isAtRoot: Bool {
        path.isEmpty
    }
}

// MARK: - App Destinations

struct SearchFilters: Hashable {
    var collections: [String]
    var priceRange: ClosedRange<Double>?
    var materials: [String]
    var availability: [ProductAvailability]
    
    init(collections: [String] = [], priceRange: ClosedRange<Double>? = nil, materials: [String] = [], availability: [ProductAvailability] = []) {
        self.collections = collections
        self.priceRange = priceRange
        self.materials = materials
        self.availability = availability
    }
}

typealias ProductFilters = SearchFilters

enum AppDestination: Hashable {
    // Core product navigation
    case productDetail(productId: String)
    case collectionDetail(collectionId: String)
    
    // Store & location navigation
    case boutiqueDetail(storeId: String)
    case appointmentBooking(storeId: String)
    
    // Advanced features navigation
    case watchConfigurator(productId: String)
    case arTryOn(productId: String)
    
    // User account navigation
    case orderHistory
    case orderDetail(orderId: String)
    case wishlistDetail(wishlistId: String)
    case settings
    case editProfile
    
    // Search and filtering
    case searchResults(query: String, filters: SearchFilters? = nil)
    case collectionFilter(collectionId: String)
    
    // Heritage and content
    case heritageStory(storyId: String)
    case brandContent(contentId: String)
    
    // Support and services
    case customerSupport
    case warrantyRegistration(productId: String)
    case serviceRequest(productId: String)
    
    // Premium features
    case exclusiveContent
    case limitedEditions
    case membershipBenefits
    
    // Onboarding
    case welcomeOnboarding
    case stylePreferences
    case locationPermissions
    case notificationPermissions
}

// MARK: - Navigation Destination View Builder



extension AppDestination {
    /// Get the display title for the destination
    var title: String {
        switch self {
        case .productDetail:
            return "Product Details"
        case .collectionDetail:
            return "Collection"
        case .boutiqueDetail:
            return "Boutique"
        case .appointmentBooking:
            return "Book Appointment"
        case .watchConfigurator:
            return "Customize Watch"
        case .arTryOn:
            return "AR Try-On"
        case .orderHistory:
            return "Order History"
        case .orderDetail:
            return "Order Details"
        case .wishlistDetail:
            return "Wishlist"
        case .settings:
            return "Settings"
        case .editProfile:
            return "Edit Profile"
        case .searchResults:
            return "Search Results"
        case .collectionFilter:
            return "Collection"
        case .heritageStory:
            return "Heritage"
        case .brandContent:
            return "Breitling"
        case .customerSupport:
            return "Support"
        case .warrantyRegistration:
            return "Warranty Registration"
        case .serviceRequest:
            return "Service Request"
        case .exclusiveContent:
            return "Exclusive"
        case .limitedEditions:
            return "Limited Editions"
        case .membershipBenefits:
            return "Membership"
        case .welcomeOnboarding:
            return "Welcome"
        case .stylePreferences:
            return "Style Preferences"
        case .locationPermissions:
            return "Location Services"
        case .notificationPermissions:
            return "Notifications"
        }
    }
    
    /// Check if destination requires authentication
    var requiresAuthentication: Bool {
        switch self {
        case .orderHistory, .orderDetail, .wishlistDetail, .settings, .editProfile,
             .appointmentBooking, .warrantyRegistration, .serviceRequest,
             .exclusiveContent, .membershipBenefits:
            return true
        default:
            return false
        }
    }
    
    /// Check if destination is premium/exclusive content
    var isPremiumContent: Bool {
        switch self {
        case .exclusiveContent, .limitedEditions, .membershipBenefits:
            return true
        default:
            return false
        }
    }
    
    
}
