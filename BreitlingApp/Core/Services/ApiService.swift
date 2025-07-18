//
//  BreitlingApp
//
//  Created by Arup Sarkar (TA) on 7/10/25.
//

//
//  APIService.swift
//  BreitlingApp
//
//  Network service for product catalog, inventory, authentication
//  Based on network_apis from JSON analysis
//

import Foundation
import Combine

@MainActor
class APIService: ObservableObject {
    
    // MARK: - Configuration
    
    private let baseURL = "https://api.breitling.com/v1"
    private let session = URLSession.shared
    private var cancellables = Set<AnyCancellable>()
    
    // Authentication token
    @Published var authToken: String?
    @Published var isAuthenticated: Bool = false
    
    // MARK: - Error Handling
    
    enum APIError: LocalizedError {
        case invalidURL
        case noData
        case decodingError
        case networkError(Error)
        case unauthorized
        case serverError(Int)
        case rateLimited
        case maintenance
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .noData:
                return "No data received"
            case .decodingError:
                return "Failed to decode response"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .unauthorized:
                return "Authentication required"
            case .serverError(let code):
                return "Server error: \(code)"
            case .rateLimited:
                return "Too many requests. Please try again later."
            case .maintenance:
                return "Service temporarily unavailable"
            }
        }
    }
    
    // MARK: - Product Catalog API
    
    /// Fetch all products with optional filtering
    func fetchProductCatalog(filters: ProductFilters? = nil) async throws -> [Product] {
        let endpoint = "/products"
        var queryItems: [URLQueryItem] = []
        
        if let filters = filters {
            if !filters.collections.isEmpty {
                queryItems.append(URLQueryItem(name: "collections", value: filters.collections.joined(separator: ",")))
            }
            if let priceRange = filters.priceRange {
                queryItems.append(URLQueryItem(name: "min_price", value: String(priceRange.lowerBound)))
                queryItems.append(URLQueryItem(name: "max_price", value: String(priceRange.upperBound)))
            }
            if !filters.materials.isEmpty {
                queryItems.append(URLQueryItem(name: "materials", value: filters.materials.joined(separator: ",")))
            }
            if !filters.availability.isEmpty {
                queryItems.append(URLQueryItem(name: "availability", value: filters.availability.map { $0.rawValue }.joined(separator: ",")))
            }
        }
        
        return try await performRequest(endpoint: endpoint, queryItems: queryItems, responseType: [Product].self)
    }
    
    /// Fetch specific product by ID
    func fetchProduct(id: String) async throws -> Product {
        let endpoint = "/products/\(id)"
        return try await performRequest(endpoint: endpoint, responseType: Product.self)
    }
    
    /// Search products
    func searchProducts(query: String, filters: SearchFilters? = nil) async throws -> [Product] {
        let endpoint = "/products/search"
        var queryItems = [URLQueryItem(name: "q", value: query)]
        
        if let filters = filters {
            if !filters.collections.isEmpty {
                queryItems.append(URLQueryItem(name: "collections", value: filters.collections.joined(separator: ",")))
            }
            if let priceRange = filters.priceRange {
                queryItems.append(URLQueryItem(name: "min_price", value: String(priceRange.lowerBound)))
                queryItems.append(URLQueryItem(name: "max_price", value: String(priceRange.upperBound)))
            }
        }
        
        return try await performRequest(endpoint: endpoint, queryItems: queryItems, responseType: [Product].self)
    }
    
    // MARK: - Collection API
    
    /// Fetch all collections
    func fetchCollections() async throws -> [Collection] {
        let endpoint = "/collections"
        return try await performRequest(endpoint: endpoint, responseType: [Collection].self)
    }
    
    /// Fetch specific collection by ID
    func fetchCollection(id: String) async throws -> Collection {
        let endpoint = "/collections/\(id)"
        return try await performRequest(endpoint: endpoint, responseType: Collection.self)
    }
    
    /// Fetch products in a collection
    func fetchCollectionProducts(collectionId: String) async throws -> [Product] {
        let endpoint = "/collections/\(collectionId)/products"
        return try await performRequest(endpoint: endpoint, responseType: [Product].self)
    }
    
    // MARK: - Inventory API
    
    /// Check inventory status for a product
    func fetchInventoryStatus(productId: String) async throws -> InventoryStatus {
        let endpoint = "/inventory/\(productId)"
        return try await performRequest(endpoint: endpoint, responseType: InventoryStatus.self)
    }
    
    /// Check inventory for multiple products
    func fetchInventoryStatus(productIds: [String]) async throws -> [String: InventoryStatus] {
        let endpoint = "/inventory/batch"
        let body = ["product_ids": productIds]
        return try await performRequest(endpoint: endpoint, method: .POST, body: body, responseType: [String: InventoryStatus].self)
    }
    
    // MARK: - User Authentication API
    
    /// Authenticate user with email and password
    func authenticateUser(email: String, password: String) async throws -> AuthResponse {
        let endpoint = "/auth/login"
        let body = [
            "email": email,
            "password": password
        ]
        
        let response: AuthResponse = try await performRequest(endpoint: endpoint, method: .POST, body: body, responseType: AuthResponse.self)
        
        // Update authentication state
        self.authToken = response.token
        self.isAuthenticated = true
        
        return response
    }
    
    /// Register new user
    func registerUser(email: String, password: String, firstName: String, lastName: String) async throws -> AuthResponse {
        let endpoint = "/auth/register"
        let body = [
            "email": email,
            "password": password,
            "first_name": firstName,
            "last_name": lastName
        ]
        
        let response: AuthResponse = try await performRequest(endpoint: endpoint, method: .POST, body: body, responseType: AuthResponse.self)
        
        // Update authentication state
        self.authToken = response.token
        self.isAuthenticated = true
        
        return response
    }
    
    /// Logout user
    func logout() async throws {
        let endpoint = "/auth/logout"
        try await performRequest(endpoint: endpoint, method: .POST, responseType: EmptyResponse.self)
        
        // Clear authentication state
        self.authToken = nil
        self.isAuthenticated = false
    }
    
    /// Fetch current user profile
    func fetchUserProfile() async throws -> User {
        let endpoint = "/user/profile"
        return try await performAuthenticatedRequest(endpoint: endpoint, responseType: User.self)
    }
    
    /// Update user profile
    func updateUserProfile(_ user: User) async throws -> User {
        let endpoint = "/user/profile"
        return try await performAuthenticatedRequest(endpoint: endpoint, method: .PUT, body: user, responseType: User.self)
    }
    
    // MARK: - Store Locations API
    
    /// Fetch all store locations
    func fetchStoreLocations() async throws -> [Store] {
        let endpoint = "/stores"
        return try await performRequest(endpoint: endpoint, responseType: [Store].self)
    }
    
    /// Fetch stores near location
    func fetchNearbyStores(latitude: Double, longitude: Double, radius: Double = 50) async throws -> [Store] {
        let endpoint = "/stores/nearby"
        let queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lng", value: String(longitude)),
            URLQueryItem(name: "radius", value: String(radius))
        ]
        return try await performRequest(endpoint: endpoint, queryItems: queryItems, responseType: [Store].self)
    }
    
    /// Fetch specific store by ID
    func fetchStore(id: String) async throws -> Store {
        let endpoint = "/stores/\(id)"
        return try await performRequest(endpoint: endpoint, responseType: Store.self)
    }
    
    // MARK: - Order Management API
    
    /// Fetch user's order history
    func fetchOrderHistory(userId: String) async throws -> [Order] {
        let endpoint = "/orders"
        return try await performAuthenticatedRequest(endpoint: endpoint, responseType: [Order].self)
    }
    
    /// Fetch specific order
    func fetchOrder(id: String) async throws -> Order {
        let endpoint = "/orders/\(id)"
        return try await performAuthenticatedRequest(endpoint: endpoint, responseType: Order.self)
    }
    
    /// Create new order
    func createOrder(_ orderRequest: OrderRequest) async throws -> Order {
        let endpoint = "/orders"
        return try await performAuthenticatedRequest(endpoint: endpoint, method: .POST, body: orderRequest, responseType: Order.self)
    }
    
    /// Update order status
    func updateOrderStatus(orderId: String, status: OrderStatus) async throws -> Order {
        let endpoint = "/orders/\(orderId)/status"
        let body = ["status": status.rawValue]
        return try await performAuthenticatedRequest(endpoint: endpoint, method: .PUT, body: body, responseType: Order.self)
    }
    
    // MARK: - Wishlist API
    
    /// Fetch user's wishlists
    func fetchWishlists() async throws -> [Wishlist] {
        let endpoint = "/wishlists"
        return try await performAuthenticatedRequest(endpoint: endpoint, responseType: [Wishlist].self)
    }
    
    /// Fetch specific wishlist
    func fetchWishlist(id: String) async throws -> Wishlist {
        let endpoint = "/wishlists/\(id)"
        return try await performAuthenticatedRequest(endpoint: endpoint, responseType: Wishlist.self)
    }
    
    /// Create new wishlist
    func createWishlist(_ wishlist: Wishlist) async throws -> Wishlist {
        let endpoint = "/wishlists"
        return try await performAuthenticatedRequest(endpoint: endpoint, method: .POST, body: wishlist, responseType: Wishlist.self)
    }
    
    /// Add item to wishlist
    func addToWishlist(wishlistId: String, productId: String) async throws -> Wishlist {
        let endpoint = "/wishlists/\(wishlistId)/items"
        let body = ["product_id": productId]
        return try await performAuthenticatedRequest(endpoint: endpoint, method: .POST, body: body, responseType: Wishlist.self)
    }
    
    /// Remove item from wishlist
    func removeFromWishlist(wishlistId: String, itemId: String) async throws -> Wishlist {
        let endpoint = "/wishlists/\(wishlistId)/items/\(itemId)"
        return try await performAuthenticatedRequest(endpoint: endpoint, method: .DELETE, responseType: Wishlist.self)
    }
    
    // MARK: - Appointment API
    
    /// Book appointment at store
    func bookAppointment(_ appointment: AppointmentRequest) async throws -> AppointmentResponse {
        let endpoint = "/appointments"
        return try await performAuthenticatedRequest(endpoint: endpoint, method: .POST, body: appointment, responseType: AppointmentResponse.self)
    }
    
    /// Fetch user appointments
    func fetchAppointments() async throws -> [AppointmentResponse] {
        let endpoint = "/appointments"
        return try await performAuthenticatedRequest(endpoint: endpoint, responseType: [AppointmentResponse].self)
    }
    
    /// Cancel appointment
    func cancelAppointment(id: String) async throws -> AppointmentResponse {
        let endpoint = "/appointments/\(id)/cancel"
        return try await performAuthenticatedRequest(endpoint: endpoint, method: .PUT, responseType: AppointmentResponse.self)
    }
}

