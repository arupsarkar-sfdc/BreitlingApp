//
//  CollectionsView+Personalization.swift
//  BreitlingApp
//
//  Luxury personalization integration for CollectionsView
//  Elegant triggers and sophisticated modal experience
//

import SwiftUI

// MARK: - Enhanced CollectionsView with Personalization

struct PersonalizedCollectionsView: View {
    @Environment(NavigationRouter.self) private var router
    @StateObject private var viewModel = CollectionsViewModel()
    @StateObject private var personalizationEngine = LocalPersonalizationEngine()
    
    @State private var showingFilters = false
    @State private var showingSort = false
    @State private var showingPersonalizationModal = false
    @State private var personalizedContent: PersonalizedContent?
    
    var body: some View {
        let debug1: () = print(
            "🎯 MAIN VIEW: PersonalizedCollectionsView rendering"
        )
        NavigationView {
            VStack(spacing: 0) {
                let _ = print("🎯 BANNER: Creating PersonalizationBanner")
                // Personalization banner (if triggered)
                PersonalizationBanner(
                    personalizationEngine: personalizationEngine,
                    onTap: {
                        Task {
                            await showPersonalizationExperience()
                        }
                    }
                )
                
                // Original header with search and filters
                CollectionsHeader(
                    searchText: $viewModel.searchText,
                    showingFilters: $showingFilters,
                    showingSort: $showingSort,
                    selectedCollection: viewModel.selectedCollection,
                    resultCount: viewModel.filteredProducts.count
                )
                
                // Collection tabs
                CollectionTabs(
                    collections: viewModel.collections,
                    selectedCollection: $viewModel.selectedCollection
                )
                
                // Product grid with personalization tracking
                PersonalizedProductGrid(
                    products: viewModel.filteredProducts,
                    isLoading: viewModel.isLoading,
                    personalizationEngine: personalizationEngine,
                    onProductTap: { product in
                        router.showProduct(product.id)
                    }
                )
            }
            .background(BreitlingColors.background)
            .navigationTitle("Collections")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingFilters) {
                FilterSheet(
                    filters: $viewModel.filters,
                    collections: viewModel.collections
                )
            }
            .sheet(isPresented: $showingSort) {
                SortSheet(sortOption: $viewModel.sortOption)
            }
            .sheet(isPresented: $showingPersonalizationModal) {
                if let content = personalizedContent {
                    LuxuryPersonalizationModal(
                        content: content,
                        onDismiss: {
                            showingPersonalizationModal = false
                        },
                        onAction: { action in
                            handlePersonalizationAction(action)
                        }
                    )
                }
            }
        }
        .onAppear {
            print("🎯 MAIN VIEW: PersonalizedCollectionsView appeared")
            viewModel.loadCollections()
        }
        .onChange(of: viewModel.searchText) { _ in
            viewModel.filterProducts()
        }
        .onChange(of: viewModel.selectedCollection) { _ in
            viewModel.filterProducts()
        }
        .onChange(of: viewModel.sortOption) { _ in
            viewModel.sortProducts()
        }
    }
    
    // MARK: - Personalization Methods
    
    private func showPersonalizationExperience() async {
        personalizedContent = await personalizationEngine.getPersonalizedContent()
        if personalizedContent != nil {
            showingPersonalizationModal = true
            
            // Track personalization view
            await personalizationEngine.trackPageView(.collections(collectionId: personalizedContent?.trigger.collectionId))
        }
    }
    
    private func handlePersonalizationAction(_ action: PersonalizationAction) {
        showingPersonalizationModal = false
        
        switch action.actionType {
        case .exploreCollection:
            if let collectionId = action.metadata["collection_id"] {
                viewModel.selectedCollection = collectionId
                viewModel.filterProducts()
            }
        case .scheduleBoutique:
            router.navigate(to: .appointmentBooking(storeId: "nearby-store"))
        case .joinNewsletter:
            // Handle newsletter signup
            break
        case .requestCatalog:
            // Handle catalog request
            break
        case .viewRecommendations:
            // Stay on current view, recommendations already visible
            break
        }
    }
}

// MARK: - Personalization Banner Component

struct PersonalizationBanner: View {
    @ObservedObject var personalizationEngine: LocalPersonalizationEngine
    let onTap: () -> Void
    
    @State private var shouldShow = false
    @State private var trigger: PersonalizationTrigger?
    
