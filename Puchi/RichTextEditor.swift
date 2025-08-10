import SwiftUI
import UIKit

struct RichTextEditor: UIViewRepresentable {
    @Binding var attributedText: AttributedString
    var placeholder: String = "Start writing..."
    var font: UIFont = UIFont.systemFont(ofSize: 17)
    
    @State private var textView = UITextView()
    @State private var coordinator: Coordinator?
    
    func makeUIView(context: Context) -> UITextView {
        textView.delegate = context.coordinator
        textView.backgroundColor = UIColor.clear
        textView.textColor = UIColor.white
        textView.font = font
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsEditingTextAttributes = true
        textView.keyboardAppearance = .dark
        
        // Set initial text
        updateTextView()
        
        // Add placeholder if needed
        updatePlaceholder()
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // Only update if the attributed text actually changed
        let currentText = AttributedString(uiView.attributedText)
        if currentText != attributedText {
            updateTextView()
        }
        updatePlaceholder()
    }
    
    func makeCoordinator() -> Coordinator {
        let coord = Coordinator(self)
        self.coordinator = coord
        return coord
    }
    
    private func updateTextView() {
        let nsAttributedString = NSAttributedString(attributedText)
        textView.attributedText = nsAttributedString
    }
    
    private func updatePlaceholder() {
        if attributedText.characters.isEmpty {
            textView.text = placeholder
            textView.textColor = UIColor.gray
            textView.font = font
        } else if textView.textColor == UIColor.gray {
            textView.textColor = UIColor.white
        }
    }
    
    // MARK: - Text Formatting Methods
    func applyFormatting(_ formatting: TextFormatting, to range: NSRange? = nil) {
        let targetRange = range ?? textView.selectedRange
        guard targetRange.location != NSNotFound else { return }
        
        let mutableAttributedText = NSMutableAttributedString(attributedString: textView.attributedText)
        
        switch formatting {
        case .bold:
            toggleBold(in: mutableAttributedText, range: targetRange)
        case .italic:
            toggleItalic(in: mutableAttributedText, range: targetRange)
        case .underline:
            toggleUnderline(in: mutableAttributedText, range: targetRange)
        case .strikethrough:
            toggleStrikethrough(in: mutableAttributedText, range: targetRange)
        case .color(let color):
            applyColor(color, in: mutableAttributedText, range: targetRange)
        case .bulletList:
            applyBulletList(in: mutableAttributedText, range: targetRange)
        case .numberedList:
            applyNumberedList(in: mutableAttributedText, range: targetRange)
        }
        
        textView.attributedText = mutableAttributedText
        attributedText = AttributedString(mutableAttributedText)
    }
    
    private func toggleBold(in text: NSMutableAttributedString, range: NSRange) {
        text.enumerateAttribute(.font, in: range) { value, subRange, _ in
            if let font = value as? UIFont {
                let newFont = font.isBold ? font.removingBold() : font.addingBold()
                text.addAttribute(.font, value: newFont, range: subRange)
            }
        }
    }
    
    private func toggleItalic(in text: NSMutableAttributedString, range: NSRange) {
        text.enumerateAttribute(.font, in: range) { value, subRange, _ in
            if let font = value as? UIFont {
                let newFont = font.isItalic ? font.removingItalic() : font.addingItalic()
                text.addAttribute(.font, value: newFont, range: subRange)
            }
        }
    }
    
    private func toggleUnderline(in text: NSMutableAttributedString, range: NSRange) {
        text.enumerateAttribute(.underlineStyle, in: range) { value, subRange, _ in
            let currentStyle = value as? Int ?? 0
            let newStyle = currentStyle == 0 ? NSUnderlineStyle.single.rawValue : 0
            text.addAttribute(.underlineStyle, value: newStyle, range: subRange)
        }
    }
    
    private func toggleStrikethrough(in text: NSMutableAttributedString, range: NSRange) {
        text.enumerateAttribute(.strikethroughStyle, in: range) { value, subRange, _ in
            let currentStyle = value as? Int ?? 0
            let newStyle = currentStyle == 0 ? NSUnderlineStyle.single.rawValue : 0
            text.addAttribute(.strikethroughStyle, value: newStyle, range: subRange)
        }
    }
    
