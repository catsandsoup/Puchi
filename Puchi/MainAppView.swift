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
                    .onTapGesture {
                        isTextFieldFocused = false
                    }
                    
                    // Custom Page Indicator
                    AnimatedPageIndicator(currentPage: $currentPage, numberOfPages: 2)
                        .padding(.bottom, 34) // Increased padding to ensure visibility above home indicator
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
            .background(Color.puchiBackground)
        }
    }
}

// Preview Provider
#Preview {
    MainAppView()
}
