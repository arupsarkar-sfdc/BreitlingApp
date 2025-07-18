//
//  LuxuryPersonalizationModal.swift
//  BreitlingApp
//
//  Created by Arup Sarkar (TA) on 7/11/25.
//

//
//  LuxuryPersonalizationModal.swift
//  BreitlingApp
//
//  Sophisticated luxury personalization modal experience
//  Designed for Breitling's discerning clientele
//

import SwiftUI

struct LuxuryPersonalizationModal: View {
    let content: PersonalizedContent
    let onDismiss: () -> Void
    let onAction: (PersonalizationAction) -> Void
    
    @State private var currentInsightIndex = 0
    @State private var showingRecommendations = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero section with collection imagery
                    heroSection
                    
                    // Insights carousel
                    insightsSection
                    
                    // Recommendations section
                    if showingRecommendations {
                        recommendationsSection
                    }
                    
                    // Actions section
                    actionsSection
                }
            }
            .background(BreitlingColors.background)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(content.trigger.luxuryTitle)
                        .font(BreitlingFonts.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(BreitlingColors.primaryText)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                    .font(BreitlingFonts.callout)
                    .fontWeight(.medium)
                    .foregroundColor(BreitlingColors.navyBlue)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        VStack(spacing: 16) {
            // Collection hero image
            AsyncImage(url: URL(string: content.collectionData.heroImageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(BreitlingColors.lightGray.opacity(0.3))
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                // Gradient overlay for text readability
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
            )
            .overlay(
                // Collection info overlay
                VStack(alignment: .leading) {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(content.collectionData.name)
                            .font(BreitlingFonts.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(content.collectionData.heritageDisplayText)
                            .font(BreitlingFonts.callout)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(20)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            )
            
            // Personalized subtitle
            VStack(spacing: 8) {
                Text(content.trigger.luxurySubtitle)
                    .font(BreitlingFonts.body)
                    .foregroundColor(BreitlingColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                
                // Confidence indicator
                HStack(spacing: 8) {
                    ForEach(0..<5) { index in
                        Circle()
                            .fill(index < Int(content.trigger.confidence * 5) ? BreitlingColors.luxuryGold : BreitlingColors.lightGray)
                            .frame(width: 6, height: 6)
                    }
                    
                    Text("Personalization Confidence")
                        .font(BreitlingFonts.caption)
                        .foregroundColor(BreitlingColors.secondaryText)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: - Insights Section
    
    private var insightsSection: some View {
        VStack(spacing: 20) {
            // Section header
            HStack {
                Text("Your Luxury Profile")
                    .font(BreitlingFonts.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(BreitlingColors.primaryText)
                
                Spacer()
                
                // Insight indicators
                HStack(spacing: 6) {
                    ForEach(0..<content.insights.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentInsightIndex ? BreitlingColors.navyBlue : BreitlingColors.lightGray)
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Insights carousel
            TabView(selection: $currentInsightIndex) {
                ForEach(Array(content.insights.enumerated()), id: \.element.id) { index, insight in
                    LuxuryInsightCard(insight: insight)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 280)
        }
        .padding(.top, 30)
    }
    
    // MARK: - Recommendations Section
    
    private var recommendationsSection: some View {
        VStack(spacing: 16) {
            // Section header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Curated for You")
                        .font(BreitlingFonts.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(BreitlingColors.primaryText)
                    
                    Text("Based on your \(content.collectionData.name) appreciation")
                        .font(BreitlingFonts.callout)
                        .foregroundColor(BreitlingColors.secondaryText)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // Recommendations horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(content.recommendations) { recommendation in
                        RecommendationCard(recommendation: recommendation)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Actions Section
    
    private var actionsSection: some View {
        VStack(spacing: 16) {
            // Toggle recommendations button
            Button {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showingRecommendations.toggle()
                }
            } label: {
                HStack {
                    Text(showingRecommendations ? "Hide Recommendations" : "View Curated Recommendations")
                        .font(BreitlingFonts.callout)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Image(systemName: showingRecommendations ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(BreitlingColors.navyBlue)
                .padding(16)
                .background(BreitlingColors.navyBlue.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            
            // Action buttons
            VStack(spacing: 12) {
                ForEach(content.actions) { action in
                    LuxuryActionButton(action: action) {
                        onAction(action)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .padding(.top, 30)
    }
}

// MARK: - Luxury Insight Card

struct LuxuryInsightCard: View {
    let insight: LuxuryInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Insight image
            AsyncImage(url: URL(string: insight.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(BreitlingColors.lightGray.opacity(0.3))
            }
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Insight content
            VStack(alignment: .leading, spacing: 8) {
                Text(insight.title)
                    .font(BreitlingFonts.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(BreitlingColors.primaryText)
                
                Text(insight.description)
                    .font(BreitlingFonts.body)
                    .foregroundColor(BreitlingColors.secondaryText)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
                
                // Confidence bar
                HStack {
                    Text("Confidence")
                        .font(BreitlingFonts.caption)
                        .foregroundColor(BreitlingColors.secondaryText)
                    
                    Spacer()
                    
                    Text("\(Int(insight.confidence * 100))%")
                        .font(BreitlingFonts.caption)
                        .fontWeight(.medium)
                        .foregroundColor(BreitlingColors.navyBlue)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(BreitlingColors.lightGray.opacity(0.3))
                            .frame(height: 4)
                            .cornerRadius(2)
                        
                        Rectangle()
                            .fill(BreitlingColors.navyBlue)
                            .frame(width: geometry.size.width * insight.confidence, height: 4)
                            .cornerRadius(2)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(20)
        .background(BreitlingColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
}

// MARK: - Recommendation Card

struct RecommendationCard: View {
    let recommendation: PersonalizedRecommendation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Product image
            AsyncImage(url: URL(string: recommendation.product.primaryImageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Rectangle()
                    .fill(BreitlingColors.lightGray.opacity(0.3))
            }
            .frame(width: 140, height: 140)
            .background(BreitlingColors.cardBackground)
            .cornerRadius(12)
            
            // Product info
            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.product.name)
                    .font(BreitlingFonts.callout)
                    .fontWeight(.medium)
                    .foregroundColor(BreitlingColors.primaryText)
                    .lineLimit(2)
                
                Text(recommendation.product.formattedPrice)
                    .font(BreitlingFonts.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(BreitlingColors.navyBlue)
                
                Text(recommendation.reason)
                    .font(BreitlingFonts.caption)
                    .foregroundColor(BreitlingColors.secondaryText)
                    .lineLimit(3)
            }
        }
        .frame(width: 160)
        .padding(12)
        .background(BreitlingColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Luxury Action Button

struct LuxuryActionButton: View {
    let action: PersonalizationAction
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: action.actionType.iconName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(BreitlingColors.navyBlue)
                    .frame(width: 24)
                
                Text(action.title)
                    .font(BreitlingFonts.callout)
                    .fontWeight(.medium)
                    .foregroundColor(BreitlingColors.primaryText)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(BreitlingColors.secondaryText)
            }
            .padding(16)
            .background(BreitlingColors.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(BreitlingColors.border, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Action Type Icon Extension

extension PersonalizationAction.ActionType {
    var iconName: String {
        switch self {
        case .exploreCollection:
            return "square.grid.3x3"
        case .scheduleBoutique:
            return "calendar.badge.plus"
        case .joinNewsletter:
            return "envelope.badge"
        case .requestCatalog:
            return "book.closed"
        case .viewRecommendations:
            return "sparkles"
        }
    }
}

#Preview {
    LuxuryPersonalizationModal(
        content: PersonalizedContent(
            trigger: PersonalizationTrigger(
                type: .collectionAffinity,
                collectionId: "navitimer",
                collectionName: "Navitimer",
                likeCount: 4,
                confidence: 0.85,
                reasoning: "Strong affinity"
            ),
            collectionData: Collection.mockCollections[0],
            insights: [],
            recommendations: [],
            actions: [],
            metadata: PersonalizationMetadata(
                generatedAt: Date(),
                experimentId: nil,
                salesforcePersonalizationId: nil
            )
        ),
        onDismiss: {},
        onAction: { _ in }
    )
}
