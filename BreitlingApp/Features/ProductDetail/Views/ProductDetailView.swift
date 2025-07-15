//
//  ProductDetailView.swift
//  BreitlingApp
//
//  Created by Arup Sarkar (TA) on 7/10/25.
//

//  Priority 3: Individual watch details with AR try-on capability
//  Features: Image gallery, specifications, AR try-on, wishlist, related products
//

import SwiftUI

struct ProductDetailView: View {
    let productId: String
    @Environment(NavigationRouter.self) private var router
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ProductDetailViewModel()
    @State private var selectedImageIndex = 0
    @State private var showingImageGallery = false
    @State private var showingARTryOn = false
    @State private var showingStoreLocator = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                if let product = viewModel.product {
                    LazyVStack(spacing: 0) {
                        // Product Image Gallery
                        ProductImageGalleryCard(
                            product: product,
                            selectedIndex: $selectedImageIndex,
                            onImageTap: { showingImageGallery = true }
                        )
                        
                        // Product Information
                        ProductInfoSection(product: product)
                        
                        // Action Buttons
                        ProductActionButtons(
                            product: product,
                            onARTryOn: { showingARTryOn = true },
                            onStoreLocator: { showingStoreLocator = true },
                            onWatchConfigurator: {
                                router.showWatchConfigurator(for: product.id)
                            }
                        )
                        
                        // Specifications
                        ProductSpecificationsSection(specifications: product.specifications)
                        
                        // Availability & Warranty
                        AvailabilityWarrantySection(product: product)
                        
                        // Related Products
                        RelatedProductsSection(
                            currentProduct: product,
                            relatedProducts: viewModel.relatedProducts,
                            onProductTap: { relatedProduct in
                                router.showProduct(relatedProduct.id)
                            }
                        )
                    }
                } else if viewModel.isLoading {
                    LoadingDetailView()
                } else {
                    ErrorDetailView(error: viewModel.error) {
                        viewModel.loadProduct(id: productId)
                    }
                }
            }
            .background(BreitlingColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let product = viewModel.product {
                        WishlistToolbarButton(productId: product.id)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingImageGallery) {
            if let product = viewModel.product {
                ImageGalleryView(
                    images: product.imageURLs,
                    selectedIndex: $selectedImageIndex,
                    productName: product.name
                )
            }
        }
        .fullScreenCover(isPresented: $showingARTryOn) {
            if let product = viewModel.product {
                ARTryOnView(productId: product.id)
            }
        }
        .sheet(isPresented: $showingStoreLocator) {
            StoreLocatorSheet()
        }
        .onAppear {
            viewModel.loadProduct(id: productId)
        }
    }
}

// MARK: - Product Image Gallery

struct ProductImageGalleryCard: View {
    let product: Product
    @Binding var selectedIndex: Int
    let onImageTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Main elevated card container
            VStack(spacing: 16) {
                // Main image
                TabView(selection: $selectedIndex) {
                    ForEach(Array(product.imageURLs.enumerated()), id: \.offset) { index, imageURL in
                        LuxuryProductImageView(
                            imageURL: imageURL,
                            aspectRatio: 1.0,
                            cornerRadius: 16
                        )
                        .tag(index)
                        .onTapGesture {
                            onImageTap()
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 350)
                
                // Image indicators
                if product.imageURLs.count > 1 {
                    HStack(spacing: 8) {
                        ForEach(0..<product.imageURLs.count, id: \.self) { index in
                            Circle()
                                .fill(selectedIndex == index ? BreitlingColors.navyBlue : BreitlingColors.divider)
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut(duration: 0.2), value: selectedIndex)
                        }
                    }
                }
                
                // Limited edition badge
                if product.isLimitedEdition {
                    LimitedEditionBadge()
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(BreitlingColors.cardBackground)
                    .shadow(
                        color: Color.black.opacity(0.1),
                        radius: 10,
                        x: 0,
                        y: 4
                    )
            )
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
    }
}

struct ProductImageGallery: View {
    let product: Product
    @Binding var selectedIndex: Int
    let onImageTap: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Main image
            TabView(selection: $selectedIndex) {
                ForEach(Array(product.imageURLs.enumerated()), id: \.offset) { index, imageURL in
                    LuxuryProductImageView(
                        imageURL: imageURL,
                        aspectRatio: 1.0,
                        cornerRadius: 0
                    )
                    .tag(index)
                    .onTapGesture {
                        onImageTap()
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 400)
            .background(BreitlingColors.cardBackground)
            
            // Image indicators
            if product.imageURLs.count > 1 {
                HStack(spacing: 8) {
                    ForEach(0..<product.imageURLs.count, id: \.self) { index in
                        Circle()
                            .fill(selectedIndex == index ? BreitlingColors.navyBlue : BreitlingColors.divider)
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut(duration: 0.2), value: selectedIndex)
                    }
                }
                .padding(.horizontal, 24)
            }
            
            // Limited edition badge
            if product.isLimitedEdition {
                LimitedEditionBadge()
                    .padding(.horizontal, 24)
            }
        }
    }
}