    var body: some View {
        Group {
            if shouldShow, let trigger = trigger {
                Button(action: onTap) {
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            // Personalization icon
                            ZStack {
                                Circle()
                                    .fill(BreitlingColors.luxuryGold.opacity(0.2))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: "sparkles")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(BreitlingColors.luxuryGold)
                            }
                            
                            // Personalized message
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Personalized for You")
                                    .font(BreitlingFonts.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(BreitlingColors.primaryText)
                                
                                Text("We've noticed your appreciation for \(trigger.collectionName)")
                                    .font(BreitlingFonts.callout)
                                    .foregroundColor(BreitlingColors.secondaryText)
                                    .lineLimit(2)
                            }
                            
                            Spacer()
                            
                            // Chevron
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(BreitlingColors.navyBlue)
                        }
                        .padding(16)
                        
                        // Confidence indicator
                        HStack {
                            Text("\(trigger.likeCount) watches liked")
                                .font(BreitlingFonts.caption)
                                .foregroundColor(BreitlingColors.secondaryText)
                            
                            Spacer()
                            
                            Text("Tap to explore")
                                .font(BreitlingFonts.caption)
                                .fontWeight(.medium)
                                .foregroundColor(BreitlingColors.navyBlue)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(BreitlingColors.cardBackground)
                            .shadow(
                                color: BreitlingColors.luxuryGold.opacity(0.3),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(BreitlingColors.luxuryGold.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
        }
        .onAppear {
            Task {
                await checkPersonalization()
            }
        }
        .onReceive(personalizationEngine.$likedProductIds) { _ in
            Task {
                await checkPersonalization()
            }
        }
    }
    
    private func checkPersonalization() async {
        print("🎯 BANNER: Checking personalization...")
        let newTrigger = await personalizationEngine.shouldShowPersonalization()
        print("🎯 BANNER: Received trigger: \(newTrigger?.collectionName ?? "nil")")
        await MainActor.run {
            if let newTrigger = newTrigger {
                print("🎯 BANNER: ✅ Setting shouldShow = true for \(newTrigger.collectionName)")
                self.trigger = newTrigger
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    self.shouldShow = true
                }
            } else {
                print("🎯 BANNER: ❌ Setting shouldShow = false")
                withAnimation(.easeOut(duration: 0.3)) {
                    self.shouldShow = false
                }
            }
        }
    }
}
// MARK: - Personalized Product Grid

struct PersonalizedProductGrid: View {
    let products: [Product]
    let isLoading: Bool
    @ObservedObject var personalizationEngine: LocalPersonalizationEngine
    let onProductTap: (Product) -> Void
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            if isLoading {
                LoadingView()
            } else if products.isEmpty {
                EmptyStateView()
            } else {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(products, id: \.id) { product in
                        PersonalizedProductCard(
                            product: product,
                            personalizationEngine: personalizationEngine
                        )
                        .onTapGesture {
                            onProductTap(product)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
    }
}

// MARK: - Personalized Product Card

struct PersonalizedProductCard: View {
    let product: Product
    @ObservedObject var personalizationEngine: LocalPersonalizationEngine
    @State private var isInWishlist = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card container with elevation
            VStack(alignment: .leading, spacing: 12) {
                // Product image with wishlist button
                ZStack(alignment: .topTrailing) {
                    LuxuryProductImageView(
                        imageURL: product.primaryImageURL,
                        aspectRatio: 1.0,
                        cornerRadius: 12
                    )
                    
                    PersonalizedWishlistButton(
                        isInWishlist: isInWishlist,
                        action: toggleWishlist
                    )
                    .padding(8)
                }
                
                // Product info
                VStack(alignment: .leading, spacing: 6) {
                    Text(product.collection)
                        .font(BreitlingFonts.caption)
                        .foregroundColor(BreitlingColors.navyBlue)
                        .fontWeight(.medium)
                    
                    Text(product.name)
                        .font(BreitlingFonts.callout)
                        .foregroundColor(BreitlingColors.text)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack {
                        Text(product.formattedPrice)
                            .font(BreitlingFonts.callout)
                            .foregroundColor(BreitlingColors.text)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        AvailabilityBadge(availability: product.availability)
                    }
                    
                    // Key features
                    if !product.specifications.functions.isEmpty {
                        Text(product.specifications.functions.prefix(2).joined(separator: " • "))
                            .font(BreitlingFonts.caption)
                            .foregroundColor(BreitlingColors.textSecondary)
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 16)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(BreitlingColors.cardBackground)
                    .shadow(
                        color: Color.black.opacity(0.08),
                        radius: 8,
                        x: 0,
                        y: 2
                    )
            )
        }
        .onAppear {
            checkWishlistStatus()
        }
    }
    
    private func toggleWishlist() {
        Task {
            if isInWishlist {
                await personalizationEngine.trackProductUnlike(productId: product.id)
            } else {
                await personalizationEngine.trackProductLike(productId: product.id)
            }
            isInWishlist.toggle()
        }
    }
    
    private func checkWishlistStatus() {
        isInWishlist = personalizationEngine.getLikedProductIds().contains(product.id)
    }
}

// MARK: - Personalized Wishlist Button

struct PersonalizedWishlistButton: View {
    let isInWishlist: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isInWishlist ? "heart.fill" : "heart")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(isInWishlist ? .red : .white)
                .frame(width: 32, height: 32)
                .background(Color.black.opacity(0.6))
                .cornerRadius(16)
                .scaleEffect(isInWishlist ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isInWishlist)
        }
    }
}

#Preview {
    PersonalizedCollectionsView()
        .environment(NavigationRouter())
}
