import SwiftUI
import PhotosUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                List {
                    // Partner Section
                    Section {
                        HStack(spacing: 16) {
                            // Partner photo
                            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                ZStack {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 60, height: 60)
                                    
                                    if let photoData = appState.partnerPhotoData,
                                       let image = UIImage(data: photoData) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 60, height: 60)
                                            .clipShape(Circle())
                                    } else {
                                        Image(systemName: "person.crop.circle")
                                            .font(.title2)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(appState.partnerName)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Text("💕 Your Love")
                                    .font(.caption)
                                    .foregroundColor(.pink)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(Color.clear)
                    
                    // Stats Section
                    Section {
                        VStack(spacing: 16) {
                            HStack {
                                VStack {
                                    Text("\(appState.entries.count)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Text("Memories")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                VStack {
                                    Text("\(daysSinceFirstEntry)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Text("Days Together")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                VStack {
                                    Text("\(mediaCount)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Text("Photos")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(Color.gray.opacity(0.1))
                    
                    // Actions Section
                    Section {
                        Button(action: {
                            showingResetAlert = true
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                Text("Reset All Data")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .listRowBackground(Color.gray.opacity(0.1))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("💕 Settings")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.pink)
                }
            }
        }
        .onChange(of: selectedPhoto) { _, newPhoto in
            Task {
                if let newPhoto = newPhoto,
                   let data = try? await newPhoto.loadTransferable(type: Data.self),
                   let image = UIImage(data: data),
                   let optimizedData = image.jpegData(compressionQuality: 0.7) {
                    await MainActor.run {
                        appState.partnerPhotoData = optimizedData
                    }
                }
            }
        }
        .alert("Reset All Data?", isPresented: $showingResetAlert) {
            Button("Reset", role: .destructive) {
                appState.resetAllData()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all your love memories. This cannot be undone.")
        }
    }
    
    private var daysSinceFirstEntry: Int {
        guard let firstEntry = appState.entries.last else { return 0 }
        return Calendar.current.dateComponents([.day], from: firstEntry.date, to: Date()).day ?? 0
    }
    
    private var mediaCount: Int {
        appState.entries.reduce(0) { $0 + $1.mediaItems.count }
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}