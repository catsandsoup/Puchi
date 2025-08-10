import SwiftUI

struct FormatPanelView: View {
    let onFormatApply: (TextFormatting) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedColor: Color = .white
    @State private var showingColorPicker = false
    
    private let colors: [Color] = [
        .white, .red, .orange, .yellow, .green, .blue, .purple, .pink,
        .gray, .black, .brown, .mint, .teal, .cyan, .indigo
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Text Formatting Section
                formatSection("Text Style", content: {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        FormatButton(
                            icon: "bold",
                            label: "B",
                            action: { onFormatApply(.bold) }
                        )
                        
                        FormatButton(
                            icon: "italic",
                            label: "I",
                            action: { onFormatApply(.italic) }
                        )
                        
                        FormatButton(
                            icon: "underline",
                            label: "U",
                            action: { onFormatApply(.underline) }
                        )
                        
                        FormatButton(
                            icon: "strikethrough",
                            label: "S",
                            action: { onFormatApply(.strikethrough) }
                        )
                    }
                })
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.vertical, 16)
                
                // List Formatting Section
                formatSection("Lists", content: {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        FormatButton(
                            icon: "list.bullet",
                            label: "•",
                            action: { onFormatApply(.bulletList) }
                        )
                        
                        FormatButton(
                            icon: "list.number",
                            label: "1.",
                            action: { onFormatApply(.numberedList) }
                        )
                    }
                })
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.vertical, 16)
                
                // Color Section
                formatSection("Text Color", content: {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(colors, id: \.self) { color in
                            ColorButton(
                                color: color,
                                isSelected: selectedColor == color,
                                action: {
                                    selectedColor = color
                                    onFormatApply(.color(UIColor(color)))
                                }
                            )
                        }
                    }
                    
                    // Custom color picker button
                    Button(action: {
                        showingColorPicker = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.red, .orange, .yellow, .green, .blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.top, 12)
                })
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .background(Color.black)
            .navigationTitle("Format")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.title3)
                    }
                }
            }
        }
        .sheet(isPresented: $showingColorPicker) {
            ColorPicker("Choose Color", selection: $selectedColor)
                .onChange(of: selectedColor) { _, newColor in
                    onFormatApply(.color(UIColor(newColor)))
                }
                .presentationDetents([.medium])
                .preferredColorScheme(.dark)
        }
    }
    
    @ViewBuilder
    private func formatSection<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            
            content()
        }
    }
}

struct FormatButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            action()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isPressed ? Color.pink.opacity(0.3) : Color.gray.opacity(0.2))
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    .frame(width: 60, height: 60)
                
                if label.count == 1 && !["•", "1."].contains(label) {
                    Text(label)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                } else {
                    if icon == "list.bullet" {
                        Text("•")
                            .font(.title)
                            .foregroundColor(.white)
                    } else if icon == "list.number" {
                        Text("1.")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: icon)
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }
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

struct ColorButton: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            action()
        }) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .stroke(color == .white ? Color.gray : Color.clear, lineWidth: 1)
                    )
                
                if isSelected {
                    Circle()
                        .stroke(Color.pink, lineWidth: 3)
                        .frame(width: 50, height: 50)
                }
                
                // Checkmark for selected color
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(color == .white || color == .yellow ? .black : .white)
                }
            }
        }
    }
}

#Preview {
    FormatPanelView { formatting in
        print("Applied formatting: \(formatting)")
    }
    .preferredColorScheme(.dark)
}