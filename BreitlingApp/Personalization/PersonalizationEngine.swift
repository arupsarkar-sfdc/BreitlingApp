//
//  PersonalizationEngine.swift
//  BreitlingApp
//
//  Enterprise-ready personalization architecture
//  Lightweight tracking with rich data model integration
//

import Foundation
import Combine

// MARK: - Personalization Engine Protocol (Salesforce-Ready)

protocol PersonalizationEngine {
    // Lightweight event tracking
    func trackProductLike(productId: String) async
    func trackProductUnlike(productId: String) async
    func trackPageView(_ page: PageViewEvent) async
    
    // Smart personalization from existing data
    func getPersonalizedContent() async -> PersonalizedContent?
    func shouldShowPersonalization() async -> PersonalizationTrigger?
    func getRecommendations(for context: RecommendationContext) async -> [PersonalizedRecommendation]
    
    // Lightweight profile
    func getLikedProductIds() -> [String]
    func getPersonalizationInsights() async -> PersonalizationInsights
}

// MARK: - Lightweight Event Models

enum PageViewEvent: Codable {
    case home(timestamp: Date = Date())
    case collections(collectionId: String?, timestamp: Date = Date())
    case productDetail(productId: String, timestamp: Date = Date())
    case search(query: String?, timestamp: Date = Date())
    case boutiques(timestamp: Date = Date())
    case account(timestamp: Date = Date())
}

// MARK: - Data-Driven Content Models

struct PersonalizedContent: Codable {
    let trigger: PersonalizationTrigger
    let collectionData: Collection  // Use existing Collection model
    let insights: [LuxuryInsight]
    let recommendations: [PersonalizedRecommendation]
    let actions: [PersonalizationAction]
    let metadata: PersonalizationMetadata
}

struct PersonalizationTrigger: Codable {
    let type: TriggerType
    let collectionId: String
    let collectionName: String
    let likeCount: Int
    let confidence: Double
    let reasoning: String
    
    enum TriggerType: String, Codable {
        case collectionAffinity = "collection_affinity"
    }
}

struct LuxuryInsight: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let imageUrl: String          // ← ADDED! From Collection.heroImageURL
    let collectionId: String
    let insightType: InsightType
    let confidence: Double
    
    enum InsightType: String, Codable {
        case heritageAppreciation = "heritage_appreciation"
        case technicalPreference = "technical_preference"
        case designAesthetic = "design_aesthetic"
        case lifestyleAlignment = "lifestyle_alignment"
    }
}

struct PersonalizedRecommendation: Codable, Identifiable {
    let id: String
    let product: Product          // ← Use actual Product model!
    let reason: String
    let confidence: Double
    let recommendationType: RecommendationType
    let priority: Int
    
    enum RecommendationType: String, Codable {
        case similarStyle = "similar_style"
        case collectionComplement = "collection_complement"
        case pricePoint = "price_point"
        case trendingInPreference = "trending_in_preference"
    }
}

struct PersonalizationAction: Codable, Identifiable {
    let id: String
    let title: String
    let actionType: ActionType
    let destination: String?
    let metadata: [String: String]
    
    enum ActionType: String, Codable {
        case viewRecommendations = "view_recommendations"
        case scheduleBoutique = "schedule_boutique"
        case exploreCollection = "explore_collection"
        case joinNewsletter = "join_newsletter"
        case requestCatalog = "request_catalog"
    }
}

struct PersonalizationMetadata: Codable {
    let generatedAt: Date
    let experimentId: String?
    let salesforcePersonalizationId: String?
}

struct PersonalizationInsights {
    let dominantCollection: Collection?
    let likedProducts: [Product]
    let collectionAffinities: [String: Int]
    let priceRange: (min: Double, max: Double)
    let preferredMaterials: [String]
    let totalLikes: Int
}

// MARK: - Recommendation Context

enum RecommendationContext {
    case collectionBrowsing(collectionId: String)
    case productViewing(productId: String)
    case personalizationModal(trigger: PersonalizationTrigger)
}

// MARK: - Local Implementation (Data-Driven)

