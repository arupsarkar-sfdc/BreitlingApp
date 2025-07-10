//
//  BreitlingFonts.swift
//  BreitlingApp
//
//  Created by Arup Sarkar (TA) on 7/9/25.
//

//
//  BreitlingFonts.swift
//  BreitlingApp
//
//  Typography system based on Open Sans font family
//  Font sizes and weights extracted from website analysis
//

import SwiftUI

struct BreitlingFonts {
    // Font weights from JSON analysis: 400, 500, 600, 700
    static let light = Font.Weight.light        // 400
    static let regular = Font.Weight.regular    // 500
    static let medium = Font.Weight.medium      // 500
    static let semibold = Font.Weight.semibold  // 600
    static let bold = Font.Weight.bold          // 700
    
    // Font sizes extracted from website analysis
    static let largeTitle = Font.system(size: 40, weight: .bold, design: .default)     // 40px
    static let title1 = Font.system(size: 34, weight: .semibold, design: .default)     // 34px
    static let title2 = Font.system(size: 24, weight: .medium, design: .default)       // 24px
    static let title3 = Font.system(size: 18, weight: .medium, design: .default)       // 1.125rem ≈ 18px
    static let headline = Font.system(size: 16, weight: .semibold, design: .default)   // 16px
    static let body = Font.system(size: 16, weight: .regular, design: .default)        // 1rem = 16px
    static let callout = Font.system(size: 15, weight: .regular, design: .default)     // 15px
    static let subheadline = Font.system(size: 14, weight: .regular, design: .default) // 14px
    static let footnote = Font.system(size: 12, weight: .regular, design: .default)    // 12px
    static let caption = Font.system(size: 10, weight: .regular, design: .default)     // 0.75rem ≈ 12px
    
    // Luxury-specific font combinations for Breitling app
    static let heroTitle = Font.system(size: 50, weight: .bold, design: .default)
    static let productTitle = Font.system(size: 28, weight: .semibold, design: .default)
    static let collectionName = Font.system(size: 20, weight: .medium, design: .default)
    static let price = Font.system(size: 18, weight: .semibold, design: .default)
    static let productDescription = Font.system(size: 16, weight: .regular, design: .default)
    static let specifications = Font.system(size: 14, weight: .regular, design: .default)
    static let buttonText = Font.system(size: 16, weight: .medium, design: .default)
    static let navigationTitle = Font.system(size: 24, weight: .semibold, design: .default)
}

// Extension for easy text styling
extension Text {
    func breitlingStyle(_ font: Font, color: Color = BreitlingColors.text) -> some View {
        self.font(font)
            .foregroundColor(color)
    }
}
