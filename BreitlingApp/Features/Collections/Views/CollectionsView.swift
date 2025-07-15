//
//  CollectionsView.swift
//  BreitlingApp
//
//  Created by Arup Sarkar (TA) on 7/10/25.
//

//
//  CollectionsView.swift
//  BreitlingApp
//
//  Priority 2: Product catalog with LazyVGrid and luxury filtering
//  Features: Collection browsing, product grid, search integration, sorting
//

import SwiftUI

struct CollectionsView: View {
    @Environment(NavigationRouter.self) private var router
    @StateObject private var viewModel = CollectionsViewModel()
    @State private var showingFilters = false
    @State private var showingSort = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with search and filters
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
                
                // Product grid
                ProductGrid(
                    products: viewModel.filteredProducts,
                    isLoading: viewModel.isLoading,
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
        }
        .onAppear {
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
}
// MARK: - ElevatedProductGridCard

struct ElevatedProductGridCard: View {
    let product: Product
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
                    
                    WishlistButton(
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
        if isInWishlist {
            CoreDataManager.shared.removeFromWishlist(productId: product.id)
        } else {
            CoreDataManager.shared.addToWishlist(productId: product.id)
        }
        isInWishlist.toggle()
    }
    
    private func checkWishlistStatus() {
        isInWishlist = CoreDataManager.shared.isInWishlist(productId: product.id)
    }
}


// MARK: - Collections Header

struct CollectionsHeader: View {
    @Binding var searchText: String
    @Binding var showingFilters: Bool
    @Binding var showingSort: Bool
    let selectedCollection: String?
    let resultCount: Int
    
    var body: some View {
        VStack(spacing: 16) {
            // Search and filter controls
            VStack(spacing: 12) {
                // Search bar
                HStack(spacing: 12) {
                    SearchBarView(text: $searchText, placeholder: "Search watches...")
                        .frame(maxWidth: .infinity)
                    
                    BoutiqueFilterButton(isActive: showingFilters) {
                        showingFilters = true
                    }
                    
                    SortButton {
                        showingSort = true
                    }
                }
                
                // Results info
                HStack {
                    if let collection = selectedCollection {
                        Text("\(resultCount) watches in \(collection)")
                            .font(BreitlingFonts.callout)
                            .foregroundColor(BreitlingColors.textSecondary)
                    } else {
                        Text("\(resultCount) watches")
                            .font(BreitlingFonts.callout)
                            .foregroundColor(BreitlingColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    if !searchText.isEmpty {
                        Button("Clear") {
                            searchText = ""
                        }
                        .font(BreitlingFonts.callout)
                        .foregroundColor(BreitlingColors.navyBlue)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(BreitlingColors.cardBackground)
                    .shadow(
                        color: Color.black.opacity(0.05),
                        radius: 6,
                        x: 0,
                        y: 2
                    )
            )
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .background(BreitlingColors.background)
    }
}

// MARK: - Collection Tabs

struct CollectionTabs: View {
    let collections: [Collection]
    @Binding var selectedCollection: String?
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // All collections tab
                    CollectionTab(
                        title: "All",
                        isSelected: selectedCollection == nil,
                        action: {
                            selectedCollection = nil
                        }
                    )
                    
                    // Individual collection tabs
                    ForEach(collections, id: \.id) { collection in
                        CollectionTab(
                            title: collection.name,
                            isSelected: selectedCollection == collection.id,
                            action: {
                                selectedCollection = collection.id
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 12)
            .background(
                Rectangle()
                    .fill(BreitlingColors.cardBackground)
                    .shadow(
                        color: Color.black.opacity(0.05),
                        radius: 4,
                        x: 0,
                        y: 1
                    )
            )
        }
    }
}

struct CollectionTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(BreitlingFonts.callout)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : BreitlingColors.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? BreitlingColors.navyBlue : BreitlingColors.background)
                        .shadow(
                            color: isSelected ? BreitlingColors.navyBlue.opacity(0.3) : Color.clear,
                            radius: isSelected ? 4 : 0,
                            x: 0,
                            y: isSelected ? 2 : 0
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isSelected ? BreitlingColors.navyBlue : BreitlingColors.divider,
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Product Grid

struct ProductGrid: View {
    let products: [Product]
    let isLoading: Bool
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
                        ElevatedProductGridCard(product: product)
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

struct ProductGridCard: View {
    let product: Product
    @State private var isInWishlist = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Product image with wishlist button
            ZStack(alignment: .topTrailing) {
                LuxuryProductImageView(
                    imageURL: product.primaryImageURL,
                    aspectRatio: 1.0,
                    cornerRadius: 12
                )
                
                WishlistButton(
                    isInWishlist: isInWishlist,
                    action: toggleWishlist
                )
                .padding(8)
            }
            
            // Product info
            VStack(alignment: .leading, spacing: 4) {
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
        }
        .onAppear {
            checkWishlistStatus()
        }
    }
    
    private func toggleWishlist() {
        if isInWishlist {
            CoreDataManager.shared.removeFromWishlist(productId: product.id)
        } else {
            CoreDataManager.shared.addToWishlist(productId: product.id)
        }
        isInWishlist.toggle()
    }
    
    private func checkWishlistStatus() {
        isInWishlist = CoreDataManager.shared.isInWishlist(productId: product.id)
    }
}

// MARK: - Supporting Views

struct SearchBarView: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(BreitlingColors.textSecondary)
                .font(.system(size: 16))
            
            TextField(placeholder, text: $text)
                .font(BreitlingFonts.body)
                .foregroundColor(BreitlingColors.text)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(BreitlingColors.textSecondary)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(BreitlingColors.cardBackground)
        .cornerRadius(10)
    }
}

struct BoutiqueFilterButton: View {
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(isActive ? .white : BreitlingColors.navyBlue)
                .frame(width: 44, height: 44)
                .background(isActive ? BreitlingColors.navyBlue : BreitlingColors.cardBackground)
                .cornerRadius(10)
        }
    }
}

struct SortButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(BreitlingColors.navyBlue)
                .frame(width: 44, height: 44)
                .background(BreitlingColors.cardBackground)
                .cornerRadius(10)
        }
    }
}

