//
//  SearchView.swift
//  BreitlingApp
//
//  Created by Arup Sarkar (TA) on 7/10/25.
//
//
//  Advanced search functionality with filters, suggestions, and luxury design
//

import SwiftUI

struct SearchView: View {
    @Environment(NavigationRouter.self) private var router
    @StateObject private var viewModel = SearchViewModel()
    @State private var showingAdvancedFilters = false
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Header
                SearchHeader(
                    searchText: $viewModel.searchText,
                    isSearchFocused: $isSearchFocused,
                    showingAdvancedFilters: $showingAdvancedFilters,
                    hasActiveFilters: viewModel.hasActiveFilters,
                    onClearSearch: {
                        viewModel.clearSearch()
                    }
                )
                
                // Search Content
                SearchContent(
                    searchState: viewModel.searchState,
                    searchResults: viewModel.searchResults,
                    recentSearches: viewModel.recentSearches,
                    searchSuggestions: viewModel.searchSuggestions,
                    trendingSearches: viewModel.trendingSearches,
                    isSearchFocused: isSearchFocused,
                    onSearchTap: { searchTerm in
                        viewModel.performSearch(searchTerm)
                        isSearchFocused = false
                    },
                    onProductTap: { product in
                        router.showProduct(product.id)
                    },
                    onClearRecentSearches: {
                        viewModel.clearRecentSearches()
                    }
                )
            }
            .background(BreitlingColors.background)
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAdvancedFilters) {
                AdvancedFiltersSheet(
                    filters: $viewModel.advancedFilters,
                    onApply: {
                        viewModel.applyAdvancedFilters()
                    }
                )
            }
        }
        .onAppear {
            viewModel.loadInitialData()
        }
        .onChange(of: viewModel.searchText) { _ in
            viewModel.handleSearchTextChange()
        }
    }
}

// MARK: - Search Header

struct SearchHeader: View {
    @Binding var searchText: String
    @FocusState.Binding var isSearchFocused: Bool
    @Binding var showingAdvancedFilters: Bool
    let hasActiveFilters: Bool
    let onClearSearch: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                // Enhanced Search Bar
                EnhancedSearchBar(
                    text: $searchText,
                    isSearchFocused: $isSearchFocused,
                    onClear: onClearSearch
                )
                
                // Advanced Filters Button
                AdvancedFiltersButton(
                    hasActiveFilters: hasActiveFilters,
                    action: {
                        showingAdvancedFilters = true
                    }
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .background(BreitlingColors.background)
    }
}

struct EnhancedSearchBar: View {
    @Binding var text: String
    @FocusState.Binding var isSearchFocused: Bool
    let onClear: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(isSearchFocused ? BreitlingColors.navyBlue : BreitlingColors.textSecondary)
            
            TextField("Search watches, collections, features...", text: $text)
                .font(BreitlingFonts.body)
                .foregroundColor(BreitlingColors.text)
                .focused($isSearchFocused)
                .submitLabel(.search)
            
            if !text.isEmpty {
                Button(action: onClear) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(BreitlingColors.textSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(BreitlingColors.cardBackground)
                .stroke(
                    isSearchFocused ? BreitlingColors.navyBlue : BreitlingColors.divider,
                    lineWidth: isSearchFocused ? 2 : 1
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isSearchFocused)
    }
}

struct AdvancedFiltersButton: View {
    let hasActiveFilters: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(hasActiveFilters ? .white : BreitlingColors.navyBlue)
                
                if hasActiveFilters {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .offset(x: 8, y: -8)
                }
            }
            .frame(width: 48, height: 48)
            .background(hasActiveFilters ? BreitlingColors.navyBlue : BreitlingColors.cardBackground)
            .cornerRadius(12)
            .shadow(
                color: hasActiveFilters ? BreitlingColors.navyBlue.opacity(0.3) : Color.clear,
                radius: hasActiveFilters ? 4 : 0,
                y: hasActiveFilters ? 2 : 0
            )
        }
    }
}

