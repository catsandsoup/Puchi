import SwiftUI
import UIKit

/*
 RICH TEXT EDITOR - CRITICAL MAINTENANCE NOTES
 
 ⚠️  COLOR ATTRIBUTION ISSUES TO WATCH FOR:
 
 1. INVISIBLE TEXT PROBLEM:
    - NEVER create AttributedString(plainText) without color attributes
    - ALWAYS use SimpleRichTextEditor.createThemedAttributedString(from:) for plain text
    - ALWAYS use SimpleRichTextEditor.ensureProperColorAttributes(_:) for external AttributedString
 
 2. LOCATIONS WHERE INVISIBLE/SMALL TEXT CAN OCCUR:
    - Love prompts (FIXED: EntryComposerView.swift:423) - Text color & size
    - Search highlighting (FIXED: SearchView.swift:468, 486) - Text color
    - Entry loading from storage (FIXED: PuchiApp.swift:535) - Text color  
    - Legacy data fallbacks (FIXED: PuchiApp.swift:503) - Text color
    - Text input changes (PROTECTED: textViewDidChange) - Text color
    - External text insertion (PROTECTED: updateUIView lines 95-111) - Font & color
 
 3. FORMATTING PRESERVATION:
    - applyFontTrait method preserves existing colors (FIXED: lines 184-207)
    - Fallback fonts maintain color attributes (PROTECTED: createFallbackFont)
    - All formatting operations set explicit foreground colors
 
 4. ACCESSIBILITY & THEMING:
    - WCAG 2.1 AA contrast validation available (validateColorContrast)
    - Theme colors automatically adapt to light/dark mode
    - VoiceOver support in BasicFormatPanelView
 
 🔍 FUTURE DEBUGGING CHECKLIST:
    - If text appears invisible, check for missing .foregroundColor attributes
    - Use SimpleRichTextEditor utility functions for all text creation
    - Test in both light and dark themes
    - Verify contrast ratios meet accessibility standards
 
 📍 KEY UTILITY FUNCTIONS:
    - createThemedAttributedString(from:) - Create properly colored AttributedString
    - ensureProperColorAttributes(_:) - Fix existing AttributedString colors
    - validateColorContrast(_:_:) - Check WCAG compliance
*/

struct SimpleRichTextEditor: UIViewRepresentable {
    @Binding var attributedText: AttributedString
    var placeholder: String = "Start writing..."
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = UIColor.clear
        textView.textColor = UIColor(Color.puchiText)
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsEditingTextAttributes = true
        textView.keyboardAppearance = .dark
        
        // Accessibility improvements
        textView.accessibilityLabel = "Rich text editor"
        textView.accessibilityHint = "Enter your journal entry. You can format text using the format panel."
        textView.adjustsFontForContentSizeCategory = true
        
        // Set the text view reference in the coordinator
        context.coordinator.setTextView(textView)
        
