//
//  HomeView.swift
//  BreitlingApp
//
//  Updated with working UIKit video player
//

import SwiftUI
import UIKit
import AVFoundation

// MARK: - UIKit Video Player Classes

class VideoPlayerViewController: UIViewController {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    var videoFileName: String = ""
    var videoExtension: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        playVideoWithoutControls()
    }
    
    // Add this new method for restarting
    func restartVideo() {
        guard let player = player else { return }
        player.seek(to: .zero)
        player.play()
        print("🔄 Video restarted")
    }
    
    func playVideoWithoutControls() {
        guard let path = Bundle.main.path(forResource: videoFileName, ofType: videoExtension) else {
            print("❌ \(videoFileName).\(videoExtension) not found")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        
        playerLayer?.frame = view.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        
        if let playerLayer = playerLayer {
            view.layer.addSublayer(playerLayer)
        }
        
//        player?.isMuted = true
        player?.play()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoDidEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
        
        print("🎬 Video started")
    }
    
    @objc func videoDidEnd() {
        restartVideo()
    }
    
    // Add this method to handle when view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player?.play()
        print("🎬 Video resumed on view appear")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        player?.pause()
    }
}

// MARK: - Updated UIKitVideoPlayer

struct UIKitVideoPlayer: UIViewControllerRepresentable {
    let videoFileName: String
    let videoExtension: String
    
    func makeUIViewController(context: Context) -> VideoPlayerViewController {
        let controller = VideoPlayerViewController()
        controller.videoFileName = videoFileName
        controller.videoExtension = videoExtension
        return controller
    }
    
    func updateUIViewController(_ uiViewController: VideoPlayerViewController, context: Context) {
        // Restart video when view updates
        uiViewController.restartVideo()
    }
}

// MARK: - Updated Hero Section with Working Video

struct HeroSection: View {
    @Environment(NavigationRouter.self) private var router
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Video Background
            UIKitVideoPlayer(
                videoFileName: "SOH_CORE_HERO_BANNER",
                videoExtension: "mp4"
            )
            .frame(height: 400)
            .clipped()
            
            // Enhanced multi-layered gradient overlay
            ZStack {
                // Bottom dark gradient for text readability
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.8),
                        Color.black.opacity(0.4),
                        Color.clear
                    ],
                    startPoint: .bottom,
                    endPoint: .center
                )
                
                // Subtle luxury gradient accent
                LinearGradient(
                    colors: [
                        BreitlingColors.navyBlue.opacity(0.3),
                        Color.clear,
                        BreitlingColors.luxuryGold.opacity(0.1)
                    ],
                    startPoint: .bottomLeading,
                    endPoint: .topTrailing
                )
            }
            .frame(height: 400)
            
            // Enhanced content with better typography and shadows
            VStack(alignment: .leading, spacing: 16) {
                Spacer()
                
                // Enhanced title with multiple shadow layers
                Text("NAVITIMER")
                    .font(BreitlingFonts.heroTitle)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .shadow(color: .black.opacity(0.8), radius: 4, x: 0, y: 2)
                    .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
                    .shadow(color: BreitlingColors.navyBlue.opacity(0.6), radius: 12, x: 0, y: 6)
                
                // Enhanced subtitle with luxury styling
                Text("The Ultimate Pilot's Watch")
                    .font(BreitlingFonts.title2)
                    .foregroundColor(.white)
                    .fontWeight(.medium)
                    .shadow(color: .black.opacity(0.6), radius: 3, x: 0, y: 2)
                    .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                
                // Enhanced button stack with luxury styling
                HStack(spacing: 16) {
                    EnhancedLuxuryButton(
                        title: "Discover",
                        style: .primary,
                        action: {
                            router.navigate(to: .collectionDetail(collectionId: "navitimer"))
                        }
                    )
                    
                    EnhancedLuxuryButton(
                        title: "Heritage",
                        style: .secondary,
                        action: {
                            router.navigate(to: .heritageStory(storyId: "navitimer-heritage"))
                        }
                    )
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .frame(height: 400)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 0)) // Will add subtle corner radius later
    }
}