@MainActor
class LocalPersonalizationEngine: PersonalizationEngine, ObservableObject {
    // Lightweight storage - just liked product IDs
    @Published var likedProductIds: Set<String> = []  // ← Made this @Published and public
    
    private let storage = UserDefaults.standard
    private let storageKey = "breitling_liked_products"
    
    init() {
        loadLikedProducts()
    }
    
    // MARK: - Lightweight Event Tracking
    
    func trackProductLike(productId: String) async {
        // Debug logging
        print("🎯 TRACKING LIKE: \(productId)")
        
        // Get product to find collection
        if let product = Product.mockProducts.first(where: { $0.id == productId }) {
            let normalizedCollection = normalizeCollectionName(product.collection)
            print("🎯 PRODUCT COLLECTION: \(product.collection) → NORMALIZED: \(normalizedCollection)")
        } else {
            print("🎯 ⚠️  PRODUCT NOT FOUND IN MOCK DATA: \(productId)")
        }
        
        likedProductIds.insert(productId)
        objectWillChange.send()
        await saveLikedProducts()
        
        print("🎯 TOTAL LIKED: \(likedProductIds.count)")
        print("🎯 LIKED PRODUCTS: \(Array(likedProductIds))")
        
        // Immediately check if this triggers personalization
        print("🎯 CHECKING PERSONALIZATION AFTER LIKE...")
        let trigger = await shouldShowPersonalization()
        if let trigger = trigger {
            print("🎯 🎉 PERSONALIZATION TRIGGERED! \(trigger.collectionName) with \(trigger.likeCount) likes")
        } else {
            print("🎯 ❌ Still not enough for trigger")
        }
        
        // Future: Send to Salesforce
        // await SalesforceSDK.track(.productLike(productId: productId))
    }
    
    func trackProductUnlike(productId: String) async {
        likedProductIds.remove(productId)
        await saveLikedProducts()
        
        // Future: Send to Salesforce
        // await SalesforceSDK.track(.productUnlike(productId: productId))
    }
    
    func trackPageView(_ page: PageViewEvent) async {
        // Future: Salesforce page view tracking
        // await SalesforceSDK.trackPageView(page)
    }
    
    // MARK: - Smart Data-Driven Personalization
    
    func getPersonalizedContent() async -> PersonalizedContent? {
        guard let trigger = await shouldShowPersonalization() else { return nil }
        
        // Get actual collection data
        guard let collectionData = Collection.mockCollections.first(where: { $0.id == trigger.collectionId || $0.name.lowercased() == trigger.collectionId.lowercased() }) else { return nil }
        
        let insights = generateLuxuryInsights(for: trigger, collection: collectionData)
        let recommendations = await getRecommendations(for: .personalizationModal(trigger: trigger))
        let actions = generatePersonalizationActions(for: trigger)
        
        return PersonalizedContent(
            trigger: trigger,
            collectionData: collectionData,
            insights: insights,
            recommendations: recommendations,
            actions: actions,
            metadata: PersonalizationMetadata(
                generatedAt: Date(),
                experimentId: nil,
                salesforcePersonalizationId: nil
            )
        )
    }
    
    func shouldShowPersonalization() async -> PersonalizationTrigger? {
        let insights = await getPersonalizationInsights()
        
        print("🎯 CHECKING PERSONALIZATION:")
        print("🎯 Collection affinities: \(insights.collectionAffinities)")
        
        // Find collections with 4+ likes (luxury threshold)
        for (collectionName, count) in insights.collectionAffinities {
            print("🎯 \(collectionName): \(count) likes")
            if count >= 4 {
                // Get collection ID
                let collectionId = Collection.mockCollections.first { $0.name.lowercased() == collectionName.lowercased() }?.id ?? collectionName.lowercased()
                
                print("🎯 ✅ TRIGGER FOUND! Collection: \(collectionName), Count: \(count)")
                
                return PersonalizationTrigger(
                    type: .collectionAffinity,
                    collectionId: collectionId,
                    collectionName: collectionName,
                    likeCount: count,
                    confidence: min(Double(count) / 6.0, 1.0),
                    reasoning: "Strong affinity detected for \(collectionName) collection"
                )
            }
        }
        
        print("🎯 ❌ NO TRIGGER - Not enough likes in any single collection")
        return nil
    }
    
