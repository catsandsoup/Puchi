import SwiftUI
import PhotosUI

struct MainAppView: View {
    @StateObject private var viewModel = LoveJournalViewModel()
    @AppStorage("partnerImageData") private var partnerImageData: Data?
    @AppStorage("partnerName") private var storedPartnerName = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var currentPage = 0
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
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
                    
                    // Notes History Page
                    NotesList(notes: viewModel.savedNotes, viewModel: viewModel)
                        .tag(1)
                        .transition(.opacity)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: currentPage) { oldValue, newValue in
                    // Add haptic feedback when changing pages
                    HapticManager.light()
                }
                
                // Custom Page Indicator
                AnimatedPageIndicator(currentPage: $currentPage, numberOfPages: 2)
                    .padding(.bottom, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Puchi")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.puchiPrimary)
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
