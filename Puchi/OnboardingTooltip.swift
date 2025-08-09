//
//  OnboardingTooltip.swift
//  Puchi
//
//  Contextual hints and tooltips for onboarding
//

import SwiftUI

// MARK: - Tooltip View
struct OnboardingTooltip: View {
    let message: String
    let isVisible: Bool
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.puchiPrimary)
                
                Text(message)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.puchiPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                Button("Got it") {
                    onDismiss()
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.puchiPrimary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.puchiPrimary.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.puchiPrimary.opacity(0.4), lineWidth: 1)
                )
        )
        .opacity(isVisible ? 1.0 : 0.0)
        .scaleEffect(isVisible ? 1.0 : 0.9)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isVisible)
    }
}

// MARK: - Feature Hint Manager
@MainActor
class FeatureHintManager: ObservableObject {
    @Published var showMediaHint = false
    @Published var showLocationHint = false
    
    @AppStorage("hasSeenMediaHint") private var hasSeenMediaHint = false
    @AppStorage("hasSeenLocationHint") private var hasSeenLocationHint = false
    
    func scheduleMediaHint() {
        guard !hasSeenMediaHint else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                self.showMediaHint = true
            }
        }
    }
    
    func scheduleLocationHint() {
        guard !hasSeenLocationHint else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                self.showLocationHint = true
            }
        }
    }
    
    func dismissMediaHint() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showMediaHint = false
        }
        hasSeenMediaHint = true
    }
    
    func dismissLocationHint() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showLocationHint = false
        }
        hasSeenLocationHint = true
    }
    
    func onMediaButtonTapped() {
        if showMediaHint {
            dismissMediaHint()
        }
    }
    
    func onLocationButtonTapped() {
        if showLocationHint {
            dismissLocationHint()
        }
    }
}

// MARK: - Feature Hints Container
struct FeatureHintsContainer<Content: View>: View {
    @ObservedObject var hintManager: FeatureHintManager
    let content: Content
    
    init(hintManager: FeatureHintManager, @ViewBuilder content: () -> Content) {
        self.hintManager = hintManager
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            content
            
            VStack {
                Spacer()
                
                // Media hint
                if hintManager.showMediaHint {
                    HStack {
                        Spacer()
                        OnboardingTooltip(
                            message: "Add photos and videos to make your notes more memorable! 📸",
                            isVisible: hintManager.showMediaHint,
                            onDismiss: {
                                hintManager.dismissMediaHint()
                            }
                        )
                        .frame(maxWidth: 280)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 200)
                }
                
                // Location hint
                if hintManager.showLocationHint {
                    HStack {
                        Spacer()
                        OnboardingTooltip(
                            message: "Tag your location to remember where special moments happened! 📍",
                            isVisible: hintManager.showLocationHint,
                            onDismiss: {
                                hintManager.dismissLocationHint()
                            }
                        )
                        .frame(maxWidth: 280)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 200)
                }
                
                Spacer()
            }
        }
        .onAppear {
            // Schedule hints when view appears
            hintManager.scheduleMediaHint()
            hintManager.scheduleLocationHint()
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var showHint = true
    
    return ZStack {
        Color.puchiBackground.ignoresSafeArea()
        
        VStack {
            Spacer()
            
            OnboardingTooltip(
                message: "Add photos and videos to make your notes more memorable! 📸",
                isVisible: showHint,
                onDismiss: { showHint = false }
            )
            .frame(maxWidth: 280)
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
}