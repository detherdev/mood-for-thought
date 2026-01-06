import SwiftUI
import Supabase

struct ContentView: View {
    @StateObject var supabaseManager = SupabaseManager.shared
    @State private var showSignUp = false
    @State private var useLocalMode = UserDefaults.standard.bool(forKey: "useLocalMode")
    
    var body: some View {
        Group {
            if !supabaseManager.isInitialized && !useLocalMode {
                // Loading screen while checking auth
                ZStack {
                    Color.white.ignoresSafeArea()
                    ProgressView()
                        .tint(.blue)
                }
            } else if supabaseManager.session == nil && !useLocalMode {
                // Auth screens
                if showSignUp {
                    SignUpView(
                        showLogin: { showSignUp = false },
                        skipLogin: { skipToLocalMode() }
                    )
                } else {
                    LoginView(
                        showSignUp: { showSignUp = true },
                        skipLogin: { skipToLocalMode() }
                    )
                }
            } else {
                // Main App (either logged in or local mode)
                MainTabView()
            }
        }
        .preferredColorScheme(.light)
    }
    
    private func skipToLocalMode() {
        useLocalMode = true
        UserDefaults.standard.set(true, forKey: "useLocalMode")
    }
}

#Preview {
    ContentView()
}

