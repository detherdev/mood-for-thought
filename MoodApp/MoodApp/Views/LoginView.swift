import SwiftUI
import Supabase

struct LoginView: View {
    let showSignUp: () -> Void
    @State private var email = ""
    @State private var password = ""
    @State private var error: String? = nil
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            // Background
            ZStack {
                Color.white.ignoresSafeArea()
                DepthBlob(color: .blue.opacity(0.2)).offset(x: -150, y: -300)
                DepthBlob(color: .purple.opacity(0.2)).offset(x: 150, y: 300)
            }
            
            VStack(spacing: 32) {
                VStack(spacing: 8) {
                    Text("Welcome Back")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                    Text("Log in to your account")
                        .font(.system(size: 14, weight: .bold))
                        .textCase(.uppercase)
                        .tracking(2)
                        .opacity(0.4)
                }
                .padding(.top, 60)
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.system(size: 10, weight: .bold))
                            .textCase(.uppercase)
                            .tracking(2)
                            .opacity(0.5)
                            .padding(.leading, 4)
                        
                        TextField("name@email.com", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(20)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.system(size: 10, weight: .bold))
                            .textCase(.uppercase)
                            .tracking(2)
                            .opacity(0.5)
                            .padding(.leading, 4)
                        
                        SecureField("••••••••", text: $password)
                            .padding()
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(20)
                    }
                    
                    if let error = error {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    
                    Button(action: handleLogin) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Log In")
                                .font(.system(size: 14, weight: .bold))
                                .textCase(.uppercase)
                                .tracking(3)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(24)
                    .shadow(color: .blue.opacity(0.3), radius: 15, x: 0, y: 8)
                    .disabled(isLoading)
                }
                .padding(24)
                .ios26Glass(radius: 40)
                
                Spacer()
                
                HStack {
                    Text("New to Mood?")
                        .opacity(0.6)
                    Button("Create Account") {
                        showSignUp()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                }
                .font(.subheadline)
                .padding(.bottom, 20)
            }
            .padding()
        }
        .preferredColorScheme(.light)
    }
    
    private func handleLogin() {
        guard !email.isEmpty && !password.isEmpty else { return }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                try await SupabaseManager.shared.client.auth.signIn(email: email, password: password)
                await SupabaseManager.shared.checkSession()
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
