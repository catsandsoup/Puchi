//
//  AnimatedPageIndicator.swift
//  Puchi
//
//  Created by Monty Giovenco on 1/2/2025.
//


import SwiftUI

struct AnimatedPageIndicator: View {
    @Binding var currentPage: Int
    let numberOfPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { page in
                Circle()
                    .fill(currentPage == page ? Color.puchiPrimary : Color.puchiPrimary.opacity(0.3))
                    .frame(width: currentPage == page ? 8 : 6, height: currentPage == page ? 8 : 6)
                    .animation(PuchiAnimation.spring, value: currentPage)
                    .onTapGesture {
                        withAnimation(PuchiAnimation.spring) {
                            currentPage = page
                        }
                        HapticManager.light()
                    }
            }
        }
        .padding(8)
        .background(
            Capsule()
                .fill(Color.background)
                .shadow(color: .black.opacity(0.05), radius: 4)
        )
    }
}

#Preview {
    AnimatedPageIndicator(currentPage: .constant(0), numberOfPages: 2)
        .padding()
        .background(Color.gray.opacity(0.1))
}