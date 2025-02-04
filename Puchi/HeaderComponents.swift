//
//  PartnerHeaderView.swift
//  Puchi
//
//  Created by Monty Giovenco on 1/2/2025.
//

import SwiftUI
import PhotosUI

struct PartnerHeaderView: View {
    let partnerName: String
    let partnerImageData: Data?
    let selectedPhoto: Binding<PhotosPickerItem?>
    
    var body: some View {
        HStack(spacing: 16) {
            PhotosPicker(selection: selectedPhoto, matching: .images) {
                if let data = partnerImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color(hex: "FF5A5F"), lineWidth: 2))
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(Color(hex: "FF5A5F").opacity(0.3))
                }
            }
            .accessibilityLabel("Change partner photo")
            
            VStack(alignment: .leading, spacing: 4) {
                Text(partnerName)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "FF5A5F"))
                
                Text("Your Love Story")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color(.systemGray))
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }
}
