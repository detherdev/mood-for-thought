import SwiftUI

struct WelcomeView: View {
    let continueWithoutAccount: () -> Void
    let showLogin: () -> Void
    let showSignUp: () -> Void
    
    @State private var pulseAnimation = false
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        ZStack {
            // Background
            ZStack {
                Color.white.ignoresSafeArea()
                DepthBlob(color: .blue.opacity(0.2)).offset(x: -150, y: -300)
                DepthBlob(color: .purple.opacity(0.2)).offset(x: 150, y: 300)
            }
            
            VStack(spacing: 40) {
                Spacer()
                
                // App Icon and Title
                VStack(spacing: 20) {
                    // App Icon
                    Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .cornerRadius(26)
                        .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 8)
                        .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                    
                    VStack(spacing: 8) {
                        Text("Octomood")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                        Text("Your Emotional Octopus Companion")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
                
                Spacer()
                
                // Main Action Buttons
                VStack(spacing: 16) {
                    // Primary: Continue without account
                    Button(action: {
                        impactLight.impactOccurred()
                        continueWithoutAccount()
                    }) {
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "iphone")
                                    .font(.system(size: 20, weight: .semibold))
                                Text("Continue without account")
                                    .font(.system(size: 17, weight: .bold))
                            }
                            Text("All data stored locally on your device")
                                .font(.system(size: 13))
                                .opacity(0.9)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: .blue.opacity(0.3), radius: 15, x: 0, y: 8)
                    }
                    
                    // Divider
                    HStack {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(height: 1)
                        Text("or")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                        Rectangle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.vertical, 8)
                    
                    // Secondary: Cloud sync options
                    VStack(spacing: 12) {
                        Button(action: {
                            impactLight.impactOccurred()
                            showLogin()
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                Text("Log in with account")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black.opacity(0.05))
                            .foregroundColor(.primary)
                            .cornerRadius(14)
                        }
                        
                        Button(action: {
                            impactLight.impactOccurred()
                            showSignUp()
                        }) {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                Text("Create new account")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black.opacity(0.05))
                            .foregroundColor(.primary)
                            .cornerRadius(14)
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                // Benefits note
                Text("With an account, sync your moods across devices")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            impactLight.prepare()
            startPulseAnimation()
        }
    }
    
    private func startPulseAnimation() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            pulseAnimation = true
        }
    }
}