// MARK: - Private Network Methods

private extension APIService {
    
    enum HTTPMethod: String {
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
        case DELETE = "DELETE"
    }
    
    /// Perform authenticated request
    func performAuthenticatedRequest<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        queryItems: [URLQueryItem] = [],
        body: Any? = nil,
        responseType: T.Type
    ) async throws -> T {
        guard isAuthenticated, let token = authToken else {
            throw APIError.unauthorized
        }
        
        return try await performRequest(
            endpoint: endpoint,
            method: method,
            queryItems: queryItems,
            body: body,
            responseType: responseType,
            authToken: token
        )
    }
    
    /// Perform network request
    func performRequest<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        queryItems: [URLQueryItem] = [],
        body: Any? = nil,
        responseType: T.Type,
        authToken: String? = nil
    ) async throws -> T {
        
        // Build URL
        guard var urlComponents = URLComponents(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        if !queryItems.isEmpty {
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("BreitlingApp/1.0", forHTTPHeaderField: "User-Agent")
        
        // Add authentication header if provided
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add body for POST/PUT requests
        if let body = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            } catch {
                throw APIError.networkError(error)
            }
        }
        
        // Perform request
        do {
            let (data, response) = try await session.data(for: request)
            
            // Handle HTTP response
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200...299:
                    break // Success
                case 401:
                    throw APIError.unauthorized
                case 429:
                    throw APIError.rateLimited
                case 503:
                    throw APIError.maintenance
                case 500...599:
                    throw APIError.serverError(httpResponse.statusCode)
                default:
                    throw APIError.serverError(httpResponse.statusCode)
                }
            }
            
            // Decode response
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(responseType, from: data)
            } catch {
                throw APIError.decodingError
            }
            
        } catch {
            if error is APIError {
                throw error
            } else {
                throw APIError.networkError(error)
            }
        }
    }
}

