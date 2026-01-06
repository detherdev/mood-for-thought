import SwiftUI
import Supabase

struct LoginView: View {
    let showSignUp: () -> Void
    let skipLogin: () -> Void
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
                VStack(spacing: 16) {
                    // App Icon
                    Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .cornerRadius(22)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    Text("Octomood")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    Text("Welcome Back")
                        .font(.system(size: 18, weight: .semibold))
                        .opacity(0.7)
                }
                .padding(.top, 40)
                
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
                
                VStack(spacing: 16) {
                    // Skip button
                    Button(action: skipLogin) {
                        VStack(spacing: 4) {
                            Text("Continue without account")
                                .font(.system(size: 15, weight: .semibold))
                            Text("Data stored locally on your device")
                                .font(.system(size: 11))
                                .opacity(0.7)
                        }
                        .foregroundColor(.secondary)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(16)
                    }
                    
                    // Sign up link
                    HStack {
                        Text("New to Octomood?")
                            .opacity(0.6)
                        Button("Create Account") {
                            showSignUp()
                        }
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    }
                    .font(.subheadline)
                }
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
