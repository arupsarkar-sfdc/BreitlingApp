//
//  ProfileView.swift
//  BreitlingApp
//
//  Created by Arup Sarkar (TA) on 7/13/25.
//

//
//  ProfileView.swift
//  BreitlingApp
//
//  Luxury Profile & Account Management
//  Swiss precision meets modern elegance
//

import SwiftUI

struct ProfileView: View {
    @Environment(NavigationRouter.self) private var router
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingEditProfile = false
    @State private var showingPreferences = false
    @State private var showingOrderHistory = false
    @State private var showingWatchRegistry = false
    @State private var showingSupport = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    ProfileHeaderView(
                        user: viewModel.currentUser,
                        onEditTap: { showingEditProfile = true }
                    )
                    
                    // Membership Status
                    if let membership = viewModel.currentUser?.membershipTier {
                        MembershipCardView(membership: membership)
                    }
                    
                    // Quick Actions
                    QuickActionsGrid(
                        onOrderHistoryTap: { showingOrderHistory = true
 },
                        onWatchRegistryTap: { showingWatchRegistry = true },
                        onBoutiqueTap: {
                            print("Navigate to boutiques")
                        },
                        onSupportTap: { showingSupport = true }
                    )
                    
                    // Account Sections
                    VStack(spacing: 16) {
                        ProfileSectionView(
                            title: "Account & Preferences",
                            items: [
                                ProfileMenuItem(
                                    title: "Personal Information",
                                    subtitle: "Manage your profile details",
                                    icon: "person.circle",
                                    action: { showingEditProfile = true }
                                ),
                                ProfileMenuItem(
                                    title: "Preferences & Personalization",
                                    subtitle: "Customize your Breitling experience",
                                    icon: "slider.horizontal.3",
                                    action: { showingPreferences = true }
                                ),
                                ProfileMenuItem(
                                    title: "Notifications",
                                    subtitle: "Collection updates and exclusives",
                                    icon: "bell",
                                    action: { router.navigate(to: .settings) }
                                )
                            ]
                        )
                        
                        ProfileSectionView(
                            title: "My Breitling Collection",
                            items: [
                                ProfileMenuItem(
                                    title: "Watch Registry",
                                    subtitle: "\(viewModel.registeredWatchesCount) watches registered",
                                    icon: "stopwatch",
                                    action: { showingWatchRegistry = true }
                                ),
                                ProfileMenuItem(
                                    title: "Wishlist",
                                    subtitle: "\(viewModel.currentUser?.profile.wishlistIds.count ?? 0) saved timepieces",
                                    icon: "heart",
                                    action: { router.navigate(to: .wishlistDetail(wishlistId: "default")) }
                                ),
                                ProfileMenuItem(
                                    title: "Purchase History",
                                    subtitle: "Your luxury acquisitions",
                                    icon: "bag",
                                    action: { showingOrderHistory = true }
                                )
                            ]
                        )
                        
                        ProfileSectionView(
                            title: "Breitling Experience",
                            items: [
                                ProfileMenuItem(
                                    title: "Boutique Services",
                                    subtitle: "Find boutiques and book appointments",
                                    icon: "building.2",
                                    action: {
                                        router
                                            .navigate(
                                                to: .boutiqueDetail(storeId: "")
                                            )
                                    }
                                ),
                                ProfileMenuItem(
                                    title: "Heritage & Stories",
                                    subtitle: "Discover Breitling's legacy",
                                    icon: "book.closed",
                                    action: {
                                        router
                                            .navigate(
                                                to: .heritageStory(storyId: "12345")
                                            )
                                    }
                                ),
//                                ProfileMenuItem(
//                                    title: "Exclusive Events",
//                                    subtitle: "Member-only experiences",
//                                    icon: "star.circle",
//                                    action: { router.navigate(to: ) }
//                                )
                            ]
                        )
                        
                        ProfileSectionView(
                            title: "Support & Services",
                            items: [
                                ProfileMenuItem(
                                    title: "Customer Support",
                                    subtitle: "Premium assistance available",
                                    icon: "headphones",
                                    action: { showingSupport = true }
                                ),
//                                ProfileMenuItem(
//                                    title: "Service Center",
//                                    subtitle: "Maintenance and repairs",
//                                    icon: "wrench.and.screwdriver",
//                                    action: { router.navigate(to: .ser) }
//                                ),
//                                ProfileMenuItem(
//                                    title: "Warranty & Authentication",
//                                    subtitle: "Verify and protect your investment",
//                                    icon: "checkmark.shield",
//                                    action: { router.navigate(to: .warranty) }
//                                )
                            ]
                        )
                    }
                    
