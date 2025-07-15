//
//  PreferencesView.swift
//  BreitlingApp
//
//  Created by Arup Sarkar (TA) on 7/13/25.
//

// MARK: - Preferences View



import SwiftUI

// MARK: - Edit Profile View

struct EditProfileView: View {
    let user: User?
    let onSave: (User) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var location: String = ""
    @State private var street: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var zipCode: String = ""
    @State private var country: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Image Section
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(BreitlingColors.luxuryGold.opacity(0.1))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(BreitlingColors.luxuryGold)
                        }
                        
                        Button("Change Photo") {
                            // Handle photo change
                        }
                        .font(BreitlingFonts.callout)
                        .fontWeight(.medium)
                        .foregroundColor(BreitlingColors.navyBlue)
                    }
                    
                    // Personal Information
                    ProfileFormSection(title: "Personal Information") {
                        ProfileTextField(title: "Name", text: $name)
                        ProfileTextField(title: "Email", text: $email)
                        ProfileTextField(title: "Phone", text: $phoneNumber)
                        ProfileTextField(title: "Location", text: $location)
                    }
                    
                    // Address Information
                    ProfileFormSection(title: "Address") {
                        ProfileTextField(title:"Street", text: $street)
                        ProfileTextField(title: "City", text: $city)
                        ProfileTextField(title: "State/Province", text: $state)
                        ProfileTextField(title: "ZIP/Postal Code", text: $zipCode)
                        ProfileTextField(title: "Country", text: $country)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(BreitlingColors.background)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(BreitlingColors.navyBlue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(BreitlingColors.navyBlue)
                }
            }
        }
        .onAppear {
            loadUserData()
        }
    }
    
    private func loadUserData() {
        guard let user = user else { return }
        
        name = user.fullName
        email = user.email
        phoneNumber = user.profile.phoneNumber ?? ""
        location = user.profile.country
        street = ""
        city = ""
        state = ""
        zipCode = ""
        country = user.profile.country
    }
    
    private func saveProfile() {
        guard let existingUser = user else { return }
        
        let nameParts = name.split(separator: " ")
        let firstName = String(nameParts.first ?? "")
        let lastName = nameParts.count > 1 ? String(nameParts.dropFirst().joined(separator: " ")) : ""
        
        let updatedProfile = UserProfile(
            phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
            dateOfBirth: existingUser.profile.dateOfBirth,
            gender: existingUser.profile.gender,
            country: country,
            preferredLanguage: existingUser.profile.preferredLanguage,
            timeZone: existingUser.profile.timeZone,
            interests: existingUser.profile.interests,
            previousPurchases: existingUser.profile.previousPurchases,
            wishlistIds: existingUser.profile.wishlistIds,
            favoriteStoreIds: existingUser.profile.favoriteStoreIds
        )
        
        let updatedUser = User(
            id: existingUser.id,
            email: email,
            firstName: firstName,
            lastName: lastName,
            dateJoined: existingUser.dateJoined,
            membershipTier: existingUser.membershipTier,
            preferences: existingUser.preferences,
            profile: updatedProfile,
            isEmailVerified: existingUser.isEmailVerified,
            lastLoginDate: existingUser.lastLoginDate
        )
        
        onSave(updatedUser)
        dismiss()
    }
}

// MARK: - Preferences View

struct PreferencesView: View {
    let preferences: UserPreferences?
    let onSave: (UserPreferences) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var preferredCollections: Set<String> = []
    @State private var minPrice: Double = 1000
    @State private var maxPrice: Double = 50000
    @State private var preferredMaterials: Set<String> = []
    @State private var emailMarketing = true
    @State private var smsNotifications = false
    @State private var pushNotifications = true
    @State private var exclusiveOffers = true
    @State private var collectionUpdates = true
    @State private var appointmentReminders = true
    @State private var selectedLanguage = "en"
    @State private var selectedCurrency = "USD"
    
    @State private var stylePreferences: Set<StylePreference> = []
    @State private var occasionPreferences: Set<OccasionType> = []
    @State private var seasonalPreferences: Set<SeasonalStyle> = []
    @State private var newCollections = true
    @State private var limitedEditions = true
    @State private var appointments = true
    @State private var priceDrops = false
    @State private var personalizedRecommendations = true
    @State private var exclusiveEvents = true
    @State private var orderUpdates = true
    @State private var newsletterSubscription = false
    @State private var allowPersonalization = true
    @State private var allowLocationServices = true
    @State private var allowMarketingEmails = true
    
