//
//  Product.swift
//  BreitlingApp
//
//  Created by Arup Sarkar (TA) on 7/9/25.
//

//
//  Product.swift
//  BreitlingApp
//
//  Core Product model for luxury watches
//  Foundation model for the entire ecommerce experience
//

import Foundation

struct Product: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let collection: String
    let price: Double
    let currency: String
    let imageURLs: [String]
    let description: String
    let specifications: ProductSpecifications
    let availability: ProductAvailability
    let isLimitedEdition: Bool
    let tags: [String]
    
    // Computed properties
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: price)) ?? "\(currency) \(price)"
    }
    
    var isAvailable: Bool {
        availability == .inStock || availability == .limitedStock
    }
    
    var primaryImageURL: String {
        imageURLs.first ?? ""
    }
}

struct ProductSpecifications: Codable, Hashable {
    let movement: String
    let caseMaterial: String
    let caseDiameter: String
    let caseThickness: String?
    let waterResistance: String
    let crystal: String
    let braceletMaterial: String?
    let functions: [String]
    
    // Watch-specific properties for luxury timepieces
    var isManufactureMovement: Bool {
        movement.lowercased().contains("manufacture") || movement.lowercased().contains("breitling")
    }
}

enum ProductAvailability: String, Codable, CaseIterable {
    case inStock = "in_stock"
    case limitedStock = "limited_stock"
    case outOfStock = "out_of_stock"
    case preOrder = "pre_order"
    case discontinued = "discontinued"
    
    var displayText: String {
        switch self {
        case .inStock:
            return "In Stock"
        case .limitedStock:
            return "Limited Stock"
        case .outOfStock:
            return "Out of Stock"
        case .preOrder:
            return "Pre-Order"
        case .discontinued:
            return "Discontinued"
        }
    }
    
    var statusColor: String {
        switch self {
        case .inStock:
            return "green"
        case .limitedStock:
            return "orange"
        case .outOfStock, .discontinued:
            return "red"
        case .preOrder:
            return "blue"
        }
    }
}

// MARK: - Mock Data for Development
extension Product {
    static let mockProduct = Product(
        id: "navitimer-b01-chronograph-43",
        name: "Navitimer B01 Chronograph 43",
        collection: "Navitimer",
        price: 8950.00,
        currency: "USD",
        imageURLs: [
            "navitimer-b01-front",
            "navitimer-b01-side",
            "navitimer-b01-back",
            "navitimer-b01-detail"
        ],
        description: "The Navitimer B01 Chronograph 43 features the manufacture Breitling Caliber 01, a COSC-certified chronometer with approximately 70 hours of power reserve.",
        specifications: ProductSpecifications(
            movement: "Breitling Manufacture Caliber 01",
            caseMaterial: "Stainless Steel",
            caseDiameter: "43mm",
            caseThickness: "13.6mm",
            waterResistance: "30m (3 bar)",
            crystal: "Sapphire crystal with anti-reflective coating",
            braceletMaterial: "Stainless Steel",
            functions: ["Hours", "Minutes", "Seconds", "Chronograph", "Date"]
        ),
        availability: .inStock,
        isLimitedEdition: false,
        tags: ["pilot", "chronograph", "luxury", "swiss-made"]
    )
    
    static let mockProducts: [Product] = [
        mockProduct,
        Product(
            id: "chronomat-b01-42",
            name: "Chronomat B01 42",
            collection: "Chronomat",
            price: 7450.00,
            currency: "USD",
            imageURLs: ["chronomat-b01-front", "chronomat-b01-side"],
            description: "The Chronomat B01 42 combines performance and style with its iconic rouleaux bracelet and distinctive bezel.",
            specifications: ProductSpecifications(
                movement: "Breitling Manufacture Caliber 01",
                caseMaterial: "Stainless Steel",
                caseDiameter: "42mm",
                caseThickness: "15.1mm",
                waterResistance: "200m (20 bar)",
                crystal: "Sapphire crystal",
                braceletMaterial: "Stainless Steel Rouleaux",
                functions: ["Hours", "Minutes", "Seconds", "Chronograph", "Date"]
            ),
            availability: .inStock,
            isLimitedEdition: false,
            tags: ["sport", "chronograph", "luxury", "diving"]
        ),
        Product(
            id: "superocean-heritage-57-limited",
            name: "Superocean Heritage '57 Limited Edition",
            collection: "Superocean Heritage",
            price: 4390.00,
            currency: "USD",
            imageURLs: ["superocean-heritage-front"],
            description: "A tribute to the original 1957 Superocean, this limited edition captures the spirit of vintage diving watches.",
            specifications: ProductSpecifications(
                movement: "Breitling Caliber 13",
                caseMaterial: "Stainless Steel",
                caseDiameter: "42mm",
                caseThickness: "13.2mm",
                waterResistance: "200m (20 bar)",
                crystal: "Sapphire crystal",
                braceletMaterial: "Mesh bracelet",
                functions: ["Hours", "Minutes", "Seconds", "Date"]
            ),
            availability: .limitedStock,
            isLimitedEdition: true,
            tags: ["diving", "heritage", "limited-edition", "vintage-inspired"]
        )
    ]
}
