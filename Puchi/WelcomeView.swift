import SwiftUI
import PhotosUI

struct FloatingHeartView: View {
    let heart: FloatingHeart
    let onComplete: () -> Void
    
    var body: some View {
        Image(systemName: "heart.fill")
            .foregroundColor(Color(hex: "FF5A5F"))
            .frame(width: 16, height: 16)
            .scaleEffect(heart.scale)
            .position(heart.position)
            .opacity(heart.opacity)
            .rotationEffect(.degrees(heart.rotation))
            .onAppear {
                animateHeart()
            }
    }
    
    private func animateHeart() {
        withAnimation(
            .easeInOut(duration: heart.animationDuration)
            .delay(heart.animationDelay)
        ) {
            // Move upward with fade
            let newPosition = CGPoint(
                x: heart.position.x,
                y: -50
            )
            
            DispatchQueue.main.asyncAfter(
                deadline: .now() + heart.animationDuration + heart.animationDelay
            ) {
                onComplete()
            }
        }
    }
}

// MARK: - Hearts Container
struct HeartsContainer: View {
    let hearts: [FloatingHeart]
    let onHeartComplete: (UUID) -> Void
    
    var body: some View {
        ForEach(hearts) { heart in
            FloatingHeartView(heart: heart) {
                onHeartComplete(heart.id)
            }
        }
    }
}

// MARK: - Enchanted Hearts View
struct EnchantedHeartsView: View {
    @State private var hearts: [FloatingHeart] = []
    @State private var isActive = true
    
    private let maxHearts = 5
    private let timer = Timer.publish(every: 1.8, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HeartsContainer(hearts: hearts) { heartId in
                    hearts.removeAll { $0.id == heartId }
                }
            }
            .onReceive(timer) { _ in
                addNewHeartIfNeeded(in: geometry)
            }
            .onAppear { isActive = true }
            .onDisappear {
                isActive = false
                hearts.removeAll()
            }
        }
    }
    
    private func addNewHeartIfNeeded(in geometry: GeometryProxy) {
        guard isActive && hearts.count < maxHearts else { return }
        
        let newHeart = createHeart(in: geometry)
        hearts.append(newHeart)
    }
    
    private func createHeart(in geometry: GeometryProxy) -> FloatingHeart {
        FloatingHeart(
            position: CGPoint(
                x: CGFloat.random(in: 50...(geometry.size.width - 50)),
                y: geometry.size.height + 20
            ),
            scale: CGFloat.random(in: 0.4...0.6),
            opacity: 0.3,
            rotation: Double.random(in: -30...30),
            animationDuration: Double.random(in: 8...12),
            animationDelay: Double.random(in: 0...0.5)
        )
    }
}

// MARK: - Floating Heart Model
struct FloatingHeart: Identifiable, Equatable {
    let id = UUID()
    var position: CGPoint
    var scale: CGFloat
    var opacity: Double
    var rotation: Double
    var animationDuration: Double
    var animationDelay: Double
}

// MARK: - Welcome View
struct WelcomeView: View {
    @Environment(\.scenePhase) private var scenePhase
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
    
    private struct TextSize {
        static let mainTitle: CGFloat = 40
        static let actionPrompt: CGFloat = 20
        static let placeholder: CGFloat = 20
        static let button: CGFloat = 18
    }
    
