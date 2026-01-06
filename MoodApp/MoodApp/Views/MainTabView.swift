import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var selectedDate = Date()
    @State private var showTutorial = false
    @Namespace private var animation
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Depth
                Color.white.ignoresSafeArea()
                DepthBlob(color: .blue.opacity(0.3)).offset(x: -150, y: -300)
                DepthBlob(color: .purple.opacity(0.3)).offset(x: 150, y: 300)
                
                // Content
                Group {
                    if selectedTab == 0 {
                        MoodLoggerView(selectedDate: $selectedDate)
                            .transition(.asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            ))
                    } else if selectedTab == 1 {
                        MoodCalendarView(
                            onDateSelected: { date in
                                selectedDate = date
                                impactLight.impactOccurred()
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    selectedTab = 0
                                }
                            }
                        )
                        .padding(.top, 120) // Accounting for header height
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.95)),
                            removal: .opacity.combined(with: .scale(scale: 1.05))
                        ))
                    } else {
                        AccountView()
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedTab)
                
                // Floating Tab Bar (iOS 26 Style) - ABSOLUTE FIXED POSITION
                HStack(spacing: 8) {
                    TabButton(icon: "house.fill", label: "Log", isActive: selectedTab == 0, namespace: animation) {
                        impactLight.impactOccurred()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            selectedTab = 0
                        }
                    }
                    TabButton(icon: "calendar", label: "History", isActive: selectedTab == 1, namespace: animation) {
                        impactLight.impactOccurred()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            selectedTab = 1
                        }
                    }
                    TabButton(icon: "person.circle.fill", label: "Account", isActive: selectedTab == 2, namespace: animation) {
                        impactLight.impactOccurred()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            selectedTab = 2
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .ios26Glass(radius: 30)
                .padding(.horizontal, 40)
                .frame(width: geometry.size.width, height: 70)
                .position(x: geometry.size.width / 2, y: geometry.size.height - 70)
            }
        }
        .ignoresSafeArea(.all)
        .preferredColorScheme(.light)
        .onAppear {
            impactLight.prepare()
            checkIfShouldShowTutorial()
        }
        .overlay {
            if showTutorial {
                TutorialView(isPresented: $showTutorial) {
                    // After tutorial completes, mark as seen
                    UserDefaults.standard.set(true, forKey: "hasSeenTutorial")
                }
                .transition(.opacity)
                .zIndex(999)
            }
        }
    }
    
    private func checkIfShouldShowTutorial() {
        let hasSeenTutorial = UserDefaults.standard.bool(forKey: "hasSeenTutorial")
        if !hasSeenTutorial {
            // Delay slightly so the UI loads first
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    showTutorial = true
                }
            }
        }
    }
}

struct TabButton: View {
    let icon: String
    let label: String
    let isActive: Bool
    var namespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                ZStack {
                    if isActive {
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 40, height: 40)
                            .matchedGeometryEffect(id: "tabIndicator", in: namespace)
                    }
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                }
                
                Text(label)
                    .font(.system(size: 9, weight: .bold))
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(isActive ? .blue : .secondary.opacity(0.5))
        }
    }
}