// MARK: - Product Information Section

struct ProductInfoSection: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text(product.collection.uppercased())
                    .font(BreitlingFonts.callout)
                    .foregroundColor(BreitlingColors.navyBlue)
                    .fontWeight(.semibold)
                
                Text(product.name)
                    .font(BreitlingFonts.productTitle)
                    .foregroundColor(BreitlingColors.text)
                    .fontWeight(.bold)
                
                HStack(alignment: .bottom, spacing: 12) {
                    Text(product.formattedPrice)
                        .font(BreitlingFonts.price)
                        .foregroundColor(BreitlingColors.text)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    AvailabilityBadge(availability: product.availability)
                }
            }
            
            Text(product.description)
                .font(BreitlingFonts.productDescription)
                .foregroundColor(BreitlingColors.textSecondary)
                .lineSpacing(4)
            
            // Key features
            if !product.specifications.functions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Key Features")
                        .font(BreitlingFonts.callout)
                        .foregroundColor(BreitlingColors.text)
                        .fontWeight(.semibold)
                    
                    ForEach(product.specifications.functions.prefix(4), id: \.self) { function in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(BreitlingColors.navyBlue)
                                .frame(width: 4, height: 4)
                            
                            Text(function)
                                .font(BreitlingFonts.body)
                                .foregroundColor(BreitlingColors.textSecondary)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
    }
}

// MARK: - Product Action Buttons

struct ProductActionButtons: View {
    let product: Product
    let onARTryOn: () -> Void
    let onStoreLocator: () -> Void
    let onWatchConfigurator: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Primary actions
            HStack(spacing: 12) {
                BoutiqueActionButton(
                    title: "AR Try-On",
                    icon: "camera.viewfinder",
                    style: .primary,
                    action: onARTryOn
                )
                
                BoutiqueActionButton(
                    title: "Customize",
                    icon: "slider.horizontal.3",
                    style: .secondary,
                    action: onWatchConfigurator
                )
            }
            
            // Secondary actions
            HStack(spacing: 12) {
                BoutiqueActionButton(
                    title: "Find in Store",
                    icon: "mappin.and.ellipse",
                    style: .outline,
                    action: onStoreLocator
                )
                
                BoutiqueActionButton(
                    title: "Book Appointment",
                    icon: "calendar",
                    style: .outline,
                    action: { /* Navigate to appointment booking */ }
                )
            }
            
            // Purchase button
            if product.isAvailable {
                BoutiqueActionButton(
                    title: "Contact for Purchase",
                    icon: "phone",
                    style: .accent,
                    fullWidth: true,
                    action: { /* Contact dealer */ }
                )
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(BreitlingColors.cardBackground)
    }
}

// MARK: - Product Specifications Section

struct ProductSpecificationsSection: View {
    let specifications: ProductSpecifications
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Specifications")
                .font(BreitlingFonts.title3)
                .foregroundColor(BreitlingColors.text)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                SpecificationRow(label: "Movement", value: specifications.movement)
                SpecificationRow(label: "Case Material", value: specifications.caseMaterial)
                SpecificationRow(label: "Case Diameter", value: specifications.caseDiameter)
                
                if let thickness = specifications.caseThickness {
                    SpecificationRow(label: "Case Thickness", value: thickness)
                }
                
                SpecificationRow(label: "Water Resistance", value: specifications.waterResistance)
                SpecificationRow(label: "Crystal", value: specifications.crystal)
                
                if let bracelet = specifications.braceletMaterial {
                    SpecificationRow(label: "Bracelet", value: bracelet)
                }
            }
            
            if specifications.isManufactureMovement {
                ManufactureMovementBadge()
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
    }
}

// MARK: - Availability & Warranty Section