// MARK: - Search Content

struct SearchContent: View {
    let searchState: SearchState
    let searchResults: [Product]
    let recentSearches: [String]
    let searchSuggestions: [String]
    let trendingSearches: [TrendingSearch]
    let isSearchFocused: Bool
    let onSearchTap: (String) -> Void
    let onProductTap: (Product) -> Void
    let onClearRecentSearches: () -> Void
    
    var body: some View {
        Group {
            switch searchState {
            case .idle:
                SearchIdleView(
                    recentSearches: recentSearches,
                    trendingSearches: trendingSearches,
                    onSearchTap: onSearchTap,
                    onClearRecentSearches: onClearRecentSearches
                )
                
            case .searching:
                SearchSuggestionsView(
                    suggestions: searchSuggestions,
                    onSearchTap: onSearchTap
                )
                
            case .loading:
                SearchLoadingView()
                
            case .results:
                InternalSearchResultsView(
//                    query: "",
//                    filters: nil,
                    results: searchResults,
                    onProductTap: onProductTap                    
                )
                
            case .noResults:
                SearchNoResultsView()
                
            case .error(let message):
                SearchErrorView(message: message)
            }
        }
    }
}

// MARK: - Search States

struct SearchIdleView: View {
    let recentSearches: [String]
    let trendingSearches: [TrendingSearch]
    let onSearchTap: (String) -> Void
    let onClearRecentSearches: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Recent Searches
                if !recentSearches.isEmpty {
                    SearchSection(title: "Recent Searches") {
                        VStack(spacing: 12) {
                            ForEach(recentSearches, id: \.self) { search in
                                RecentSearchRow(
                                    search: search,
                                    onTap: { onSearchTap(search) }
                                )
                            }
                            
                            Button("Clear Recent Searches") {
                                onClearRecentSearches()
                            }
                            .font(BreitlingFonts.callout)
                            .foregroundColor(BreitlingColors.textSecondary)
                            .padding(.top, 8)
                        }
                    }
                }
                
