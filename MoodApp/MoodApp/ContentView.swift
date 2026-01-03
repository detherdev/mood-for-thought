import SwiftUI
import Supabase

struct ContentView: View {
    @StateObject var supabaseManager = SupabaseManager.shared
    @State private var showSignUp = false
    
    var body: some View {
        Group {
            if !supabaseManager.isInitialized {
                // Loading screen while checking auth
                ZStack {
                    Color.white.ignoresSafeArea()
                    ProgressView()
                        .tint(.blue)
                }
            } else if supabaseManager.session == nil {
                // Auth screens
                if showSignUp {
                    SignUpView(showLogin: { showSignUp = false })
                } else {
                    LoginView(showSignUp: { showSignUp = true })
                }
            } else {
                // Main App
                MainTabView()
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}

