import SwiftUI

enum BasicFormatting {
    case bold
    case italic
    case underline
}

struct BasicFormatPanelView: View {
    let onFormatApply: (BasicFormatting) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var lastAppliedFormat: BasicFormatting?
    @State private var showConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Format")
                        .font(.headline)
                        .foregroundColor(.puchiText)
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.puchiTextSecondary)
                            .font(.title3)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                // Formatting Options
                VStack(spacing: 24) {
                    HStack(spacing: 32) {
                        BasicFormatButton(
                            title: "B",
                            subtitle: "Bold",
                            isActive: lastAppliedFormat == .bold,
                            action: { 
                                applyFormattingWithFeedback(.bold)
                            }
                        )
                        
                        BasicFormatButton(
                            title: "I",
                            subtitle: "Italic", 
                            isActive: lastAppliedFormat == .italic,
                            action: { 
                                applyFormattingWithFeedback(.italic)
                            }
                        )
                        
                        BasicFormatButton(
                            title: "U",
                            subtitle: "Underline",
                            isActive: lastAppliedFormat == .underline,
                            action: { 
                                applyFormattingWithFeedback(.underline)
                            }
                        )
                        
                        Spacer()
                    }
                    
                    Text(showConfirmation ? "Formatting applied!" : "Select text in your entry, then tap a format option")
                        .font(.caption)
                        .foregroundColor(showConfirmation ? .puchiAccent : .puchiTextSecondary)
                        .multilineTextAlignment(.center)
                        .animation(.easeInOut(duration: 0.3), value: showConfirmation)
                }
                .padding(.horizontal, 20)
                .padding(.top, 32)
                
                Spacer()
            }
            .background(Color.puchiSurface)
            .preferredColorScheme(.dark)
        }
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.visible)
    }
    
    private func applyFormattingWithFeedback(_ formatting: BasicFormatting) {
        onFormatApply(formatting)
        lastAppliedFormat = formatting
        showConfirmation = true
        
        // Reset confirmation after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.3)) {
                showConfirmation = false
                lastAppliedFormat = nil
            }
        }
    }
}

struct BasicFormatButton: View {
    let title: String
    let subtitle: String
    let isActive: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            action()
        }) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isActive ? Color.puchiAccent.opacity(0.8) : 
                             (isPressed ? Color.puchiAccent.opacity(0.3) : Color.puchiHighlight))
                        .stroke(isActive ? Color.puchiAccent : Color.puchiBorder, lineWidth: isActive ? 2 : 1)
                        .frame(width: 60, height: 60)
                        .animation(.easeInOut(duration: 0.2), value: isActive)
                    
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(isActive ? .puchiButtonText : .puchiText)
                        .animation(.easeInOut(duration: 0.2), value: isActive)
                }
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.puchiTextSecondary)
            }
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: 0.0, maximumDistance: .infinity) {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onPressingChanged: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }
        .accessibilityLabel("\(subtitle) formatting")
        .accessibilityHint(isActive ? "\(subtitle) formatting is currently active" : "Apply \(subtitle) formatting to selected text")
        .accessibilityAddTraits(isActive ? [.isSelected] : [])
        .accessibilityRemoveTraits(isActive ? [] : [.isSelected])
    }
}

#Preview {
    BasicFormatPanelView { formatting in
        print("Applied formatting: \(formatting)")
    }
    .preferredColorScheme(.dark)
}

// Fix for missing isActive parameter in preview
extension BasicFormatButton {
    init(title: String, subtitle: String, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.isActive = false
        self.action = action
    }
}