import SwiftUI
import MessageUI

// MARK: - Note Card Image Section
struct NoteCardImageSection: View {
    let images: [MediaItem]?
    
    var body: some View {
        Group {
            if let images = images, !images.isEmpty {
                if let firstImage = images.first,
                   let uiImage = UIImage(data: firstImage.data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}

// MARK: - Note Card Content Section
struct NoteCardContentSection: View {
    let note: LoveNote
    let onShowActionSheet: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Note Header
            HStack {
                Text("Love Note #\(note.noteNumber)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.puchiPrimary)
                
                Spacer()
                
                // More Actions Button
                Button(action: {
                    HapticManager.light()
                    onShowActionSheet()
                }) {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.puchiPrimary.opacity(0.8))
                }
                .buttonStyle(ScaleButtonStyle())
            }
            
            // Note Text
            Text(note.text)
                .font(.system(size: 16, design: .rounded))
                .lineSpacing(4)
                .lineLimit(6)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.leading)
            
            // Footer Info
            HStack(spacing: 8) {
                // Date
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                    Text(note.dateFormatted)
                }
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.textSecondary)
                
                // Location if available
                if let location = note.location {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 12))
                        Text(location.placeName)
                    }
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.textSecondary)
                }
            }
        }
        .padding(20)
    }
}

// MARK: - Main Note Card
struct NoteCard: View {
    let note: LoveNote
    let onDelete: () -> Void
    
    @State private var showActionSheet = false
    @State private var isPressed = false
    @State private var showShareSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Section
            NoteCardImageSection(images: note.images)
                .transition(.opacity.combined(with: .scale))
            
            // Content Section
            NoteCardContentSection(note: note) {
                withAnimation(PuchiAnimation.spring) {
                    showActionSheet = true
                }
            }
        }
        .background(Color.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(
            color: .black.opacity(0.05),
            radius: 8,
            x: 0,
            y: isPressed ? 2 : 4
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        // Add press animation
        .onTapGesture {
            withAnimation(PuchiAnimation.spring) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(PuchiAnimation.spring) {
                    isPressed = false
                }
            }
            HapticManager.light()
        }
        // Action Sheet
        .confirmationDialog("Note Actions", isPresented: $showActionSheet) {
            Button("Share") {
                HapticManager.medium()
                shareNote()
            }
            
            Button("Delete", role: .destructive) {
                HapticManager.error()
                withAnimation(PuchiAnimation.spring) {
                    onDelete()
                }
            }
            
            Button("Cancel", role: .cancel) {
                HapticManager.light()
            }
        }
    }
    
    // Share functionality
    private func shareNote() {
        let shareText = """
        Love Note #\(note.noteNumber)
        
        \(note.text)
        
        Written on \(note.date.formatted())
        """
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootVC = window.rootViewController else { return }
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let presentationController = activityVC.popoverPresentationController {
            presentationController.sourceView = window
            presentationController.sourceRect = CGRect(x: window.frame.width / 2,
                                                     y: window.frame.height / 2,
                                                     width: 0,
                                                     height: 0)
            presentationController.permittedArrowDirections = []
        }
        
        rootVC.present(activityVC, animated: true)
    }
}

// Preview Provider
#Preview {
    NoteCard(
        note: LoveNote(
            text: "Sample love note text for preview",
            partnerName: "Partner",
            date: Date(),
            noteNumber: 1,
            location: LocationData(
                latitude: 0,
                longitude: 0,
                placeName: "Sample Location"
            ),
            tags: ["preview", "sample"]
        ),
        onDelete: {}
    )
    .padding()
}
