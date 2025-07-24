//
//  MainTabView.swift
//  Puchi
//
//  Created by Monty Giovenco on 1/2/2025.
//
import SwiftUI
import PhotosUI

// Timeline Page - Enhanced timeline view with integrated display
struct TimelinePage: View {
    let notes: [LoveNote]
    @StateObject var viewModel: LoveJournalViewModel
    
    var body: some View {
        TimelineView(notes: notes, viewModel: viewModel)
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
            .onTapGesture {
                isTextFieldFocused = false
            }
            .gesture(
                DragGesture()
                    .onChanged { _ in
                        isTextFieldFocused = false
                    }
            )
            
            TimelinePage(notes: viewModel.savedNotes, viewModel: viewModel)
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
