import SwiftUI

struct TagsEditorView: View {
    @Binding var tags: [String]
    @Environment(\.dismiss) private var dismiss
    @State private var newTag = ""
    @FocusState private var tagFieldFocused: Bool
    
    // Common tag suggestions
    private let suggestedTags = [
        "love", "datenight", "adventure", "cozy", "special", "memories",
        "romantic", "fun", "cute", "sweet", "happy", "together",
        "anniversary", "surprise", "weekend", "vacation", "home"
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Add Tags")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("Tag your memories to find them easier later")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 16)
                        
                        // Add new tag section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Add New Tag")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack {
                                TextField("Enter tag name...", text: $newTag)
                                    .focused($tagFieldFocused)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .onSubmit {
                                        addTag()
                                    }
                                
                                Button("Add", action: addTag)
                                    .foregroundColor(.pink)
                                    .disabled(newTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemGray6).opacity(0.2))
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Current tags
                        if !tags.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Your Tags")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                FlowLayout(spacing: 8) {
                                    ForEach(tags, id: \.self) { tag in
                                        TagChip(tag: tag, isRemovable: true) {
                                            removeTag(tag)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Suggested tags
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Suggested Tags")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(availableSuggestedTags, id: \.self) { tag in
                                    TagChip(tag: tag, isRemovable: false) {
                                        addSuggestedTag(tag)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationTitle("Edit Tags")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.pink)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.pink)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                tagFieldFocused = true
            }
        }
    }
    
    private var availableSuggestedTags: [String] {
        suggestedTags.filter { !tags.contains($0) }
    }
    
    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmedTag.isEmpty && !tags.contains(trimmedTag) else { return }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            tags.append(trimmedTag)
            newTag = ""
        }
    }
    
    private func addSuggestedTag(_ tag: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            tags.append(tag)
        }
    }
    
    private func removeTag(_ tag: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            tags.removeAll { $0 == tag }
        }
    }
}

struct TagChip: View {
    let tag: String
    let isRemovable: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text("#\(tag)")
                    .font(.subheadline)
                
                if isRemovable {
                    Image(systemName: "xmark")
                        .font(.caption)
                }
            }
            .foregroundColor(isRemovable ? .white : .pink)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isRemovable ? Color.pink.opacity(0.2) : Color.clear)
                    .stroke(Color.pink.opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Flow Layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.width ?? .infinity,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: ProposedViewSize(result.sizes[index]))
        }
    }
}

struct FlowResult {
    var size = CGSize.zero
    var positions: [CGPoint] = []
    var sizes: [CGSize] = []
    
    init(in maxWidth: CGFloat, subviews: LayoutSubviews, spacing: CGFloat) {
        var currentPosition = CGPoint.zero
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let subviewSize = subview.sizeThatFits(.unspecified)
            
            if currentPosition.x + subviewSize.width > maxWidth && !positions.isEmpty {
                // Start a new line
                currentPosition.x = 0
                currentPosition.y += lineHeight + spacing
                lineHeight = 0
            }
            
            positions.append(currentPosition)
            sizes.append(subviewSize)
            
            currentPosition.x += subviewSize.width + spacing
            lineHeight = max(lineHeight, subviewSize.height)
        }
        
        size = CGSize(
            width: maxWidth,
            height: currentPosition.y + lineHeight
        )
    }
}

#Preview {
    @Previewable @State var tags: [String] = ["love", "datenight", "special"]
    return TagsEditorView(tags: $tags)
        .preferredColorScheme(.dark)
}