struct AvailabilityWarrantySection: View {
    let product: Product
    
    var body: some View {
        VStack(spacing: 20) {
            Divider()
                .padding(.horizontal, 24)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    InfoCard(
                        icon: "checkmark.seal",
                        title: "Warranty",
                        subtitle: "2-Year International",
                        color: BreitlingColors.navyBlue
                    )
                    
                    InfoCard(
                        icon: "truck",
                        title: "Delivery",
                        subtitle: "Free & Insured",
                        color: BreitlingColors.luxuryGold
                    )
                }
                
                HStack(spacing: 16) {
                    InfoCard(
                        icon: "return",
                        title: "Returns",
                        subtitle: "30-Day Policy",
                        color: BreitlingColors.textSecondary
                    )
                    
                    InfoCard(
                        icon: "lock.shield",
                        title: "Authenticity",
                        subtitle: "Guaranteed Swiss",
                        color: BreitlingColors.navyBlue
                    )
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Related Products Section

struct RelatedProductsSection: View {
    let currentProduct: Product
    let relatedProducts: [Product]
    let onProductTap: (Product) -> Void
    
    var body: some View {
        if !relatedProducts.isEmpty {
            VStack(alignment: .leading, spacing: 20) {
                Divider()
                    .padding(.horizontal, 24)
                
                Text("You Might Also Like")
                    .font(BreitlingFonts.title3)
                    .foregroundColor(BreitlingColors.text)
                    .fontWeight(.bold)
                    .padding(.horizontal, 24)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(relatedProducts, id: \.id) { product in
                            RelatedProductCard(product: product)
                                .onTapGesture {
                                    onProductTap(product)
                                }
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
            .padding(.vertical, 24)
        }
    }
}

// MARK: - Supporting Views

struct BackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                Text("Back")
                    .font(BreitlingFonts.body)
            }
            .foregroundColor(BreitlingColors.navyBlue)
        }
    }
}

struct WishlistToolbarButton: View {
    let productId: String
    @State private var isInWishlist = false
    
    var body: some View {
        Button(action: toggleWishlist) {
            Image(systemName: isInWishlist ? "heart.fill" : "heart")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(isInWishlist ? .red : BreitlingColors.navyBlue)
        }
        .onAppear {
            checkWishlistStatus()
        }
    }
    
    private func toggleWishlist() {
        if isInWishlist {
            CoreDataManager.shared.removeFromWishlist(productId: productId)
        } else {
            CoreDataManager.shared.addToWishlist(productId: productId)
        }
        isInWishlist.toggle()
    }
    
    private func checkWishlistStatus() {
        isInWishlist = CoreDataManager.shared.isInWishlist(productId: productId)
    }
}

struct LimitedEditionBadge: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "crown.fill")
                .font(.system(size: 14))
                .foregroundColor(BreitlingColors.luxuryGold)
            
            Text("LIMITED EDITION")
                .font(BreitlingFonts.caption)
                .fontWeight(.bold)
                .foregroundColor(BreitlingColors.luxuryGold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(BreitlingColors.luxuryGold.opacity(0.1))
        .cornerRadius(12)
    }
}

struct BoutiqueActionButton: View {
    let title: String
    let icon: String
    let style: ButtonStyle
    let fullWidth: Bool
    let action: () -> Void
    
    init(title: String, icon: String, style: ButtonStyle, fullWidth: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.fullWidth = fullWidth
        self.action = action
    }
    
    enum ButtonStyle {
        case primary, secondary, outline, accent
        
        var backgroundColor: Color {
            switch self {
            case .primary: return BreitlingColors.navyBlue
            case .secondary: return BreitlingColors.cardBackground
            case .outline: return Color.clear
            case .accent: return BreitlingColors.luxuryGold
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary: return .white
            case .secondary: return BreitlingColors.navyBlue
            case .outline: return BreitlingColors.textSecondary
            case .accent: return BreitlingColors.navyBlue
            }
        }
        