// MARK: - Enhanced Luxury Button Component

struct EnhancedLuxuryButton: View {
    let title: String
    let style: ButtonStyle
    let action: () -> Void
    
    @State private var isPressed = false
    
    enum ButtonStyle {
        case primary
        case secondary
        
        var backgroundColor: Color {
            switch self {
            case .primary:
                return BreitlingColors.navyBlue
            case .secondary:
                return Color.clear
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary:
                return .white
            case .secondary:
                return .white
            }
        }
        
        var borderColor: Color {
            switch self {
            case .primary:
                return BreitlingColors.navyBlue
            case .secondary:
                return .white.opacity(0.8)
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(BreitlingFonts.buttonText)
                .fontWeight(.semibold)
                .foregroundColor(style.foregroundColor)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    ZStack {
                        // Base background
                        RoundedRectangle(cornerRadius: 12)
                            .fill(style.backgroundColor)
                        
                        // Glassmorphism effect for secondary button
                        if style == .secondary {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial.opacity(0.3))
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(style.borderColor, lineWidth: style == .secondary ? 1.5 : 0)
                }
                .shadow(
                    color: style == .primary
                        ? BreitlingColors.navyBlue.opacity(0.4)
                        : Color.black.opacity(0.3),
                    radius: isPressed ? 4 : 8,
                    x: 0,
                    y: isPressed ? 2 : 4
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Complete HomeView with Video Integration

struct HomeView: View {
    @Environment(NavigationRouter.self) private var router
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Hero Section with Working Video
                    HeroSection()
                        .environment(router)
                    // Featured Collections
                    FeaturedCollectionsSection()
                        .environment(router)
                    // Heritage Storytelling
//                    HeritageSection()
//                        .environment(router)
                    
                    // New Arrivals
                    NewArrivalsSection()
                        .environment(router)
                    
                    // Limited Editions
                    LimitedEditionsSection()
                        .environment(router)
                    
                    // Brand Values
                    BrandValuesSection()
                }
            }
            .background(BreitlingColors.background)
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.loadHomeContent()
        }
    }
}

// MARK: - Keep all your existing sections exactly the same

struct FeaturedCollectionsSection: View {
    @Environment(NavigationRouter.self) private var router
    
    private let featuredCollections = Collection.mockCollections.prefix(3)

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            SectionHeader(
                title: "Featured Collections",
                subtitle: "Discover our most iconic timepieces"
            )
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(Array(featuredCollections), id: \.id) { collection in
                        FeaturedCollectionCard(collection: collection)
                            .onTapGesture {
                                router.showCollection(collection.id)
                            }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.vertical, 32)
    }
}

