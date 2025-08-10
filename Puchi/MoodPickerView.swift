import SwiftUI

struct MoodPickerView: View {
    @Binding var selectedMood: Mood?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("How are you feeling?")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("Add a mood to capture this moment's essence")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 16)
                        
                        // Mood grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(Mood.allCases, id: \.self) { mood in
                                MoodOptionView(
                                    mood: mood,
                                    isSelected: selectedMood == mood
                                ) {
                                    selectMood(mood)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Clear mood option
                        if selectedMood != nil {
                            Button(action: clearMood) {
                                HStack {
                                    Image(systemName: "xmark.circle")
                                        .foregroundColor(.gray)
                                    Text("Remove Mood")
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule()
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                )
                            }
                            .padding(.top, 8)
                        }
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationTitle("Select Mood")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.pink)
                }
            }
        }
    }
    
    private func selectMood(_ mood: Mood) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedMood = mood
        }
        
        // Auto-dismiss after selection
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dismiss()
        }
    }
    
    private func clearMood() {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedMood = nil
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dismiss()
        }
    }
}

struct MoodOptionView: View {
    let mood: Mood
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Emoji
                Text(mood.emoji)
                    .font(.system(size: 48))
                
                // Mood name
                Text(mood.rawValue.capitalized)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .gray)
                
                // Description
                Text(moodDescription(for: mood))
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(height: 140)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? moodColor(for: mood).opacity(0.2) : Color.clear)
                    .stroke(isSelected ? moodColor(for: mood) : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func moodDescription(for mood: Mood) -> String {
        switch mood {
        case .amazing:
            return "On top of the world!"
        case .happy:
            return "Joyful and content"
        case .content:
            return "Peaceful and satisfied"
        case .neutral:
            return "Balanced and calm"
        case .sad:
            return "Feeling down"
        case .romantic:
            return "Full of love"
        case .grateful:
            return "Thankful and blessed"
        }
    }
    
    private func moodColor(for mood: Mood) -> Color {
        switch mood {
        case .amazing:
            return .yellow
        case .happy:
            return .orange
        case .content:
            return .green
        case .neutral:
            return .gray
        case .sad:
            return .blue
        case .romantic:
            return .pink
        case .grateful:
            return .purple
        }
    }
}

#Preview {
    @Previewable @State var selectedMood: Mood? = .happy
    return MoodPickerView(selectedMood: $selectedMood)
        .preferredColorScheme(.dark)
}