struct WishlistButton: View {
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
        }
    }
}

struct AvailabilityBadge: View {
    let availability: ProductAvailability
    
    var body: some View {
        Text(availability.displayText)
            .font(BreitlingFonts.caption)
            .fontWeight(.medium)
            .foregroundColor(badgeTextColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(badgeBackgroundColor)
            .cornerRadius(4)
    }
    
    private var badgeTextColor: Color {
        switch availability {
        case .inStock:
            return .white
        case .limitedStock:
            return BreitlingColors.navyBlue
        case .outOfStock, .discontinued:
            return .white
        case .preOrder:
            return BreitlingColors.navyBlue
        }
    }
    
    private var badgeBackgroundColor: Color {
        switch availability {
        case .inStock:
            return .green
        case .limitedStock:
            return BreitlingColors.luxuryGold
        case .outOfStock, .discontinued:
            return .red
        case .preOrder:
            return .blue.opacity(0.2)
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: BreitlingColors.navyBlue))
                .scaleEffect(1.2)
            
            Text("Loading collections...")
                .font(BreitlingFonts.body)
                .foregroundColor(BreitlingColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(BreitlingColors.textSecondary)
            
            Text("No watches found")
                .font(BreitlingFonts.title3)
                .foregroundColor(BreitlingColors.text)
                .fontWeight(.medium)
            
            Text("Try adjusting your search or filters")
                .font(BreitlingFonts.body)
                .foregroundColor(BreitlingColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
}

// MARK: - Filter Sheet

struct FilterSheet: View {
    @Binding var filters: ProductFilters
    let collections: [Collection]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 24) {
                // Price Range
                VStack(alignment: .leading, spacing: 12) {
                    Text("Price Range")
                        .font(BreitlingFonts.callout)
                        .fontWeight(.semibold)
                    
                    PriceRangeSlider(range: $filters.priceRange)
                }
                
                // Materials
                VStack(alignment: .leading, spacing: 12) {
                    Text("Materials")
                        .font(BreitlingFonts.callout)
                        .fontWeight(.semibold)
                    
                    MaterialSelector(selectedMaterials: $filters.materials)
                }
                
                // Availability
                VStack(alignment: .leading, spacing: 12) {
                    Text("Availability")
                        .font(BreitlingFonts.callout)
                        .fontWeight(.semibold)
                    
                    AvailabilitySelector(selectedAvailability: $filters.availability)
                }
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 16) {
                    Button("Reset") {
                        filters = ProductFilters()
                    }
                    .font(BreitlingFonts.buttonText)
                    .foregroundColor(BreitlingColors.navyBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(BreitlingColors.cardBackground)
                    .cornerRadius(8)
                    
                    Button("Apply") {
                        dismiss()
                    }
                    .font(BreitlingFonts.buttonText)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(BreitlingColors.navyBlue)
                    .cornerRadius(8)
                }
            }
            .padding(20)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Sort Sheet

struct SortSheet: View {
    @Binding var sortOption: SortOption
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Sort By")
                .font(BreitlingFonts.title3)
                .fontWeight(.semibold)
                .padding(.top, 20)
                .padding(.bottom, 24)
            
            VStack(spacing: 0) {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Button(action: {
                        sortOption = option
                        dismiss()
                    }) {
                        HStack {
                            Text(option.displayName)
                                .font(BreitlingFonts.body)
                                .foregroundColor(BreitlingColors.text)
                            
                            Spacer()
                            
                            if sortOption == option {
                                Image(systemName: "checkmark")
                                    .foregroundColor(BreitlingColors.navyBlue)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if option != SortOption.allCases.last {
                        Divider()
                            .padding(.horizontal, 20)
                    }
                }
            }
            
            Spacer()
        }
        .presentationDetents([.height(300)])
    }
}

// MARK: - Filter Components

struct PriceRangeSlider: View {
    @Binding var range: ClosedRange<Double>?
    @State private var minValue: Double = 0
    @State private var maxValue: Double = 50000
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("$\(Int(minValue))")
                    .font(BreitlingFonts.callout)
                    .foregroundColor(BreitlingColors.textSecondary)
                
                Spacer()
                
                Text("$\(Int(maxValue))")
                    .font(BreitlingFonts.callout)
                    .foregroundColor(BreitlingColors.textSecondary)
            }
            
            // Custom dual slider would go here
            // For now, using a simple slider for max value
            Slider(value: $maxValue, in: 1000...50000, step: 500)
                .accentColor(BreitlingColors.navyBlue)
        }
        .onAppear {
            if let range = range {
                minValue = range.lowerBound
                maxValue = range.upperBound
            }
        }
        .onChange(of: maxValue) { _ in
            range = minValue...maxValue
        }
    }
}