struct HeritageSection: View {
    var body: some View {
        VStack(spacing: 0) {
            HeroImageView(
                imageURL: "Classic_avi_1",
                height: 280
            ) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                BreitlingColors.navyBlue.opacity(0.8),
                                BreitlingColors.navyBlue.opacity(0.4)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            .overlay(alignment: .center) {
                VStack(spacing: 16) {
                    Text("Since 1884")
                        .font(BreitlingFonts.title3)
                        .foregroundColor(BreitlingColors.luxuryGold)
                        .fontWeight(.semibold)
                    
                    Text("SWISS EXCELLENCE")
                        .font(BreitlingFonts.title1)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Precision, performance, and passion\nfor over 140 years")
                        .font(BreitlingFonts.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

struct NewArrivalsSection: View {
    @Environment(NavigationRouter.self) private var router
    
    private let newProducts = Product.mockProducts
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            SectionHeader(
                title: "New Arrivals",
                subtitle: "The latest additions to our collections",
                actionTitle: "View All",
                action: {
                    // Navigate to new arrivals
                }
            )
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) { // Increased spacing for better breathing room
                    ForEach(newProducts, id: \.id) { product in
                        ProductCard(product: product, onTap: {
                            print("on tap gesture triggered for product: \(product.id)")
                            router.showProduct(product.id)
                        })
//                            .onTapGesture {
//                                print("on tap gesture triggered for product: \(product.id)")
//                                router.showProduct(product.id)
//                            }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 8) // Adds breathing room for shadows
            }
        }
        .padding(.vertical, 32)
        .background(
            // Modern gradient background
            LinearGradient(
                colors: [
                    BreitlingColors.background,
                    BreitlingColors.cardBackground.opacity(0.4),
                    BreitlingColors.cardBackground.opacity(0.8),
                    BreitlingColors.cardBackground
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            // Subtle top border
            VStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                BreitlingColors.divider.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
                Spacer()
            }
        )
    }
}

// MARK: - Enhanced Limited Editions Section with Modern Design

struct LimitedEditionsSection: View {
    @Environment(NavigationRouter.self) private var router
    
    var body: some View {
        VStack(spacing: 28) {
            // Enhanced section header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 12) {
                    // Premium badge indicator
                    HStack(spacing: 8) {
                        Circle()
                            .fill(BreitlingColors.luxuryGold)
                            .frame(width: 6, height: 6)
                        
                        Text("EXCLUSIVE")
                            .font(BreitlingFonts.caption)
                            .foregroundColor(BreitlingColors.luxuryGold)
                            .fontWeight(.bold)
                            .tracking(1.2)
                    }
                    
                    Text("LIMITED EDITIONS")
                        .font(BreitlingFonts.title2)
                        .foregroundColor(BreitlingColors.text)
                        .fontWeight(.bold)
                    
                    Text("Exclusive timepieces for collectors")
                        .font(BreitlingFonts.body)
                        .foregroundColor(BreitlingColors.textSecondary)
                        .fontWeight(.regular)
                }
                
                Spacer()
                
                // Enhanced explore button
                Button(action: {
                    router.navigate(to: .limitedEditions)
                }) {
                    HStack(spacing: 8) {
                        Text("Explore")
                            .font(BreitlingFonts.callout)
                            .fontWeight(.semibold)
                        
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        BreitlingColors.luxuryGold,
                                        BreitlingColors.luxuryGold.opacity(0.8)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(
                                color: BreitlingColors.luxuryGold.opacity(0.4),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Enhanced limited edition cards
            HStack(spacing: 20) {
                EnhancedLimitedEditionCard(
                    title: "Superocean Heritage '57",
                    subtitle: "Limited to 1,957 pieces",
                    imageURL: "AB0146101L1X1",
                    isLeftCard: true,
                    action: {
                        router.showProduct("superocean-heritage-57-limited")
                    }
                )
                
                EnhancedLimitedEditionCard(
                    title: "Chronomat NFL",
                    subtitle: "Team Edition Collection",
                    imageURL: "endurance",
                    isLeftCard: false,
                    action: {
                        router.showProduct("chronomat-nfl-team-editions")
                    }
                )
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 36)
        .background(
            // Sophisticated gradient background
            LinearGradient(
                colors: [
                    BreitlingColors.background,
                    BreitlingColors.cardBackground.opacity(0.3),
                    BreitlingColors.cardBackground.opacity(0.6)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            // Subtle border treatment
            VStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                BreitlingColors.luxuryGold.opacity(0.2),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
                Spacer()
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                BreitlingColors.divider.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
            }
        )
    }
}

// MARK: - Enhanced Limited Edition Card

struct EnhancedLimitedEditionCard: View {
    let title: String
    let subtitle: String
    let imageURL: String
    let isLeftCard: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // Enhanced image with modern styling
                ZStack {
                    // Sophisticated shadow system
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white)
                        .shadow(
                            color: Color.black.opacity(0.12),
                            radius: 16,
                            x: 0,
                            y: 8
                        )
                        .shadow(
                            color: Color.black.opacity(0.06),
                            radius: 4,
                            x: 0,
                            y: 2
                        )
                    
                    // Product image with premium treatment
                    LuxuryProductImageView(
                        imageURL: imageURL,
                        aspectRatio: 1.0,
                        cornerRadius: 18
                    )
                    .frame(height: 140)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(BreitlingColors.cardBackground)
                    )
                    .padding(8)
                    
                    // Premium overlay effect
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.7),
                                    Color.clear,
                                    Color.black.opacity(0.04)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                        .frame(height: 140)
                        .padding(8)
                    
                    // Limited edition badge
                    VStack {
                        HStack {
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.white)
                                
                                Text("LIMITED")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.white)
                                    .tracking(0.5)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(BreitlingColors.luxuryGold)
                                    .shadow(
                                        color: BreitlingColors.luxuryGold.opacity(0.4),
                                        radius: 4,
                                        x: 0,
                                        y: 2
                                    )
                            )
                        }
                        .padding(.trailing, 16)
                        .padding(.top, 16)
                        
                        Spacer()
                    }
                }
                .frame(height: 156)
                
                // Enhanced text content
                VStack(spacing: 10) {
                    Text(title)
                        .font(BreitlingFonts.callout)
                        .foregroundColor(BreitlingColors.text)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Enhanced subtitle with accent
                    HStack(spacing: 6) {
                        Rectangle()
                            .fill(BreitlingColors.luxuryGold)
                            .frame(width: 2, height: 12)
                            .cornerRadius(1)
                        
                        Text(subtitle)
                            .font(BreitlingFonts.caption)
                            .foregroundColor(BreitlingColors.luxuryGold)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(BreitlingColors.cardBackground)
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(BreitlingColors.cardBackground)
                    .shadow(
                        color: Color.black.opacity(0.08),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
                    .shadow(
                        color: Color.black.opacity(0.04),
                        radius: 3,
                        x: 0,
                        y: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct BrandValuesSection: View {
    var body: some View {
        VStack(spacing: 32) {
            Text("INSTRUMENTS FOR PROFESSIONALS")
                .font(BreitlingFonts.title2)
                .foregroundColor(BreitlingColors.text)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 24) {
                BrandValueCard(
                    icon: "airplane",
                    title: "Aviation",
                    description: "Trusted by pilots worldwide"
                )
                
                BrandValueCard(
                    icon: "drop.fill",
                    title: "Diving",
                    description: "Built for underwater exploration"
                )
                
                BrandValueCard(
                    icon: "crown.fill",
                    title: "Luxury",
                    description: "Swiss craftsmanship at its finest"
                )
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 40)
        .background(BreitlingColors.navyBlue)
        .foregroundColor(.white)
    }
}

// MARK: - Keep all your existing supporting views
// (SectionHeader, FeaturedCollectionCard, ProductCard, etc. - all stay exactly the same)


// MARK: - Enhanced Featured Collection Card with Modern Design

struct FeaturedCollectionCard: View {
    let collection: Collection
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Enhanced image container with floating effect
            ZStack {
                // Background card for elevation
                RoundedRectangle(cornerRadius: 20)
                    .fill(BreitlingColors.cardBackground)
                    .shadow(
                        color: Color.black.opacity(0.08),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
                    .shadow(
                        color: Color.black.opacity(0.04),
                        radius: 4,
                        x: 0,
                        y: 2
                    )
                
                VStack(alignment: .leading, spacing: 20) {
                    // Enhanced image with modern iOS styling and depth
                    ZStack {
                        // Background shadow for depth
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.white)
                            .shadow(
                                color: Color.black.opacity(0.12),
                                radius: 16,
                                x: 0,
                                y: 8
                            )
                            .shadow(
                                color: Color.black.opacity(0.06),
                                radius: 4,
                                x: 0,
                                y: 2
                            )
                        
                        // Image with modern aspect ratio and cropping
                        LuxuryProductImageView(
                            imageURL: collection.heroImageURL,
                            aspectRatio: 1.4, // More modern 7:5 ratio instead of 6:5
                            cornerRadius: 18
                        )
                        .frame(width: 264, height: 188) // Optimized dimensions
                        .clipped()
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(BreitlingColors.cardBackground)
                        )
                        .padding(8) // Creates clean border effect
                        
                        // Subtle inner shadow for depth
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.8),
                                        Color.clear,
                                        Color.black.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                            .frame(width: 264, height: 188)
                            .padding(8)
                    }
                    .frame(width: 280, height: 204) // Adjusted for new proportions
                    
                    // Enhanced text content with better spacing
                    VStack(alignment: .leading, spacing: 12) {
                        // Collection name with enhanced typography
                        Text(collection.name)
                            .font(BreitlingFonts.collectionName)
                            .foregroundColor(BreitlingColors.text)
                            .fontWeight(.semibold)
                        
                        // Tagline with improved styling
                        Text(collection.tagline)
                            .font(BreitlingFonts.body)
                            .foregroundColor(BreitlingColors.textSecondary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Heritage text with luxury accent
                        HStack {
                            // Small luxury accent line
                            Rectangle()
                                .fill(BreitlingColors.luxuryGold)
                                .frame(width: 3, height: 16)
                                .cornerRadius(1.5)
                            
                            Text(collection.heritage)
                                .font(BreitlingFonts.footnote)
                                .foregroundColor(BreitlingColors.navyBlue)
                                .fontWeight(.medium)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
                .padding(.top, 16)
            }
        }
        .frame(width: 300) // Slightly wider for better proportions
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isPressed)
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Enhanced Section Header with Subtle Background

struct SectionHeader: View {
    let title: String
    let subtitle: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(title: String, subtitle: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(BreitlingFonts.title2)
                        .foregroundColor(BreitlingColors.text)
                        .fontWeight(.bold)
                    
                    Text(subtitle)
                        .font(BreitlingFonts.body)
                        .foregroundColor(BreitlingColors.textSecondary)
                        .fontWeight(.regular)
                }
                
                Spacer()
                
                if let actionTitle = actionTitle, let action = action {
                    Button(action: action) {
                        HStack(spacing: 6) {
                            Text(actionTitle)
                                .font(BreitlingFonts.callout)
                                .foregroundColor(BreitlingColors.navyBlue)
                                .fontWeight(.semibold)
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(BreitlingColors.navyBlue)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(BreitlingColors.navyBlue.opacity(0.08))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .background(
            // Subtle background treatment
            RoundedRectangle(cornerRadius: 0)
                .fill(
                    LinearGradient(
                        colors: [
                            BreitlingColors.background,
                            BreitlingColors.cardBackground.opacity(0.3)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
    }
}

// MARK: - Enhanced Product Card with Modern iOS Design

struct ProductCard: View {
    let product: Product
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Enhanced card container
            VStack(alignment: .leading, spacing: 16) {
                // Modern image with floating effect
                ZStack {
                    // Enhanced shadow system
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(
                            color: Color.black.opacity(0.1),
                            radius: 12,
                            x: 0,
                            y: 6
                        )
                        .shadow(
                            color: Color.black.opacity(0.05),
                            radius: 3,
                            x: 0,
                            y: 1
                        )
                    
                    // Product image with modern styling
                    LuxuryProductImageView(
                        imageURL: product.primaryImageURL,
                        aspectRatio: 1.0,
                        cornerRadius: 16
                    )
                    .frame(width: 168, height: 168) // Optimized for mobile
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(BreitlingColors.cardBackground)
                    )
                    .padding(6) // Clean border effect
                    
                    // Subtle gradient overlay for depth
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.clear,
                                    Color.black.opacity(0.03)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                        .frame(width: 168, height: 168)
                        .padding(6)
                }
                .frame(width: 180, height: 180)
                
                // Enhanced product information
                VStack(alignment: .leading, spacing: 8) {
                    // Collection name with accent
                    HStack(spacing: 6) {
                        Circle()
                            .fill(BreitlingColors.navyBlue)
                            .frame(width: 4, height: 4)
                        
                        Text(product.collection)
                            .font(BreitlingFonts.caption)
                            .foregroundColor(BreitlingColors.navyBlue)
                            .fontWeight(.semibold)
                            .textCase(.uppercase)
                            .tracking(0.5)
                    }
                    
                    // Product name with better typography
                    Text(product.name)
                        .font(BreitlingFonts.callout)
                        .foregroundColor(BreitlingColors.text)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Price with enhanced styling
                    Text(product.formattedPrice)
                        .font(BreitlingFonts.callout)
                        .foregroundColor(BreitlingColors.text)
                        .fontWeight(.bold)
                        .padding(.top, 4)
                }
                .padding(.horizontal, 4)
            }
            .padding(12) // Internal card padding
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(BreitlingColors.cardBackground)
                    .shadow(
                        color: Color.black.opacity(0.06),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                    .shadow(
                        color: Color.black.opacity(0.03),
                        radius: 2,
                        x: 0,
                        y: 1
                    )
            )
        }
        .frame(width: 200)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isPressed)
        .onTapGesture {
            onTap() // Call the passed action
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct LimitedEditionCard: View {
    let title: String
    let subtitle: String
    let imageURL: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                LuxuryProductImageView(
                    imageURL: imageURL,
                    aspectRatio: 1.0,
                    cornerRadius: 12
                )
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(BreitlingFonts.callout)
                        .foregroundColor(BreitlingColors.text)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                    
                    Text(subtitle)
                        .font(BreitlingFonts.caption)
                        .foregroundColor(BreitlingColors.luxuryGold)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BrandValueCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(BreitlingColors.luxuryGold)
            
            Text(title)
                .font(BreitlingFonts.callout)
                .fontWeight(.semibold)
            
            Text(description)
                .font(BreitlingFonts.caption)
                .multilineTextAlignment(.center)
                .opacity(0.9)
        }
        .frame(maxWidth: .infinity)
    }
}

struct LuxuryButton: View {
    let title: String
    let style: ButtonStyle
    let action: () -> Void
    
    enum ButtonStyle {
        case primary
        case secondary
        case accent
        
        var backgroundColor: Color {
            switch self {
            case .primary:
                return BreitlingColors.navyBlue
            case .secondary:
                return Color.clear
            case .accent:
                return BreitlingColors.luxuryGold
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary:
                return .white
            case .secondary:
                return .white
            case .accent:
                return BreitlingColors.navyBlue
            }
        }
        
        var borderColor: Color {
            switch self {
            case .primary:
                return BreitlingColors.navyBlue
            case .secondary:
                return .white
            case .accent:
                return BreitlingColors.luxuryGold
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(BreitlingFonts.buttonText)
                .fontWeight(.medium)
                .foregroundColor(style.foregroundColor)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(style.backgroundColor)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(style.borderColor, lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Home View Model (Keep exactly the same)

@MainActor
class HomeViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var featuredCollections: [Collection] = []
    @Published var newProducts: [Product] = []
    @Published var error: String?
    
    func loadHomeContent() {
        isLoading = true
        
        Task {
            do {
                await loadMockData()
                isLoading = false
            } catch {
                self.error = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    private func loadMockData() async {
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        featuredCollections = Array(Collection.mockCollections.prefix(3))
        newProducts = Product.mockProducts
    }
}

#Preview {
    HomeView()
        .environment(NavigationRouter())
}
