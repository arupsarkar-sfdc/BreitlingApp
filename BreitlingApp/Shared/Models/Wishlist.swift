//
//  Wishlist.swift
//  BreitlingApp
//
//  Created by Arup Sarkar (TA) on 7/10/25.
//

//
//  Wishlist.swift
//  BreitlingApp
//
//  Wishlist model for saved products and collections
//  Supports personalization and cross-device sync
//

import Foundation

struct Wishlist: Identifiable, Codable {
    let id: String
    let userId: String
    let name: String
    let description: String?
    let items: [WishlistItem]
    let collections: [WishlistCollection]
    let createdDate: Date
    let lastModifiedDate: Date
    let isPrivate: Bool
    let shareCode: String?
    let category: WishlistCategory
    let tags: [String]
    
    // Computed properties
    var totalItems: Int {
        items.count
    }
    
    var totalValue: Double {
        items.compactMap { $0.estimatedPrice }.reduce(0, +)
    }
    
    var formattedTotalValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD" // Default to USD, could be user preference
        return formatter.string(from: NSNumber(value: totalValue)) ?? "USD \(totalValue)"
    }
    
    var hasHighValueItems: Bool {
        items.contains { ($0.estimatedPrice ?? 0) > 10000 }
    }
    
    var mostExpensiveItem: WishlistItem? {
        items.max { ($0.estimatedPrice ?? 0) < ($1.estimatedPrice ?? 0) }
    }
    
    var newestItem: WishlistItem? {
        items.max { $0.addedDate < $1.addedDate }
    }
    
    var collectionsRepresented: [String] {
        Array(Set(items.compactMap { $0.collectionName }))
    }
    
    var isPremiumWishlist: Bool {
        totalValue > 25000 || hasHighValueItems
    }
    
    var canShare: Bool {
        !isPrivate && !items.isEmpty
    }
}

struct WishlistItem: Identifiable, Codable {
    let id: String
    let productId: String
    let productName: String
    let collectionName: String?
    let imageURL: String?
    let estimatedPrice: Double?
    let currency: String
    let availability: ProductAvailability?
    let addedDate: Date
    let priority: WishlistPriority
    let notes: String?
    let desiredCustomizations: [ProductCustomization]?
    let reminderDate: Date?
    let giftRecipient: String? // For gift ideas
    let occasionTag: String? // Birthday, anniversary, etc.
    
    // Computed properties
    var formattedPrice: String? {
        guard let price = estimatedPrice else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: price))
    }
    
    var isAvailable: Bool {
        availability == .inStock || availability == .limitedStock
    }
    
    var daysSinceAdded: Int {
        Calendar.current.dateComponents([.day], from: addedDate, to: Date()).day ?? 0
    }
    
    var hasReminder: Bool {
        reminderDate != nil
    }
    
    var isReminderDue: Bool {
        guard let reminderDate = reminderDate else { return false }
        return Date() >= reminderDate
    }
    
    var isGiftIdea: Bool {
        giftRecipient != nil
    }
    
    var hasCustomizations: Bool {
        !(desiredCustomizations?.isEmpty ?? true)
    }
}

struct WishlistCollection: Identifiable, Codable {
    let id: String
    let collectionId: String
    let collectionName: String
    let addedDate: Date
    let reason: String? // Why this collection interests the user
    let notificationPreference: CollectionNotificationPreference
}

enum WishlistCategory: String, Codable, CaseIterable {
    case general = "general"
    case giftIdeas = "gift_ideas"
    case dreamWatches = "dream_watches"
    case investment = "investment"
    case occasionSpecific = "occasion_specific"
    case limitedEdition = "limited_edition"
    case heritage = "heritage"
    case professional = "professional"
    
    var displayName: String {
        switch self {
        case .general:
            return "General Wishlist"
        case .giftIdeas:
            return "Gift Ideas"
        case .dreamWatches:
            return "Dream Watches"
        case .investment:
            return "Investment Pieces"
        case .occasionSpecific:
            return "Special Occasions"
        case .limitedEdition:
            return "Limited Editions"
        case .heritage:
            return "Heritage Collection"
        case .professional:
            return "Professional Use"
        }
    }
    
