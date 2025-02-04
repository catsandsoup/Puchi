import SwiftUI
import PhotosUI

struct WelcomeView: View {
    @AppStorage("isFirstTimeUser") private var isFirstTimeUser = true
    @AppStorage("partnerName") private var partnerName = ""
    
    @State private var name = ""
    @State private var currentStep = 0
    @State private var opacity = 0.0
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var partnerImage: Image?
    @State private var isImageLoading = false
    @State private var showImageError = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var showPhotoConfirmation = false
    @State private var tempUIImage: UIImage?
    @FocusState private var isNameFieldFocused: Bool
    
    private let steps = [
        "Welcome to Puchi",
        "Let's create your\nlove journal",
        "Who's your special\nsomeone?"
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.puchiBackground
                    .edgesIgnoringSafeArea(.all)
                
                // Dismiss keyboard on tap
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isNameFieldFocused = false
                    }
                
                VStack(spacing: 0) {
                    // Top padding for content
                    Spacer()
                        .frame(height: geometry.safeAreaInsets.top + 8)
                    
                    // Main content
                    VStack(spacing: 0) { // Removed default spacing
                        // Reduced top spacing
                        Spacer()
                            .frame(height: geometry.size.height * 0.02)
                        
                        // Heart Logo or Selected Photo
                        if currentStep < 2 {
                            Image(systemName: "heart.fill")
                                .resizable()
                                .frame(width: 60, height: 54)
                                .foregroundColor(.puchiPrimary) // Updated color
                                .opacity(opacity)
                                .animation(.easeIn(duration: 0.6).delay(0.3), value: opacity)
                        } else {
                            VStack(spacing: 24) { // Adjusted spacing
                                if isImageLoading {
                                    ProgressView()
                                        .frame(width: 120, height: 120)
                                } else if let partnerImage {
                                    ZStack(alignment: .topTrailing) {
                                        partnerImage
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 120)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color(hex: "FF5A5F"), lineWidth: 3))
                                        
                                        // Remove photo button
                                        Button(action: {
                                            withAnimation {
                                                self.partnerImage = nil
                                                self.selectedPhoto = nil
                                                self.tempUIImage = nil
                                            }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(Color(hex: "FF5A5F"))
                                                .background(Color.white.clipShape(Circle()))
                                        }
                                        .offset(x: 8, y: -8)
                                    }
                                } else {
                                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                        VStack {
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .frame(width: 120, height: 120)
                                                .foregroundColor(Color(hex: "FF5A5F").opacity(0.3))
                                            
                                            Text("Add photo")
                                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                                .foregroundColor(Color(hex: "FF5A5F"))
                                        }
                                    }
                                    .accessibilityLabel("Add partner photo")
                                }
                            }
                            .padding(.bottom, 24) // Adjusted bottom padding
                        }
                        
                        // Main Content
                        VStack(spacing: 24) {
                            if currentStep < 2 {
                                Text(steps[currentStep])
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "FF5A5F"))
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .transition(.opacity)
                            } else {
                                VStack(spacing: 32) {
                                    Text(steps[currentStep])
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(hex: "FF5A5F"))
                                        .multilineTextAlignment(.center)
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    ZStack(alignment: .center) {
                                        if name.isEmpty {
                                            Text("Enter their name")
                                                .font(.system(size: 20, design: .rounded))
                                                .foregroundColor(Color(.systemGray3))
                                        }
                                        
                                        TextField("", text: $name)
                                            .font(.system(size: 20, design: .rounded))
                                            .multilineTextAlignment(.center)
                                            .focused($isNameFieldFocused)
                                            .submitLabel(.done)
                                            .textContentType(.name)
                                    }
                                    .frame(maxWidth: 250)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white)
                                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                                    )
                                }
                                .transition(.opacity)
                            }
                        }
                        .animation(.easeInOut, value: currentStep)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Fixed bottom button container
                    VStack {
                        Spacer()
                        
                        // Navigation Button
                        Button(action: {
                            HapticManager.medium() // Add haptic feedback
                            if currentStep < 2 {
                                withAnimation(PuchiAnimation.spring) { // Use our custom animation
                                    currentStep += 1
                                }
                                // Delay keyboard focus to prevent animation conflict
                                if currentStep == 2 {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                        isNameFieldFocused = true
                                    }
                                }
                            } else {
                                guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                                isNameFieldFocused = false
                                HapticManager.success() // Add success haptic
                                withAnimation(PuchiAnimation.spring) {
                                    partnerName = name
                                    isFirstTimeUser = false
                                }
                            }
                        }) {
                            HStack {
                                Text(currentStep == 2 ? "Start Journey" : "Continue")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                
                                if currentStep < 2 {
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 18, weight: .semibold))
                                } else {
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                name.isEmpty && currentStep == 2 ?
                                Color(hex: "FF5A5F").opacity(0.6) :
                                    Color(hex: "FF5A5F")
                            )
                            .cornerRadius(16)
                            .shadow(
                                color: Color(hex: "FF5A5F").opacity(0.3),
                                radius: 10,
                                x: 0,
                                y: 4
                            )
                            .buttonStyle(PressableButtonStyle()) // Add pressable style
                        }
                        .disabled(name.isEmpty && currentStep == 2)
                        .padding(.horizontal, 24)
                        .padding(.bottom, geometry.safeAreaInsets.bottom + 16)
                    }
                    .animation(.none, value: keyboardHeight) // Prevent button from animating with keyboard
                }
            }
        }
        .onChange(of: selectedPhoto) { oldItem, newItem in
            Task {
                isImageLoading = true
                do {
                    if let data = try await newItem?.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            // Store temporary image
                            tempUIImage = uiImage
                            showPhotoConfirmation = true
                        } else {
                            showImageError = true
                        }
                    } else {
                        // Handle case where no data was loaded
                        if newItem != nil {
                            showImageError = true
                        }
                    }
                } catch {
                    showImageError = true
                }
                isImageLoading = false
            }
        }
        .alert("Image Error", isPresented: $showImageError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("There was an error loading your image. Please try again.")
                }
                .alert("Confirm Photo", isPresented: $showPhotoConfirmation) {
                    Button("Use Photo") {
                        if let uiImage = tempUIImage,
                           let optimizedData = uiImage.optimizedForStorage() {
                            UserDefaults.standard.set(optimizedData, forKey: "partnerImageData")
                            withAnimation {
                                partnerImage = Image(uiImage: uiImage)
                            }
                        }
                    }
                    Button("Cancel", role: .cancel) {
                        selectedPhoto = nil
                        tempUIImage = nil
                    }
                } message: {
                    Text("Would you like to use this photo?")
                }
                .onAppear {
                    // Load existing partner image if available
                    if let data = UserDefaults.standard.data(forKey: "partnerImageData"),
                       let uiImage = UIImage(data: data) {
                        partnerImage = Image(uiImage: uiImage)
                    }
                    
                    opacity = 1.0
                    
                    // Set up keyboard notifications
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                            keyboardHeight = keyboardFrame.height
                        }
                    }
                    
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                        keyboardHeight = 0
                    }
                }
                .preferredColorScheme(.light)
            }
            
        #if DEBUG
            struct WelcomeView_Previews: PreviewProvider {
                static var previews: some View {
                    WelcomeView()
                }
            }
        #endif
        }