                // Trending Searches
                SearchSection(title: "Trending Now") {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(trendingSearches, id: \.id) { trending in
                            TrendingSearchCard(
                                trending: trending,
                                onTap: { onSearchTap(trending.term) }
                            )
                        }
                    }
                }
                
                // Quick Categories
                SearchSection(title: "Browse by Category") {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(SearchCategory.allCases, id: \.self) { category in
                            CategoryCard(
                                category: category,
                                onTap: { onSearchTap(category.searchTerm) }
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
}

struct SearchSuggestionsView: View {
    let suggestions: [String]
    let onSearchTap: (String) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(suggestions, id: \.self) { suggestion in
                    SuggestionRow(
                        suggestion: suggestion,
                        onTap: { onSearchTap(suggestion) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
}

struct InternalSearchResultsView: View {
//    let query: String
//    let filters: SearchFilters?
    let results: [Product]
    let onProductTap: (Product) -> Void
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Results count
                HStack {
                    Text("\(results.count) \(results.count == 1 ? "result" : "results") found")
                        .font(BreitlingFonts.callout)
                        .foregroundColor(BreitlingColors.textSecondary)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                // Results grid
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(results, id: \.id) { product in
                        ElevatedProductGridCard(product: product)
                            .onTapGesture {
                                onProductTap(product)
                            }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 16)
        }
    }
}

struct SearchLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: BreitlingColors.navyBlue))
                .scaleEffect(1.2)
            
            Text("Searching...")
                .font(BreitlingFonts.body)
                .foregroundColor(BreitlingColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
}

struct SearchNoResultsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(BreitlingColors.textSecondary)
            
            Text("No Results Found")
                .font(BreitlingFonts.title3)
                .foregroundColor(BreitlingColors.text)
                .fontWeight(.medium)
            
            Text("Try adjusting your search terms or browse our collections")
                .font(BreitlingFonts.body)
                .foregroundColor(BreitlingColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
}

struct SearchErrorView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(BreitlingColors.textSecondary)
            
            Text("Search Error")
                .font(BreitlingFonts.title3)
                .foregroundColor(BreitlingColors.text)
                .fontWeight(.medium)
            
            Text(message)
                .font(BreitlingFonts.body)
                .foregroundColor(BreitlingColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
}

// MARK: - Supporting Views

struct SearchSection: View {
    let title: String
    let content: AnyView
    
    init(title: String, @ViewBuilder content: () -> some View) {
        self.title = title
        self.content = AnyView(content())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(BreitlingFonts.title3)
                .foregroundColor(BreitlingColors.text)
                .fontWeight(.semibold)
            
            content
        }
    }
}

struct RecentSearchRow: View {
    let search: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 16))
                    .foregroundColor(BreitlingColors.textSecondary)
                
                Text(search)
                    .font(BreitlingFonts.body)
                    .foregroundColor(BreitlingColors.text)
                
                Spacer()
                
                Image(systemName: "arrow.up.left")
                    .font(.system(size: 14))
                    .foregroundColor(BreitlingColors.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(BreitlingColors.cardBackground)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TrendingSearchCard: View {
    let trending: TrendingSearch
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    Text("#\(trending.rank)")
                        .font(BreitlingFonts.caption)
                        .foregroundColor(BreitlingColors.textSecondary)
                }
                
                Text(trending.term)
                    .font(BreitlingFonts.callout)
                    .foregroundColor(BreitlingColors.text)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(BreitlingColors.cardBackground)
                    .shadow(
                        color: Color.black.opacity(0.05),
                        radius: 4,
                        y: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CategoryCard: View {
    let category: SearchCategory
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: category.iconName)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(BreitlingColors.navyBlue)
                
                Text(category.displayName)
                    .font(BreitlingFonts.callout)
                    .foregroundColor(BreitlingColors.text)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(BreitlingColors.cardBackground)
                    .shadow(
                        color: Color.black.opacity(0.05),
                        radius: 4,
                        y: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SuggestionRow: View {
    let suggestion: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundColor(BreitlingColors.textSecondary)
                
                Text(suggestion)
                    .font(BreitlingFonts.body)
                    .foregroundColor(BreitlingColors.text)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(BreitlingColors.cardBackground)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Advanced Filters Sheet

struct AdvancedFiltersSheet: View {
    @Binding var filters: AdvancedSearchFilters
    let onApply: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Collection Filter
                    BoutiqueFilterSection(title: "Collections") {
                        CollectionFilterView(selectedCollections: $filters.collections)
                    }
                    
                    // Price Range
                    BoutiqueFilterSection(title: "Price Range") {
                        PriceRangeSlider(range: $filters.priceRange)
                    }
                    
                    // Materials
                    BoutiqueFilterSection(title: "Materials") {
                        MaterialSelector(selectedMaterials: $filters.materials)
                    }
                    
                    // Functions
                    BoutiqueFilterSection(title: "Functions") {
                        FunctionSelector(selectedFunctions: $filters.functions)
                    }
                    
                    // Availability
                    BoutiqueFilterSection(title: "Availability") {
                        AvailabilitySelector(selectedAvailability: $filters.availability)
                    }
                }
                .padding(20)
            }
            .navigationTitle("Advanced Filters")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        filters = AdvancedSearchFilters()
                    }
                    .foregroundColor(BreitlingColors.navyBlue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        onApply()
                        dismiss()
                    }
                    .foregroundColor(BreitlingColors.navyBlue)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct BoutiqueFilterSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(BreitlingFonts.callout)
                .foregroundColor(BreitlingColors.text)
                .fontWeight(.semibold)
            
            content
        }
    }
}