    func getRecommendations(for context: RecommendationContext) async -> [PersonalizedRecommendation] {
        switch context {
        case .personalizationModal(let trigger):
            return generateSmartRecommendations(for: trigger.collectionName)
        case .collectionBrowsing(let collectionId):
            return generateComplementaryRecommendations(for: collectionId)
        case .productViewing(let productId):
            return generateSimilarProductRecommendations(for: productId)
        }
    }
    
    func getLikedProductIds() -> [String] {
        return Array(likedProductIds)
    }
    
    func getPersonalizationInsights() async -> PersonalizationInsights {
        let likedProducts = Product.mockProducts.filter { likedProductIds.contains($0.id) }
        
        // Extract collection affinities using NORMALIZED collection names
        var collectionCounts: [String: Int] = [:]
        
        // Method 1: Try to find products in mock data
        for product in likedProducts {
            let normalizedCollection = normalizeCollectionName(product.collection)
            collectionCounts[normalizedCollection, default: 0] += 1
        }
        
        // Method 2: Fallback - infer collection from product ID if not found in mock data
        for productId in likedProductIds {
            // Skip if already found in mock data
            if likedProducts.contains(where: { $0.id == productId }) {
                continue
            }
            
            // Infer collection from product ID
            let inferredCollection = inferCollectionFromProductId(productId)
            if let collection = inferredCollection {
                collectionCounts[collection, default: 0] += 1
                print("🎯 INFERRED COLLECTION: \(productId) → \(collection)")
            }
        }
        
        print("🎯 COLLECTION BREAKDOWN (Normalized):")
        for (collection, count) in collectionCounts.sorted(by: { $0.value > $1.value }) {
            print("🎯   \(collection): \(count) likes")
        }
        
        // Find dominant collection
        let dominantCollectionName = collectionCounts.max(by: { $0.value < $1.value })?.key
        let dominantCollection = Collection.mockCollections.first {
            normalizeCollectionName($0.name) == dominantCollectionName
        }
        
        // Extract price preferences (only from found products)
        let prices = likedProducts.map { $0.price }
        let priceRange = (min: prices.min() ?? 0, max: prices.max() ?? 0)
        
        // Extract material preferences (only from found products)
        let materials = likedProducts.map { $0.specifications.caseMaterial }
        let uniqueMaterials = Array(Set(materials))
        
        return PersonalizationInsights(
            dominantCollection: dominantCollection,
            likedProducts: likedProducts,
            collectionAffinities: collectionCounts,
            priceRange: priceRange,
            preferredMaterials: uniqueMaterials,
            totalLikes: likedProductIds.count
        )
    }
    
    // MARK: - Collection Inference from Product ID
    
    private func inferCollectionFromProductId(_ productId: String) -> String? {
        let id = productId.lowercased()
        
        if id.contains("chronomat") {
            return "Chronomat"
        } else if id.contains("navitimer") {
            return "Navitimer"
        } else if id.contains("avenger") {
            return "Avenger"
        } else if id.contains("superocean") && id.contains("heritage") {
            return "Superocean Heritage"
        } else if id.contains("superocean") {
            return "Superocean"
        } else if id.contains("premier") {
            return "Premier"
        } else {
            print("🎯 ⚠️  UNKNOWN COLLECTION FOR ID: \(productId)")
            return nil
        }
    }
    
    // MARK: - Collection Name Normalization
    
    private func normalizeCollectionName(_ collectionName: String) -> String {
        let name = collectionName.lowercased()
        
        // Group similar collection names
        if name.contains("chronomat") {
            return "Chronomat"
        } else if name.contains("navitimer") {
            return "Navitimer"
        } else if name.contains("avenger") {
            return "Avenger"
        } else if name.contains("superocean") && name.contains("heritage") {
            return "Superocean Heritage"
        } else if name.contains("superocean") {
            return "Superocean"
        } else if name.contains("premier") {
            return "Premier"
        } else {
            // Return the original name capitalized for unknown collections
            return collectionName.capitalized
        }
    }
    
    // MARK: - Private Methods
    
