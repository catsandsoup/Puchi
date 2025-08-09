import SwiftUI

// MARK: - Color Extensions
extension Color {
    // Brand Colors
    static let puchiPrimary = Color(hex: "FF7B7E")    // Warmer, softer pink
    static let puchiSecondary = Color(hex: "FF9B9E")  // Lighter accent pink
    static let puchiBackground = Color(hex: "F8F8F8") // Slightly warmer background
    
    // Semantic Colors
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let background = Color(.systemBackground)
    static let groupedBackground = Color(.systemGroupedBackground)
    
    // Functional Colors
    static let success = Color.green
    static let warning = Color.yellow
    static let error = Color.red
    
    // Helper function for hex colors
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
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Style Extensions
extension View {
    // Card Style
    func puchiCard() -> some View {
        self.modifier(CardStyleModifier())
    }
    
    // Button Style
    func puchiButton() -> some View {
        self.modifier(ButtonStyleModifier())
    }
    
    // Input Field Style
    func puchiInput() -> some View {
        self.modifier(InputStyleModifier())
    }
}

// MARK: - Style Modifiers
struct CardStyleModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.background)
            .cornerRadius(16)
            .shadow(
                color: colorScheme == .dark
                    ? Color.black.opacity(0.3)
                    : Color.black.opacity(0.05),
                radius: 10,
                x: 0,
                y: 4
            )
    }
}

struct ButtonStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(height: 50)
            .background(
                LinearGradient(
                    colors: [Color.puchiPrimary, Color.puchiSecondary],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(12)
            .shadow(color: Color.puchiPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

struct InputStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 17, design: .rounded))
            .padding(16)
            .background(Color.background)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
}

// MARK: - UIImage Extensions
extension UIImage {
    func optimizedForStorage() -> Data? {
        let maxDimension: CGFloat = 1024
        var newImage = self
        
        // Prevent NaN by checking for valid dimensions
        let maxSize = max(size.width, size.height)
        if maxSize > maxDimension && maxSize > 0 {
            let scale = maxDimension / maxSize
            let newSize = CGSize(width: size.width * scale, height: size.height * scale)
            
            // Additional safety check for valid new size
            guard newSize.width > 0 && newSize.height > 0 else {
                return self.jpegData(compressionQuality: 0.5)
            }
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            draw(in: CGRect(origin: .zero, size: newSize))
            newImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
            UIGraphicsEndImageContext()
        }
        
        return newImage.jpegData(compressionQuality: 0.5)
    }
}
