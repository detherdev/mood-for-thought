import SwiftUI

struct MoodLoggerView: View {
    @Binding var selectedDate: Date
    
    @State private var dragOffset: CGSize = .zero
    @State private var selectedMood: MoodType? = nil
    @State private var showNote = false
    @State private var note = ""
    @State private var isSaved = false
    @State private var isSaving = false
    @State private var isLoadingMood = false
    @State private var dragIntensity: CGFloat = 0
    @State private var showColorBurst = false
    @State private var burstColor: Color = .clear
    @State private var octopusModeEnabled = true // Default to Octopus mode! 🐙
    @State private var octopusAnimatedFrame: Int? = nil
    
    // Haptic Generators - Each mood has distinct feedback
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let impactRigid = UIImpactFeedbackGenerator(style: .rigid)
    private let impactSoft = UIImpactFeedbackGenerator(style: .soft)
    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    // Professional Color Palette
    private let goodColor = Color(red: 0.2, green: 0.78, blue: 0.55) // Emerald
    private let badColor = Color(red: 0.95, green: 0.45, blue: 0.45) // Coral
    private let midColor = Color(red: 1.0, green: 0.8, blue: 0.2) // Amber Yellow
    
    var body: some View {
        VStack(spacing: 32) {
            // Date Indicator at top
            Text(selectedDate.format("EEEE, MMMM d, yyyy"))
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.top, 20)
            
            // Date Controls
            HStack(spacing: 40) {
                Button(action: { moveDate(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .ios26Glass(radius: 20)
                        .frame(width: 50, height: 50)
                }
                
                Button(action: { moveDate(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .ios26Glass(radius: 20)
                        .frame(width: 50, height: 50)
                }
                .disabled(Calendar.current.isDateInToday(selectedDate))
                .opacity(Calendar.current.isDateInToday(selectedDate) ? 0.3 : 1)
            }
            .padding(.top, 20)
            
            // Central Circle or Octopus - Lower for better reachability
            VStack(spacing: 16) {
                ZStack {
                    if octopusModeEnabled {
                        // 🐙 Octopus Mode
                        OctopusView(
                            mood: selectedMood,
                            dragProgress: calculateDragProgress(),
                            size: 240,
                            isDragging: dragIntensity > 0,
                            animatedFrame: octopusAnimatedFrame
                        )
                        .scaleEffect(1.0 + dragIntensity * 0.05)
                        .offset(x: dragOffset.width * 0.8, y: dragOffset.height * 0.8)
                    } else {
                        // Regular Circle Mode
                        // Outer glow effect
                        Circle()
                            .fill(circleBackground.opacity(0.3))
                            .frame(width: 260, height: 260)
                            .blur(radius: 20)
                            .opacity(dragIntensity)
                        
                        Circle()
                            .fill(circleBackground)
                            .frame(width: 240, height: 240)
                            .ios26Glass(radius: 120)
                            .scaleEffect(1.0 + dragIntensity * 0.05)
                            .offset(x: dragOffset.width * 0.8, y: dragOffset.height * 0.8)
                            .rotationEffect(.degrees(dragOffset.width * 0.1))
                        
                        VStack(spacing: 8) {
                            // Show emoji preview when dragging far enough
                            if dragIntensity > 0.6 && selectedMood == nil {
                                if abs(dragOffset.width) > abs(dragOffset.height) {
                                    Text(dragOffset.width > 0 ? "😊" : "😔")
                                        .font(.system(size: 80))
                                        .transition(.scale.combined(with: .opacity))
                                } else if dragOffset.height < 0 {
                                    Text("😐")
                                        .font(.system(size: 80))
                                        .transition(.scale.combined(with: .opacity))
                                }
                            } else {
                                Text(selectedDate.format("EEEE"))
                                    .font(.system(size: 14, weight: .bold))
                                    .textCase(.uppercase)
                                    .tracking(4)
                                    .opacity(0.5)
                                
                                Text(selectedDate.format("d"))
                                    .font(.system(size: 96, weight: .ultraLight, design: .rounded))
                                
                                Text(selectedDate.format("MMM yyyy"))
                                    .font(.system(size: 15, weight: .semibold))
                                    .textCase(.uppercase)
                                    .tracking(2.5)
                                    .opacity(0.5)
                            }
                        }
                        .foregroundColor(selectedMood != nil || dragIntensity > 0.6 ? .white : .primary)
                    }
                }
                .background(
                    // Radiating color burst effect - behind everything, doesn't affect layout
                    Group {
                        if showColorBurst {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            burstColor.opacity(0.3),
                                            burstColor.opacity(0.2),
                                            burstColor.opacity(0.1),
                                            burstColor.opacity(0.0)
                                        ]),
                                        center: .center,
                                        startRadius: 100,
                                        endRadius: 400
                                    )
                                )
                                .frame(width: 800, height: 800)
                                .scaleEffect(showColorBurst ? 1.0 : 0.3)
                                .opacity(showColorBurst ? 1.0 : 0.0)
                                .blur(radius: 30)
                        }
                    }
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let prevOffset = dragOffset
                            dragOffset = value.translation
                            
                            // Calculate drag intensity for visual feedback
                            let distance = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
                            withAnimation(.easeOut(duration: 0.1)) {
                                dragIntensity = min(distance / 150, 1.0)
                            }
                            
                            handleDrag(current: value.translation, previous: prevOffset)
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.65, blendDuration: 0)) {
                                finalizeMood()
                                dragOffset = .zero
                                dragIntensity = 0
                            }
                        }
                )
                
                // Hint text - only shows when no mood selected
                if selectedMood == nil && !isLoadingMood {
                    VStack(spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "hand.draw")
                                .font(.system(size: 12))
                            Text("Swipe to select mood")
                                .font(.system(size: 13, weight: .medium))
                        }
                        
                        // Direction hints
                        Text("← Bad  •  ↑ Mid  •  Good →")
                            .font(.system(size: 11, weight: .regular))
                            .opacity(0.8)
                    }
                    .foregroundColor(.secondary.opacity(0.6))
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.top, 60)
            
            Spacer()
            
            // Bottom Action Card - Above tab bar
            if selectedMood != nil {
                VStack(spacing: 12) {
                    HStack(spacing: 10) {
                        MoodButton(type: .bad, current: $selectedMood) { animateButtonSelection(to: .bad) }
                        MoodButton(type: .mid, current: $selectedMood) { animateButtonSelection(to: .mid) }
                        MoodButton(type: .good, current: $selectedMood) { animateButtonSelection(to: .good) }
                    }
                    
                    if !showNote {
                        Button("+ Add Context") {
                            impactLight.impactOccurred()
                            withAnimation { showNote = true }
                        }
                        .font(.system(size: 9, weight: .bold))
                        .textCase(.uppercase)
                        .tracking(2)
                        .opacity(0.5)
                    } else {
                        TextField("What's on your mind?", text: $note)
                            .font(.system(size: 14))
                            .padding(12)
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(16)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    Button(action: syncMood) {
                        HStack(spacing: 8) {
                            if isSaving {
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(0.9)
                                Text("Saving...")
                                    .font(.system(size: 12, weight: .bold))
                                    .textCase(.uppercase)
                                    .tracking(2)
                            } else if isSaved {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16))
                                Text("Saved")
                                    .font(.system(size: 12, weight: .bold))
                                    .textCase(.uppercase)
                                    .tracking(2)
                            } else {
                                Text("Confirm Mood")
                                    .font(.system(size: 12, weight: .bold))
                                    .textCase(.uppercase)
                                    .tracking(2)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(isSaved ? goodColor : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .shadow(color: (isSaved ? goodColor : Color.blue).opacity(0.3), radius: 12, x: 0, y: 6)
                    }
                    .disabled(isSaving || isSaved)
                }
                .padding(16)
                .ios26Glass(radius: 32)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.bottom, 120)
            }
        }
        .padding()
        .onAppear {
            selectionFeedback.prepare()
            impactLight.prepare()
            impactMedium.prepare()
            impactHeavy.prepare()
            impactRigid.prepare()
            impactSoft.prepare()
            notificationFeedback.prepare()
            loadOctopusModeState()
            loadMoodForDate()
        }
        .onChange(of: selectedDate) { _ in
            loadMoodForDate()
        }
        .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
            loadOctopusModeState()
        }
    }
    
    private var circleBackground: Color {
        // If actively dragging without a selected mood, show progressive color
        if selectedMood == nil && dragIntensity > 0 {
            let threshold: CGFloat = 100
            
            if abs(dragOffset.width) > abs(dragOffset.height) {
                // Horizontal drag
                let progress = min(abs(dragOffset.width) / threshold, 1.0)
                if dragOffset.width > 0 {
                    // Dragging right → Good (blend to green)
                    return blendColor(from: Color.secondary.opacity(0.1), to: goodColor, progress: progress)
                } else {
                    // Dragging left → Bad (blend to red)
                    return blendColor(from: Color.secondary.opacity(0.1), to: badColor, progress: progress)
                }
            } else if dragOffset.height < 0 {
                // Dragging up → Mid (blend to gray)
                let progress = min(abs(dragOffset.height) / threshold, 1.0)
                return blendColor(from: Color.secondary.opacity(0.1), to: midColor, progress: progress)
            }
        }
        
        // Selected mood or default
        guard let mood = selectedMood else { return Color.secondary.opacity(0.1) }
        switch mood {
            case .good: return goodColor
            case .bad: return badColor
            case .mid: return midColor
        }
    }
    
    private func blendColor(from: Color, to: Color, progress: CGFloat) -> Color {
        // Simple interpolation by adjusting opacity
        // The 'to' color becomes more visible as progress increases
        return to.opacity(progress)
    }
    
    private func handleDrag(current: CGSize, previous: CGSize) {
        let threshold: CGFloat = 100 // Increased from 80
        
        // Haptic "clicks" when crossing thresholds
        if (abs(current.width) >= threshold && abs(previous.width) < threshold) ||
           (abs(current.height) >= threshold && abs(previous.height) < threshold) {
            selectionFeedback.prepare()
            selectionFeedback.selectionChanged()
        }
    }
    
    private func animateButtonSelection(to mood: MoodType) {
        // Color burst for button selection too
        let color: Color
        switch mood {
        case .good: color = goodColor
        case .bad: color = badColor
        case .mid: color = midColor
        }
        
        // Different haptics for each mood when using buttons
        switch mood {
        case .good:
            triggerDoubleTapHaptic(first: impactMedium, second: impactHeavy, delay: 0.08)
        case .bad:
            triggerDoubleTapHaptic(first: impactHeavy, second: impactHeavy, delay: 0.1)
        case .mid:
            triggerDoubleTapHaptic(first: impactRigid, second: impactMedium, delay: 0.08)
        }
        
        // In Octopus mode, animate through frames for smooth transition
        if octopusModeEnabled {
            animateOctopusTransition(to: mood, color: color)
            return
        }
        
        // Visual "swipe" feedback when clicking a button (increased distance)
        let targetOffset: CGSize
        switch mood {
            case .good: targetOffset = CGSize(width: 140, height: 0)
            case .bad: targetOffset = CGSize(width: -140, height: 0)
            case .mid: targetOffset = CGSize(width: 0, height: -140)
        }
        
        // Animate the swipe
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7, blendDuration: 0)) {
            dragOffset = targetOffset
            dragIntensity = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            triggerColorBurst(color: color)
            withAnimation(.spring(response: 0.4, dampingFraction: 0.65, blendDuration: 0)) {
                selectedMood = mood
                dragOffset = .zero
                dragIntensity = 0
            }
        }
    }
    
    private func animateOctopusTransition(to targetMood: MoodType, color: Color) {
        // Trigger color burst immediately! 🌟
        triggerColorBurst(color: color)
        
        // Determine start and end frames
        let currentFrame: Int
        if let mood = selectedMood {
            switch mood {
            case .good: currentFrame = 0
            case .bad: currentFrame = 160
            case .mid: currentFrame = 64
            }
        } else {
            currentFrame = 64 // Start from mid if no mood
        }
        
        let targetFrame: Int
        switch targetMood {
        case .good: targetFrame = 0   // Frame 0 (Happy)
        case .bad: targetFrame = 160  // Frame 160 (Sad)
        case .mid: targetFrame = 64   // Frame 64 (Mid)
        }
        
        // SET MOOD IMMEDIATELY so button moves right away! 🎯
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0)) {
            selectedMood = targetMood
        }
        
        // 60FPS for buttery smooth animation - matches iOS refresh rate
        let fps: Double = 60.0
        let frameDelay: TimeInterval = 1.0 / fps // 0.01667 seconds per frame (~16ms)
        
        let frameDifference = abs(targetFrame - currentFrame)
        guard frameDifference > 0 else {
            return
        }
        
        // Show every 2nd or 3rd frame for good pacing
        // For 160 frames: show every 2nd = 80 frames over 1.33 seconds
        let skipFrames = max(1, frameDifference / 80) // Show up to 80 frames
        let framesToShow = frameDifference / skipFrames
        
        let direction = currentFrame < targetFrame ? 1 : -1
        
        // Animate through frames at 60FPS while button is already moving!
        for i in 0...framesToShow {
            let delay = frameDelay * Double(i)
            let frameOffset = skipFrames * i * direction
            let frame = (currentFrame + frameOffset).clamped(to: min(currentFrame, targetFrame)...max(currentFrame, targetFrame))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                octopusAnimatedFrame = frame
            }
        }
        
        // Clear animated frame after animation completes
        let totalDuration = Double(framesToShow) * frameDelay
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            octopusAnimatedFrame = targetFrame
            
            // Clear animated frame after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                octopusAnimatedFrame = nil
            }
        }
    }
    
    private func finalizeMood() {
        let threshold: CGFloat = 100 // Increased from 80 for more intentional swipes
        if dragOffset.width > threshold { 
            selectedMood = .good
            triggerColorBurst(color: goodColor)
            // Good = Double tap with increasing intensity (uplifting)
            triggerDoubleTapHaptic(first: impactMedium, second: impactHeavy, delay: 0.08)
        } else if dragOffset.width < -threshold { 
            selectedMood = .bad
            triggerColorBurst(color: badColor)
            // Bad = Heavy double tap (firm acknowledgment)
            triggerDoubleTapHaptic(first: impactHeavy, second: impactHeavy, delay: 0.1)
        } else if dragOffset.height < -threshold { 
            selectedMood = .mid
            triggerColorBurst(color: midColor)
            // Mid = Rigid tap (neutral, balanced)
            triggerDoubleTapHaptic(first: impactRigid, second: impactMedium, delay: 0.08)
        }
    }
    
    private func triggerColorBurst(color: Color) {
        // Cancel any existing burst first
        showColorBurst = false
        
        // Set new color and trigger burst
        burstColor = color
        
        // Small delay to ensure previous animation is cancelled
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            // Radiate outward effect - quick and subtle
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                self.showColorBurst = true
            }
            
            // Fade out faster for subtlety
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.3)) {
                    self.showColorBurst = false
                }
            }
        }
    }
    
    private func triggerDoubleTapHaptic(first: UIImpactFeedbackGenerator, second: UIImpactFeedbackGenerator, delay: TimeInterval) {
        // Prepare both generators to ensure they're ready
        first.prepare()
        second.prepare()
        
        // First tap
        first.impactOccurred()
        
        // Second tap after delay, with re-preparation
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            second.prepare()
            second.impactOccurred()
        }
    }
    
    private func syncMood() {
        // Rigid haptic for confirm action (like pressing a physical button)
        impactRigid.prepare()
        impactRigid.impactOccurred()
        withAnimation { isSaving = true }
        
        Task {
            do {
                let currentMood = selectedMood ?? .mid
                let isLocalMode = UserDefaults.standard.bool(forKey: "useLocalMode")
                
                // Save mood (cloud or local)
                if isLocalMode {
                    // Local storage (no account)
                    LocalMoodStorage.shared.saveMood(
                        date: selectedDate,
                        mood: currentMood,
                        note: note.isEmpty ? nil : note
                    )
                } else {
                    // Cloud storage (Supabase)
                    try await SupabaseManager.shared.saveMood(
                        date: selectedDate.format("yyyy-MM-dd"),
                        mood: currentMood,
                        note: note.isEmpty ? nil : note
                    )
                }
                
                // Sync to iOS Calendar if enabled
                let calendarSynced = await CalendarManager.shared.syncMoodToCalendar(
                    date: selectedDate,
                    mood: currentMood,
                    note: note.isEmpty ? nil : note
                )
                
                if calendarSynced {
                    print("✓ Mood synced to iOS Calendar")
                }
                
                await MainActor.run {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        isSaving = false
                        isSaved = true
                    }
                    notificationFeedback.notificationOccurred(.success)
                }
                
                // Show success for 1.5 seconds
                try await Task.sleep(nanoseconds: 1_500_000_000)
                
                await MainActor.run {
                    withAnimation { isSaved = false }
                }
            } catch {
                print("Sync failed: \(error)")
                await MainActor.run {
                    withAnimation { 
                        isSaving = false
                        isSaved = false 
                    }
                    notificationFeedback.notificationOccurred(.error)
                }
            }
        }
    }
    
    private func moveDate(by days: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) {
            withAnimation {
                selectedDate = newDate
                showNote = false
                note = ""
                isSaved = false
                isSaving = false
                showColorBurst = false
            }
            selectionFeedback.prepare()
            selectionFeedback.selectionChanged()
        }
    }
    
    private func loadMoodForDate() {
        isLoadingMood = true
        isSaved = false
        isSaving = false
        
        Task {
            let isLocalMode = UserDefaults.standard.bool(forKey: "useLocalMode")
            
            if isLocalMode {
                // Load from local storage
                if let savedMood = LocalMoodStorage.shared.getMood(for: selectedDate) {
                    await MainActor.run {
                        selectedMood = savedMood.mood
                        note = savedMood.note ?? ""
                        showNote = savedMood.note != nil && !savedMood.note!.isEmpty
                        isLoadingMood = false
                    }
                } else {
                    await MainActor.run {
                        selectedMood = nil
                        note = ""
                        showNote = false
                        isLoadingMood = false
                    }
                }
            } else {
                // Load from cloud storage
                do {
                    let dateString = selectedDate.format("yyyy-MM-dd")
                    if let savedMood = try await SupabaseManager.shared.fetchMoodForDate(date: dateString) {
                        await MainActor.run {
                            selectedMood = savedMood.mood
                            note = savedMood.note ?? ""
                            showNote = savedMood.note != nil && !savedMood.note!.isEmpty
                            isLoadingMood = false
                        }
                    } else {
                        await MainActor.run {
                            selectedMood = nil
                            note = ""
                            showNote = false
                            isLoadingMood = false
                        }
                    }
                } catch {
                    print("Failed to load mood: \(error)")
                    await MainActor.run {
                        isLoadingMood = false
                    }
                }
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
    
    /// Calculates drag progress from -1 (left/bad) to +1 (right/good) for octopus animation
    private func calculateDragProgress() -> CGFloat {
        let threshold: CGFloat = 100
        
        // If we have a selected mood, return fixed value
        if let mood = selectedMood, dragIntensity == 0 {
            switch mood {
            case .good: return 1.0
            case .bad: return -1.0
            case .mid: return 0.0
            }
        }
        
        // During drag, calculate based on offset
        if abs(dragOffset.width) > abs(dragOffset.height) {
            // Horizontal drag (good/bad)
            return min(max(dragOffset.width / threshold, -1.0), 1.0)
        } else if dragOffset.height < 0 {
            // Vertical drag up (mid) - map to 0
            return 0.0
        }
        
        return 0.0
    }
}

struct MoodButton: View {
    let type: MoodType
    @Binding var current: MoodType?
    let action: () -> Void
    
    private let goodColor = Color(red: 0.2, green: 0.78, blue: 0.55)
    private let badColor = Color(red: 0.95, green: 0.45, blue: 0.45)
    private let midColor = Color(red: 1.0, green: 0.8, blue: 0.2)
    
    var body: some View {
        Button(action: action) {
            Text(type.rawValue.uppercased())
                .font(.system(size: 9, weight: .bold))
                .tracking(1.5)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(current == type ? color : Color.black.opacity(0.05))
                .foregroundColor(current == type ? .white : .secondary)
                .cornerRadius(16)
        }
    }
    
    private var color: Color {
        switch type {
            case .good: return goodColor
            case .bad: return badColor
            case .mid: return midColor
        }
    }
}

// Helper extension for clamping integers
private extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        return Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
