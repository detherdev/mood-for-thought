import SwiftUI
import Auth

struct AccountView: View {
    @ObservedObject var supabaseManager = SupabaseManager.shared
    @State private var isLoggingOut = false
    @State private var calendarSyncEnabled = false
    @State private var octopusModeEnabled = true // Default to Octopus mode! 🐙
    @State private var showTutorial = false
    @State private var showCloudSyncSheet = false
    @State private var showSignUpInSheet = false
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: UserDefaults.standard.bool(forKey: "useLocalMode") ? "iphone" : "cloud.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue.opacity(0.3))
                    
                    if UserDefaults.standard.bool(forKey: "useLocalMode") {
                        Text("Local Account")
                            .font(.system(size: 20, weight: .bold))
                        Text("Data stored on device")
                            .font(.system(size: 12, weight: .bold))
                            .textCase(.uppercase)
                            .tracking(2)
                            .foregroundColor(.secondary)
                    } else {
                        Text(supabaseManager.currentUser?.email ?? "Account")
                            .font(.system(size: 20, weight: .bold))
                        Text("Cloud Sync Enabled")
                            .font(.system(size: 12, weight: .bold))
                            .textCase(.uppercase)
                            .tracking(2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                // Settings Card
                VStack(spacing: 0) {
                    // Calendar Sync
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Sync with Calendar")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Add mood entries to iOS Calendar")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $calendarSyncEnabled)
                            .labelsHidden()
                    }
                    .padding(20)
                    .background(Color.white)
                    
                    Divider()
                        .padding(.leading, 20)
                    
                    // Octopus Mode
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("🐙 Octopus Mode")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Fun reversible octopus plush")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $octopusModeEnabled)
                            .labelsHidden()
                    }
                    .padding(20)
                    .background(Color.white)
                    
                    Divider()
                        .padding(.leading, 20)
                    
                    // Replay Tutorial
                    Button(action: {
                        impactLight.impactOccurred()
                        showTutorial = true
                    }) {
                        HStack {
                            Text("Replay Tutorial")
                                .font(.system(size: 16, weight: .semibold))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .foregroundColor(.primary)
                        .padding(20)
                        .background(Color.white)
                    }
                    
                    Divider()
                        .padding(.leading, 20)
                    
                    // About
                    Button(action: {
                        impactLight.impactOccurred()
                        // Could open about/help screen
                    }) {
                        HStack {
                            Text("About")
                                .font(.system(size: 16, weight: .semibold))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .foregroundColor(.primary)
                        .padding(20)
                        .background(Color.white)
                    }
                }
                .ios26Glass(radius: 24)
                .padding(.horizontal, 20)
                
                // Logout or Login Button
                if UserDefaults.standard.bool(forKey: "useLocalMode") {
                    // Local mode - offer to create account/login
                    VStack(spacing: 12) {
                        Button(action: enableCloudSync) {
                            VStack(spacing: 6) {
                                HStack {
                                    Image(systemName: "cloud")
                                    Text("Enable Cloud Sync")
                                        .font(.system(size: 14, weight: .bold))
                                        .textCase(.uppercase)
                                        .tracking(3)
                                }
                                Text("Sync your moods across devices")
                                    .font(.system(size: 11))
                                    .opacity(0.9)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(24)
                        .shadow(color: .blue.opacity(0.3), radius: 15, x: 0, y: 8)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                } else {
                    // Cloud mode - offer logout
                    Button(action: logout) {
                        if isLoggingOut {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Logout")
                                .font(.system(size: 14, weight: .bold))
                                .textCase(.uppercase)
                                .tracking(3)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(24)
                    .shadow(color: .red.opacity(0.3), radius: 15, x: 0, y: 8)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .disabled(isLoggingOut)
                }
                
                Spacer()
            }
            .padding(.bottom, 100)
        }
        .onAppear {
            impactLight.prepare()
            loadCalendarSyncState()
            loadOctopusModeState()
        }
        .onChange(of: calendarSyncEnabled) { newValue in
            handleCalendarSyncToggle(newValue)
        }
        .onChange(of: octopusModeEnabled) { newValue in
            handleOctopusModeToggle(newValue)
        }
        .overlay {
            if showTutorial {
                TutorialView(isPresented: $showTutorial) {
                    // Tutorial already seen, just dismiss
                }
                .transition(.opacity)
                .zIndex(999)
            }
        }
        .fullScreenCover(isPresented: $showCloudSyncSheet) {
            if showSignUpInSheet {
                SignUpView(
                    showLogin: { 
                        showSignUpInSheet = false
                    },
                    skipLogin: { 
                        showCloudSyncSheet = false
                    }
                )
            } else {
                LoginView(
                    showSignUp: { 
                        showSignUpInSheet = true
                    },
                    skipLogin: { 
                        showCloudSyncSheet = false
                    }
                )
            }
        }
        .onChange(of: supabaseManager.session) { newSession in
            // If user logs in successfully, dismiss the cloud sync sheet
            if newSession != nil && showCloudSyncSheet {
                showCloudSyncSheet = false
            }
        }
    }
    
    private func enableCloudSync() {
        impactLight.impactOccurred()
        // Clear local mode flag
        UserDefaults.standard.set(false, forKey: "useLocalMode")
        // Show login sheet
        showSignUpInSheet = false // Start with login
        showCloudSyncSheet = true
    }
    
    private func logout() {
        impactLight.impactOccurred()
        isLoggingOut = true
        
        Task {
            await supabaseManager.signOut()
            await MainActor.run {
                // Reset to fresh app state
                UserDefaults.standard.set(false, forKey: "hasSeenWelcome")
                UserDefaults.standard.set(false, forKey: "useLocalMode")
                isLoggingOut = false
            }
        }
    }
    
    private func loadCalendarSyncState() {
        calendarSyncEnabled = UserDefaults.standard.bool(forKey: "calendarSyncEnabled")
    }
    
    private func handleCalendarSyncToggle(_ enabled: Bool) {
        impactLight.impactOccurred()
        UserDefaults.standard.set(enabled, forKey: "calendarSyncEnabled")
        
        if enabled {
            Task {
                await CalendarManager.shared.requestAccess()
            }
        }
    }
    
    private func loadOctopusModeState() {
        // Check if user has set a preference, otherwise default to true (Octopus mode ON!)
        if UserDefaults.standard.object(forKey: "octopusModeEnabled") != nil {
            octopusModeEnabled = UserDefaults.standard.bool(forKey: "octopusModeEnabled")
        } else {
            // First launch - default to Octopus mode ON! 🐙
            octopusModeEnabled = true
            UserDefaults.standard.set(true, forKey: "octopusModeEnabled")
        }
    }
    
    private func handleOctopusModeToggle(_ enabled: Bool) {
        impactLight.impactOccurred()
        UserDefaults.standard.set(enabled, forKey: "octopusModeEnabled")
    }
}