    private let steps = [
        "Welcome to Your\nLove Story",
        "Let's Create Your\nLove Journey\nTogether",
        "Tell Me About Your\nSpecial Someone"
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                EnchantedHeartsView()
                    .allowsHitTesting(false)
                
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isNameFieldFocused = false
                    }
                
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: geometry.size.height * 0.15)
                    
                    if currentStep < 2 {
                        Image(systemName: "heart.fill")
                            .resizable()
                            .frame(width: 44, height: 40)
                            .foregroundColor(Color(hex: "FF5A5F"))
                            .padding(.bottom, 24)
                        
                        Text(steps[currentStep])
                            .font(.system(size: TextSize.mainTitle, weight: .bold))
                            .foregroundColor(Color(hex: "FF5A5F"))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .transition(.opacity)
                            .padding(.horizontal, 24)
                    } else {
                        VStack(spacing: 32) {
                            photoSection
                                .padding(.bottom, 16)
                            
                            Text(steps[currentStep])
                                .font(.system(size: TextSize.mainTitle, weight: .bold))
                                .foregroundColor(Color(hex: "FF5A5F"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                            
                            inputField
                                .padding(.top, 16)
                        }
                    }
                    
                    Spacer()
                    
                    navigationButton
                        .padding(.horizontal, 24)
                        .padding(.bottom, geometry.safeAreaInsets.bottom + 16)
                }
            }
        }
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                isImageLoading = true
                do {
                    if let data = try await newItem?.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            tempUIImage = uiImage
                            showPhotoConfirmation = true
                        } else {
                            showImageError = true
                        }
                    } else if newItem != nil {
                        showImageError = true
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
            Button("Use Photo") { handlePhotoConfirmation() }
            Button("Cancel", role: .cancel) { cancelPhotoSelection() }
        } message: {
            Text("Would you like to use this photo?")
        }
        .onAppear {
            loadSavedImage()
            setupKeyboardNotifications()
            opacity = 1.0
        }
    }
    
    private var photoSection: some View {
        VStack(spacing: 16) {
            if isImageLoading {
                ProgressView()
                    .frame(width: 80, height: 80)
            } else if let partnerImage {
                ZStack(alignment: .topTrailing) {
                    partnerImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color(hex: "FF5A5F"), lineWidth: 3))
                    
                    Button(action: { clearPhoto() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(hex: "FF5A5F"))
                            .background(Color.white.clipShape(Circle()))
                    }
                    .offset(x: 8, y: -8)
                }
            } else {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "FF5A5F").opacity(0.1))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "heart.fill")
                                .resizable()
                                .frame(width: 32, height: 28)
                                .foregroundColor(.white)
                        }
                        
                        Text("Add a photo of your love")
                            .font(.system(size: TextSize.actionPrompt))
                            .foregroundColor(Color(hex: "FF5A5F"))
                    }
                }
            }
        }
    }
    
    private var inputField: some View {
        TextField("", text: $name)
            .font(.system(size: TextSize.placeholder))
            .multilineTextAlignment(.center)
            .focused($isNameFieldFocused)
            .submitLabel(.done)
            .placeholder(when: name.isEmpty) {
                Text("Their name goes here...")
                    .font(.system(size: TextSize.placeholder))
                    .foregroundColor(Color(.systemGray3))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
            )
            .padding(.horizontal, 24)
    }
    
    private var navigationButton: some View {
        Button(action: handleNavigation) {
            HStack(spacing: 8) {
                Text(currentStep == 2 ? "Begin Your Journey" : "Next Step")
                    .font(.system(size: TextSize.button, weight: .semibold))
                
                Image(systemName: currentStep == 2 ? "heart.fill" : "arrow.right")
                    .font(.system(size: TextSize.button, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(hex: "FF5A5F"))
            )
        }
        .disabled(currentStep == 2 && name.isEmpty)
    }
    
    private func handleNavigation() {
        if currentStep < 2 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep += 1
            }
            if currentStep == 2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isNameFieldFocused = true
                }
            }
        } else {
            guard !name.isEmpty else { return }
            isNameFieldFocused = false
            withAnimation {
                partnerName = name
                isFirstTimeUser = false
            }
        }
    }
    
    private func handlePhotoConfirmation() {
        guard let uiImage = tempUIImage,
              let optimizedData = uiImage.optimizedForStorage() else { return }
        
        UserDefaults.standard.set(optimizedData, forKey: "partnerImageData")
        withAnimation {
            partnerImage = Image(uiImage: uiImage)
        }
    }
    
    private func cancelPhotoSelection() {
        selectedPhoto = nil
        tempUIImage = nil
    }
    
    private func clearPhoto() {
        withAnimation {
            partnerImage = nil
            selectedPhoto = nil
            tempUIImage = nil
            UserDefaults.standard.removeObject(forKey: "partnerImageData")
        }
    }
    
    private func loadSavedImage() {
        // Only load saved image if this is not a first-time user
        // This prevents the partner image from persisting after app reset
        guard !isFirstTimeUser else {
            // Clear any existing partner image data if this is first time user
            UserDefaults.standard.removeObject(forKey: "partnerImageData")
            partnerImage = nil
            selectedPhoto = nil
            tempUIImage = nil
            return
        }
        
        if let data = UserDefaults.standard.data(forKey: "partnerImageData"),
           let uiImage = UIImage(data: data) {
            partnerImage = Image(uiImage: uiImage)
        }
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            keyboardHeight = 0
        }
    }
}

// MARK: - Helper Extensions
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .center,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
