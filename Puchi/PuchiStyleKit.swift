//
//  PuchiStyleKit.swift
//  Puchi
//
//  Created by Monty Giovenco on 1/2/2025.
//

import SwiftUI

// MARK: - Animation Constants
enum PuchiAnimation {
    static let spring = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let springBouncy = Animation.spring(response: 0.5, dampingFraction: 0.6)
    static let easeInOut = Animation.easeInOut(duration: 0.3)
    static let easeOut = Animation.easeOut(duration: 0.2)
}

// MARK: - Haptic Feedback
enum HapticManager {
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}


// MARK: - Animation Modifiers
struct ScaleButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.97
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(configuration.isPressed ? .easeIn(duration: 0.2) : .spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct PressableButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.97
    var animation: Animation = .easeOut(duration: 0.2)
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(animation, value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                if newValue {
                    HapticManager.light()
                }
            }
    }
}

// MARK: - Simplified Button with Debouncing
struct DebouncedButton<Label: View>: View {
    let action: () -> Void
    let debounceTime: TimeInterval
    let label: Label
    
    @State private var isDebouncing = false
    private let debounceQueue = DispatchQueue.main
    
    init(debounceTime: TimeInterval = 0.5, action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.action = action
        self.debounceTime = debounceTime
        self.label = label()
    }
    
    var body: some View {
        Button {
            guard !isDebouncing else { return }
            
            isDebouncing = true
            action()
            
            debounceQueue.asyncAfter(deadline: .now() + debounceTime) {
                isDebouncing = false
            }
        } label: {
            label
                .opacity(isDebouncing ? 0.7 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: isDebouncing)
        }
        .disabled(isDebouncing)
    }
}

// MARK: - Custom Transitions
extension AnyTransition {
    static var slideUp: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        )
    }
    
    static var scaleUp: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.9).combined(with: .opacity),
            removal: .scale(scale: 1.1).combined(with: .opacity)
        )
    }
}

// MARK: - Loading Animation View
struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.puchiPrimary)
                    .frame(width: 8, height: 8)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}
