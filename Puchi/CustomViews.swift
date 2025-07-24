//
//  CustomViews.swift
//  Puchi
//
//  Created by Monty Giovenco on 27/1/2025.
//

import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: 16, design: .rounded))
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}
// MARK: - Partner Header Components (from HeaderComponents.swift)
struct PartnerHeaderView: View {
    let partnerName: String
    let partnerImageData: Data?
    let selectedPhoto: Binding<PhotosPickerItem?>
    
    var body: some View {
        HStack(spacing: 16) {
            PhotosPicker(selection: selectedPhoto, matching: .images) {
                if let data = partnerImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color(hex: "FF5A5F"), lineWidth: 2))
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(Color(hex: "FF5A5F").opacity(0.3))
                }
            }
            .accessibilityLabel("Change partner photo")
            
            VStack(alignment: .leading, spacing: 4) {
                Text(partnerName)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "FF5A5F"))
                
                Text("Your Love Story")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color(.systemGray))
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }
}

// MARK: - Note Entry Components (from NoteEntryComponents.swift)
struct NoteEntryView: View {
    @Binding var text: String
    @FocusState var isFocused: Bool
    var placeholder: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
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
            
            if text.isEmpty {
                Text(placeholder)
                    .font(.system(size: 17, design: .rounded))
                    .foregroundColor(.textSecondary.opacity(0.6))
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .allowsHitTesting(false)
            }
            
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
        .frame(height: 380)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Streak Card (from StreakCardView.swift)
struct StreakCardView: View {
    let streakCount: Int
    
    var body: some View {
        HStack(spacing: 8) {
            Spacer()
            
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(Color(hex: "FF5A5F"))
            
            Text("\(streakCount) Days Love Streak")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color(hex: "FF5A5F"))
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10)
        )
        .padding(.horizontal)
    }
}