                    // App Information
                    AppInfoSection()
                    
                    // Sign Out
                    SignOutButton {
                        viewModel.signOut()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(BreitlingColors.background)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(user: viewModel.currentUser) { updatedUser in
                viewModel.updateUser(updatedUser)
            }
        }
        .sheet(isPresented: $showingPreferences) {
            PreferencesView(preferences: viewModel.currentUser?.preferences) { preferences in
                viewModel.updatePreferences(preferences)
            }
        }
        .sheet(isPresented: $showingOrderHistory) {
            OrderHistoryView()
        }
        .sheet(isPresented: $showingWatchRegistry) {
            WatchRegistryView()
        }
        .sheet(isPresented: $showingSupport) {
            SupportView()
        }
        .onAppear {
            viewModel.loadUserData()
        }
    }
}

// MARK: - Profile Header Component

struct ProfileHeaderView: View {
    let user: User?
    let onEditTap: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Profile Image and Basic Info
            HStack(spacing: 16) {
                // Profile Avatar
                ZStack {
                    Circle()
                        .fill(BreitlingColors.luxuryGold.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    // Use initials as placeholder
                    Text(user?.initials ?? "GU")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(BreitlingColors.luxuryGold)
                }
                
                // User Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(user?.fullName ?? "Guest User")
                        .font(BreitlingFonts.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(BreitlingColors.primaryText)
                    
                    Text(user?.email ?? "Not signed in")
                        .font(BreitlingFonts.callout)
                        .foregroundColor(BreitlingColors.secondaryText)
                    
                    if let user = user {
                        HStack(spacing: 4) {
                            Image(systemName: "location")
                                .font(.caption)
                                .foregroundColor(BreitlingColors.navyBlue)
                            
                            Text(user.profile.country)
                                .font(BreitlingFonts.caption)
                                .foregroundColor(BreitlingColors.secondaryText)
                        }
                    }
                }
                
                Spacer()
                
                // Edit Button
                Button(action: onEditTap) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(BreitlingColors.navyBlue)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(BreitlingColors.cardBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Membership Card Component

struct MembershipCardView: View {
    let membership: MembershipTier
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Breitling \(membership.displayName)")
                        .font(BreitlingFonts.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(membershipDescription)
                        .font(BreitlingFonts.callout)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                membershipIcon
            }
            
            // Membership Benefits
            if !membership.benefits.isEmpty {
                HStack {
                    ForEach(membership.benefits.prefix(3), id: \.self) { benefit in
                        Text(benefit)
                            .font(BreitlingFonts.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(membershipGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var membershipGradient: LinearGradient {
        switch membership {
        case .explorer:
            return LinearGradient(
                colors: [Color.gray, Color(red: 0.5, green: 0.5, blue: 0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .classic:
            return LinearGradient(
                colors: [BreitlingColors.navyBlue, Color(red: 0.1, green: 0.2, blue: 0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .premier:
            return LinearGradient(
                colors: [BreitlingColors.luxuryGold, Color(red: 0.8, green: 0.6, blue: 0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .exclusive:
            return LinearGradient(
                colors: [Color.black, Color(red: 0.2, green: 0.2, blue: 0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var membershipIcon: some View {
        Image(systemName: membership == .exclusive ? "crown.fill" : "star.fill")
            .font(.title)
            .foregroundColor(.white)
    }
    
    private var membershipDescription: String {
        switch membership {
        case .explorer: return "Welcome to the Breitling family"
        case .classic: return "Elevated luxury experiences"
        case .premier: return "Premium collector privileges"
        case .exclusive: return "Ultimate connoisseur status"
        }
    }
}

// MARK: - Quick Actions Grid

struct QuickActionsGrid: View {
    let onOrderHistoryTap: () -> Void
    let onWatchRegistryTap: () -> Void
    let onBoutiqueTap: () -> Void
    let onSupportTap: () -> Void
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            QuickActionCard(
                icon: "bag.circle.fill",
                title: "Orders",
                color: BreitlingColors.navyBlue,
                action: onOrderHistoryTap
            )
            
            QuickActionCard(
                icon: "stopwatch.fill",
                title: "Registry",
                color: BreitlingColors.luxuryGold,
                action: onWatchRegistryTap
            )
            
            QuickActionCard(
                icon: "building.2.fill",
                title: "Boutiques",
                color: BreitlingColors.navyBlue,
                action: onBoutiqueTap
            )
            
            QuickActionCard(
                icon: "headphones.circle.fill",
                title: "Support",
                color: BreitlingColors.luxuryGold,
                action: onSupportTap
            )
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(BreitlingFonts.caption)
                    .fontWeight(.medium)
                    .foregroundColor(BreitlingColors.primaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(BreitlingColors.cardBackground)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Profile Section Component

struct ProfileSectionView: View {
    let title: String
    let items: [ProfileMenuItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(BreitlingFonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(BreitlingColors.primaryText)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    ProfileMenuItemView(item: item)
                    
                    if index < items.count - 1 {
                        Divider()
                            .padding(.leading, 52)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(BreitlingColors.cardBackground)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
    }
}

struct ProfileMenuItem {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void
}

struct ProfileMenuItemView: View {
    let item: ProfileMenuItem
    
    var body: some View {
        Button(action: item.action) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: item.icon)
                    .font(.title3)
                    .foregroundColor(BreitlingColors.navyBlue)
                    .frame(width: 24, height: 24)
                
                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(BreitlingFonts.callout)
                        .fontWeight(.medium)
                        .foregroundColor(BreitlingColors.primaryText)
                    
                    Text(item.subtitle)
                        .font(BreitlingFonts.caption)
                        .foregroundColor(BreitlingColors.secondaryText)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(BreitlingColors.secondaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - App Info Section

struct AppInfoSection: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("App Information")
                .font(BreitlingFonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(BreitlingColors.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                AppInfoItem(title: "Version", value: "1.0.0")
                Divider().padding(.leading, 16)
                AppInfoItem(title: "Privacy Policy", value: "", hasChevron: true) {
                    // Handle privacy policy
                }
                Divider().padding(.leading, 16)
                AppInfoItem(title: "Terms of Service", value: "", hasChevron: true) {
                    // Handle terms of service
                }
                Divider().padding(.leading, 16)
                AppInfoItem(title: "About Breitling", value: "", hasChevron: true) {
                    // Handle about
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(BreitlingColors.cardBackground)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
    }
}

struct AppInfoItem: View {
    let title: String
    let value: String
    var hasChevron: Bool = false
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: action ?? {}) {
            HStack {
                Text(title)
                    .font(BreitlingFonts.callout)
                    .foregroundColor(BreitlingColors.primaryText)
                
                Spacer()
                
                if !value.isEmpty {
                    Text(value)
                        .font(BreitlingFonts.callout)
                        .foregroundColor(BreitlingColors.secondaryText)
                }
                
                if hasChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(BreitlingColors.secondaryText)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil)
    }
}

// MARK: - Sign Out Button

struct SignOutButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Sign Out")
                .font(BreitlingFonts.callout)
                .fontWeight(.medium)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(BreitlingColors.cardBackground)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ProfileView()
        .environment(NavigationRouter())
}
