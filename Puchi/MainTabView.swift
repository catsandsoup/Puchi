//
//  MainTabView.swift
//  Puchi
//
//  Created by Monty Giovenco on 1/2/2025.
//
import SwiftUI
import PhotosUI

//Note History Page
struct NotesHistoryPage: View {
    let notes: [LoveNote]
    @StateObject var viewModel: LoveJournalViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Love Note History")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "FF5A5F"))
                .padding(.top, 16)
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(Array(notes.enumerated()), id: \.element.id) { index, note in
                        NoteCard(note: note) {
                            viewModel.deleteNote(at: IndexSet([index]))
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color(hex: "F5F5F5"))
    }
}

//Main Tab View
struct MainTabView: View {
    @Binding var currentPage: Int
    let partnerName: String
    @ObservedObject var viewModel: LoveJournalViewModel
    @Binding var partnerImageData: Data?
    @Binding var selectedPhoto: PhotosPickerItem?
    @FocusState var isTextFieldFocused: Bool
    
    var body: some View {
        TabView(selection: $currentPage) {
            MainContent(
                partnerName: partnerName,
                viewModel: viewModel,
                partnerImageData: $partnerImageData,
                selectedPhoto: $selectedPhoto,
                isTextFieldFocused: _isTextFieldFocused
            )
            .tag(0)
            
            NotesHistoryPage(notes: viewModel.savedNotes, viewModel: viewModel)
                .tag(1)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

// MARK: - Preview
struct MainTabView_Previews: PreviewProvider {
    @FocusState static var previewFocus: Bool
    
    static var previews: some View {
        MainTabView(
            currentPage: .constant(0),
            partnerName: "Preview Partner",
            viewModel: LoveJournalViewModel(),
            partnerImageData: .constant(nil),
            selectedPhoto: .constant(nil),
            isTextFieldFocused: _previewFocus
        )
    }
}
