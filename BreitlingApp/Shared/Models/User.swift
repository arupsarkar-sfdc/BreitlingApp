//
//  User.swift
//  BreitlingApp
//
//  Created by Arup Sarkar (TA) on 7/10/25.
//

//
//  User.swift
//  BreitlingApp
//
//  User model for authentication and preferences
//  Supports personalization opportunities from JSON analysis
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let dateJoined: Date
    let membershipTier: MembershipTier
    let preferences: UserPreferences
    let profile: UserProfile
    let isEmailVerified: Bool
    let lastLoginDate: Date?
    
    // Computed properties
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var initials: String {
        let firstInitial = firstName.first?.uppercased() ?? ""
        let lastInitial = lastName.first?.uppercased() ?? ""
        return "\(firstInitial)\(lastInitial)"
    }
    
    var membershipBenefits: [String] {
        membershipTier.benefits
    }
    
    var isActive: Bool {
        guard let lastLogin = lastLoginDate else { return false }
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return lastLogin > thirtyDaysAgo
    }
}

struct UserPreferences: Codable {
    // Collection preferences for personalization
    let preferredCollections: [String]
    let priceRange: PriceRange
    let preferredMaterials: [String]
    let stylePreferences: [StylePreference]
    
    // Notification preferences
    let notifications: NotificationPreferences
    
    // Behavioral preferences from JSON analysis
    let occasionPreferences: [OccasionType]
    let seasonalPreferences: [SeasonalStyle]
    
    // Privacy preferences
    let allowPersonalization: Bool
    let allowLocationServices: Bool
    let allowMarketingEmails: Bool
}

struct UserProfile: Codable {
    let phoneNumber: String?
    let dateOfBirth: Date?
    let gender: Gender?
    let country: String
    let preferredLanguage: String
    let timeZone: String
    
    // Luxury customer profile
    let interests: [LuxuryInterest]
    let previousPurchases: [String] // Product IDs
    let wishlistIds: [String]
    let favoriteStoreIds: [String]
}

enum MembershipTier: String, Codable, CaseIterable {
    case explorer = "explorer"
    case classic = "classic"
    case premier = "premier"
    case exclusive = "exclusive"
    
    var displayName: String {
        switch self {
        case .explorer:
            return "Explorer"
        case .classic:
            return "Classic"
        case .premier:
            return "Premier"
        case .exclusive:
            return "Exclusive"
        }
    }
    
    var benefits: [String] {
        switch self {
        case .explorer:
            return ["Access to collections", "Basic support"]
        case .classic:
            return ["Priority support", "Exclusive content", "Early access to new releases"]
        case .premier:
            return ["Personal shopping assistant", "Private events", "Complimentary services", "Express shipping"]
        case .exclusive:
            return ["Limited edition access", "VIP concierge", "Private boutique appointments", "Exclusive experiences"]
        }
    }
    
    var color: String {
        switch self {
        case .explorer:
            return "gray"
        case .classic:
            return "blue"
        case .premier:
            return "gold"
        case .exclusive:
            return "black"
        }
    }
}

struct NotificationPreferences: Codable {
    let newCollections: Bool
    let limitedEditions: Bool
    let appointments: Bool
    let priceDrops: Bool
    let personalizedRecommendations: Bool
    let exclusiveEvents: Bool
    let orderUpdates: Bool
    let newsletterSubscription: Bool
    
    static let defaultSettings = NotificationPreferences(
        newCollections: true,
        limitedEditions: true,
        appointments: true,
        priceDrops: false,
        personalizedRecommendations: true,
        exclusiveEvents: true,
        orderUpdates: true,
        newsletterSubscription: false
    )
}

enum StylePreference: String, Codable, CaseIterable {
    case classic = "classic"
    case modern = "modern"
    case vintage = "vintage"
    case sporty = "sporty"
    case elegant = "elegant"
    case professional = "professional"
    
    var displayName: String {
        rawValue.capitalized
    }
}

