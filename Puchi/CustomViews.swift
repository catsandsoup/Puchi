//
//  CustomViews.swift
//  Puchi
//
//  Created by Monty Giovenco on 27/1/2025.
//

import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: 16, design: .rounded))
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}
