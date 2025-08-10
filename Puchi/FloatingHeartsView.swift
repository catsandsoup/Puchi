import SwiftUI

struct FloatingHeartsView: View {
    @State private var hearts: [FloatingHeart] = []
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            ForEach(hearts) { heart in
                HeartView(heart: heart)
            }
        }
        .onAppear {
            startHeartAnimation()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startHeartAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in
            addRandomHeart()
            removeOldHearts()
        }
    }
    
    private func addRandomHeart() {
        let heart = FloatingHeart()
        hearts.append(heart)
    }
    
    private func removeOldHearts() {
        hearts.removeAll { $0.creationTime.timeIntervalSinceNow < -4.0 }
    }
}

struct HeartView: View {
    let heart: FloatingHeart
    @State private var animationOffset: CGFloat = 0
    @State private var opacity: Double = 1.0
    @State private var rotation: Double = 0
    @State private var scale: Double = 0.1
    
    var body: some View {
        Text("💕")
            .font(.system(size: heart.size))
            .opacity(opacity)
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .offset(x: heart.xPosition + sin(animationOffset * 0.02) * 30, 
                   y: animationOffset)
            .onAppear {
                withAnimation(.easeOut(duration: 4.0)) {
                    animationOffset = -UIScreen.main.bounds.height - 100
                }
                
                withAnimation(.easeOut(duration: 0.5)) {
                    scale = 1.0
                }
                
                withAnimation(.linear(duration: 4.0)) {
                    opacity = 0.0
                }
                
                withAnimation(.linear(duration: 4.0)) {
                    rotation = Double.random(in: -45...45)
                }
            }
    }
}

struct FloatingHeart: Identifiable {
    let id = UUID()
    let xPosition: CGFloat
    let size: CGFloat
    let creationTime: Date
    
    init() {
        self.xPosition = CGFloat.random(in: -50...UIScreen.main.bounds.width + 50)
        self.size = CGFloat.random(in: 20...40)
        self.creationTime = Date()
    }
}

// Heart animation view that can be overlaid on any view
struct HeartAnimationOverlay: ViewModifier {
    @State private var showHearts = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                FloatingHeartsView()
                    .opacity(showHearts ? 1.0 : 0.0)
                    .allowsHitTesting(false)
            )
            .onAppear {
                withAnimation(.easeIn(duration: 1.0)) {
                    showHearts = true
                }
            }
    }
}

extension View {
    func floatingHearts() -> some View {
        self.modifier(HeartAnimationOverlay())
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        FloatingHeartsView()
    }
}