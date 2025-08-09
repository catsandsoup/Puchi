import SwiftUI
import PhotosUI

struct SettingsSectionHeader: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundColor(Color(hex: "FF5A5F"))
    }
}

struct SettingsCardView: View {
    let content: AnyView
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 10)
            )
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("partnerName") private var storedPartnerName = ""
    @AppStorage("partnerImageData") private var partnerImageData: Data?
    @AppStorage("isFirstTimeUser") private var isFirstTimeUser = false
    @ObservedObject var viewModel: LoveJournalViewModel
    
    @State private var newPartnerName = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showingResetAlert = false
    @State private var showingSaveAlert = false
    @State private var showingExportAlert = false
    @State private var showingDataInfo = false
    @State private var isProcessing = false
    
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Partner Details Section
                    VStack(alignment: .leading, spacing: 12) {
                        SettingsSectionHeader(text: "Partner Details")
                        
                        SettingsCardView(content: AnyView(
                            VStack(spacing: 20) {
                                // Partner Photo Section
                                VStack(spacing: 12) {
                                    Text("Partner Photo")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.puchiPrimary)
                                    
                                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                        if let data = partnerImageData, let uiImage = UIImage(data: data) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Color.puchiPrimary, lineWidth: 3))
                                                .shadow(color: .black.opacity(0.1), radius: 4)
                                        } else {
                                            Circle()
                                                .fill(Color.puchiPrimary.opacity(0.1))
                                                .frame(width: 100, height: 100)
                                                .overlay(
                                                    VStack(spacing: 4) {
                                                        Image(systemName: "person.crop.circle.badge.plus")
                                                            .font(.system(size: 30))
                                                        Text("Add Photo")
                                                            .font(.system(size: 12, weight: .medium))
                                                    }
                                                    .foregroundColor(.puchiPrimary)
                                                )
                                        }
                                    }
                                    .buttonStyle(ScaleButtonStyle())
                                }
                                
                                Divider()
                                
                                // Partner Name Section
                                VStack(spacing: 12) {
                                    Text("Partner Name")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.puchiPrimary)
                                    
                                    ZStack(alignment: .topLeading) {
                                        if newPartnerName.isEmpty {
                                            Text("Enter partner's name...")
                                                .font(.system(size: 16, design: .rounded))
                                                .foregroundColor(Color(.systemGray3))
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 12)
                                        }
                                        
                                        TextField("", text: $newPartnerName)
                                            .font(.system(size: 16, design: .rounded))
                                            .padding(12)
                                            .background(Color.clear)
                                    }
                                    .frame(height: 48)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.puchiPrimary.opacity(0.3), lineWidth: 1)
                                    )
                                    .onAppear { newPartnerName = storedPartnerName }
                                }
                                
                                // Save Button
                                DebouncedButton(debounceTime: 0.8, action: {
                                    HapticManager.light()
                                    if !newPartnerName.isEmpty {
                                        showingSaveAlert = true
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text("Save Changes")
                                    }
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(
                                        LinearGradient(
                                            colors: [Color.puchiPrimary, Color.puchiSecondary],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                    .shadow(color: .puchiPrimary.opacity(0.3), radius: 6)
                                }
                                .buttonStyle(PressableButtonStyle())
                                .disabled(newPartnerName.isEmpty || newPartnerName == storedPartnerName)
                                .opacity((newPartnerName.isEmpty || newPartnerName == storedPartnerName) ? 0.6 : 1.0)
                            }
                        ))
                    }
                    
                    // Data Management Section
                    VStack(alignment: .leading, spacing: 12) {
                        SettingsSectionHeader(text: "Your Data")
                        
                        SettingsCardView(content: AnyView(
                            VStack(spacing: 16) {
                                // Data Summary
                                Button(action: { showingDataInfo = true }) {
                                    HStack {
                                        Image(systemName: "info.circle.fill")
                                            .foregroundColor(.blue)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("View Data Summary")
                                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                            Text("\(viewModel.savedNotes.count) love notes stored")
                                                .font(.system(size: 14, design: .rounded))
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(12)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(10)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Export Data
                                Button(action: { 
                                    HapticManager.medium()
                                    showingExportAlert = true 
                                }) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.up.fill")
                                            .foregroundColor(.green)
                                        Text("Export Love Notes")
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.gray)
                                    }
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .padding(12)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(10)
                                }
                                .buttonStyle(ScaleButtonStyle())
                                
                                Divider()
                                
                                // Reset App - Dangerous Action
                                DebouncedButton(debounceTime: 1.0, action: { 
                                    HapticManager.error()
                                    showingResetAlert = true 
                                }) {
                                    HStack {
                                        Image(systemName: "trash.fill")
                                            .foregroundColor(.red)
                                        Text("Reset App")
                                        Spacer()
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.red)
                                    }
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .padding(12)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        ))
                    }
                    
                    // About Section
                    VStack(alignment: .leading, spacing: 8) {
                        SettingsSectionHeader(text: "About")
                        
                        SettingsCardView(content: AnyView(
                            VStack(spacing: 12) {
                                VStack(spacing: 4) {
                                    Text("Version \(appVersion) (\(buildNumber))")
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(.gray)
                                    
                                    Text("Developer: Monty Giovenco")
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(.gray)
                                    
                                    Text("© 2025")
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(.gray)
                                }
                                
                                Divider()
                                
                                HStack(spacing: 4) {
                                    Text("Made with")
                                        .font(.system(size: 14, design: .rounded))
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(Color(hex: "FF5A5F"))
                                    Text("in Sydney")
                                        .font(.system(size: 14, design: .rounded))
                                }
                                .foregroundColor(.gray)
                            }
                        ))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, -20)
                .padding(.bottom, 34)
            }
            .background(Color(hex: "F5F5F5"))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .top, spacing: 0) {
                Color.clear.frame(height: 34)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "FF5A5F"))
                }
            }
            .onChange(of: selectedPhoto) { _, newPhoto in
                Task {
                    if let newPhoto = newPhoto {
                        isProcessing = true
                        if let data = try? await newPhoto.loadTransferable(type: Data.self),
                           let image = UIImage(data: data),
                           let optimizedData = image.optimizedForStorage() {
                            await MainActor.run {
                                partnerImageData = optimizedData
                                HapticManager.success()
                                isProcessing = false
                            }
                        }
                    }
                }
            }
            .alert("Confirm Name Change", isPresented: $showingSaveAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Save") {
                    storedPartnerName = newPartnerName
                    HapticManager.success()
                }
            } message: {
                Text("Change your partner's name to '\(newPartnerName)'?\n\nThis will update all your love notes.")
            }
            .alert("Export Love Notes", isPresented: $showingExportAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Export as Text") {
                    exportNotesAsText()
                }
            } message: {
                Text("Export all \(viewModel.savedNotes.count) love notes as a text file to share or backup.")
            }
            .alert("Data Summary", isPresented: $showingDataInfo) {
                Button("OK") { }
            } message: {
                Text("💝 \(viewModel.savedNotes.count) love notes\n📸 \(getTotalMediaCount()) photos/videos\n📍 \(getNotesWithLocationCount()) notes with location\n\nYour precious memories are safely stored on this device.")
            }
            .alert("⚠️ Reset Warning", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset Everything", role: .destructive) {
                    resetAllData()
                    HapticManager.error()
                }
            } message: {
                Text("This will permanently delete:\n• All \(viewModel.savedNotes.count) love notes\n• Partner photo and name\n• All app data\n\nThis cannot be undone! Consider exporting first.")
            }
        }
    }
    
    // MARK: - Helper Functions
    private func getTotalMediaCount() -> Int {
        var count = 0
        for note in viewModel.savedNotes {
            if let images = note.images { count += images.count }
            if let videos = note.videos { count += videos.count }
        }
        return count
    }
    
    private func getNotesWithLocationCount() -> Int {
        return viewModel.savedNotes.filter { $0.location != nil }.count
    }
    
    private func exportNotesAsText() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .short
        
        var exportText = "💝 Love Notes Export\n"
        exportText += "Partner: \(storedPartnerName)\n"
        exportText += "Exported: \(dateFormatter.string(from: Date()))\n"
        exportText += "Total Notes: \(viewModel.savedNotes.count)\n\n"
        exportText += String(repeating: "=", count: 50) + "\n\n"
        
        for (_, note) in viewModel.savedNotes.enumerated().reversed() {
            exportText += "Love Note #\(note.noteNumber)\n"
            exportText += "Date: \(dateFormatter.string(from: note.date))\n"
            if let location = note.location {
                exportText += "Location: \(location.placeName)\n"
            }
            exportText += "\n\(note.text)\n"
            if let images = note.images, !images.isEmpty {
                exportText += "\n📸 Contains \(images.count) photo(s)\n"
            }
            if let videos = note.videos, !videos.isEmpty {
                exportText += "\n🎥 Contains \(videos.count) video(s)\n"
            }
            exportText += "\n" + String(repeating: "-", count: 30) + "\n\n"
        }
        
        // Share the text
        let activityVC = UIActivityViewController(
            activityItems: [exportText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            
            if let presentationController = activityVC.popoverPresentationController {
                presentationController.sourceView = window
                // Prevent NaN by ensuring non-zero frame dimensions
                let safeX = window.frame.width > 0 ? window.frame.width / 2 : 0
                let safeY = window.frame.height > 0 ? window.frame.height / 2 : 0
                presentationController.sourceRect = CGRect(x: safeX, y: safeY, width: 0, height: 0)
                presentationController.permittedArrowDirections = []
            }
            
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private func resetAllData() {
        // Clear all stored data
        UserDefaults.standard.removeObject(forKey: "savedNotes")
        UserDefaults.standard.removeObject(forKey: "partnerImageData")
        UserDefaults.standard.removeObject(forKey: "lastNoteDate")
        storedPartnerName = ""
        partnerImageData = nil
        isFirstTimeUser = true
        
        // Dismiss settings and return to welcome
        dismiss()
    }
}

#Preview {
    SettingsView(viewModel: LoveJournalViewModel())
}