    private let collections = ["Navitimer", "Chronomat", "Superocean", "Premier", "Avenger", "Superocean Heritage"]
    private let materials = ["Steel", "Gold", "Titanium", "Ceramic", "Bronze"]
    private let languages = ["en": "English", "fr": "Français", "de": "Deutsch", "es": "Español"]
    private let currencies = ["USD": "US Dollar", "EUR": "Euro", "GBP": "British Pound", "CHF": "Swiss Franc"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Collection Preferences
                    ProfileFormSection(title: "Preferred Collections") {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(collections, id: \.self) { collection in
                                CollectionToggleCard(
                                    collection: collection,
                                    isSelected: preferredCollections.contains(collection)
                                ) {
                                    if preferredCollections.contains(collection) {
                                        preferredCollections.remove(collection)
                                    } else {
                                        preferredCollections.insert(collection)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Price Range
                    ProfileFormSection(title: "Price Range") {
                        VStack(spacing: 16) {
                            HStack {
                                Text("$\(Int(minPrice))")
                                    .font(BreitlingFonts.callout)
                                    .fontWeight(.medium)
                                Spacer()
                                Text("$\(Int(maxPrice))")
                                    .font(BreitlingFonts.callout)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(BreitlingColors.primaryText)
                            
                            // Dual slider would go here - simplified for demo
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Min: $\(Int(minPrice))")
                                        .font(BreitlingFonts.caption)
                                        .foregroundColor(BreitlingColors.secondaryText)
                                    Spacer()
                                }
                                Slider(value: $minPrice, in: 1000...25000, step: 500)
                                    .accentColor(BreitlingColors.navyBlue)
                                
                                HStack {
                                    Text("Max: $\(Int(maxPrice))")
                                        .font(BreitlingFonts.caption)
                                        .foregroundColor(BreitlingColors.secondaryText)
                                    Spacer()
                                }
                                Slider(value: $maxPrice, in: 5000...50000, step: 1000)
                                    .accentColor(BreitlingColors.navyBlue)
                            }
                        }
                    }
                    
                    // Material Preferences
                    ProfileFormSection(title: "Preferred Materials") {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(materials, id: \.self) { material in
                                MaterialToggleCard(
                                    material: material,
                                    isSelected: preferredMaterials.contains(material)
                                ) {
                                    if preferredMaterials.contains(material) {
                                        preferredMaterials.remove(material)
                                    } else {
                                        preferredMaterials.insert(material)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Communication Preferences
                    ProfileFormSection(title: "Communication Preferences") {
                        VStack(spacing: 16) {
                            PreferenceToggle(title: "Email Marketing", isOn: $emailMarketing)
                            PreferenceToggle(title: "SMS Notifications", isOn: $smsNotifications)
                            PreferenceToggle(title: "Push Notifications", isOn: $pushNotifications)
                            PreferenceToggle(title: "Exclusive Offers", isOn: $exclusiveOffers)
                            PreferenceToggle(title: "Collection Updates", isOn: $collectionUpdates)
                            PreferenceToggle(title: "Appointment Reminders", isOn: $appointmentReminders)
                        }
                    }
                    
                    // Language & Currency
                    ProfileFormSection(title: "Language & Currency") {
                        VStack(spacing: 16) {
                            ProfilePicker(title: "Language", selection: $selectedLanguage, options: languages)
                            ProfilePicker(title: "Currency", selection: $selectedCurrency, options: currencies)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(BreitlingColors.background)
            .navigationTitle("Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(BreitlingColors.navyBlue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        savePreferences()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(BreitlingColors.navyBlue)
                }
            }
        }
        .onAppear {
            loadPreferences()
        }
    }
    
    private func loadPreferences() {
        guard let prefs = preferences else { return }
        
        preferredCollections = Set(prefs.preferredCollections)
        minPrice = prefs.priceRange.min
        maxPrice = prefs.priceRange.max
        preferredMaterials = Set(prefs.preferredMaterials)
        stylePreferences = Set(prefs.stylePreferences)
        occasionPreferences = Set(prefs.occasionPreferences)
        seasonalPreferences = Set(prefs.seasonalPreferences)
        
        let notifications = prefs.notifications
        newCollections = notifications.newCollections
        limitedEditions = notifications.limitedEditions
        appointments = notifications.appointments
        priceDrops = notifications.priceDrops
        personalizedRecommendations = notifications.personalizedRecommendations
        exclusiveEvents = notifications.exclusiveEvents
        orderUpdates = notifications.orderUpdates
        newsletterSubscription = notifications.newsletterSubscription
        
        allowPersonalization = prefs.allowPersonalization
        allowLocationServices = prefs.allowLocationServices
        allowMarketingEmails = prefs.allowMarketingEmails
    }
    
    private func savePreferences() {
        let newPreferences = UserPreferences(
            preferredCollections: Array(preferredCollections),
            priceRange: PriceRange(min: minPrice, max: maxPrice, currency: "USD"),
            preferredMaterials: Array(preferredMaterials),
            stylePreferences: Array(stylePreferences),
            notifications: NotificationPreferences(
                newCollections: newCollections,
                limitedEditions: limitedEditions,
                appointments: appointments,
                priceDrops: priceDrops,
                personalizedRecommendations: personalizedRecommendations,
                exclusiveEvents: exclusiveEvents,
                orderUpdates: orderUpdates,
                newsletterSubscription: newsletterSubscription
            ),
            occasionPreferences: Array(occasionPreferences),
            seasonalPreferences: Array(seasonalPreferences),
            allowPersonalization: allowPersonalization,
            allowLocationServices: allowLocationServices,
            allowMarketingEmails: allowMarketingEmails
        )
        
        onSave(newPreferences)
        dismiss()
    }
}

// MARK: - Order History View

struct OrderHistoryView: View {
    @StateObject private var viewModel = OrderHistoryViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.orders.isEmpty {
                    EmptyOrderHistoryView()
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.orders) { order in
                            OrderHistoryCard(order: order)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .background(BreitlingColors.background)
            .navigationTitle("Order History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(BreitlingColors.navyBlue)
                }
            }
        }
        .onAppear {
            viewModel.loadOrders()
        }
    }
}

// MARK: - Watch Registry View

struct WatchRegistryView: View {
    @StateObject private var viewModel = WatchRegistryViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Add Watch Button
                    Button(action: {
                        viewModel.showingAddWatch = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(BreitlingColors.luxuryGold)
                            
                            Text("Register New Watch")
                                .font(BreitlingFonts.callout)
                                .fontWeight(.medium)
                                .foregroundColor(BreitlingColors.primaryText)
                            
                            Spacer()
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(BreitlingColors.cardBackground)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Registered Watches
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if viewModel.registeredWatches.isEmpty {
                        EmptyRegistryView()
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.registeredWatches) { watch in
                                RegisteredWatchCard(watch: watch)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(BreitlingColors.background)
            .navigationTitle("Watch Registry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(BreitlingColors.navyBlue)
                }
            }
        }
        .sheet(isPresented: $viewModel.showingAddWatch) {
            AddWatchView { watch in
                viewModel.registerWatch(watch)
            }
        }
        .onAppear {
            viewModel.loadRegisteredWatches()
        }
    }
}

// MARK: - Support View

struct SupportView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Contact Options
                    ProfileFormSection(title: "Contact Options") {
                        VStack(spacing: 0) {
                            SupportMenuItem(
                                icon: "phone.fill",
                                title: "Call Customer Service",
                                subtitle: "+1 (800) BREITLING",
                                color: BreitlingColors.navyBlue
                            ) {
                                // Handle phone call
                            }
                            
                            Divider().padding(.leading, 52)
                            
                            SupportMenuItem(
                                icon: "message.fill",
                                title: "Live Chat",
                                subtitle: "Available 24/7",
                                color: BreitlingColors.luxuryGold
                            ) {
                                // Handle live chat
                            }
                            
                            Divider().padding(.leading, 52)
                            
                            SupportMenuItem(
                                icon: "envelope.fill",
                                title: "Email Support",
                                subtitle: "support@breitling.com",
                                color: BreitlingColors.navyBlue
                            ) {
                                // Handle email
                            }
                        }
                    }
                    
                    // FAQ & Resources
                    ProfileFormSection(title: "Resources") {
                        VStack(spacing: 0) {
                            SupportMenuItem(
                                icon: "questionmark.circle.fill",
                                title: "Frequently Asked Questions",
                                subtitle: "Find answers to common questions",
                                color: BreitlingColors.navyBlue
                            ) {
                                // Handle FAQ
                            }
                            
                            Divider().padding(.leading, 52)
                            
                            SupportMenuItem(
                                icon: "book.fill",
                                title: "User Manual",
                                subtitle: "Download watch manuals",
                                color: BreitlingColors.luxuryGold
                            ) {
                                // Handle manual download
                            }
                            
                            Divider().padding(.leading, 52)
                            
                            SupportMenuItem(
                                icon: "wrench.and.screwdriver.fill",
                                title: "Service Centers",
                                subtitle: "Find authorized service locations",
                                color: BreitlingColors.navyBlue
                            ) {
                                // Handle service centers
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(BreitlingColors.background)
            .navigationTitle("Customer Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(BreitlingColors.navyBlue)
                }
            }
        }
    }
}

// MARK: - Supporting Components

struct ProfileFormSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(BreitlingFonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(BreitlingColors.primaryText)
                .padding(.horizontal, 4)
            
            content
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(BreitlingColors.cardBackground)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                )
        }
    }
}

struct ProfileTextField: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(BreitlingFonts.callout)
                .fontWeight(.medium)
                .foregroundColor(BreitlingColors.primaryText)
            
