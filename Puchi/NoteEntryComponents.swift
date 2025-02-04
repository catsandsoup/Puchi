//
//  NoteEntryComponents.swift
//  Puchi
//
//  Created by Monty Giovenco on 1/2/2025.
//

import SwiftUI
import CoreLocation

struct NoteEntryView: View {
    @Binding var text: String
    @FocusState var isFocused: Bool
    var placeholder: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Placeholder text
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.leading, 12)  // Adjust horizontal padding for alignment
                    .padding(.top, 8)      // Adjust vertical padding for alignment
            }
            
            // TextEditor for user input
            TextEditor(text: $text)
                .focused($isFocused)  // Bind to FocusState
                .padding(.horizontal, 12)  // Adjust horizontal padding for alignment
                .padding(.vertical, 8)    // Adjust vertical padding
                .cornerRadius(8)
                .frame(height: 275)  // Set height to match your design
        }
        .background(Color.gray.opacity(0.1))  // Optional: background to highlight the area
        .cornerRadius(8)
        .padding(.horizontal)  // Optional: Adjust container padding
    }
}

struct NoteEntrySectionView: View {
    let partnerName: String
    @Binding var loveNote: String
    let onSave: () -> Void
    @ObservedObject var viewModel: LoveJournalViewModel
    @FocusState var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Love Note")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.puchiPrimary)
            
            // NoteEntryView with binding for loveNote
            NoteEntryView(
                text: $loveNote,
                isFocused: _isTextFieldFocused,
                placeholder: "Write something sweet for \(partnerName)..."
            )
            .puchiInput()  // Any custom styling for inputs, if necessary
            .frame(maxWidth: .infinity)  // Ensure it expands horizontally
            .frame(height: 275) // Adjust to your desired height
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.background)
                .shadow(color: .black.opacity(0.05), radius: 10)
        )
        .padding(.horizontal)
    }
}


