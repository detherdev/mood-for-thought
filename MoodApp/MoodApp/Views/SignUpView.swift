import SwiftUI
import Supabase

struct SignUpView: View {
    let showLogin: () -> Void
    let skipLogin: () -> Void
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var error: String? = nil
    @State private var isLoading = false
    @State private var isSuccess = false
    
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
                    // App Icon from bundle
                    if let appIcon = getAppIcon() {
                        Image(uiImage: appIcon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .cornerRadius(22)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    } else {
                        // Fallback octopus emoji
                        Text("🐙")
                            .font(.system(size: 80))
                    }
                    
                    Text("Octomood")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    Text("Create Account")
                        .font(.system(size: 18, weight: .semibold))
                        .opacity(0.7)
                }
                .padding(.top, 40)
                
                if isSuccess {
                    VStack(spacing: 24) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        Text("Check your email")
                            .font(.headline)
                        Text("We've sent a verification link to your inbox.")
                            .multilineTextAlignment(.center)
                            .opacity(0.6)
                        
                        Button("Back to Login") {
                            showLogin()
                        }
                        .fontWeight(.bold)
                    }
                    .padding(32)
                    .ios26Glass(radius: 40)
                } else {
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
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.system(size: 10, weight: .bold))
                                .textCase(.uppercase)
                                .tracking(2)
                                .opacity(0.5)
                                .padding(.leading, 4)
                            
                            SecureField("••••••••", text: $confirmPassword)
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
                        
                        Button(action: handleSignUp) {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Create Account")
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
                }
                
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
                    
                    // Login link
                    HStack {
                        Text("Already have an account?")
                            .opacity(0.6)
                        Button("Log In") {
                            showLogin()
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
    
    private func handleSignUp() {
        guard !email.isEmpty && !password.isEmpty && password == confirmPassword else {
            if password != confirmPassword { error = "Passwords do not match" }
            return
        }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                try await SupabaseManager.shared.client.auth.signUp(email: email, password: password)
                await MainActor.run {
                    self.isLoading = false
                    self.isSuccess = true
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    private func getAppIcon() -> UIImage? {
        // Try to get the app icon from the bundle
        if let icons = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last {
            return UIImage(named: lastIcon)
        }
        return nil
    }
}
