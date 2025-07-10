//
//  BreitlingColors.swift
//  BreitlingApp
//
//  Created by Arup Sarkar (TA) on 7/9/25.
//

//
//  BreitlingColors.swift
//  BreitlingApp
//
//  Color palette extracted from Breitling website analysis
//  Luxury brand colors with sophisticated aesthetic
//

import SwiftUI

struct BreitlingColors {
    // Primary colors from JSON analysis
    static let primary = Color(hex: "#FFFFFF")
    static let secondary = Color(hex: "#FAFAFA")
    static let accent = Color(hex: "#000000")
    static let background = Color(hex: "#FFFFFF")
    static let text = Color(hex: "#000000")
    
    // Brand-specific colors extracted from website
    static let navyBlue = Color(hex: "#072C54")
    static let luxuryGold = Color(hex: "#FFC62D")
    static let lightGray = Color(hex: "#D5D5D5")
    static let mediumGray = Color(hex: "#7A7A7A")
    static let darkCharcoal = Color(hex: "#111820")
    static let textSecondary = Color(hex: "#77777A")
    
    // Luxury UI color scheme
    static let cardBackground = Color(hex: "#FAFAFA")
    static let buttonPrimary = Color(hex: "#000000")
    static let buttonSecondary = Color(hex: "#072C54")
    static let divider = Color(hex: "#D5D5D5")
    
    // Status colors
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let info = navyBlue
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
