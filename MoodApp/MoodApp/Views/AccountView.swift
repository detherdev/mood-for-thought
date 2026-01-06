import SwiftUI
import Auth

struct AccountView: View {
    @ObservedObject var supabaseManager = SupabaseManager.shared
    @State private var isLoggingOut = false
    @State private var calendarSyncEnabled = false
    @State private var octopusModeEnabled = true // Default to Octopus mode! 🐙
    @State private var showTutorial = false
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue.opacity(0.3))
                    
                    Text(supabaseManager.currentUser?.email ?? "Account")
                        .font(.system(size: 20, weight: .bold))
                    
                    Text("Mood Tracker")
                        .font(.system(size: 12, weight: .bold))
                        .textCase(.uppercase)
                        .tracking(2)
                        .foregroundColor(.secondary)
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
                
                // Logout Button
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
                
                Spacer()
            }
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
    }
    
    private func logout() {
        impactLight.impactOccurred()
        isLoggingOut = true
        
        Task {
            await supabaseManager.signOut()
            await MainActor.run {
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