struct CollectionFilterView: View {
    @Binding var selectedCollections: [String]
    
    private let collections = Collection.mockCollections
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 8) {
            ForEach(collections, id: \.id) { collection in
                FilterChip(
                    title: collection.name,
                    isSelected: selectedCollections.contains(collection.id),
                    onTap: {
                        if selectedCollections.contains(collection.id) {
                            selectedCollections.removeAll { $0 == collection.id }
                        } else {
                            selectedCollections.append(collection.id)
                        }
                    }
                )
            }
        }
    }
}

struct FunctionSelector: View {
    @Binding var selectedFunctions: [String]
    
    private let functions = ["Chronograph", "GMT", "Date", "Moon Phase", "Power Reserve", "Alarm"]
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 8) {
            ForEach(functions, id: \.self) { function in
                FilterChip(
                    title: function,
                    isSelected: selectedFunctions.contains(function),
                    onTap: {
                        if selectedFunctions.contains(function) {
                            selectedFunctions.removeAll { $0 == function }
                        } else {
                            selectedFunctions.append(function)
                        }
                    }
                )
            }
        }
    }
}

struct FilterChip: View {
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

// MARK: - Data Models

enum SearchState: Equatable {
    case idle
    case searching
    case loading
    case results
    case noResults
    case error(String)
}

struct TrendingSearch: Identifiable {
    let id = UUID()
    let term: String
    let rank: Int
}

enum SearchCategory: CaseIterable {
    case aviation
    case diving
    case chronograph
    case luxury
    case limited
    case new
    
    var displayName: String {
        switch self {
        case .aviation: return "Aviation"
        case .diving: return "Diving"
        case .chronograph: return "Chronograph"
        case .luxury: return "Luxury"
        case .limited: return "Limited Edition"
        case .new: return "New Arrivals"
        }
    }
    
    var iconName: String {
        switch self {
        case .aviation: return "airplane"
        case .diving: return "drop.fill"
        case .chronograph: return "stopwatch"
        case .luxury: return "crown.fill"
        case .limited: return "star.fill"
        case .new: return "sparkles"
        }
    }
    
    var searchTerm: String {
        return displayName.lowercased()
    }
}

struct AdvancedSearchFilters {
    var collections: [String] = []
    var priceRange: ClosedRange<Double>? = nil
    var materials: [String] = []
    var functions: [String] = []
    var availability: [ProductAvailability] = []
}

// MARK: - Search View Model

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchState: SearchState = .idle
    @Published var searchResults: [Product] = []
    @Published var recentSearches: [String] = []
    @Published var searchSuggestions: [String] = []
    @Published var trendingSearches: [TrendingSearch] = []
    @Published var advancedFilters = AdvancedSearchFilters()
    
    private var allProducts: [Product] = []
    private var searchTask: Task<Void, Never>?
    
    var hasActiveFilters: Bool {
        !advancedFilters.collections.isEmpty ||
        advancedFilters.priceRange != nil ||
        !advancedFilters.materials.isEmpty ||
        !advancedFilters.functions.isEmpty ||
        !advancedFilters.availability.isEmpty
    }
    
    func loadInitialData() {
        loadMockData()
    }
    
    func handleSearchTextChange() {
        searchTask?.cancel()
        
        if searchText.isEmpty {
            searchState = .idle
            searchSuggestions = []
            return
        }
        
        if searchText.count < 2 {
            searchState = .searching
            generateSuggestions()
            return
        }
        
        searchTask = Task {
            await performDelayedSearch()
        }
    }
    
    func performSearch(_ term: String) {
        searchText = term
        addToRecentSearches(term)
        
        searchState = .loading
        
        Task {
            await performActualSearch(term)
        }
    }
    
    func clearSearch() {
        searchText = ""
        searchState = .idle
        searchResults = []
        searchSuggestions = []
    }
    
    func clearRecentSearches() {
        recentSearches = []
    }
    
