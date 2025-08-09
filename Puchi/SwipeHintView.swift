//
//  SwipeHintView.swift
//  Puchi
//
//  Timeline discovery hints and navigation cues
//

import SwiftUI

// MARK: - Swipe Hint View
struct SwipeHintView: View {
    @Binding var isVisible: Bool
    let direction: SwipeDirection
    let message: String
    
    enum SwipeDirection {
        case left, right
        
        var arrow: String {
            switch self {
            case .left: return "arrow.left"
            case .right: return "arrow.right"
            }
        }
        
        var animation: Animation {
            .easeInOut(duration: 1.5).repeatForever(autoreverses: true)
        }
    }
    
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 12) {
            if direction == .right {
                Text(message)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.puchiPrimary)
                
                Image(systemName: direction.arrow)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.puchiPrimary)
                    .offset(x: animationOffset)
            } else {
                Image(systemName: direction.arrow)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.puchiPrimary)
                    .offset(x: -animationOffset)
                
                Text(message)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.puchiPrimary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color.puchiPrimary.opacity(0.1))
                .overlay(
                    Capsule()
                        .stroke(Color.puchiPrimary.opacity(0.3), lineWidth: 1)
                )
        )
        .opacity(isVisible ? 1.0 : 0.0)
        .scaleEffect(isVisible ? 1.0 : 0.8)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isVisible)
        .onAppear {
            startAnimation()
        }
        .onTapGesture {
            dismissHint()
        }
    }
    
    private func startAnimation() {
        withAnimation(direction.animation) {
            animationOffset = direction == .right ? 8 : 8
        }
    }
    
    private func dismissHint() {
        HapticManager.light()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isVisible = false
        }
    }
}

// MARK: - Timeline Discovery Hint Manager
@MainActor
class NavigationHintManager: ObservableObject {
    @Published var showTimelineHint = false
    @Published var showCreateNoteHint = false
    
    @AppStorage("hasSeenTimelineHint") private var hasSeenTimelineHint = false
    @AppStorage("hasSeenCreateNoteHint") private var hasSeenCreateNoteHint = false
    
    private var timelineHintTimer: Timer?
    private var createNoteHintTimer: Timer?
    
    init() {
        scheduleHints()
    }
    
    private func scheduleHints() {
        // Show timeline discovery hint after 3 seconds if user hasn't seen it
        if !hasSeenTimelineHint {
            timelineHintTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
                Task { @MainActor in
                    self.showTimelineDiscoveryHint()
                }
            }
        }
    }
    
    func showTimelineDiscoveryHint() {
        guard !hasSeenTimelineHint else { return }
        
        showTimelineHint = true
        
        // Auto-dismiss after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.dismissTimelineHint()
        }
    }
    
    func showCreateNoteDiscoveryHint() {
        guard !hasSeenCreateNoteHint else { return }
        
        showCreateNoteHint = true
        
        // Auto-dismiss after 4 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.dismissCreateNoteHint()
        }
    }
    
    func dismissTimelineHint() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showTimelineHint = false
        }
        hasSeenTimelineHint = true
        timelineHintTimer?.invalidate()
    }
    
    func dismissCreateNoteHint() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showCreateNoteHint = false
        }
        hasSeenCreateNoteHint = true
        createNoteHintTimer?.invalidate()
    }
    
    func onPageChanged(to page: Int, hasNotes: Bool) {
        // If user navigated to timeline, mark timeline hint as seen
        if page == 1 {
            dismissTimelineHint()
            
            // Show create note hint if timeline is empty
            if !hasNotes && !hasSeenCreateNoteHint {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.showCreateNoteDiscoveryHint()
                }
            }
        }
        
        // If user navigated back to create page from timeline, mark create hint as seen
        if page == 0 {
            dismissCreateNoteHint()
        }
    }
    
    deinit {
        timelineHintTimer?.invalidate()
        createNoteHintTimer?.invalidate()
    }
}

// MARK: - Enhanced Navigation Hints Container
struct NavigationHintsContainer<Content: View>: View {
    @ObservedObject var hintManager: NavigationHintManager
    @Binding var currentPage: Int
    let hasNotes: Bool
    let content: Content
    
    init(hintManager: NavigationHintManager, currentPage: Binding<Int>, hasNotes: Bool, @ViewBuilder content: () -> Content) {
        self.hintManager = hintManager
        self._currentPage = currentPage
        self.hasNotes = hasNotes
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            content
            
            // Timeline discovery hint - shown on main page
            if currentPage == 0 {
                VStack {
                    Spacer()
                    
                    SwipeHintView(
                        isVisible: $hintManager.showTimelineHint,
                        direction: .right,
                        message: "Swipe to view your timeline"
                    )
                    .padding(.bottom, 120) // Above page indicator
                }
            }
            
            // Create note hint - shown on empty timeline
            if currentPage == 1 {
                VStack {
                    Spacer()
                    
                    SwipeHintView(
                        isVisible: $hintManager.showCreateNoteHint,
                        direction: .left,
                        message: "Swipe back to write a note"
                    )
                    .padding(.bottom, 120) // Above page indicator
                }
            }
        }
        .onChange(of: currentPage) { _, newPage in
            hintManager.onPageChanged(to: newPage, hasNotes: hasNotes)
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var isVisible = true
    @Previewable @State var currentPage = 0
    
    return ZStack {
        Color.puchiBackground.ignoresSafeArea()
        
        VStack {
            Spacer()
            SwipeHintView(
                isVisible: $isVisible,
                direction: .right,
                message: "Swipe to view your timeline"
            )
            Spacer()
        }
    }
}