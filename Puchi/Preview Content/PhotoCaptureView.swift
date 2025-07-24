//
//  PhotoCaptureView.swift
//  Puchi
//
//  Created by Monty Giovenco on 29/1/2025.
//


import SwiftUI
import PhotosUI

struct PhotoCaptureView: View {
    @ObservedObject var viewModel: LoveJournalViewModel
    @Binding var isShowingImagePicker: Bool
    @State private var showCamera = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Selected Photos Grid
            if !viewModel.mediaManager.selectedMedia.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(viewModel.mediaManager.selectedMedia.enumerated()), id: \.element.id) { index, mediaItem in
                            ZStack(alignment: .topTrailing) {
                                if let image = UIImage(data: mediaItem.data) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                
                                Button {
                                    viewModel.removeMediaItem(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                }
                                .padding(4)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            HStack(spacing: 16) {
                // Camera Button
                Button {
                    showCamera = true
                } label: {
                    VStack {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 24))
                        Text("Camera")
                            .font(.caption)
                    }
                    .frame(width: 80, height: 80)
                    .background(Color(hex: "FF5A5F").opacity(0.1))
                    .foregroundColor(Color(hex: "FF5A5F"))
                    .cornerRadius(12)
                }
                
                // Photo Library Button
                Button {
                    isShowingImagePicker = true
                } label: {
                    VStack {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 24))
                        Text("Library")
                            .font(.caption)
                    }
                    .frame(width: 80, height: 80)
                    .background(Color(hex: "FF5A5F").opacity(0.1))
                    .foregroundColor(Color(hex: "FF5A5F"))
                    .cornerRadius(12)
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            MediaPicker(sourceType: .camera, allowsMultipleSelection: false, onMediaSelected: { mediaItems in
                viewModel.addMediaItems(mediaItems)
            })
        }
    }
}