        var borderColor: Color {
            switch self {
            case .primary: return BreitlingColors.navyBlue
            case .secondary: return BreitlingColors.divider
            case .outline: return BreitlingColors.divider
            case .accent: return BreitlingColors.luxuryGold
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                
                Text(title)
                    .font(BreitlingFonts.buttonText)
                    .fontWeight(.medium)
            }
            .foregroundColor(style.foregroundColor)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(style.backgroundColor)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style.borderColor, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SpecificationRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(BreitlingFonts.body)
                .foregroundColor(BreitlingColors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(BreitlingFonts.body)
                .foregroundColor(BreitlingColors.text)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct ManufactureMovementBadge: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "gearshape.2.fill")
                .font(.system(size: 16))
                .foregroundColor(BreitlingColors.navyBlue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("MANUFACTURE MOVEMENT")
                    .font(BreitlingFonts.caption)
                    .fontWeight(.bold)
                    .foregroundColor(BreitlingColors.navyBlue)
                
                Text("Developed and produced in-house")
                    .font(BreitlingFonts.caption)
                    .foregroundColor(BreitlingColors.textSecondary)
            }
        }
        .padding(12)
        .background(BreitlingColors.navyBlue.opacity(0.1))
        .cornerRadius(8)
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(color)
            
            Text(title)
                .font(BreitlingFonts.callout)
                .foregroundColor(BreitlingColors.text)
                .fontWeight(.medium)
            
            Text(subtitle)
                .font(BreitlingFonts.caption)
                .foregroundColor(BreitlingColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(BreitlingColors.cardBackground)
        .cornerRadius(12)
    }
}

struct RelatedProductCard: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            LuxuryProductImageView(
                imageURL: product.primaryImageURL,
                aspectRatio: 1.0,
                cornerRadius: 8
            )
            .frame(width: 140)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(BreitlingFonts.footnote)
                    .foregroundColor(BreitlingColors.text)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                Text(product.formattedPrice)
                    .font(BreitlingFonts.footnote)
                    .foregroundColor(BreitlingColors.navyBlue)
                    .fontWeight(.semibold)
            }
        }
        .frame(width: 140)
    }
}

struct LoadingDetailView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: BreitlingColors.navyBlue))
                .scaleEffect(1.5)
            
            Text("Loading watch details...")
                .font(BreitlingFonts.body)
                .foregroundColor(BreitlingColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
}

struct ErrorDetailView: View {
    let error: String?
    let retry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(BreitlingColors.textSecondary)
            
            Text("Unable to load watch details")
                .font(BreitlingFonts.title3)
                .foregroundColor(BreitlingColors.text)
                .fontWeight(.medium)
            
            if let error = error {
                Text(error)
                    .font(BreitlingFonts.body)
                    .foregroundColor(BreitlingColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Try Again") {
                retry()
            }
            .font(BreitlingFonts.buttonText)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(BreitlingColors.navyBlue)
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
        .padding(.horizontal, 24)
    }
}

// MARK: - Full Screen Views (Placeholders)

struct ImageGalleryView: View {
    let images: [String]
    @Binding var selectedIndex: Int
    let productName: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedIndex) {
                ForEach(Array(images.enumerated()), id: \.offset) { index, imageURL in
                    LuxuryProductImageView(
                        imageURL: imageURL,
                        aspectRatio: 1.0,
                        cornerRadius: 0
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .background(Color.black)
            .navigationTitle(productName)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct StoreLocatorSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Text("Store Locator")
                .font(BreitlingFonts.title2)
                .navigationTitle("Find a Boutique")
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

// MARK: - Product Detail View Model

@MainActor
class ProductDetailViewModel: ObservableObject {
    @Published var product: Product?
    @Published var relatedProducts: [Product] = []
    @Published var isLoading = false
    @Published var error: String?
    
    func loadProduct(id: String) {
        isLoading = true
        error = nil
        
        Task {
            do {
                // In production, this would be an API call
                await loadMockProduct(id: id)
                await loadRelatedProducts()
                isLoading = false
            } catch {
                self.error = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    private func loadMockProduct(id: String) async {
        // Simulate API delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Find product in mock data or create one
        if let existingProduct = Product.mockProducts.first(where: { $0.id == id }) {
            product = existingProduct
        } else {
            // Create a mock product for the given ID
            product = Product.mockProduct
        }
    }
    
    private func loadRelatedProducts() async {
        guard let currentProduct = product else { return }
        
        // Get products from the same collection, excluding current product
        relatedProducts = Product.mockProducts
            .filter { $0.collection == currentProduct.collection && $0.id != currentProduct.id }
            .prefix(5)
            .map { $0 }
    }
}

#Preview {
    ProductDetailView(productId: "navitimer-b01-chronograph-43")
        .environment(NavigationRouter())
}
