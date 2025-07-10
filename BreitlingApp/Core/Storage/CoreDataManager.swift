//
//  CoreDataManager.swift
//  BreitlingApp
//
//  Created by Arup Sarkar (TA) on 7/10/25.
//

//
//  CoreDataManager.swift
//  BreitlingApp
//
//  Simplified storage management using UserDefaults
//  Will be upgraded to Core Data later in development
//

import Foundation
import Combine

@MainActor
class CoreDataManager: ObservableObject {
    
    // MARK: - UserDefaults Keys
    
    private enum Keys {
        static let cachedProducts = "breitling_cached_products"
        static let cachedCollections = "breitling_cached_collections"
        static let wishlistItems = "breitling_wishlist_items"
        static let browsingHistory = "breitling_browsing_history"
        static let userPreferences = "breitling_user_preferences"
        static let favoriteStores = "breitling_favorite_stores"
        static let searchHistory = "breitling_search_history"
    }
    
    private let userDefaults = UserDefaults.standard
    private let maxHistoryItems = 50
    private let maxSearchHistory = 20
    
    // MARK: - Published Properties
    
    @Published var isLoading = false
    @Published var error: StorageError?
    
    enum StorageError: LocalizedError {
        case encodingFailed
        case decodingFailed
        case notFound
        
        var errorDescription: String? {
            switch self {
            case .encodingFailed:
                return "Failed to save data"
            case .decodingFailed:
                return "Failed to load data"
            case .notFound:
                return "Data not found"
            }
        }
    }
    
    // MARK: - Product Caching
    
    /// Cache product for offline access
    func cacheProduct(_ product: Product) {
        var cachedProducts = fetchCachedProducts()
        
        // Remove existing product if it exists
        cachedProducts.removeAll { $0.id == product.id }
        
        // Add new product
        cachedProducts.append(product)
        
        // Keep only last 100 products
        if cachedProducts.count > 100 {
            cachedProducts = Array(cachedProducts.suffix(100))
        }
        
        saveProducts(cachedProducts)
    }
    
