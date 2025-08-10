//
//  OnboardingView.swift
//  Puchi
//
//  Clean Journal-style onboarding
//

import SwiftUI
import PhotosUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var partnerName = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @FocusState private var nameFieldFocused: Bool
    
    var body: some View {
        ZStack {
            // Journal-style dark background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // App icon/logo
                VStack(spacing: 16) {
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.pink)
                    
                    Text("💕 Puchi")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                // Intro text
                VStack(spacing: 12) {
                    Text("Your Love Story Journal")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Capture and cherish beautiful moments\nwith the one you love")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // Partner setup
                VStack(spacing: 24) {
                    // Partner photo
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 120, height: 120)
                            
                            if let photoData = appState.partnerPhotoData,
                               let image = UIImage(data: photoData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            } else {
                                VStack(spacing: 8) {
                                    Image(systemName: "person.crop.circle.fill.badge.plus")
                                        .font(.system(size: 32))
                                        .foregroundColor(.gray)
                                    Text("Add Photo")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    
                    // Partner name field
                    VStack(spacing: 8) {
                        TextField("Partner's name", text: $partnerName)
                            .focused($nameFieldFocused)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(PlainTextFieldStyle())
                            .onSubmit {
                                if !partnerName.isEmpty {
                                    completeOnboarding()
                                }
                            }
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(height: 1)
                            .frame(maxWidth: 200)
                    }
                }
                
                Spacer()
                
                // Continue button
                Button(action: completeOnboarding) {
                    Text("Start Our Love Story")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [.pink, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .shadow(color: .pink.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 32)
                .disabled(partnerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(partnerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
                
                Spacer()
            }
            .padding(.horizontal, 32)
        }
        .preferredColorScheme(.dark)
        .floatingHearts()
        .onAppear {
            // Auto-focus name field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                nameFieldFocused = true
            }
        }
        .onChange(of: selectedPhoto) { _, newPhoto in
            Task {
                if let newPhoto = newPhoto,
                   let data = try? await newPhoto.loadTransferable(type: Data.self),
                   let image = UIImage(data: data),
                   let optimizedData = image.jpegData(compressionQuality: 0.7) {
                    await MainActor.run {
                        appState.partnerPhotoData = optimizedData
                    }
                }
            }
        }
    }
    
    private func completeOnboarding() {
        let trimmedName = partnerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        withAnimation(.easeInOut(duration: 0.5)) {
            appState.partnerName = trimmedName
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
}