        // Set initial content with explicit color attributes
        if !attributedText.characters.isEmpty {
            let mutableText = NSMutableAttributedString(attributedText)
            // Ensure all text has proper color attributes
            let fullRange = NSRange(location: 0, length: mutableText.length)
            mutableText.enumerateAttribute(.foregroundColor, in: fullRange) { value, range, _ in
                if value == nil {
                    mutableText.addAttribute(.foregroundColor, value: UIColor(Color.puchiText), range: range)
                }
            }
            textView.attributedText = mutableText
        } else {
            textView.text = placeholder
            textView.textColor = UIColor(Color.puchiTextSecondary)
        }
        
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        // Only update if there's a significant change to avoid cursor jumping
        let currentAttributedString = AttributedString(textView.attributedText)
        if currentAttributedString != attributedText && !attributedText.characters.isEmpty {
            let selection = textView.selectedRange
            let nsAttributedText = NSMutableAttributedString(attributedText)
            
            // LANDMARK: Ensure proper styling when updating from external source (like love prompts)
            // This prevents small, dark text by enforcing consistent font and color
            let fullRange = NSRange(location: 0, length: nsAttributedText.length)
            nsAttributedText.enumerateAttribute(NSAttributedString.Key.font, in: fullRange) { value, range, _ in
                if value == nil {
                    nsAttributedText.addAttribute(NSAttributedString.Key.font, 
                                                value: UIFont.systemFont(ofSize: 17), 
                                                range: range)
                }
            }
            nsAttributedText.enumerateAttribute(NSAttributedString.Key.foregroundColor, in: fullRange) { value, range, _ in
                if value == nil {
                    nsAttributedText.addAttribute(NSAttributedString.Key.foregroundColor, 
                                                value: UIColor(Color.puchiText), 
                                                range: range)
                }
            }
            
            textView.attributedText = nsAttributedText
            // Restore selection if possible
            if selection.location <= textView.attributedText.length {
                textView.selectedRange = selection
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Public methods for formatting - called through coordinator
    static var activeCoordinator: Coordinator?
    
    func applyBold() {
        Self.activeCoordinator?.applyBold()
    }
    
    func applyItalic() {
        Self.activeCoordinator?.applyItalic()
    }
    
    func applyUnderline() {
        Self.activeCoordinator?.applyUnderline()
    }
    
    func applyColor(_ color: UIColor) {
        Self.activeCoordinator?.applyColor(color)
    }
    
    // MARK: - Utility Functions for Proper Text Color Attribution
    
    /// Creates an AttributedString with proper theme color attributes applied
    /// LANDMARK: Use this function whenever creating AttributedString from plain text
    /// to ensure proper color attribution and avoid invisible text issues
    static func createThemedAttributedString(from text: String, size: CGFloat = 17) -> AttributedString {
        // FIXED: Use NSAttributedString approach to ensure proper font and color application
        // This prevents the small, dark text issue when inserting love prompts
        let nsAttributedString = NSMutableAttributedString(string: text)
        let fullRange = NSRange(location: 0, length: nsAttributedString.length)
        
        // Apply consistent styling that matches UITextView defaults
        nsAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, 
                                      value: UIColor(Color.puchiText), 
                                      range: fullRange)
        nsAttributedString.addAttribute(NSAttributedString.Key.font, 
                                      value: UIFont.systemFont(ofSize: size), 
                                      range: fullRange)
        
        return AttributedString(nsAttributedString)
    }
    
    /// Ensures existing AttributedString has proper color attributes
    /// LANDMARK: Call this when receiving AttributedString from external sources
    /// that might lack proper color attributes
    static func ensureProperColorAttributes(_ attributedString: AttributedString) -> AttributedString {
        var mutableString = attributedString
        
        // Check if any part lacks foreground color and apply theme color
        // Use NSAttributedString approach for more reliable attribute checking
        let nsString = NSMutableAttributedString(mutableString)
        let nsFullRange = NSRange(location: 0, length: nsString.length)
        
        nsString.enumerateAttribute(NSAttributedString.Key.foregroundColor, in: nsFullRange) { value, range, _ in
            if value == nil {
                nsString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(Color.puchiText), range: range)
            }
        }
        
        mutableString = AttributedString(nsString)
        
        return mutableString
    }
    
    // MARK: - Color Contrast Validation
    
    static func validateColorContrast(_ foreground: UIColor, _ background: UIColor) -> Bool {
        return contrastRatio(foreground, background) >= 4.5 // WCAG AA standard
    }
    
    static private func contrastRatio(_ color1: UIColor, _ color2: UIColor) -> CGFloat {
        let luminance1 = relativeLuminance(color1)
        let luminance2 = relativeLuminance(color2)
        let lighter = max(luminance1, luminance2)
        let darker = min(luminance1, luminance2)
        return (lighter + 0.05) / (darker + 0.05)
    }
    