    var iconName: String {
        switch self {
        case .general:
            return "heart"
        case .giftIdeas:
            return "gift"
        case .dreamWatches:
            return "star.circle"
        case .investment:
            return "chart.line.uptrend.xyaxis"
        case .occasionSpecific:
            return "calendar.badge.plus"
        case .limitedEdition:
            return "crown"
        case .heritage:
            return "clock.arrow.circlepath"
        case .professional:
            return "briefcase"
        }
    }
    
    var color: String {
        switch self {
        case .general:
            return "red"
        case .giftIdeas:
            return "green"
        case .dreamWatches:
            return "purple"
        case .investment:
            return "blue"
        case .occasionSpecific:
            return "orange"
        case .limitedEdition:
            return "gold"
        case .heritage:
            return "brown"
        case .professional:
            return "gray"
        }
    }
}

enum WishlistPriority: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case urgent = "urgent"
    
    var displayName: String {
        switch self {
        case .low:
            return "Low Priority"
        case .medium:
            return "Medium Priority"
        case .high:
            return "High Priority"
        case .urgent:
            return "Must Have"
        }
    }
    
    var color: String {
        switch self {
        case .low:
            return "gray"
        case .medium:
            return "blue"
        case .high:
            return "orange"
        case .urgent:
            return "red"
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .urgent:
            return 1
        case .high:
            return 2
        case .medium:
            return 3
        case .low:
            return 4
        }
    }
}

enum CollectionNotificationPreference: String, Codable, CaseIterable {
    case all = "all"
    case newReleases = "new_releases"
    case limitedEditions = "limited_editions"
    case priceChanges = "price_changes"
    case none = "none"
    
    var displayName: String {
        switch self {
        case .all:
            return "All Updates"
        case .newReleases:
            return "New Releases Only"
        case .limitedEditions:
            return "Limited Editions Only"
        case .priceChanges:
            return "Price Changes Only"
        case .none:
            return "No Notifications"
        }
    }
}

// MARK: - Wishlist Management Extensions
extension Wishlist {
    // Sort items by priority and date
    var sortedItems: [WishlistItem] {
        items.sorted { item1, item2 in
            if item1.priority.sortOrder != item2.priority.sortOrder {
                return item1.priority.sortOrder < item2.priority.sortOrder
            }
            return item1.addedDate > item2.addedDate
        }
    }
    
    // Get items by collection
    func items(forCollection collectionName: String) -> [WishlistItem] {
        items.filter { $0.collectionName == collectionName }
    }
    
    // Get items by priority
    func items(withPriority priority: WishlistPriority) -> [WishlistItem] {
        items.filter { $0.priority == priority }
    }
    
    // Get gift ideas
    var giftIdeas: [WishlistItem] {
        items.filter { $0.isGiftIdea }
    }
    
    // Get items with due reminders
    var itemsWithDueReminders: [WishlistItem] {
        items.filter { $0.isReminderDue }
    }
    
    // Get available items only
    var availableItems: [WishlistItem] {
        items.filter { $0.isAvailable }
    }
    
    // Get items within price range
    func items(inPriceRange range: ClosedRange<Double>) -> [WishlistItem] {
        items.filter { item in
            guard let price = item.estimatedPrice else { return false }
            return range.contains(price)
        }
    }
}

// MARK: - Mock Data for Development
extension Wishlist {
    static let mockWishlists: [Wishlist] = [
        Wishlist(
            id: "wishlist-001",
            userId: "user-12345",
            name: "My Dream Watches",
            description: "Timepieces I aspire to own someday",
            items: [
                WishlistItem.mockNavitimerItem,
                WishlistItem.mockChronomatItem,
                WishlistItem.mockSuperoceanItem
            ],
            collections: [
                WishlistCollection(
                    id: "wc-001",
                    collectionId: "navitimer",
                    collectionName: "Navitimer",
                    addedDate: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
                    reason: "Love the aviation heritage and slide rule functionality",
                    notificationPreference: .newReleases
                )
            ],
            createdDate: Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date(),
            lastModifiedDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            isPrivate: false,
            shareCode: "BR-WL-ABC123",
            category: .dreamWatches,
            tags: ["luxury", "swiss", "chronograph"]
        ),
        Wishlist(
            id: "wishlist-002",
            userId: "user-12345",
            name: "Anniversary Gift Ideas",
            description: "Gift options for our 10th anniversary",
            items: [WishlistItem.mockGiftItem],
            collections: [],
            createdDate: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date(),
            lastModifiedDate: Calendar.current
                .date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date(),
            isPrivate: true,
            shareCode: nil,
            category: .giftIdeas,
            tags: ["anniversary", "gift", "special-occasion"]
        ),
        Wishlist(
            id: "wishlist-003",
            userId: "user-12345",
            name: "Limited Edition Watch",
            description: "Exclusive and rare timepieces to collect",
            items: [WishlistItem.mockLimitedEditionItem],
            collections: [],
            createdDate: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date(),
            lastModifiedDate: Date(),
            isPrivate: false,
            shareCode: "BR-WL-XYZ789",
            category: .limitedEdition,
            tags: ["limited-edition", "collectible", "investment"]
        )
    ]
    
