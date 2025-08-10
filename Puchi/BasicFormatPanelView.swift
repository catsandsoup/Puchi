import SwiftUI

enum BasicFormatting {
    case bold
    case italic
    case underline
}

struct BasicFormatPanelView: View {
    let onFormatApply: (BasicFormatting) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Format")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
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
                            action: { onFormatApply(.bold) }
                        )
                        
                        BasicFormatButton(
                            title: "I",
                            subtitle: "Italic",
                            action: { onFormatApply(.italic) }
                        )
                        
                        BasicFormatButton(
                            title: "U",
                            subtitle: "Underline",
                            action: { onFormatApply(.underline) }
                        )
                        
                        Spacer()
                    }
                    
                    Text("Select text in your entry, then tap a format option")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                .padding(.top, 32)
                
                Spacer()
            }
            .background(Color.black)
            .preferredColorScheme(.dark)
        }
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.visible)
    }
}

struct BasicFormatButton: View {
    let title: String
    let subtitle: String
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
                        .fill(isPressed ? Color.pink.opacity(0.3) : Color.gray.opacity(0.2))
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        .frame(width: 60, height: 60)
                    
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
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
    }
}

#Preview {
    BasicFormatPanelView { formatting in
        print("Applied formatting: \(formatting)")
    }
    .preferredColorScheme(.dark)
}