    static private func relativeLuminance(_ color: UIColor) -> CGFloat {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        func sRGBToLinear(_ value: CGFloat) -> CGFloat {
            return value <= 0.03928 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }
        
        let linearR = sRGBToLinear(red)
        let linearG = sRGBToLinear(green)
        let linearB = sRGBToLinear(blue)
        
        return 0.2126 * linearR + 0.7152 * linearG + 0.0722 * linearB
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        let parent: SimpleRichTextEditor
        weak var textView: UITextView?
        
        init(_ parent: SimpleRichTextEditor) {
            self.parent = parent
            super.init()
            // Set this as the active coordinator for formatting
            SimpleRichTextEditor.activeCoordinator = self
        }
        
        func setTextView(_ textView: UITextView) {
            self.textView = textView
        }
        
        // MARK: - Formatting Methods
        
        func applyBold() {
            guard let textView = self.textView else { return }
            applyFontTrait(.traitBold, to: textView)
        }
        
        func applyItalic() {
            guard let textView = self.textView else { return }
            applyFontTrait(.traitItalic, to: textView)
        }
        
        func applyUnderline() {
            guard let textView = self.textView else { return }
            let range = textView.selectedRange
            if range.length > 0 {
                let mutableText = NSMutableAttributedString(attributedString: textView.attributedText)
                
                // Toggle underline
                let hasUnderline = mutableText.attribute(.underlineStyle, at: range.location, effectiveRange: nil) as? Int == NSUnderlineStyle.single.rawValue
                let underlineValue = hasUnderline ? 0 : NSUnderlineStyle.single.rawValue
                
                mutableText.addAttribute(.underlineStyle, value: underlineValue, range: range)
                textView.attributedText = mutableText
                textView.selectedRange = range
                
                parent.attributedText = AttributedString(mutableText)
            }
        }
        
        func applyColor(_ color: UIColor) {
            guard let textView = self.textView else { return }
            let range = textView.selectedRange
            if range.length > 0 {
                let mutableText = NSMutableAttributedString(attributedString: textView.attributedText)
                mutableText.addAttribute(.foregroundColor, value: color, range: range)
                textView.attributedText = mutableText
                textView.selectedRange = range
                
                parent.attributedText = AttributedString(mutableText)
            }
        }
        
        private func applyFontTrait(_ trait: UIFontDescriptor.SymbolicTraits, to textView: UITextView) {
            let range = textView.selectedRange
            if range.length > 0 {
                let mutableText = NSMutableAttributedString(attributedString: textView.attributedText)
                
                mutableText.enumerateAttribute(.font, in: range) { value, subRange, _ in
                    // Preserve existing color or use theme default
                    let existingColor = mutableText.attribute(.foregroundColor, at: subRange.location, effectiveRange: nil) as? UIColor
                    let textColor = existingColor ?? UIColor(Color.puchiText)
                    
                    if let font = value as? UIFont {
                        let currentTraits = font.fontDescriptor.symbolicTraits
                        let newTraits = currentTraits.contains(trait) ? 
                            currentTraits.subtracting(trait) : 
                            currentTraits.union(trait)
                        
                        if let newDescriptor = font.fontDescriptor.withSymbolicTraits(newTraits) {
                            let newFont = UIFont(descriptor: newDescriptor, size: font.pointSize)
                            mutableText.addAttribute(.font, value: newFont, range: subRange)
                            // Always set/preserve the text color
                            mutableText.addAttribute(.foregroundColor, value: textColor, range: subRange)
                        } else {
                            // Fallback: create font with trait manually if descriptor fails
                            let fallbackFont = createFallbackFont(baseFont: font, trait: trait)
                            mutableText.addAttribute(.font, value: fallbackFont, range: subRange)
                            mutableText.addAttribute(.foregroundColor, value: textColor, range: subRange)
                        }
                    } else {
                        // If no font attribute, use default font with the desired trait
                        let defaultFont = UIFont.systemFont(ofSize: 17)
                        if let newDescriptor = defaultFont.fontDescriptor.withSymbolicTraits(trait) {
                            let newFont = UIFont(descriptor: newDescriptor, size: defaultFont.pointSize)
                            mutableText.addAttribute(.font, value: newFont, range: subRange)
                            // Always set the text color for new fonts
                            mutableText.addAttribute(.foregroundColor, value: textColor, range: subRange)
                        } else {
                            // Fallback for default font
                            let fallbackFont = createFallbackFont(baseFont: defaultFont, trait: trait)
                            mutableText.addAttribute(.font, value: fallbackFont, range: subRange)
                            mutableText.addAttribute(.foregroundColor, value: textColor, range: subRange)
                        }
                    }
                }
                
                textView.attributedText = mutableText
                textView.selectedRange = range
                
                parent.attributedText = AttributedString(mutableText)
            }
        }
        
        // MARK: - Helper Methods
        
        private func createFallbackFont(baseFont: UIFont, trait: UIFontDescriptor.SymbolicTraits) -> UIFont {
            // Create fallback fonts when descriptor creation fails
            switch trait {
            case .traitBold:
                return UIFont.boldSystemFont(ofSize: baseFont.pointSize)
            case .traitItalic:
                return UIFont.italicSystemFont(ofSize: baseFont.pointSize)
            default:
                // For other traits or combinations, return the base font
                return baseFont
            }
        }
        
        // MARK: - UITextViewDelegate
        
        func textViewDidChange(_ textView: UITextView) {
            // Handle placeholder
            if textView.textColor == UIColor(Color.puchiTextSecondary) && !textView.text.isEmpty {
                textView.textColor = UIColor(Color.puchiText)
            }
            
            // LANDMARK: Ensure any new text typed has proper color attributes
            // This prevents typing new text that becomes invisible
            guard let currentAttributedText = textView.attributedText else {
                parent.attributedText = AttributedString()
                return
            }
            
            let mutableText = NSMutableAttributedString(attributedString: currentAttributedText)
            let fullRange = NSRange(location: 0, length: mutableText.length)
            
            // Ensure all text has proper foreground color
            mutableText.enumerateAttribute(NSAttributedString.Key.foregroundColor, in: fullRange) { value, range, _ in
                if value == nil {
                    mutableText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(Color.puchiText), range: range)
                }
            }
            
            // Update binding safely with color-corrected text
            parent.attributedText = AttributedString(mutableText)
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == UIColor(Color.puchiTextSecondary) {
                textView.text = ""
                textView.textColor = UIColor(Color.puchiText)
            }
            // Set as active coordinator when editing begins
            SimpleRichTextEditor.activeCoordinator = self
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = UIColor(Color.puchiTextSecondary)
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var attributedText = AttributedString("Sample rich text")
        
        var body: some View {
            VStack {
                SimpleRichTextEditor(attributedText: $attributedText)
                    .frame(height: 200)
                    .background(Color.puchiSurface)
                
                HStack {
                    Button("Bold") { /* formatting logic */ }
                    Button("Italic") { /* formatting logic */ }
                    Button("Underline") { /* formatting logic */ }
                }
                .padding()
            }
            .background(Color.puchiBackground)
        }
    }
    
    return PreviewWrapper()
        .preferredColorScheme(.dark)
}