            TextField(title, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct CollectionToggleCard: View {
    let collection: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(collection)
                .font(BreitlingFonts.callout)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : BreitlingColors.primaryText)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? BreitlingColors.navyBlue : Color.gray.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MaterialToggleCard: View {
    let material: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(material)
                .font(BreitlingFonts.callout)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : BreitlingColors.primaryText)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? BreitlingColors.luxuryGold : Color.gray.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PreferenceToggle: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(BreitlingFonts.callout)
                .foregroundColor(BreitlingColors.primaryText)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: BreitlingColors.navyBlue))
        }
    }
}

struct ProfilePicker: View {
    let title: String
    @Binding var selection: String
    let options: [String: String]
    
    var body: some View {
        HStack {
            Text(title)
                .font(BreitlingFonts.callout)
                .foregroundColor(BreitlingColors.primaryText)
            
            Spacer()
            
            Picker(title, selection: $selection) {
                ForEach(Array(options.keys), id: \.self) { key in
                    Text(options[key] ?? key).tag(key)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
}

struct SupportMenuItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(BreitlingFonts.callout)
                        .fontWeight(.medium)
                        .foregroundColor(BreitlingColors.primaryText)
                    
                    Text(subtitle)
                        .font(BreitlingFonts.caption)
                        .foregroundColor(BreitlingColors.secondaryText)
                }
                
                Spacer()
                
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

// MARK: - Empty State Views

struct EmptyOrderHistoryView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "bag.circle")
                .font(.system(size: 60))
                .foregroundColor(BreitlingColors.secondaryText)
            
            Text("No Orders Yet")
                .font(BreitlingFonts.title2)
                .fontWeight(.semibold)
                .foregroundColor(BreitlingColors.primaryText)
            
            Text("Your purchase history will appear here")
                .font(BreitlingFonts.callout)
                .foregroundColor(BreitlingColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

struct EmptyRegistryView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "stopwatch.circle")
                .font(.system(size: 60))
                .foregroundColor(BreitlingColors.secondaryText)
            
            Text("No Watches Registered")
                .font(BreitlingFonts.title2)
                .fontWeight(.semibold)
                .foregroundColor(BreitlingColors.primaryText)
            
            Text("Register your Breitling watches for warranty and service tracking")
                .font(BreitlingFonts.callout)
                .foregroundColor(BreitlingColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

// MARK: - Placeholder ViewModels

class OrderHistoryViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var isLoading = false
    
    func loadOrders() {
        isLoading = true
        // Simulate loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.orders = [] // Mock empty for demo
            self.isLoading = false
        }
    }
}

class WatchRegistryViewModel: ObservableObject {
    @Published var registeredWatches: [Product] = []
    @Published var isLoading = false
    @Published var showingAddWatch = false
    
    func loadRegisteredWatches() {
        isLoading = true
        // Simulate loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.registeredWatches = [] // Mock empty for demo
            self.isLoading = false
        }
    }
    
    func registerWatch(_ watch: Product) {
        registeredWatches.append(watch)
    }
}

// MARK: - Placeholder Views

struct OrderHistoryCard: View {
    let order: Order
    
    var body: some View {
        Text("Order Card Placeholder")
    }
}

struct RegisteredWatchCard: View {
    let watch: Product
    
    var body: some View {
        Text("Watch Card Placeholder")
    }
}

struct AddWatchView: View {
    let onSave: (Product) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Text("Add Watch Form Placeholder")
                .navigationTitle("Register Watch")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") { dismiss() }
                    }
                }
        }
    }
}
