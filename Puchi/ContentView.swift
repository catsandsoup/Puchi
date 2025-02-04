import SwiftUI

struct ContentView: View {
    @AppStorage("isFirstTimeUser") private var isFirstTimeUser = true
    @AppStorage("partnerName") private var storedPartnerName = ""
    
    var body: some View {
        ZStack {
            if isFirstTimeUser {
                WelcomeView()
            } else {
                MainAppView()
            }
        }
        .preferredColorScheme(.light)
    }
}
