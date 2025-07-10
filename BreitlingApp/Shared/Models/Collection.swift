//
//  Collection.swift
//  BreitlingApp
//
//  Created by Arup Sarkar (TA) on 7/9/25.
//

//
//  Collection.swift
//  BreitlingApp
//
//  Watch collection model (Navitimer, Chronomat, Superocean, etc.)
//  Groups products by heritage and design philosophy
//

import Foundation

struct Collection: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let tagline: String
    let description: String
    let heritage: String
    let imageURL: String
    let heroImageURL: String
    let category: CollectionCategory
    let establishedYear: Int
    let featuredProductIds: [String]
    let totalProductCount: Int
    let priceRange: PriceRange
    let keyFeatures: [String]
    
    // Computed properties
    var formattedPriceRange: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = priceRange.currency
        
        let minPrice = formatter.string(from: NSNumber(value: priceRange.min)) ?? "\(priceRange.currency) \(priceRange.min)"
        let maxPrice = formatter.string(from: NSNumber(value: priceRange.max)) ?? "\(priceRange.currency) \(priceRange.max)"
        
        return "\(minPrice) - \(maxPrice)"
    }
    
    var heritageDisplayText: String {
        "Est. \(establishedYear)"
    }
}

struct PriceRange: Codable, Hashable {
    let min: Double
    let max: Double
    let currency: String
}

enum CollectionCategory: String, Codable, CaseIterable {
    case aviation = "aviation"
    case diving = "diving"
    case professional = "professional"
    case lifestyle = "lifestyle"
    case heritage = "heritage"
    
    var displayName: String {
        switch self {
        case .aviation:
            return "Aviation"
        case .diving:
            return "Diving"
        case .professional:
            return "Professional"
        case .lifestyle:
            return "Lifestyle"
        case .heritage:
            return "Heritage"
        }
    }
    
    var iconName: String {
        switch self {
        case .aviation:
            return "airplane"
        case .diving:
            return "drop.fill"
        case .professional:
            return "briefcase.fill"
        case .lifestyle:
            return "star.fill"
        case .heritage:
            return "clock.fill"
        }
    }
}

// MARK: - Mock Data for Development
extension Collection {
    static let mockCollections: [Collection] = [
        Collection(
            id: "navitimer",
            name: "Navitimer",
            tagline: "The Ultimate Pilot's Watch",
            description: "The Navitimer, launched in 1952, is Breitling's flagship timepiece and one of the most recognizable chronographs in the world. With its distinctive circular slide rule bezel, it has been the trusted companion of aviators for over 70 years.",
            heritage: "The original pilot's chronograph since 1952",
            imageURL: "navitimer-collection-card",
            heroImageURL: "navitimer-collection-hero",
            category: .aviation,
            establishedYear: 1952,
            featuredProductIds: ["navitimer-b01-chronograph-43", "navitimer-aviator-8-b01"],
            totalProductCount: 18,
            priceRange: PriceRange(min: 4390.00, max: 12950.00, currency: "USD"),
            keyFeatures: ["Circular slide rule", "Chronograph", "Aviation heritage", "COSC certified"]
        ),
        Collection(
            id: "chronomat",
            name: "Chronomat",
            tagline: "Performance and Style",
            description: "Born in 1984, the Chronomat marked Breitling's return to mechanical chronographs. This bold and distinctive timepiece combines robust functionality with unmistakable style, featuring the iconic rouleaux bracelet and distinctive bezel.",
            heritage: "The mechanical chronograph revival since 1984",
            imageURL: "chronomat-collection-card",
            heroImageURL: "chronomat-collection-hero",
            category: .professional,
            establishedYear: 1984,
            featuredProductIds: ["chronomat-b01-42", "chronomat-gmt-40"],
            totalProductCount: 24,
            priceRange: PriceRange(min: 3690.00, max: 15950.00, currency: "USD"),
            keyFeatures: ["Rouleaux bracelet", "Robust construction", "Distinctive bezel", "Versatile styling"]
        ),
        Collection(
            id: "superocean",
            name: "Superocean",
            tagline: "Dive Into Adventure",
            description: "The Superocean collection represents Breitling's commitment to underwater exploration. Built for professional divers and water sports enthusiasts, these timepieces offer exceptional water resistance and reliability in the most demanding conditions.",
            heritage: "Professional diving instruments since 1957",
            imageURL: "superocean-collection-card",
            heroImageURL: "superocean-collection-hero",
            category: .diving,
            establishedYear: 1957,
            featuredProductIds: ["superocean-automatic-46", "superocean-heritage-57"],
            totalProductCount: 16,
            priceRange: PriceRange(min: 1890.00, max: 4950.00, currency: "USD"),
            keyFeatures: ["Professional diving", "High water resistance", "Robust construction", "Legible displays"]
        ),
        Collection(
            id: "premier",
            name: "Premier",
            tagline: "Sophisticated Elegance",
            description: "The Premier collection embodies timeless elegance and refined sophistication. Inspired by Breitling's heritage in elegant chronographs, these timepieces are perfect for special occasions and formal settings.",
            heritage: "Elegant chronographs since the 1940s",
            imageURL: "premier-collection-card",
            heroImageURL: "premier-collection-hero",
            category: .lifestyle,
            establishedYear: 1943,
            featuredProductIds: ["premier-b01-chronograph-42", "premier-heritage-b01"],
            totalProductCount: 12,
            priceRange: PriceRange(min: 4690.00, max: 8950.00, currency: "USD"),
            keyFeatures: ["Elegant design", "Dress chronograph", "Classic styling", "Premium materials"]
        ),
        Collection(
            id: "avenger",
            name: "Avenger",
            tagline: "Built for Extremes",
            description: "The Avenger series is engineered for the most demanding environments. These robust timepieces offer exceptional shock resistance, readability, and reliability for professionals who operate in extreme conditions.",
            heritage: "Extreme performance instruments",
            imageURL: "avenger-collection-card",
            heroImageURL: "avenger-collection-hero",
            category: .professional,
            establishedYear: 2001,
            featuredProductIds: ["avenger-b01-chronograph-45", "avenger-gmt-45"],
            totalProductCount: 8,
            priceRange: PriceRange(min: 3990.00, max: 6950.00, currency: "USD"),
            keyFeatures: ["Extreme robustness", "High legibility", "Professional grade", "Shock resistant"]
        ),
        Collection(
            id: "superocean-heritage",
            name: "Superocean Heritage",
            tagline: "Vintage Soul, Modern Heart",
            description: "The Superocean Heritage pays tribute to Breitling's diving watch legacy while incorporating modern technology and materials. These timepieces capture the aesthetic of vintage diving watches with contemporary performance.",
            heritage: "Vintage-inspired diving since 2017",
            imageURL: "superocean-heritage-collection-card",
            heroImageURL: "superocean-heritage-collection-hero",
            category: .heritage,
            establishedYear: 2017,
            featuredProductIds: ["superocean-heritage-57-limited", "superocean-heritage-b20-42"],
            totalProductCount: 14,
            priceRange: PriceRange(min: 2190.00, max: 5950.00, currency: "USD"),
            keyFeatures: ["Vintage design", "Modern movement", "Diving capability", "Heritage styling"]
        )
    ]
    
    static let featuredCollection = mockCollections[0] // Navitimer as featured
}
