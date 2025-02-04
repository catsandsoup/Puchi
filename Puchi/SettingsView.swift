import SwiftUI

struct SettingsSectionHeader: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundColor(Color(hex: "FF5A5F"))
    }
}

struct SettingsCardView: View {
    let content: AnyView
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 10)
            )
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("partnerName") private var storedPartnerName = ""
    @AppStorage("isFirstTimeUser") private var isFirstTimeUser = false
    
    @State private var newPartnerName = ""
    @State private var showingResetAlert = false
    @State private var showingSaveAlert = false
    
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Partner Details Section
                    VStack(alignment: .leading, spacing: 12) {
                        SettingsSectionHeader(text: "Partner Details")
                        
                        SettingsCardView(content: AnyView(
                            VStack(spacing: 16) {
                                ZStack(alignment: .topLeading) {
                                    if newPartnerName.isEmpty {
                                        Text("Partner's Name")
                                            .font(.system(size: 16, design: .rounded))
                                            .foregroundColor(Color(.systemGray3))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                    }
                                    
                                    TextField("", text: $newPartnerName)
                                        .font(.system(size: 16, design: .rounded))
                                        .padding(12)
                                        .background(Color.clear)
                                }
                                .frame(height: 48)
                                .background(Color(hex: "F5F5F5").opacity(0.5))
                                .cornerRadius(12)
                                .onAppear { newPartnerName = storedPartnerName }
                                
                                Button(action: {
                                    if !newPartnerName.isEmpty {
                                        showingSaveAlert = true
                                    }
                                }) {
                                    Text("Save Name Change")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                        .background(Color(hex: "FF5A5F"))
                                        .cornerRadius(12)
                                }
                            }
                        ))
                    }
                    
                    // App Management Section
                    VStack(alignment: .leading, spacing: 8) {
                        SettingsSectionHeader(text: "App Management")
                        
                        SettingsCardView(content: AnyView(
                            Button(action: { showingResetAlert = true }) {
                                Text("Reset App")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(12)
                            }
                        ))
                    }
                    
                    // About Section
                    VStack(alignment: .leading, spacing: 8) {
                        SettingsSectionHeader(text: "About")
                        
                        SettingsCardView(content: AnyView(
                            VStack(spacing: 12) {
                                VStack(spacing: 4) {
                                    Text("Version \(appVersion) (\(buildNumber))")
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(.gray)
                                    
                                    Text("Developer: Monty Giovenco")
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(.gray)
                                    
                                    Text("© 2025")
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(.gray)
                                }
                                
                                Divider()
                                
                                HStack(spacing: 4) {
                                    Text("Made with")
                                        .font(.system(size: 14, design: .rounded))
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(Color(hex: "FF5A5F"))
                                    Text("in Sydney")
                                        .font(.system(size: 14, design: .rounded))
                                }
                                .foregroundColor(.gray)
                            }
                        ))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, -20)
                .padding(.bottom, 34)
            }
            .background(Color(hex: "F5F5F5"))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .top, spacing: 0) {
                Color.clear.frame(height: 34)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "FF5A5F"))
                }
            }
            .alert("Confirm Name Change", isPresented: $showingSaveAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Save") {
                    storedPartnerName = newPartnerName
                }
            } message: {
                Text("Are you sure you want to change your partner's name to '\(newPartnerName)'?")
            }
            .alert("Reset App", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    UserDefaults.standard.removeObject(forKey: "savedNotes")
                    storedPartnerName = ""
                    isFirstTimeUser = true
                    dismiss()
                }
            } message: {
                Text("This will delete all your love notes and reset the app to its initial state. This action cannot be undone.")
            }
        }
    }
}

#Preview {
    SettingsView()
}
