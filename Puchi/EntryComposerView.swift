import SwiftUI
import PhotosUI

struct EntryComposerView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var showSaveHearts = false
    
    @State private var title = ""
    @State private var content = ""
    // LANDMARK: Initialize with proper theme color to avoid invisible text on startup
    @State private var richContent = SimpleRichTextEditor.createThemedAttributedString(from: "")
    @State private var showingFormatPanel = false
    @State private var showingLocationPicker = false
    @State private var mediaItems: [MediaItem] = []
    @State private var location: LocationInfo? = nil
    @State private var mood: Mood? = nil
    @State private var tags: [String] = []
    @State private var weather: String? = nil
    @State private var newTag = ""
    @State private var showingMediaPicker = false
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var showingCamera = false
    @State private var showingMoodPicker = false
    @State private var showingTagsEditor = false
    @State private var showingVoiceRecorder = false
    @State private var richTextEditor: RichTextEditor?
    
    @FocusState private var titleFocused: Bool
    @FocusState private var contentFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.puchiBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Date header like Journal
                        DateHeaderView()
                        
                        // Title field
                        TitleFieldView()
                        
                        // Rich Content field  
                        RichContentFieldView()
                        
                        // Media preview
                        if !mediaItems.isEmpty {
                            MediaPreviewView()
                        }
                        
                        // Mood display
                        if let mood = mood {
                            MoodDisplayView(mood: mood)
                        }
                        
                        // Tags display
                        if !tags.isEmpty {
                            TagsDisplayView()
                        }
                        
                        // Location display
                        if let location = location {
                            LocationView(location: location)
                        }
                        
                        // Weather display
                        if let weather = weather {
                            WeatherDisplayView(weather: weather)
                        }
                        
                        // Love prompts (when empty)
                        if title.isEmpty && richContent.characters.isEmpty {
                            LovePromptsView()
                        }
                        
                        Spacer(minLength: 200) // Space for toolbar
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                
                // Journal-style bottom toolbar
                MediaToolbarView()
                
                // Heart animation overlay for save moments
                if showSaveHearts {
                    FloatingHeartsView()
                        .allowsHitTesting(false)
                }
            }
            .navigationTitle("New Memory")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.puchiAccent)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        saveEntry()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.puchiAccent)
                    .disabled(title.isEmpty && richContent.characters.isEmpty && mediaItems.isEmpty)
                }
            }
        }
        .onAppear {
            // Pre-populate if editing existing entry
            if let editingEntry = appState.editingEntry {
                title = editingEntry.title
                content = editingEntry.content
                // LANDMARK: Ensure loaded content has proper color attributes
                richContent = SimpleRichTextEditor.ensureProperColorAttributes(editingEntry.attributedContent)
                mediaItems = editingEntry.mediaItems
                location = editingEntry.location
                mood = editingEntry.mood
                tags = editingEntry.tags
                weather = editingEntry.weather
            }
            
            // Focus title first like Journal
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                titleFocused = true
            }
        }
        .onChange(of: selectedPhotos) { _, newPhotos in
            Task {
                for photo in newPhotos {
                    if let data = try? await photo.loadTransferable(type: Data.self),
                       let image = UIImage(data: data),
                       let optimizedData = image.jpegData(compressionQuality: 0.8) {
                        await MainActor.run {
                            let mediaItem = MediaItem(data: optimizedData, type: .photo)
                            mediaItems.append(mediaItem)
                        }
                    }
                }
                selectedPhotos = [] // Clear selection
            }
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraView { imageData in
                if let imageData = imageData {
                    let mediaItem = MediaItem(data: imageData, type: .photo)
                    mediaItems.append(mediaItem)
                }
                showingCamera = false
            }
        }
        .sheet(isPresented: $showingMoodPicker) {
            MoodPickerView(selectedMood: $mood)
        }
        .sheet(isPresented: $showingTagsEditor) {
            TagsEditorView(tags: $tags)
        }
        .sheet(isPresented: $showingVoiceRecorder) {
            VoiceRecorderView { recordingData in
                if let data = recordingData {
                    let voiceNote = MediaItem(data: data, type: .voice)
                    mediaItems.append(voiceNote)
                }
            }
        }
        .sheet(isPresented: $showingFormatPanel) {
            BasicFormatPanelView { formatting in
                applyFormatting(formatting)
            }
        }
        .sheet(isPresented: $showingLocationPicker) {
            LocationPickerView { selectedLocation in
                location = selectedLocation
            }
        }
    }
    
    private func applyFormatting(_ formatting: BasicFormatting) {
        // Apply formatting to rich content through the active text editor
        switch formatting {
        case .bold:
            SimpleRichTextEditor.activeCoordinator?.applyBold()
        case .italic:
            SimpleRichTextEditor.activeCoordinator?.applyItalic()
        case .underline:
            SimpleRichTextEditor.activeCoordinator?.applyUnderline()
        }
    }
    
    private func saveEntry() {
        // Show heart animation for romantic save moment
        withAnimation(.easeIn(duration: 0.3)) {
            showSaveHearts = true
        }
        
        // Slight delay for heart animation, then save
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let editingEntry = appState.editingEntry {
                // Update existing entry
                var updatedEntry = editingEntry
                updatedEntry.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
                updatedEntry.attributedContent = richContent
                updatedEntry.mediaItems = mediaItems
                updatedEntry.location = location
                updatedEntry.mood = mood
                updatedEntry.tags = tags
                updatedEntry.weather = weather
                
                withAnimation(.easeInOut) {
                    appState.updateEntry(updatedEntry)
                    appState.cancelEditing()
                }
            } else {
                // Create new entry
                var newEntry = LoveEntry(
                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                    content: String(richContent.characters).trimmingCharacters(in: .whitespacesAndNewlines),
                    date: Date(),
                    mediaItems: mediaItems,
                    location: location,
                    mood: mood,
                    weather: weather,
                    tags: tags
                )
                newEntry.attributedContent = richContent
                
                withAnimation(.easeInOut) {
                    appState.addEntry(newEntry)
                }
            }
            
            // Dismiss after brief delay for hearts
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                dismiss()
            }
        }
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private func DateHeaderView() -> some View {
        HStack {
            Text(DateFormatter.composerHeader.string(from: Date()))
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.puchiTextSecondary)
            Spacer()
        }
    }
    
    @ViewBuilder
    private func TitleFieldView() -> some View {
        TextField("Title", text: $title, axis: .vertical)
            .focused($titleFocused)
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.puchiText)
            .textFieldStyle(PlainTextFieldStyle())
            .onSubmit {
                contentFocused = true
            }
    }
    
    @ViewBuilder  
    private func ContentFieldView() -> some View {
        TextField("Start writing...", text: $content, axis: .vertical)
            .focused($contentFocused)
            .font(.body)
            .foregroundColor(.puchiText)
            .textFieldStyle(PlainTextFieldStyle())
            .lineLimit(10...100)
    }
    
    @ViewBuilder
    private func RichContentFieldView() -> some View {
        SimpleRichTextEditor(
            attributedText: $richContent,
            placeholder: "Start writing..."
        )
        .frame(minHeight: 120)
    }
    
    @ViewBuilder
    private func MediaPreviewView() -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8)
        ], spacing: 8) {
            ForEach(mediaItems) { item in
                MediaItemView(mediaItem: item)
                    .aspectRatio(1, contentMode: .fill)
                    .cornerRadius(8)
                    .clipped()
                    .overlay(alignment: .topTrailing) {
                        Button(action: {
                            mediaItems.removeAll { $0.id == item.id }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.puchiText)
                                .background(Circle().fill(Color.red))
                        }
                        .padding(8)
                    }
            }
        }
    }
    
    @ViewBuilder
    private func LocationView(location: LocationInfo) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "location.fill")
                .foregroundColor(.puchiAccent)
            Text(location.name)
                .foregroundColor(.puchiTextSecondary)
            Spacer()
            Button("Remove") {
                self.location = nil
            }
            .font(.caption)
            .foregroundColor(.red)
        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private func MoodDisplayView(mood: Mood) -> some View {
        HStack(spacing: 8) {
            Text(mood.emoji)
                .font(.title3)
            Text("Feeling \(mood.rawValue)")
                .font(.subheadline)
                .foregroundColor(.puchiTextSecondary)
            Spacer()
            Button("Change") {
                showingMoodPicker = true
            }
            .font(.caption)
            .foregroundColor(.puchiAccent)
            Button("Remove") {
                self.mood = nil
            }
            .font(.caption)
            .foregroundColor(.red)
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $showingMoodPicker) {
            MoodPickerView(selectedMood: $mood)
        }
    }
    
    @ViewBuilder
    private func TagsDisplayView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "tag")
                    .foregroundColor(.puchiAccent)
                Text("Tags")
                    .font(.subheadline)
                    .foregroundColor(.puchiTextSecondary)
                Spacer()
                Button("Edit") {
                    showingTagsEditor = true
                }
                .font(.caption)
                .foregroundColor(.puchiAccent)
            }
            
            FlowLayout(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.caption)
                        .foregroundColor(.puchiAccent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.puchiAccent.opacity(0.1))
                                .stroke(Color.puchiAccent.opacity(0.3), lineWidth: 1)
                        )
                }
            }
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $showingTagsEditor) {
            TagsEditorView(tags: $tags)
        }
    }
    
    @ViewBuilder
    private func WeatherDisplayView(weather: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "cloud.sun")
                .foregroundColor(.blue)
            Text(weather)
                .foregroundColor(.puchiTextSecondary)
            Spacer()
            Button("Remove") {
                self.weather = nil
            }
            .font(.caption)
            .foregroundColor(.red)
        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private func LovePromptsView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("💕 Love prompts:")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.puchiTextSecondary)
            
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(lovePrompts, id: \.self) { prompt in
                    Button(action: {
                        // FIXED: Use themed AttributedString to prevent invisible text
                        // LANDMARK: Always use SimpleRichTextEditor.createThemedAttributedString
                        // when setting richContent from plain text to ensure proper colors
                        richContent = SimpleRichTextEditor.createThemedAttributedString(from: prompt)
                        contentFocused = true
                    }) {
                        Text(prompt)
                            .font(.callout)
                            .foregroundColor(.puchiText)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.puchiAccent.opacity(0.2))
                                    .stroke(Color.puchiAccent.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    @ViewBuilder
    private func MediaToolbarView() -> some View {
        VStack {
            Spacer()
            
            HStack(spacing: 16) {
                // Text formatting
                ToolbarButton(icon: "textformat", action: {
                    showingFormatPanel = true
                })
                
                // Photo Library
                PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 5, matching: .images) {
                    Image(systemName: "photo")
                        .font(.title3)
                        .foregroundColor(.puchiAccent)
                }
                
                // Camera
                ToolbarButton(icon: "camera", action: {
                    showingCamera = true
                })
                
                // Voice note
                ToolbarButton(icon: "waveform", action: {
                    // Ensure no other sheets are showing before presenting voice recorder
                    if !showingMoodPicker && !showingTagsEditor && !showingCamera {
                        showingVoiceRecorder = true
                    }
                })
                
                // Mood
                ToolbarButton(icon: mood?.emoji ?? "face.smiling", action: {
                    showingMoodPicker = true
                })
                
                // Tags
                ToolbarButton(icon: "tag", action: {
                    showingTagsEditor = true
                })
                
                // Location
                ToolbarButton(icon: "location", action: {
                    showingLocationPicker = true
                })
                
                Spacer()
                
                // Character count
                if content.count > 50 {
                    Text("\(content.count)")
                        .font(.caption)
                        .foregroundColor(.puchiTextSecondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.8))
        }
    }
    
    @ViewBuilder
    private func ToolbarButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            if icon.count == 1 && icon.unicodeScalars.allSatisfy({ $0.isEmoji }) {
                // Handle emoji icons
                Text(icon)
                    .font(.title3)
            } else {
                // Handle system icons
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.puchiAccent)
            }
        }
    }
    
    private let lovePrompts = [
        "Today I loved how you...",
        "You made me smile when...", 
        "I'm grateful for...",
        "Our perfect moment was...",
        "You always make me feel..."
    ]
}

extension DateFormatter {
    static let composerHeader: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }()
}

extension Unicode.Scalar {
    var isEmoji: Bool {
        switch value {
        case 0x1F600...0x1F64F, // Emoticons
             0x1F300...0x1F5FF, // Misc Symbols and Pictographs
             0x1F680...0x1F6FF, // Transport and Map
             0x1F1E6...0x1F1FF, // Regional country flags
             0x2600...0x26FF,   // Misc symbols
             0x2700...0x27BF,   // Dingbats
             0xFE00...0xFE0F,   // Variation Selectors
             0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
             127000...127600,    // Various asian characters
             65024...65039,      // Variation selector
             9100...9300,        // Misc items
             8400...8447:        // Combining Diacritical Marks for Symbols
            return true
        default:
            return false
        }
    }
}

#Preview {
    EntryComposerView()
        .environment(AppState())
}