    private func loadLikedProducts() {
        if let data = storage.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            likedProductIds = decoded
        }
    }
    
    private func saveLikedProducts() async {
        if let encoded = try? JSONEncoder().encode(likedProductIds) {
            storage.set(encoded, forKey: storageKey)
        }
    }
    
    // MARK: - Data-Driven Luxury Insights Generation
    
    func generateLuxuryInsights(for trigger: PersonalizationTrigger, collection: Collection) -> [LuxuryInsight] {
        let collectionName = collection.name.lowercased()
        let confidence = trigger.confidence
        
        // Base insights using collection's rich data
        var insights: [LuxuryInsight] = []
        
        // Heritage Insight (using collection.heritage)
        insights.append(LuxuryInsight(
            id: "\(collectionName)-heritage-appreciation",
            title: "Heritage Connoisseur",
            description: collection.heritage + ". Your appreciation for the \(collection.name) reveals a refined understanding of this distinguished legacy.",
            imageUrl: collection.heroImageURL,
            collectionId: collection.id,
            insightType: .heritageAppreciation,
            confidence: confidence
        ))
        
        // Technical Insight (using collection.keyFeatures)
        if !collection.keyFeatures.isEmpty {
            let features = collection.keyFeatures.prefix(2).joined(separator: " and ")
            insights.append(LuxuryInsight(
                id: "\(collectionName)-technical-mastery",
                title: "Technical Sophistication",
                description: "Your selection demonstrates appreciation for \(features). These signature elements represent the pinnacle of Swiss horological engineering.",
                imageUrl: collection.imageURL,
                collectionId: collection.id,
                insightType: .technicalPreference,
                confidence: confidence
            ))
        }
        
        // Collection-specific luxury insights
        insights.append(contentsOf: generateCollectionSpecificInsights(collection: collection, confidence: confidence))
        
        return insights
    }
    
    private func generateCollectionSpecificInsights(collection: Collection, confidence: Double) -> [LuxuryInsight] {
        switch collection.name.lowercased() {
        case "navitimer":
            return [
                LuxuryInsight(
                    id: "navitimer-pilot-heritage",
                    title: "Aviation Excellence",
                    description: "The Navitimer's legendary slide rule bezel and aviation DNA speak to those who value both precision and professional heritage. \(collection.tagline)",
                    imageUrl: collection.heroImageURL,
                    collectionId: collection.id,
                    insightType: .lifestyleAlignment,
                    confidence: confidence
                )
            ]
            
        case "chronomat":
            return [
                LuxuryInsight(
                    id: "chronomat-versatility",
                    title: "Versatile Luxury",
                    description: "\(collection.tagline) - Your Chronomat selections reveal an appreciation for timepieces that seamlessly transition from adventure to elegance.",
                    imageUrl: collection.heroImageURL,
                    collectionId: collection.id,
                    insightType: .lifestyleAlignment,
                    confidence: confidence
                )
            ]
            
        case "superocean":
            return [
                LuxuryInsight(
                    id: "superocean-adventure",
                    title: "Ocean Explorer",
                    description: "\(collection.tagline) - Your choices reflect an adventurous spirit paired with luxury sensibilities, embodying Breitling's commitment to underwater excellence.",
                    imageUrl: collection.heroImageURL,
                    collectionId: collection.id,
                    insightType: .lifestyleAlignment,
                    confidence: confidence
                )
            ]
            
        case "premier":
            return [
                LuxuryInsight(
                    id: "premier-elegance",
                    title: "Sophisticated Elegance",
                    description: "\(collection.tagline) - Your Premier selections showcase an appreciation for refined sophistication and dress chronographs perfect for life's finest moments.",
                    imageUrl: collection.heroImageURL,
                    collectionId: collection.id,
                    insightType: .designAesthetic,
                    confidence: confidence
                )
            ]
            
        case "avenger":
            return [
                LuxuryInsight(
                    id: "avenger-performance",
                    title: "Extreme Performance",
                    description: "\(collection.tagline) - Your choices demonstrate an appreciation for instruments engineered for the most demanding environments.",
                    imageUrl: collection.heroImageURL,
                    collectionId: collection.id,
                    insightType: .technicalPreference,
                    confidence: confidence
                )
            ]
            
        case "superocean heritage":
            return [
                LuxuryInsight(
                    id: "heritage-vintage-soul",
                    title: "Vintage Soul, Modern Heart",
                    description: "\(collection.tagline) - Your appreciation reveals a sophisticated understanding of vintage aesthetics enhanced by contemporary technology.",
                    imageUrl: collection.heroImageURL,
                    collectionId: collection.id,
                    insightType: .heritageAppreciation,
                    confidence: confidence
                )
            ]
            
        default:
            return []
        }
    }
    
    // MARK: - Smart Product Recommendations (Using Real Product Data)
    
    func generateSmartRecommendations(for collectionName: String) -> [PersonalizedRecommendation] {
        let likedProductIds = getLikedProductIds()
        let collectionProducts = Product.mockProducts.filter { $0.collection.lowercased() == collectionName.lowercased() }
        
        // Recommend products from same collection user hasn't liked yet
        let unlikedInCollection = collectionProducts.filter { !likedProductIds.contains($0.id) }
        
        var recommendations: [PersonalizedRecommendation] = []
        
        // Add collection complement recommendations
        for (index, product) in unlikedInCollection.prefix(2).enumerated() {
            recommendations.append(PersonalizedRecommendation(
                id: "collection-rec-\(index)",
                product: product,
                reason: "Complements your \(collectionName) appreciation with \(product.specifications.movement) and \(product.specifications.caseMaterial) craftsmanship",
                confidence: 0.9,
                recommendationType: .collectionComplement,
                priority: index + 1
            ))
        }
        
        // Add cross-collection recommendations based on insights
        let crossCollectionRecs = generateCrossCollectionRecommendations(for: collectionName, excludingLiked: likedProductIds)
        recommendations.append(contentsOf: crossCollectionRecs)
        
        return recommendations
    }
    
    private func generateCrossCollectionRecommendations(for collectionName: String, excludingLiked likedIds: [String]) -> [PersonalizedRecommendation] {
        var recommendations: [PersonalizedRecommendation] = []
        
        switch collectionName.lowercased() {
        case "navitimer":
            // Recommend Chronomat for aviation enthusiasts
            if let chronomat = Product.mockProducts.first(where: { $0.collection == "Chronomat" && !likedIds.contains($0.id) }) {
                recommendations.append(PersonalizedRecommendation(
                    id: "nav-cross-chr",
                    product: chronomat,
                    reason: "The Chronomat shares aviation heritage with enhanced versatility for modern adventurers",
                    confidence: 0.85,
                    recommendationType: .similarStyle,
                    priority: 3
                ))
            }
            
        case "chronomat":
            // Recommend Avenger for sports chronograph enthusiasts
            if let avenger = Product.mockProducts.first(where: { $0.collection == "Avenger" && !likedIds.contains($0.id) }) {
                recommendations.append(PersonalizedRecommendation(
                    id: "chr-cross-ave",
                    product: avenger,
                    reason: "The Avenger extends your sports chronograph passion with extreme durability",
                    confidence: 0.82,
                    recommendationType: .similarStyle,
                    priority: 3
                ))
            }
            
        case "superocean":
            // Recommend Superocean Heritage for diving enthusiasts
            if let heritage = Product.mockProducts.first(where: { $0.collection == "Superocean Heritage" && !likedIds.contains($0.id) }) {
                recommendations.append(PersonalizedRecommendation(
                    id: "so-cross-soh",
                    product: heritage,
                    reason: "Combines your diving passion with vintage aesthetics and collector appeal",
                    confidence: 0.88,
                    recommendationType: .collectionComplement,
                    priority: 3
                ))
            }
            
        default:
            break
        }
        
        return recommendations
    }
    
    private func generateComplementaryRecommendations(for collectionId: String) -> [PersonalizedRecommendation] {
        let products = Product.mockProducts.filter { $0.collection.lowercased().contains(collectionId.lowercased()) }
        let likedIds = getLikedProductIds()
        let available = products.filter { !likedIds.contains($0.id) }
        
        return available.prefix(2).enumerated().map { index, product in
            PersonalizedRecommendation(
                id: "comp-\(index)",
                product: product,
                reason: "Expands your \(product.collection) collection with distinctive \(product.specifications.caseDiameter) sizing",
                confidence: 0.8,
                recommendationType: .collectionComplement,
                priority: index + 1
            )
        }
    }
    
    private func generateSimilarProductRecommendations(for productId: String) -> [PersonalizedRecommendation] {
        guard let targetProduct = Product.mockProducts.first(where: { $0.id == productId }) else { return [] }
        
        let similarProducts = Product.mockProducts.filter { product in
            product.id != productId &&
            product.collection == targetProduct.collection &&
            !getLikedProductIds().contains(product.id)
        }
        
        return similarProducts.prefix(2).enumerated().map { index, product in
            PersonalizedRecommendation(
                id: "similar-\(index)",
                product: product,
                reason: "Shares \(targetProduct.collection) DNA with \(product.specifications.movement) excellence",
                confidence: 0.87,
                recommendationType: .similarStyle,
                priority: index + 1
            )
        }
    }
    
    // MARK: - Personalization Actions (Collection-Aware)
    
    func generatePersonalizationActions(for trigger: PersonalizationTrigger) -> [PersonalizationAction] {
        let collection = Collection.mockCollections.first { $0.id == trigger.collectionId || $0.name.lowercased() == trigger.collectionId.lowercased() }
        let collectionName = collection?.name ?? trigger.collectionName
        
        return [
            PersonalizationAction(
                id: "action-explore-collection",
                title: "Explore Complete \(collectionName) Collection",
                actionType: .exploreCollection,
                destination: "collection-\(trigger.collectionId)",
                metadata: [
                    "collection_id": trigger.collectionId,
                    "collection_name": collectionName
                ]
            ),
            PersonalizationAction(
                id: "action-boutique-consultation",
                title: "Schedule \(collectionName) Consultation",
                actionType: .scheduleBoutique,
                destination: "boutique-appointment",
                metadata: [
                    "collection_focus": trigger.collectionId,
                    "consultation_type": "\(collectionName.lowercased())_specialist",
                    "heritage_year": String(collection?.establishedYear ?? 1884)
                ]
            ),
            PersonalizationAction(
                id: "action-collection-newsletter",
                title: "Join \(collectionName) Enthusiasts",
                actionType: .joinNewsletter,
                destination: "newsletter-\(trigger.collectionId)",
                metadata: [
                    "newsletter_type": "collection_heritage",
                    "collection_id": trigger.collectionId,
                    "heritage_focus": collection?.heritage ?? ""
                ]
            ),
            PersonalizationAction(
                id: "action-heritage-catalog",
                title: "Request \(collectionName) Heritage Catalog",
                actionType: .requestCatalog,
                destination: "catalog-request",
                metadata: [
                    "catalog_type": "heritage_collection",
                    "focus_collection": trigger.collectionId,
                    "established_year": String(collection?.establishedYear ?? 1884),
                    "price_range": collection?.formattedPriceRange ?? ""
                ]
            )
        ]
    }
}

// MARK: - Luxury Messaging Extensions (Collection Data-Driven)

extension PersonalizationTrigger {
    var luxuryTitle: String {
        let collection = Collection.mockCollections.first { $0.id == collectionId || $0.name.lowercased() == collectionId.lowercased() }
        return collection?.tagline ?? "Luxury Curated for Your Taste"
    }
    
    var luxurySubtitle: String {
        let collection = Collection.mockCollections.first { $0.id == collectionId || $0.name.lowercased() == collectionId.lowercased() }
        
        if let collection = collection {
            return "Based on your \(likeCount) selections from the \(collection.name) collection, we've curated an exclusive experience that honors your sophisticated taste for \(collection.heritage.lowercased())."
        }
        
        return "Your sophisticated selections reveal refined horological taste deserving of personalized attention."
    }
    
    var collectionPersonality: String {
        let collection = Collection.mockCollections.first { $0.id == collectionId || $0.name.lowercased() == collectionId.lowercased() }
        return collection?.description ?? "Swiss luxury timepieces of exceptional craftsmanship"
    }
}
