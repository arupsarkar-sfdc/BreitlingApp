//
//  MainTabView.swift
//  BreitlingApp
//
//  Created by Arup Sarkar (TA) on 7/10/25.
//
//
//  MainTabView.swift
//  BreitlingApp
//
//  Main tab navigation - Collections, Search, Boutiques, Account
//  Primary pattern: NavigationStack, Secondary: TabView (luxury brand preference)
//

//
//  MainTabView.swift
//  BreitlingApp
//
//  Main tab navigation - Collections, Search, Boutiques, Account
//  Primary pattern: NavigationStack, Secondary: TabView (luxury brand preference)
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: TabSelection = .collections
    @State private var router = NavigationRouter()
    
    var body: some View {
        

        
        
        
        TabView(selection: $selectedTab) {
            
            
            // Tab 1: Home (Priority 1 - Landing screen)
            NavigationStack(path: $router.path) {
                HomeView()
                    .navigationDestination(for: AppDestination.self) { destination in
                        NavigationDestinationView(destination: destination)
                    }
            }
            .environment(router)
            .tabItem {
                TabItemView(
                    iconName: "house",
                    title: "Home",
                    isSelected: selectedTab == .home
                )
            }
            .tag(TabSelection.home)
            
            
            // Tab 1: Collections (Priority 2 from JSON analysis)
            NavigationStack(path: $router.path) {
                PersonalizedCollectionsView()
//                CollectionsView()
                    .navigationDestination(for: AppDestination.self) { destination in
                        NavigationDestinationView(destination: destination)
                    }
            }
            .environment(router)
            .tabItem {
                TabItemView(
                    iconName: "square.grid.2x2",
                    title: "Collections",
                    isSelected: selectedTab == .collections
                )
            }
            .tag(TabSelection.collections)
            
            // Tab 2: Search (Priority 4 from JSON analysis)
            NavigationStack(path: $router.path) {
                SearchView()
                    .navigationDestination(for: AppDestination.self) { destination in
                        NavigationDestinationView(destination: destination)
                    }
            }
            .environment(router)
            .tabItem {
                TabItemView(
                    iconName: "magnifyingglass",
                    title: "Search",
                    isSelected: selectedTab == .search
                )
            }
            .tag(TabSelection.search)
            
            // Tab 3: Boutiques (Priority 5 from JSON analysis)
            NavigationStack(path: $router.path) {
                BoutiqueLocatorView()
                    .navigationDestination(for: AppDestination.self) { destination in
                        NavigationDestinationView(destination: destination)
                    }
            }
            .environment(router)
            .tabItem {
                TabItemView(
                    iconName: "mappin.and.ellipse",
                    title: "Boutiques",
                    isSelected: selectedTab == .boutiques
                )
            }
            .tag(TabSelection.boutiques)
            
            // Tab 4: Account (Priority 7 from JSON analysis)
            NavigationStack(path: $router.path) {
                ProfileView()
                    .navigationDestination(for: AppDestination.self) { destination in
                        NavigationDestinationView(destination: destination)
                    }
            }
            .environment(router)
            .tabItem {
                TabItemView(
                    iconName: "person.circle",
                    title: "Account",
                    isSelected: selectedTab == .account
                )
            }
            .tag(TabSelection.account)
        }
        .accentColor(BreitlingColors.navyBlue)
        .tint(BreitlingColors.navyBlue)
        .onAppear {
            configureTabBarAppearance()
        }
    }
    
    private func configureTabBarAppearance() {
        // Configure tab bar appearance for luxury feel
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(BreitlingColors.background)
        
        // Selected tab item color
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(BreitlingColors.navyBlue)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(BreitlingColors.accent)
        ]
        
        // Unselected tab item color
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(BreitlingColors.mediumGray)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(BreitlingColors.mediumGray)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Tab Selection Enum

enum TabSelection: CaseIterable {
    case home
    case collections
    case search
    case boutiques
    case account
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .collections:
            return "Collections"
        case .search:
            return "Search"
        case .boutiques:
            return "Boutiques"
        case .account:
            return "Account"
        }
    }
    
    var iconName: String {
        switch self {
        case .home:
            return "house"
        case .collections:
            return "square.grid.2x2"
        case .search:
            return "magnifyingglass"
        case .boutiques:
            return "mappin.and.ellipse"
        case .account:
            return "person.circle"
        }
    }
}

// MARK: - Custom Tab Item View

struct TabItemView: View {
    let iconName: String
    let title: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: iconName)
                .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
            
            Text(title)
                .font(BreitlingFonts.caption)
                .fontWeight(isSelected ? .semibold : .regular)
        }
        .foregroundColor(
            isSelected ? BreitlingColors.navyBlue : BreitlingColors.mediumGray
        )
    }
}

struct NavigationCollectionFilterView: View {
    let collectionId: String
    
    var body: some View {
        Text("Filter Collection: \(collectionId)")
            .font(BreitlingFonts.title2)
    }
}

// MARK: - Navigation Destination View

struct NavigationDestinationView: View {
    let destination: AppDestination
    
