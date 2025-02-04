//
//  SwipeIndicatorView.swift
//  Puchi
//
//  Created by Monty Giovenco on 1/2/2025.
//


import SwiftUI

struct SwipeIndicatorView: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "chevron.left")
                .opacity(0.6)
            Text("Swipe to view history")
                .font(.system(size: 14, weight: .medium, design: .rounded))
            Image(systemName: "chevron.right")
                .opacity(0.6)
        }
        .foregroundColor(Color(hex: "FF5A5F"))
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            Capsule()
                .fill(Color(hex: "FF5A5F").opacity(0.1))
        )
        .offset(x: isAnimating ? 20 : -20)
        .opacity(isAnimating ? 0.5 : 1.0)
        .animation(
            Animation.easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true),
            value: isAnimating
        )
        .onAppear {
            isAnimating = true
        }
    }
}

// Enhanced page indicator
struct EnhancedPageIndicator: View {
    @Binding var currentPage: Int
    let numberOfPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { page in
                Circle()
                    .fill(currentPage == page ? Color(hex: "FF5A5F") : Color(hex: "FF5A5F").opacity(0.3))
                    .frame(width: 8, height: 8)
                    .scaleEffect(currentPage == page ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3), value: currentPage)
            }
        }
        .padding(.vertical, 8)
    }
}