// MARK: - Supporting Types

struct InventoryStatus: Codable {
    let productId: String
    let available: Bool
    let quantity: Int
    let estimatedRestockDate: Date?
}

struct AuthResponse: Codable {
    let token: String
    let user: User
    let expiresAt: Date
}

struct OrderRequest: Codable {
    let items: [OrderItemRequest]
    let shippingAddress: ShippingAddress
    let billingAddress: BillingAddress
    let paymentMethod: PaymentMethod
    let specialInstructions: String?
}

struct OrderItemRequest: Codable {
    let productId: String
    let quantity: Int
    let customizations: [ProductCustomization]?
}

struct AppointmentRequest: Codable {
    let storeId: String
    let serviceType: StoreService
    let preferredDate: Date
    let preferredTime: String
    let notes: String?
}

struct AppointmentResponse: Codable {
    let id: String
    let storeId: String
    let userId: String
    let serviceType: StoreService
    let scheduledDate: Date
    let scheduledTime: String
    let status: AppointmentStatus
    let confirmationNumber: String
}

enum AppointmentStatus: String, Codable {
    case pending = "pending"
    case confirmed = "confirmed"
    case cancelled = "cancelled"
    case completed = "completed"
}

struct EmptyResponse: Codable {}

// MARK: - Singleton Instance

extension APIService {
    static let shared = APIService()
}
