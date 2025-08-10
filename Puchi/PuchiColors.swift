//
//  PuchiColors.swift
//  Puchi
//
//  Cute pink, white, beige color theme for light and dark modes
//

import SwiftUI

extension Color {
    // MARK: - Primary Theme Colors
    
    /// Soft, warm pink - primary accent color
    static let puchiPink = Color(red: 0.98, green: 0.84, blue: 0.89) // #FAD6E4
    
    /// Deeper pink for emphasis and buttons
    static let puchiPinkDeep = Color(red: 0.93, green: 0.71, blue: 0.81) // #EEB5CE
    
    /// Warm beige/cream for backgrounds and cards
    static let puchiBeige = Color(red: 0.98, green: 0.96, blue: 0.94) // #FAF5F0
    
    /// Slightly deeper beige for subtle contrast
    static let puchiBeigeDeep = Color(red: 0.94, green: 0.92, blue: 0.89) // #F0EBE3
    
    /// Pure white with warmth
    static let puchiWhite = Color(red: 1.0, green: 0.99, blue: 0.98) // #FFFEFB
    
    /// Soft lavender for subtle accents
    static let puchiLavender = Color(red: 0.95, green: 0.91, blue: 0.96) // #F2E8F5
    
    // MARK: - Semantic Colors (adapt to light/dark mode)
    
    /// Primary background color
    static var puchiBackground: Color {
        Color(light: .puchiBeige, dark: Color(red: 0.08, green: 0.05, blue: 0.08)) // Light beige / Very dark warm
    }
    
    /// Secondary background for cards and surfaces
    static var puchiSurface: Color {
        Color(light: .puchiWhite, dark: Color(red: 0.12, green: 0.09, blue: 0.12)) // Pure white / Dark warm
    }
    
    /// Primary text color
    static var puchiText: Color {
        Color(light: Color(red: 0.25, green: 0.15, blue: 0.20), dark: .puchiBeige) // Dark warm brown / Light beige
    }
    
    /// Secondary text color
    static var puchiTextSecondary: Color {
        Color(light: Color(red: 0.5, green: 0.4, blue: 0.45), dark: Color(red: 0.8, green: 0.75, blue: 0.77)) // Medium brown / Light gray-beige
    }
    
    /// Primary accent color (always pink)
    static var puchiAccent: Color {
        Color(light: .puchiPinkDeep, dark: .puchiPink) // Deeper in light, softer in dark
    }
    
    /// Button background
    static var puchiButton: Color {
        Color(light: .puchiPinkDeep, dark: .puchiPink) // Same as accent
    }
    
    /// Button text
    static var puchiButtonText: Color {
        Color(light: .puchiWhite, dark: Color(red: 0.25, green: 0.15, blue: 0.20)) // White in light, dark in dark mode
    }
    
    /// Border and separator color
    static var puchiBorder: Color {
        Color(light: .puchiBeigeDeep, dark: Color(red: 0.2, green: 0.15, blue: 0.18)) // Light border / Dark border
    }
    
    /// Subtle highlight color
    static var puchiHighlight: Color {
        Color(light: .puchiLavender, dark: Color(red: 0.2, green: 0.15, blue: 0.2)) // Lavender / Dark purple
    }
    
    // MARK: - Gradient Support
    
    /// Primary gradient for buttons and highlights
    static var puchiGradient: LinearGradient {
        LinearGradient(
            colors: [.puchiAccent, .puchiPink],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Subtle background gradient
    static var puchiBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [.puchiBackground, .puchiSurface],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Helper Extension for Light/Dark Mode
extension Color {
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}