struct MaterialSelector: View {
    @Binding var selectedMaterials: [String]
    
    private let materials = ["Stainless Steel", "Gold", "Titanium", "Ceramic", "Carbon Fiber"]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            ForEach(materials, id: \.self) { material in
                MaterialChip(
                    title: material,
                    isSelected: selectedMaterials.contains(material),
                    onTap: {
                        if selectedMaterials.contains(material) {
                            selectedMaterials.removeAll { $0 == material }
                        } else {
                            selectedMaterials.append(material)
                        }
                    }
                )
            }
        }
    }
}

struct AvailabilitySelector: View {
    @Binding var selectedAvailability: [ProductAvailability]
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(ProductAvailability.allCases, id: \.self) { availability in
                MaterialChip(
                    title: availability.displayText,
                    isSelected: selectedAvailability.contains(availability),
                    onTap: {
                        if selectedAvailability.contains(availability) {
                            selectedAvailability.removeAll { $0 == availability }
                        } else {
                            selectedAvailability.append(availability)
                        }
                    }
                )
            }
        }
    }
}

struct MaterialChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(BreitlingFonts.callout)
                .foregroundColor(isSelected ? .white : BreitlingColors.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? BreitlingColors.navyBlue : BreitlingColors.cardBackground)
                .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Collections View Model

@MainActor
class CollectionsViewModel: ObservableObject {
    @Published var collections: [Collection] = []
    @Published var allProducts: [Product] = []
    @Published var filteredProducts: [Product] = []
    @Published var searchText = ""
    @Published var selectedCollection: String?
    @Published var sortOption: SortOption = .name
    @Published var filters = ProductFilters()
    @Published var isLoading = false
    @Published var error: String?
    
