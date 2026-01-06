import SwiftUI
import Supabase

struct ContentView: View {
    @StateObject var supabaseManager = SupabaseManager.shared
    @State private var showSignUp = false
    @State private var showLogin = false
    @State private var useLocalMode = UserDefaults.standard.bool(forKey: "useLocalMode")
    @State private var hasSeenWelcome = UserDefaults.standard.bool(forKey: "hasSeenWelcome")
    
    var body: some View {
        Group {
            if !hasSeenWelcome {
                // First launch - show welcome screen
                WelcomeView(
                    continueWithoutAccount: { chooseLocalMode() },
                    showLogin: { 
                        hasSeenWelcome = true
                        showLogin = true
                    },
                    showSignUp: {
                        hasSeenWelcome = true
                        showSignUp = true
                    }
                )
            } else if !supabaseManager.isInitialized && !useLocalMode {
                // Loading screen while checking auth
                ZStack {
                    Color.white.ignoresSafeArea()
                    ProgressView()
                        .tint(.blue)
                }
            } else if (supabaseManager.session == nil && !useLocalMode) || showLogin || showSignUp {
                // Auth screens (only if explicitly requested or not in local mode)
                if showSignUp {
                    SignUpView(
                        showLogin: { 
                            showSignUp = false
                            showLogin = true
                        },
                        skipLogin: { chooseLocalMode() }
                    )
                } else {
                    LoginView(
                        showSignUp: { 
                            showLogin = false
                            showSignUp = true
                        },
                        skipLogin: { chooseLocalMode() }
                    )
                }
            } else {
                // Main App (either logged in or local mode)
                MainTabView()
            }
        }
        .preferredColorScheme(.light)
    }
    
    private func chooseLocalMode() {
        useLocalMode = true
        hasSeenWelcome = true
        UserDefaults.standard.set(true, forKey: "useLocalMode")
        UserDefaults.standard.set(true, forKey: "hasSeenWelcome")
        showLogin = false
        showSignUp = false
    }
}

#Preview {
    ContentView()
}

