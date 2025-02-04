//
//  StreakCardView.swift
//  Puchi
//
//  Created by Monty Giovenco on 29/1/2025.
//


import SwiftUI

struct StreakCardView: View {
    let streakCount: Int
    
    var body: some View {
        HStack(spacing: 8) {
            Spacer()
            
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(Color(hex: "FF5A5F"))
            
            Text("\(streakCount) Days Love Streak")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color(hex: "FF5A5F"))
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10)
        )
        .padding(.horizontal)
    }
}