    private func applyColor(_ color: UIColor, in text: NSMutableAttributedString, range: NSRange) {
        text.addAttribute(.foregroundColor, value: color, range: range)
    }
    
    private func applyBulletList(in text: NSMutableAttributedString, range: NSRange) {
        let paragraphRange = text.paragraphRange(for: range)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = 20
        paragraphStyle.firstLineHeadIndent = 0
        
        text.addAttribute(.paragraphStyle, value: paragraphStyle, range: paragraphRange)
        
        // Add bullet point if not present
        let paragraphText = text.attributedSubstring(from: paragraphRange).string
        if !paragraphText.hasPrefix("• ") {
            text.insert(NSAttributedString(string: "• "), at: paragraphRange.location)
        }
    }
    
    private func applyNumberedList(in text: NSMutableAttributedString, range: NSRange) {
        let paragraphRange = text.paragraphRange(for: range)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = 25
        paragraphStyle.firstLineHeadIndent = 0
        
        text.addAttribute(.paragraphStyle, value: paragraphStyle, range: paragraphRange)
        
        // Add number if not present
        let paragraphText = text.attributedSubstring(from: paragraphRange).string
        let numberPattern = #"^\d+\.\s"#
        if paragraphText.range(of: numberPattern, options: .regularExpression) == nil {
            // Find the number for this item (simplified - could be more sophisticated)
            let number = 1 // In a real implementation, count previous numbered items
            text.insert(NSAttributedString(string: "\(number). "), at: paragraphRange.location)
        }
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        let parent: RichTextEditor
        
        init(_ parent: RichTextEditor) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            // Handle placeholder
            if textView.text.isEmpty {
                parent.updatePlaceholder()
            }
            
            // Update binding
            parent.attributedText = AttributedString(textView.attributedText)
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == UIColor.gray {
                textView.text = ""
                textView.textColor = UIColor.white
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            parent.updatePlaceholder()
        }
    }
}

// MARK: - Text Formatting Types
enum TextFormatting {
    case bold
    case italic
    case underline
    case strikethrough
    case color(UIColor)
    case bulletList
    case numberedList
}

// MARK: - UIFont Extensions
extension UIFont {
    var isBold: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitBold)
    }
    
    var isItalic: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitItalic)
    }
    
    func addingBold() -> UIFont {
        let traits = fontDescriptor.symbolicTraits.union(.traitBold)
        if let descriptor = fontDescriptor.withSymbolicTraits(traits) {
            return UIFont(descriptor: descriptor, size: pointSize)
        }
        return self
    }
    
    func removingBold() -> UIFont {
        let traits = fontDescriptor.symbolicTraits.subtracting(.traitBold)
        if let descriptor = fontDescriptor.withSymbolicTraits(traits) {
            return UIFont(descriptor: descriptor, size: pointSize)
        }
        return self
    }
    
    func addingItalic() -> UIFont {
        let traits = fontDescriptor.symbolicTraits.union(.traitItalic)
        if let descriptor = fontDescriptor.withSymbolicTraits(traits) {
            return UIFont(descriptor: descriptor, size: pointSize)
        }
        return self
    }
    
    func removingItalic() -> UIFont {
        let traits = fontDescriptor.symbolicTraits.subtracting(.traitItalic)
        if let descriptor = fontDescriptor.withSymbolicTraits(traits) {
            return UIFont(descriptor: descriptor, size: pointSize)
        }
        return self
    }
}

// MARK: - NSMutableAttributedString Extensions
extension NSMutableAttributedString {
    func paragraphRange(for range: NSRange) -> NSRange {
        return (string as NSString).paragraphRange(for: range)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var attributedText = AttributedString("Sample text for rich text editing")
        
        var body: some View {
            VStack {
                RichTextEditor(attributedText: $attributedText, placeholder: "Start typing...")
                    .frame(height: 200)
                    .background(Color.black)
                
                Text(attributedText)
                    .foregroundColor(.white)
                    .padding()
            }
            .background(Color.black)
        }
    }
    
    return PreviewWrapper()
        .preferredColorScheme(.dark)
}