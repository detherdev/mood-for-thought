import SwiftUI

struct TutorialView: View {
    @Binding var isPresented: Bool
    var onComplete: () -> Void
    
    @State private var currentStep = 0
    @State private var pulseAnimation = false
    @State private var fingerOffset: CGSize = .zero
    @State private var fingerOpacity: Double = 0
    @State private var simulatedDragProgress: CGFloat = 0 // -1 to 1
    @State private var demoMood: MoodType? = nil
    @State private var showFingerHint = false
    
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        ZStack {
            // Semi-transparent backdrop
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                if currentStep == 0 {
                    // Interactive Demo Step
                    interactiveDemoView
                        .transition(.opacity)
                } else {
                    // Regular tutorial card
                    tutorialCard
                        .transition(.opacity)
                }
                
                Spacer()
                    .frame(height: 100)
            }
        }
        .onAppear {
            impactLight.prepare()
            if currentStep == 0 {
                startSwipeDemo()
            }
        }
    }
    
    // MARK: - Interactive Demo View
    
    private var interactiveDemoView: some View {
        VStack(spacing: 40) {
            // Title
            VStack(spacing: 8) {
                Text("🐙 Meet Your Octopus!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                Text("Watch how it responds to your swipes")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // Demo Area with Octopus
            ZStack {
                // Background circle
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 280, height: 280)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    )
                
                // Octopus with animation
                OctopusView(
                    mood: demoMood,
                    dragProgress: simulatedDragProgress,
                    size: 200,
                    isDragging: fingerOpacity > 0.3,
                    animatedFrame: nil
                )
                .scaleEffect(fingerOpacity > 0.3 ? 1.05 : 1.0)
                
                // Animated Finger Indicator
                if fingerOpacity > 0 {
                    fingerIndicator
                        .offset(fingerOffset)
                        .opacity(fingerOpacity)
                }
            }
            
            // Gesture Labels
            gestureLabels
            
            // Continue Button (appears after a few cycles)
            if showFingerHint {
                VStack(spacing: 12) {
                    Button(action: handleNext) {
                        Text("Got it!")
                            .font(.system(size: 16, weight: .bold))
                            .textCase(.uppercase)
                            .tracking(2)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.white)
                            .foregroundColor(.blue)
                            .cornerRadius(20)
                    }
                    .padding(.horizontal, 40)
                    
                    Button(action: completeTutorial) {
                        Text("Skip Tutorial")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var fingerIndicator: some View {
        ZStack {
            // Glow effect
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.4),
                            Color.white.opacity(0.1),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 30
                    )
                )
                .frame(width: 60, height: 60)
            
            // Finger icon
            Image(systemName: "hand.point.up.fill")
                .font(.system(size: 36))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 5)
        }
    }
    
    private var gestureLabels: some View {
        HStack(spacing: 20) {
            gestureLabel("←", "Bad", Color(red: 0.95, green: 0.45, blue: 0.45))
            gestureLabel("↑", "Mid", Color(red: 0.6, green: 0.65, blue: 0.7))
            gestureLabel("→", "Good", Color(red: 0.2, green: 0.78, blue: 0.55))
        }
        .padding(.horizontal, 20)
    }
    
    private func gestureLabel(_ arrow: String, _ label: String, _ color: Color) -> some View {
        VStack(spacing: 4) {
            Text(arrow)
                .font(.system(size: 24))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .textCase(.uppercase)
                .tracking(1)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Regular Tutorial Card
    
    private var tutorialCard: some View {
        VStack(spacing: 24) {
            // Step Indicator
            HStack(spacing: 8) {
                ForEach(0..<steps.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentStep - 1 ? Color.blue : Color.white.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 8)
            
            // Icon
            ZStack {
                Circle()
                    .fill(steps[currentStep - 1].color.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: steps[currentStep - 1].icon)
                    .font(.system(size: 36))
                    .foregroundColor(steps[currentStep - 1].color)
            }
            .scaleEffect(pulseAnimation ? 1.1 : 1.0)
            
            // Title
            Text(steps[currentStep - 1].title)
                .font(.system(size: 24, weight: .bold))
                .multilineTextAlignment(.center)
            
            // Description
            Text(steps[currentStep - 1].description)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // Button
            Button(action: handleNext) {
                Text(currentStep == steps.count ? "Get Started" : "Next")
                    .font(.system(size: 16, weight: .bold))
                    .textCase(.uppercase)
                    .tracking(2)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
            
            // Skip button
            if currentStep < steps.count {
                Button(action: completeTutorial) {
                    Text("Skip Tutorial")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 12)
            }
        }
        .padding(.vertical, 32)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(32)
        .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 20)
        .padding(.horizontal, 24)
    }
    
    // MARK: - Animation Logic
    
    private func startSwipeDemo() {
        // Wait a moment, then start the demo loop
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            animateSwipeSequence()
        }
    }
    
    private func animateSwipeSequence() {
        // Sequence: Bad (left), Mid (up), Good (right), repeat
        let gestures: [(offset: CGSize, progress: CGFloat, mood: MoodType?)] = [
            (CGSize(width: -100, height: 0), -0.8, .bad),   // Left - Bad
            (CGSize(width: 0, height: -100), 0, .mid),      // Up - Mid
            (CGSize(width: 100, height: 0), 0.8, .good),    // Right - Good
        ]
        
        var gestureIndex = 0
        
        func performGesture() {
            let gesture = gestures[gestureIndex]
            
            // Show finger
            withAnimation(.easeOut(duration: 0.3)) {
                fingerOpacity = 1.0
                fingerOffset = .zero
            }
            
            // Wait, then swipe
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Animate swipe
                withAnimation(.easeInOut(duration: 1.2)) {
                    fingerOffset = gesture.offset
                    simulatedDragProgress = gesture.progress
                }
                
                // Fade out finger and set mood
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeIn(duration: 0.3)) {
                        fingerOpacity = 0
                    }
                    
                    // Set the mood
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        demoMood = gesture.mood
                        simulatedDragProgress = 0
                    }
                    
                    // Wait, then reset and continue
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            demoMood = nil
                            fingerOffset = .zero
                        }
                        
                        // Show continue button after 2 full cycles (6 gestures)
                        if gestureIndex == gestures.count - 1 {
                            let cycleCount = (gestureIndex + 1) / gestures.count + 1
                            if cycleCount >= 2 && !showFingerHint {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    showFingerHint = true
                                }
                            }
                        }
                        
                        // Move to next gesture
                        gestureIndex = (gestureIndex + 1) % gestures.count
                        
                        // Continue loop after a pause
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            performGesture()
                        }
                    }
                }
            }
        }
        
        performGesture()
    }
    
    // MARK: - Navigation
    
    private func handleNext() {
        impactLight.impactOccurred()
        
        if currentStep < steps.count {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                currentStep += 1
            }
            if currentStep > 0 {
                startPulseAnimation()
            }
        } else {
            completeTutorial()
        }
    }
    
    private func completeTutorial() {
        impactLight.impactOccurred()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            isPresented = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onComplete()
        }
    }
    
    private func startPulseAnimation() {
        pulseAnimation = false
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            pulseAnimation = true
        }
    }
    
    // MARK: - Tutorial Steps (for later screens)
    
    private let steps: [TutorialStep] = [
        TutorialStep(
            icon: "calendar",
            color: .purple,
            title: "View Your History",
            description: "Check the History tab to see your mood patterns over time. Tap any day to jump back and edit."
        ),
        TutorialStep(
            icon: "sparkles",
            color: Color(red: 0.2, green: 0.78, blue: 0.55),
            title: "You're All Set!",
            description: "Start tracking your daily mood and discover patterns in your emotional wellbeing with your octopus companion! 🐙"
        )
    ]
}

struct TutorialStep {
    let icon: String
    let color: Color
    let title: String
    let description: String
}
