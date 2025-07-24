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
            // Background with seamless design
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isFocused ? Color.puchiPrimary.opacity(0.3) : Color.clear,
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
            
            // Placeholder text with better styling
            if text.isEmpty {
                Text(placeholder)
                    .font(.system(size: 17, design: .rounded))
                    .foregroundColor(.textSecondary.opacity(0.6))
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .allowsHitTesting(false)
            }
            
            // TextEditor with seamless styling like Tinder
            TextEditor(text: $text)
                .focused($isFocused)
                .font(.system(size: 17, design: .rounded))
                .foregroundColor(.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.clear)
                .scrollContentBackground(.hidden)
                .onSubmit {
                    isFocused = false
                }
        }
        .frame(height: 380) // Increased height for better user experience
        .animation(.easeInOut(duration: 0.2), value: isFocused)
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
            
            // NoteEntryView with seamless styling
            NoteEntryView(
                text: $loveNote,
                isFocused: _isTextFieldFocused,
                placeholder: "Write something sweet for \(partnerName)..."
            )
            .frame(maxWidth: .infinity)
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


