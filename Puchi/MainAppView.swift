import SwiftUI
import PhotosUI

struct MainAppView: View {
    @StateObject private var viewModel = LoveJournalViewModel()
    @StateObject private var navigationHintManager = NavigationHintManager()
    @AppStorage("partnerImageData") private var partnerImageData: Data?
    @AppStorage("partnerName") private var storedPartnerName = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var currentPage = 0
    @State private var showingSettings = false
    @FocusState private var isTextFieldFocused: Bool
    
    private var hasContentInCurrentPage: Bool {
        currentPage == 0 && (!viewModel.loveNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
                            !viewModel.mediaManager.selectedMedia.isEmpty || 
                            viewModel.currentLocation != nil)
    }
    
    var body: some View {
        NavigationStack {
            NavigationHintsContainer(
                hintManager: navigationHintManager,
                currentPage: $currentPage,
                hasNotes: !viewModel.savedNotes.isEmpty
            ) {
                ZStack(alignment: .bottom) {
                    // Main Content TabView
                    TabView(selection: $currentPage) {
                        // Love Note Creation Page
                        MainContent(
                            partnerName: storedPartnerName,
                            viewModel: viewModel,
                            partnerImageData: $partnerImageData,
                            selectedPhoto: $selectedPhoto,
                            isTextFieldFocused: _isTextFieldFocused
                        )
                        .tag(0)
                        .transition(.opacity)
                        
                        // Timeline Page
                        TimelineView(notes: viewModel.savedNotes, viewModel: viewModel)
                            .tag(1)
                            .transition(.opacity)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .onChange(of: currentPage) { oldValue, newValue in
                        // Add haptic feedback when changing pages
                        HapticManager.light()
                        // Dismiss keyboard when changing pages
                        isTextFieldFocused = false
                        // Also dismiss any system keyboard
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    
                    // Custom Page Indicator
                    AnimatedPageIndicator(currentPage: $currentPage, numberOfPages: 2)
                        .padding(.bottom, hasContentInCurrentPage ? 94 : 34) // Dynamic padding based on content
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Puchi")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.puchiPrimary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        HapticManager.light()
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.puchiPrimary)
                            .frame(width: 44, height: 44) // Proper touch target
                            .contentShape(Circle())
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(viewModel: viewModel)
            }
            .onChange(of: selectedPhoto) { _, newPhoto in
                Task {
                    if let newPhoto = newPhoto {
                        if let data = try? await newPhoto.loadTransferable(type: Data.self),
                           let image = UIImage(data: data),
                           let optimizedData = image.optimizedForStorage() {
                            await MainActor.run {
                                partnerImageData = optimizedData
                                HapticManager.success()
                            }
                        }
                        // Clear the selectedPhoto to allow selecting the same photo again
                        selectedPhoto = nil
                    }
                }
            }
            .background(Color.puchiBackground)
        }
    }
}

// Preview Provider
#Preview {
    MainAppView()
}
