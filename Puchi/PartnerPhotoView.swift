//
//  PartnerPhotoView.swift
//  Puchi
//
//  Created by Monty Giovenco on 28/1/2025.
//

import SwiftUI

struct PartnerPhotoView: View {
    let size: CGFloat
    let strokeWidth: CGFloat
    @AppStorage("partnerImageData") private var partnerImageData: Data?
    
    var body: some View {
        Group {
            if let partnerImage = loadPartnerImage() {
                partnerImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color(hex: "FF5A5F"), lineWidth: strokeWidth))
                    .accessibilityLabel("Partner photo")
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: size, height: size)
                    .foregroundColor(Color(hex: "FF5A5F").opacity(0.3))
                    .accessibilityLabel("No partner photo")
            }
        }
    }
    
    private func loadPartnerImage() -> Image? {
        guard let data = partnerImageData,
              let uiImage = UIImage(data: data) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }
}