    func applyAdvancedFilters() {
        if !searchText.isEmpty {
            performSearch(searchText)
        }
    }
    
    private func performDelayedSearch() async {
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
        
        if !Task.isCancelled {
            await performActualSearch(searchText)
        }
    }
    
    private func performActualSearch(_ term: String) async {
        var results = allProducts.filter { product in
            product.name.localizedCaseInsensitiveContains(term) ||
            product.collection.localizedCaseInsensitiveContains(term) ||
            product.description.localizedCaseInsensitiveContains(term) ||
            product.tags.contains { $0.localizedCaseInsensitiveContains(term) }
        }
        
        // Apply advanced filters
        results = applyFilters(to: results)
        
        await MainActor.run {
            searchResults = results
            searchState = results.isEmpty ? .noResults : .results
        }
    }
    
    private func applyFilters(to products: [Product]) -> [Product] {
        var filtered = products
        
        // Collection filter
        if !advancedFilters.collections.isEmpty {
            filtered = filtered.filter { product in
                advancedFilters.collections.contains { collectionId in
                    product.collection.localizedCaseInsensitiveContains(collectionId)
                }
            }
        }
        
        // Price range filter
        if let priceRange = advancedFilters.priceRange {
            filtered = filtered.filter { priceRange.contains($0.price) }
        }
        
        // Materials filter
        if !advancedFilters.materials.isEmpty {
            filtered = filtered.filter { product in
                advancedFilters.materials.contains { material in
                    product.specifications.caseMaterial.localizedCaseInsensitiveContains(material)
                }
            }
        }
        
        // Functions filter
        if !advancedFilters.functions.isEmpty {
            filtered = filtered.filter { product in
                advancedFilters.functions.contains { function in
                    product.specifications.functions.contains { $0.localizedCaseInsensitiveContains(function) }
                }
            }
        }
        
        // Availability filter
        if !advancedFilters.availability.isEmpty {
            filtered = filtered.filter { advancedFilters.availability.contains($0.availability) }
        }
        
        return filtered
    }
    
    private func generateSuggestions() {
        let commonTerms = ["Navitimer", "Chronomat", "Superocean", "Premier", "Avenger", "Chronograph", "Diving", "Aviation"]
        searchSuggestions = commonTerms.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    private func addToRecentSearches(_ term: String) {
        recentSearches.removeAll { $0 == term }
        recentSearches.insert(term, at: 0)
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }
    }
    
    private func loadMockData() {
        allProducts = Collection.mockCollections.flatMap { collection in
            Product.mockProducts.map { product in
                Product(
                    id: "\(collection.id)-\(product.id)",
                    name: "\(collection.name) \(product.name.components(separatedBy: " ").suffix(3).joined(separator: " "))",
                    collection: collection.name,
                    price: product.price + Double.random(in: -1000...3000),
                    currency: product.currency,
                    imageURLs: ["A17375211B1A1"],
                    description: product.description,
                    specifications: product.specifications,
                    availability: ProductAvailability.allCases.randomElement() ?? .inStock,
                    isLimitedEdition: Bool.random(),
                    tags: product.tags + [collection.name.lowercased()]
                )
            }
        }
        
        // Load trending searches
        trendingSearches = [
            TrendingSearch(term: "Navitimer B01", rank: 1),
            TrendingSearch(term: "Superocean Heritage", rank: 2),
            TrendingSearch(term: "Chronomat GMT", rank: 3),
            TrendingSearch(term: "Premier Chronograph", rank: 4),
            TrendingSearch(term: "Avenger Blackbird", rank: 5),
            TrendingSearch(term: "Limited Edition", rank: 6)
        ]
        
        // Load recent searches (mock data)
        recentSearches = ["Navitimer", "Diving watches", "Chronograph", "Steel bracelet"]
    }
}

#Preview {
    SearchView()
        .environment(NavigationRouter())
}