    var body: some View {
        Group {
            switch destination {
            // Core product navigation
            case .productDetail(let productId):
                AnyView(ProductDetailView(productId: productId))
                
            case .collectionDetail(let collectionId):
                AnyView(CollectionDetailView(collectionId: collectionId))
                
            // Store & location navigation
            case .boutiqueDetail(let storeId):
                AnyView(BoutiqueDetailView(storeId: storeId))
                
            case .appointmentBooking(let storeId):
                AnyView(AppointmentBookingView(storeId: storeId))
                
            // Advanced features navigation
            case .watchConfigurator(let productId):
                AnyView(WatchConfiguratorView(productId: productId))
                
            case .arTryOn(let productId):
                AnyView(ARTryOnView(productId: productId))
                
            // User account navigation
            case .orderHistory:
                AnyView(Text("Order History - Coming Soon").font(BreitlingFonts.title2))
                
            case .orderDetail(let orderId):
                AnyView(OrderDetailView(orderId: orderId))
                
            case .wishlistDetail(let wishlistId):
                AnyView(WishlistDetailView(wishlistId: wishlistId))
                
            case .settings:
                AnyView(SettingsView())
                
            case .editProfile:
                AnyView(Text("Edit Profile - Coming Soon").font(BreitlingFonts.title2))
                
                
            case .collectionFilter(let collectionId):
                AnyView(NavigationCollectionFilterView(collectionId: collectionId))
                
            // Heritage and content
            case .heritageStory(let storyId):
                AnyView(HeritageStoryView(storyId: storyId))
                
            case .brandContent(let contentId):
                AnyView(BrandContentView(contentId: contentId))
                
            // Support and services
            case .customerSupport:
                AnyView(CustomerSupportView())
                
            case .warrantyRegistration(let productId):
                AnyView(WarrantyRegistrationView(productId: productId))
                
            case .serviceRequest(let productId):
                AnyView(ServiceRequestView(productId: productId))
                
            // Premium features
            case .exclusiveContent:
                AnyView(ExclusiveContentView())
                
            case .limitedEditions:
                AnyView(LimitedEditionsView())
                
            case .membershipBenefits:
                AnyView(MembershipBenefitsView())
                
            // Onboarding
            case .welcomeOnboarding:
                AnyView(WelcomeOnboardingView())
                
            case .stylePreferences:
                AnyView(StylePreferencesView())
                
            case .locationPermissions:
                AnyView(LocationPermissionsView())
                
            case .notificationPermissions:
                AnyView(NotificationPermissionsView())
                
                default:
                    AnyView(Text("Placeholder"))
            }
        }
        .navigationTitle(destination.title)
        .navigationBarTitleDisplayMode(.automatic)
    }
}

// MARK: - Placeholder Views (To be implemented in Phase 3)


//struct ProfileView: View {
//    var body: some View {
//        Text("Profile View - Coming Soon")
//            .font(BreitlingFonts.title2)
//            .foregroundColor(BreitlingColors.text)
//    }
//}


struct CollectionDetailView: View {
    let collectionId: String
    var body: some View {
        Text("Collection: \(collectionId)")
            .font(BreitlingFonts.title2)
    }
}

struct BoutiqueDetailView: View {
    let storeId: String
    var body: some View {
        Text("Boutique: \(storeId)")
            .font(BreitlingFonts.title2)
    }
}

struct AppointmentBookingView: View {
    let storeId: String
    var body: some View {
        Text("Book Appointment at: \(storeId)")
            .font(BreitlingFonts.title2)
    }
}

struct WatchConfiguratorView: View {
    let productId: String
    var body: some View {
        Text("Configure: \(productId)")
            .font(BreitlingFonts.title2)
    }
}

struct ARTryOnView: View {
    let productId: String
    var body: some View {
        Text("AR Try-On: \(productId)")
            .font(BreitlingFonts.title2)
    }
}

//struct OrderHistoryView: View {
//    var body: some View {
//        Text("Order History")
//            .font(BreitlingFonts.title2)
//    }
//}

struct OrderDetailView: View {
    let orderId: String
    var body: some View {
        Text("Order: \(orderId)")
            .font(BreitlingFonts.title2)
    }
}

struct WishlistDetailView: View {
    let wishlistId: String
    var body: some View {
        Text("Wishlist: \(wishlistId)")
            .font(BreitlingFonts.title2)
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings")
            .font(BreitlingFonts.title2)
    }
}

//struct EditProfileView: View {
//    var body: some View {
//        Text("Edit Profile")
//            .font(BreitlingFonts.title2)
//    }
//}

struct HeritageStoryView: View {
    let storyId: String
    var body: some View {
        Text("Heritage: \(storyId)")
            .font(BreitlingFonts.title2)
    }
}

struct BrandContentView: View {
    let contentId: String
    var body: some View {
        Text("Brand Content: \(contentId)")
            .font(BreitlingFonts.title2)
    }
}

struct CustomerSupportView: View {
    var body: some View {
        Text("Customer Support")
            .font(BreitlingFonts.title2)
    }
}

struct WarrantyRegistrationView: View {
    let productId: String
    var body: some View {
        Text("Warranty: \(productId)")
            .font(BreitlingFonts.title2)
    }
}

struct ServiceRequestView: View {
    let productId: String
    var body: some View {
        Text("Service: \(productId)")
            .font(BreitlingFonts.title2)
    }
}

struct ExclusiveContentView: View {
    var body: some View {
        Text("Exclusive Content")
            .font(BreitlingFonts.title2)
    }
}

struct LimitedEditionsView: View {
    var body: some View {
        Text("Limited Editions")
            .font(BreitlingFonts.title2)
    }
}

struct MembershipBenefitsView: View {
    var body: some View {
        Text("Membership Benefits")
            .font(BreitlingFonts.title2)
    }
}

struct WelcomeOnboardingView: View {
    var body: some View {
        Text("Welcome")
            .font(BreitlingFonts.title2)
    }
}

struct StylePreferencesView: View {
    var body: some View {
        Text("Style Preferences")
            .font(BreitlingFonts.title2)
    }
}

struct LocationPermissionsView: View {
    var body: some View {
        Text("Location Permissions")
            .font(BreitlingFonts.title2)
    }
}

struct NotificationPermissionsView: View {
    var body: some View {
        Text("Notification Permissions")
            .font(BreitlingFonts.title2)
    }
}

#Preview {
    MainTabView()
}
