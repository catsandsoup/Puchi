import SwiftUI
import UIKit

struct SimpleRichTextEditor: UIViewRepresentable {
    @Binding var attributedText: AttributedString
    var placeholder: String = "Start writing..."
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = UIColor.clear
        textView.textColor = UIColor.white
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsEditingTextAttributes = true
        textView.keyboardAppearance = .dark
        
        // Set initial content
        if !attributedText.characters.isEmpty {
            textView.attributedText = NSAttributedString(attributedText)
        } else {
            textView.text = placeholder
            textView.textColor = UIColor.gray
        }
        
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        // Only update if there's a significant change to avoid cursor jumping
        let currentAttributedString = AttributedString(textView.attributedText)
        if currentAttributedString != attributedText && !attributedText.characters.isEmpty {
            let selection = textView.selectedRange
            textView.attributedText = NSAttributedString(attributedText)
            // Restore selection if possible
            if selection.location <= textView.attributedText.length {
                textView.selectedRange = selection
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Public methods for formatting
    func applyBold() {
        guard let textView = getCurrentTextView() else { return }
        applyFontTrait(.traitBold, to: textView)
    }
    
    func applyItalic() {
        guard let textView = getCurrentTextView() else { return }
        applyFontTrait(.traitItalic, to: textView)
    }
    
    func applyUnderline() {
        guard let textView = getCurrentTextView() else { return }
        let range = textView.selectedRange
        if range.length > 0 {
            let mutableText = NSMutableAttributedString(attributedString: textView.attributedText)
            
            // Toggle underline
            let hasUnderline = mutableText.attribute(.underlineStyle, at: range.location, effectiveRange: nil) as? Int == NSUnderlineStyle.single.rawValue
            let underlineValue = hasUnderline ? 0 : NSUnderlineStyle.single.rawValue
            
            mutableText.addAttribute(.underlineStyle, value: underlineValue, range: range)
            textView.attributedText = mutableText
            textView.selectedRange = range
            
            attributedText = AttributedString(mutableText)
        }
    }
    
    func applyColor(_ color: UIColor) {
        guard let textView = getCurrentTextView() else { return }
        let range = textView.selectedRange
        if range.length > 0 {
            let mutableText = NSMutableAttributedString(attributedString: textView.attributedText)
            mutableText.addAttribute(.foregroundColor, value: color, range: range)
            textView.attributedText = mutableText
            textView.selectedRange = range
            
            attributedText = AttributedString(mutableText)
        }
    }
    
    private func getCurrentTextView() -> UITextView? {
        // This is a simplified approach - in production you'd need better UITextView reference management
        return nil // Will be properly implemented with coordinator reference
    }
    
    private func applyFontTrait(_ trait: UIFontDescriptor.SymbolicTraits, to textView: UITextView) {
        let range = textView.selectedRange
        if range.length > 0 {
            let mutableText = NSMutableAttributedString(attributedString: textView.attributedText)
            
            mutableText.enumerateAttribute(.font, in: range) { value, subRange, _ in
                if let font = value as? UIFont {
                    let currentTraits = font.fontDescriptor.symbolicTraits
                    let newTraits = currentTraits.contains(trait) ? 
                        currentTraits.subtracting(trait) : 
                        currentTraits.union(trait)
                    
                    if let newDescriptor = font.fontDescriptor.withSymbolicTraits(newTraits) {
                        let newFont = UIFont(descriptor: newDescriptor, size: font.pointSize)
                        mutableText.addAttribute(.font, value: newFont, range: subRange)
                    }
                }
            }
            
            textView.attributedText = mutableText
            textView.selectedRange = range
            
            attributedText = AttributedString(mutableText)
        }
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        let parent: SimpleRichTextEditor
        
        init(_ parent: SimpleRichTextEditor) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            // Handle placeholder
            if textView.textColor == UIColor.gray && !textView.text.isEmpty {
                textView.textColor = UIColor.white
            }
            
            // Update binding safely
            parent.attributedText = AttributedString(textView.attributedText)
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == UIColor.gray {
                textView.text = ""
                textView.textColor = UIColor.white
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = UIColor.gray
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
                    .background(Color.black)
                
                HStack {
                    Button("Bold") { /* formatting logic */ }
                    Button("Italic") { /* formatting logic */ }
                    Button("Underline") { /* formatting logic */ }
                }
                .padding()
            }
            .background(Color.black)
        }
    }
    
    return PreviewWrapper()
        .preferredColorScheme(.dark)
}