    func loadCollections() {
        isLoading = true
        
        Task {
            do {
                // In production, these would be API calls
                await loadMockData()
                filterProducts()
                isLoading = false
            } catch {
                self.error = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    func filterProducts() {
        var filtered = allProducts
        
        // Filter by collection
        if let selectedCollection = selectedCollection {
            filtered = filtered.filter { $0.collection.lowercased() == selectedCollection.lowercased() }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { product in
                product.name.localizedCaseInsensitiveContains(searchText) ||
                product.collection.localizedCaseInsensitiveContains(searchText) ||
                product.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply filters
        if let priceRange = filters.priceRange {
            filtered = filtered.filter { priceRange.contains($0.price) }
        }
        
        if !filters.materials.isEmpty {
            filtered = filtered.filter { product in
                filters.materials.contains { material in
                    product.specifications.caseMaterial.localizedCaseInsensitiveContains(material)
                }
            }
        }
        
        if !filters.availability.isEmpty {
            filtered = filtered.filter { filters.availability.contains($0.availability) }
        }
        
        filteredProducts = filtered
        sortProducts()
    }
    
    func sortProducts() {
        switch sortOption {
        case .name:
            filteredProducts.sort { $0.name < $1.name }
        case .priceAscending:
            filteredProducts.sort { $0.price < $1.price }
        case .priceDescending:
            filteredProducts.sort { $0.price > $1.price }
        case .newest:
            // In production, would sort by actual creation date
            filteredProducts = filteredProducts.reversed()
        }
    }
    
    private func loadMockData() async {
        // Simulate API delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        collections = Collection.mockCollections
        
        // Generate multiple products per collection
        allProducts = Collection.mockCollections.flatMap { collection in
            // Create 3-4 products per collection with your actual image
            let productVariants = [
                ("B01 Chronograph 43", "Classic_avi_1"), // Your actual image
                ("Automatic 42", "navitimer"),      // Reuse same image
                ("GMT 40", "endurance_1"),            // Reuse same image
                ("Heritage Edition", "SOH-1-temp")    // Reuse same image
            ]
            
            return productVariants.enumerated().map { index, variant in
                Product(
                    id: "\(collection.id)-\(variant.0.lowercased().replacingOccurrences(of: " ", with: "-"))",
                    name: "\(collection.name) \(variant.0)",
                    collection: collection.name,
                    price: Double.random(in: 3000...15000), // Random price range
                    currency: "USD",
                    imageURLs: [variant.1], // ✅ Use your actual image name
                    description: "Premium \(collection.name) timepiece featuring Swiss craftsmanship and exceptional precision.",
                    specifications: ProductSpecifications(
                        movement: "Breitling Caliber \(String(format: "%02d", Int.random(in: 10...25)))",
                        caseMaterial: ["Stainless Steel", "Titanium", "Gold"].randomElement() ?? "Stainless Steel",
                        caseDiameter: "\(Int.random(in: 40...46))mm",
                        caseThickness: String(format: "%.1fmm", Double.random(in: 12.0...16.0)),
                        waterResistance: ["\(Int.random(in: 3...30))0m", "100m", "200m", "300m"].randomElement() ?? "100m",
                        crystal: "Sapphire crystal",
                        braceletMaterial: ["Steel Bracelet", "Leather Strap", "Rubber Strap"].randomElement(),
                        functions: ["Hours", "Minutes", "Seconds", "Date", "Chronograph"].shuffled().prefix(Int.random(in: 3...5)).map { String($0) }
                    ),
                    availability: ProductAvailability.allCases.randomElement() ?? .inStock,
                    isLimitedEdition: Bool.random(),
                    tags: [collection.name.lowercased(), "luxury", "swiss-made"]
                )
            }
        }
    }
}

// MARK: - Sort Options

enum SortOption: CaseIterable {
    case name
    case priceAscending
    case priceDescending
    case newest
    
    var displayName: String {
        switch self {
        case .name:
            return "Name A-Z"
        case .priceAscending:
            return "Price: Low to High"
        case .priceDescending:
            return "Price: High to Low"
        case .newest:
            return "Newest First"
        }
    }
}

#Preview {
    CollectionsView()
        .environment(NavigationRouter())
}
