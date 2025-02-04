//
//  SwiftIndicators.swift
//  Puchi
//
//  Created by Monty Giovenco on 27/1/2025.
//

import SwiftUI

struct SwipeUpIndicator: View {
    @State private var offsetY: CGFloat = 0
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("💌")
                .font(.system(size: 24))
            
            Image(systemName: "chevron.up")
                .foregroundColor(color)
                .font(.system(size: 16, weight: .bold))
                .offset(y: offsetY)
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true)
                    ) {
                        offsetY = -8
                    }
                }
        }
    }
}

struct SwipeDownIndicator: View {
    @State private var offsetY: CGFloat = 0
    let color: Color
    
    var body: some View {
        Image(systemName: "chevron.down")
            .foregroundColor(color)
            .font(.system(size: 16, weight: .bold))
            .offset(y: offsetY)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true)
                ) {
                    offsetY = 8
                }
            }
    }
}

struct DraggableNotesView: View {
    @Binding var isShowingNotes: Bool
    @State private var dragOffset: CGFloat = 0
    let color: Color
    
    var body: some View {
        VStack(spacing: 0) {
            SwipeDownIndicator(color: color)
                .padding(.top, 8)
            
            Text("Your Love Notes")
                .foregroundColor(color)
                .font(.headline)
                .padding(.vertical, 8)
            
            // Your existing notes content here
            ScrollView {
                // Your notes content
            }
        }
        .offset(y: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    let newOffset = value.translation.height
                    if newOffset > 0 { // Only allow dragging downward
                        dragOffset = newOffset
                    }
                }
                .onEnded { value in
                    withAnimation(.spring()) {
                        if dragOffset > 100 { // Threshold to dismiss
                            isShowingNotes = false
                        }
                        dragOffset = 0
                    }
                }
        )
        .transition(.move(edge: .bottom))
    }
}

// Example usage in your main view
struct MainNotesView: View {
    @State private var showingNotes = false
    let accentColor = Color("PuchiPink") // Your app's accent color
    
    var body: some View {
        ZStack {
            // Your main content here
            VStack {
                Spacer()
                
                if !showingNotes {
                    SwipeUpIndicator(color: accentColor)
                        .padding(.bottom, 20)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                showingNotes = true
                            }
                        }
                }
            }
            
            if showingNotes {
                DraggableNotesView(
                    isShowingNotes: $showingNotes,
                    color: accentColor
                )
            }
        }
    }
}
