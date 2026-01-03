import SwiftUI

struct TutorialView: View {
    @Binding var isPresented: Bool
    var onComplete: () -> Void
    
    @State private var currentStep = 0
    @State private var pulseAnimation = false
    
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        ZStack {
            // Semi-transparent backdrop
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    if currentStep == steps.count - 1 {
                        completeTutorial()
                    }
                }
            
            VStack {
                Spacer()
                
                // Tutorial Content Card
                VStack(spacing: 24) {
                    // Step Indicator
                    HStack(spacing: 8) {
                        ForEach(0..<steps.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentStep ? Color.blue : Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.top, 8)
                    
                    // Icon
                    ZStack {
                        Circle()
                            .fill(steps[currentStep].color.opacity(0.15))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: steps[currentStep].icon)
                            .font(.system(size: 36))
                            .foregroundColor(steps[currentStep].color)
                    }
                    .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                    
                    // Title
                    Text(steps[currentStep].title)
                        .font(.system(size: 24, weight: .bold))
                        .multilineTextAlignment(.center)
                    
                    // Description
                    Text(steps[currentStep].description)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    // Gesture Hint (for swipe step)
                    if currentStep == 0 {
                        gestureHints
                    }
                    
                    // Button
                    Button(action: handleNext) {
                        Text(currentStep == steps.count - 1 ? "Get Started" : "Next")
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
                    if currentStep < steps.count - 1 {
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
                
                Spacer()
                    .frame(height: 100)
            }
        }
        .onAppear {
            impactLight.prepare()
            startPulseAnimation()
        }
    }
    
    private var gestureHints: some View {
        HStack(spacing: 16) {
            gestureHint(direction: "←", label: "Bad", color: Color(red: 0.95, green: 0.45, blue: 0.45))
            gestureHint(direction: "↑", label: "Mid", color: Color(red: 0.6, green: 0.65, blue: 0.7))
            gestureHint(direction: "→", label: "Good", color: Color(red: 0.2, green: 0.78, blue: 0.55))
        }
        .padding(.vertical, 12)
    }
    
    private func gestureHint(direction: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(direction)
                .font(.system(size: 28))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .textCase(.uppercase)
                .tracking(1)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.08))
        .cornerRadius(12)
    }
    
    private func handleNext() {
        impactLight.impactOccurred()
        
        if currentStep < steps.count - 1 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                currentStep += 1
            }
            startPulseAnimation()
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
    
    private let steps: [TutorialStep] = [
        TutorialStep(
            icon: "hand.draw",
            color: .blue,
            title: "Swipe to Select",
            description: "Swipe left for bad, right for good, or up for mid. Feel free to try it now!"
        ),
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
            description: "Start tracking your daily mood and discover patterns in your emotional wellbeing."
        )
    ]
}

struct TutorialStep {
    let icon: String
    let color: Color
    let title: String
    let description: String
}