    static let defaultWishlist = mockWishlists[0]
}

extension WishlistItem {
    static let mockNavitimerItem = WishlistItem(
        id: "wi-001",
        productId: "navitimer-b01-chronograph-43",
        productName: "Navitimer B01 Chronograph 43",
        collectionName: "Navitimer",
        imageURL: "navitimer-b01-front",
        estimatedPrice: 8950.00,
        currency: "USD",
        availability: .inStock,
        addedDate: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
        priority: .high,
        notes: "Perfect pilot's watch for my aviation hobby",
        desiredCustomizations: nil,
        reminderDate: Calendar.current.date(byAdding: .month, value: 2, to: Date()),
        giftRecipient: nil,
        occasionTag: nil
    )
    
    static let mockChronomatItem = WishlistItem(
        id: "wi-002",
        productId: "chronomat-b01-42",
        productName: "Chronomat B01 42",
        collectionName: "Chronomat",
        imageURL: "chronomat-b01-front",
        estimatedPrice: 7450.00,
        currency: "USD",
        availability: .inStock,
        addedDate: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date(),
        priority: .medium,
        notes: "Love the rouleaux bracelet design",
        desiredCustomizations: [
            ProductCustomization(type: .dial, value: "Blue Dial", additionalCost: 0)
        ],
        reminderDate: nil,
        giftRecipient: nil,
        occasionTag: nil
    )
    
    static let mockSuperoceanItem = WishlistItem(
        id: "wi-003",
        productId: "superocean-automatic-46",
        productName: "Superocean Automatic 46",
        collectionName: "Superocean",
        imageURL: "superocean-automatic-front",
        estimatedPrice: 2190.00,
        currency: "USD",
        availability: .limitedStock,
        addedDate: Calendar.current
            .date(byAdding: .weekOfYear, value: -2, to: Date()) ?? Date(),
        priority: .low,
        notes: "Great diving watch for summer trips",
        desiredCustomizations: nil,
        reminderDate: nil,
        giftRecipient: nil,
        occasionTag: "summer-vacation"
    )
    
    static let mockGiftItem = WishlistItem(
        id: "wi-004",
        productId: "premier-heritage-b01",
        productName: "Premier Heritage B01 Chronograph",
        collectionName: "Premier",
        imageURL: "premier-heritage-front",
        estimatedPrice: 4690.00,
        currency: "USD",
        availability: .inStock,
        addedDate: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(),
        priority: .urgent,
        notes: "Perfect elegant piece for special occasions",
        desiredCustomizations: nil,
        reminderDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()),
        giftRecipient: "Sarah",
        occasionTag: "10th-anniversary"
    )
    
    static let mockLimitedEditionItem = WishlistItem(
        id: "wi-005",
        productId: "superocean-heritage-57-limited",
        productName: "Superocean Heritage '57 Limited Edition",
        collectionName: "Superocean Heritage",
        imageURL: "superocean-heritage-limited-front",
        estimatedPrice: 4390.00,
        currency: "USD",
        availability: .limitedStock,
        addedDate: Date(),
        priority: .urgent,
        notes: "Only 1957 pieces made - must have for collection",
        desiredCustomizations: nil,
        reminderDate: Calendar.current
            .date(byAdding: .weekOfYear, value: 1, to: Date()),
        giftRecipient: nil,
        occasionTag: nil
    )
}
