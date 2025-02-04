//
//  MediaPreviewView.swift
//  Puchi
//
//  Created by Monty Giovenco on 1/2/2025.
//

import SwiftUI
import AVKit

struct MediaPreviewView: View {
    let mediaItem: MediaItem
    
    var body: some View {
        Group {
            switch mediaItem.type {
            case .image:
                if let uiImage = UIImage(data: mediaItem.data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                }
            case .video:
                if let url = URL(dataRepresentation: mediaItem.data, relativeTo: nil) {
                    VideoPlayer(player: AVPlayer(url: url))
                }
            }
        }
    }
}