    /// Fetch cached products
    func fetchCachedProducts() -> [Product] {
        guard let data = userDefaults.data(forKey: Keys.cachedProducts) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Product].self, from: data)
        } catch {
            print("Error fetching cached products: \(error)")
            return []
        }
    }
    
    /// Get cached product by ID
    func getCachedProduct(id: String) -> Product? {
        return fetchCachedProducts().first { $0.id == id }
    }
    
    private func saveProducts(_ products: [Product]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(products)
            userDefaults.set(data, forKey: Keys.cachedProducts)
        } catch {
            print("Error saving products: \(error)")
            self.error = .encodingFailed
        }
    }
    
    // MARK: - Collection Caching
    
    /// Cache collection
    func cacheCollection(_ collection: Collection) {
        var cachedCollections = fetchCachedCollections()
        
        // Remove existing collection if it exists
        cachedCollections.removeAll { $0.id == collection.id }
        
        // Add new collection
        cachedCollections.append(collection)
        
        saveCollections(cachedCollections)
    }
    
    /// Fetch cached collections
    func fetchCachedCollections() -> [Collection] {
        guard let data = userDefaults.data(forKey: Keys.cachedCollections) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Collection].self, from: data)
        } catch {
            print("Error fetching cached collections: \(error)")
            return []
        }
    }
    
    private func saveCollections(_ collections: [Collection]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(collections)
            userDefaults.set(data, forKey: Keys.cachedCollections)
        } catch {
            print("Error saving collections: \(error)")
            self.error = .encodingFailed
        }
    }
    
    // MARK: - Wishlist Management
    
    /// Add product to wishlist
    func addToWishlist(productId: String, wishlistId: String = "default", notes: String? = nil, priority: WishlistPriority = .medium) {
        var wishlistItems = fetchWishlistItems()
        
        // Check if already in wishlist
        guard !wishlistItems.contains(where: { $0.productId == productId }) else {
            return
        }
        
        let wishlistItem = SimpleWishlistItem(
            id: UUID().uuidString,
            productId: productId,
            wishlistId: wishlistId,
            notes: notes,
            priority: priority,
            addedDate: Date()
        )
        
        wishlistItems.append(wishlistItem)
        saveWishlistItems(wishlistItems)
    }
    
    /// Remove product from wishlist
    func removeFromWishlist(productId: String, wishlistId: String = "default") {
        var wishlistItems = fetchWishlistItems()
        wishlistItems.removeAll { $0.productId == productId && $0.wishlistId == wishlistId }
        saveWishlistItems(wishlistItems)
    }
    
    /// Check if product is in wishlist
    func isInWishlist(productId: String, wishlistId: String = "default") -> Bool {
        return fetchWishlistItems().contains { $0.productId == productId && $0.wishlistId == wishlistId }
    }
    
    /// Fetch wishlist items
    func fetchWishlistItems(wishlistId: String = "default") -> [SimpleWishlistItem] {
        guard let data = userDefaults.data(forKey: Keys.wishlistItems) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let allItems = try decoder.decode([SimpleWishlistItem].self, from: data)
            return allItems.filter { $0.wishlistId == wishlistId }
        } catch {
            print("Error fetching wishlist items: \(error)")
            return []
        }
    }
    
    private func saveWishlistItems(_ items: [SimpleWishlistItem]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(items)
            userDefaults.set(data, forKey: Keys.wishlistItems)
        } catch {
            print("Error saving wishlist items: \(error)")
            self.error = .encodingFailed
        }
    }
    
    // MARK: - Browsing History
    
    /// Save product to browsing history
    func saveToBrowsingHistory(productId: String) {
        var history = fetchBrowsingHistory()
        
        // Remove if already exists to update timestamp
        history.removeAll { $0 == productId }
        
        // Add to beginning
        history.insert(productId, at: 0)
        
        // Keep only last items
        if history.count > maxHistoryItems {
            history = Array(history.prefix(maxHistoryItems))
        }
        
        saveBrowsingHistory(history)
    }
    
    /// Fetch browsing history
    func fetchBrowsingHistory(limit: Int = 20) -> [String] {
        let history = userDefaults.stringArray(forKey: Keys.browsingHistory) ?? []
        return Array(history.prefix(limit))
    }
    
    private func saveBrowsingHistory(_ history: [String]) {
        userDefaults.set(history, forKey: Keys.browsingHistory)
    }
    
    // MARK: - User Preferences
    
    /// Save user preferences
    func saveUserPreferences(_ preferences: UserPreferences) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(preferences)
            userDefaults.set(data, forKey: Keys.userPreferences)
        } catch {
            print("Error saving user preferences: \(error)")
            self.error = .encodingFailed
        }
    }
    
    /// Fetch user preferences
    func fetchUserPreferences() -> UserPreferences? {
        guard let data = userDefaults.data(forKey: Keys.userPreferences) else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(UserPreferences.self, from: data)
        } catch {
            print("Error fetching user preferences: \(error)")
            return nil
        }
    }
    
    // MARK: - Favorite Stores
    
    /// Add store to favorites
    func addFavoriteStore(storeId: String) {
        var favoriteStores = fetchFavoriteStoreIds()
        
        if !favoriteStores.contains(storeId) {
            favoriteStores.append(storeId)
            saveFavoriteStores(favoriteStores)
        }
    }
    
    /// Remove store from favorites
    func removeFavoriteStore(storeId: String) {
        var favoriteStores = fetchFavoriteStoreIds()
        favoriteStores.removeAll { $0 == storeId }
        saveFavoriteStores(favoriteStores)
    }
    
    /// Check if store is favorited
    func isStoreFavorited(storeId: String) -> Bool {
        return fetchFavoriteStoreIds().contains(storeId)
    }
    
    /// Fetch favorite store IDs
    func fetchFavoriteStoreIds() -> [String] {
        return userDefaults.stringArray(forKey: Keys.favoriteStores) ?? []
    }
    
    private func saveFavoriteStores(_ storeIds: [String]) {
        userDefaults.set(storeIds, forKey: Keys.favoriteStores)
    }
    
    // MARK: - Search History
    
    /// Save search query
    func saveSearchQuery(_ query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }
        
        var searchHistory = fetchSearchHistory()
        
        // Remove if already exists
        searchHistory.removeAll { $0 == trimmedQuery }
        
        // Add to beginning
        searchHistory.insert(trimmedQuery, at: 0)
        
        // Keep only recent searches
        if searchHistory.count > maxSearchHistory {
            searchHistory = Array(searchHistory.prefix(maxSearchHistory))
        }
        
        saveSearchHistory(searchHistory)
    }
    
    /// Fetch search history
    func fetchSearchHistory(limit: Int = 10) -> [String] {
        let history = userDefaults.stringArray(forKey: Keys.searchHistory) ?? []
        return Array(history.prefix(limit))
    }
    
    private func saveSearchHistory(_ history: [String]) {
        userDefaults.set(history, forKey: Keys.searchHistory)
    }
    
    // MARK: - Utility Methods
    
    /// Clear all data (for logout or reset)
    func clearAllData() {
        let keys = [Keys.cachedProducts, Keys.cachedCollections, Keys.wishlistItems,
                   Keys.browsingHistory, Keys.userPreferences, Keys.favoriteStores, Keys.searchHistory]
        
        for key in keys {
            userDefaults.removeObject(forKey: key)
        }
    }
    
    /// Clear only user-specific data (keep cached products/collections)
    func clearUserData() {
        let userKeys = [Keys.wishlistItems, Keys.browsingHistory, Keys.userPreferences,
                       Keys.favoriteStores, Keys.searchHistory]
        
        for key in userKeys {
            userDefaults.removeObject(forKey: key)
        }
    }
    
    /// Get storage usage info
    func getStorageInfo() -> StorageInfo {
        let cachedProducts = fetchCachedProducts().count
        let cachedCollections = fetchCachedCollections().count
        let wishlistItems = fetchWishlistItems().count
        let browsingHistory = fetchBrowsingHistory().count
        let searchHistory = fetchSearchHistory().count
        let favoriteStores = fetchFavoriteStoreIds().count
        
        return StorageInfo(
            cachedProducts: cachedProducts,
            cachedCollections: cachedCollections,
            wishlistItems: wishlistItems,
            browsingHistory: browsingHistory,
            searchHistory: searchHistory,
            favoriteStores: favoriteStores
        )
    }
}

// MARK: - Supporting Types

struct SimpleWishlistItem: Codable {
    let id: String
    let productId: String
    let wishlistId: String
    let notes: String?
    let priority: WishlistPriority
    let addedDate: Date
}

struct StorageInfo {
    let cachedProducts: Int
    let cachedCollections: Int
    let wishlistItems: Int
    let browsingHistory: Int
    let searchHistory: Int
    let favoriteStores: Int
    
    var totalItems: Int {
        cachedProducts + cachedCollections + wishlistItems + browsingHistory + searchHistory + favoriteStores
    }
}

// MARK: - Singleton Instance

extension CoreDataManager {
    static let shared = CoreDataManager()
}