enum OccasionType: String, Codable, CaseIterable {
    case daily = "daily"
    case business = "business"
    case formal = "formal"
    case sport = "sport"
    case travel = "travel"
    case special = "special"
    
    var displayName: String {
        switch self {
        case .daily:
            return "Daily Wear"
        case .business:
            return "Business"
        case .formal:
            return "Formal Events"
        case .sport:
            return "Sports & Active"
        case .travel:
            return "Travel"
        case .special:
            return "Special Occasions"
        }
    }
}

enum SeasonalStyle: String, Codable, CaseIterable {
    case spring = "spring"
    case summer = "summer"
    case autumn = "autumn"
    case winter = "winter"
    
    var displayName: String {
        rawValue.capitalized
    }
}

enum Gender: String, Codable, CaseIterable {
    case male = "male"
    case female = "female"
    case nonBinary = "non_binary"
    case preferNotToSay = "prefer_not_to_say"
    
    var displayName: String {
        switch self {
        case .male:
            return "Male"
        case .female:
            return "Female"
        case .nonBinary:
            return "Non-binary"
        case .preferNotToSay:
            return "Prefer not to say"
        }
    }
}

enum LuxuryInterest: String, Codable, CaseIterable {
    case horology = "horology"
    case aviation = "aviation"
    case diving = "diving"
    case racing = "racing"
    case travel = "travel"
    case art = "art"
    case fashion = "fashion"
    case technology = "technology"
    
    var displayName: String {
        switch self {
        case .horology:
            return "Horology & Watchmaking"
        case .aviation:
            return "Aviation"
        case .diving:
            return "Diving & Water Sports"
        case .racing:
            return "Motor Racing"
        case .travel:
            return "Luxury Travel"
        case .art:
            return "Art & Culture"
        case .fashion:
            return "Fashion & Style"
        case .technology:
            return "Technology & Innovation"
        }
    }
}

// MARK: - Mock Data for Development
extension User {
    static let mockUser = User(
        id: "user-12345",
        email: "john.smith@example.com",
        firstName: "John",
        lastName: "Smith",
        dateJoined: Calendar.current.date(byAdding: .year, value: -2, to: Date()) ?? Date(),
        membershipTier: .premier,
        preferences: UserPreferences(
            preferredCollections: ["navitimer", "chronomat"],
            priceRange: PriceRange(min: 5000.00, max: 15000.00, currency: "USD"),
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
            previousPurchases: ["navitimer-b01-chronograph-43"],
            wishlistIds: ["chronomat-b01-42", "superocean-heritage-57-limited"],
            favoriteStoreIds: ["store-ny-madison", "store-ca-beverly-hills"]
        ),
        isEmailVerified: true,
        lastLoginDate: Date()
    )
    
    static let guestUser = User(
        id: "guest",
        email: "",
        firstName: "Guest",
        lastName: "User",
        dateJoined: Date(),
        membershipTier: .explorer,
        preferences: UserPreferences(
            preferredCollections: [],
            priceRange: PriceRange(min: 0, max: 50000, currency: "USD"),
            preferredMaterials: [],
            stylePreferences: [],
            notifications: NotificationPreferences(
                newCollections: false,
                limitedEditions: false,
                appointments: false,
                priceDrops: false,
                personalizedRecommendations: false,
                exclusiveEvents: false,
                orderUpdates: false,
                newsletterSubscription: false
            ),
            occasionPreferences: [],
            seasonalPreferences: [],
            allowPersonalization: false,
            allowLocationServices: false,
            allowMarketingEmails: false
        ),
        profile: UserProfile(
            phoneNumber: nil,
            dateOfBirth: nil,
            gender: nil,
            country: "United States",
            preferredLanguage: "en",
            timeZone: TimeZone.current.identifier,
            interests: [],
            previousPurchases: [],
            wishlistIds: [],
            favoriteStoreIds: []
        ),
        isEmailVerified: false,
        lastLoginDate: nil
    )
}
