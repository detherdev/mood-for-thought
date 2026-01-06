import SwiftUI

/// Animated reversible octopus plush view - ULTRA SMOOTH 161 FRAME VERSION
/// Maps mood to octopus state: Good = Pink/Happy, Bad = Blue/Sad, Mid = Mixed
/// Cinema-quality animation with 161 transparent frames and beautiful glow effect
struct OctopusView: View {
    /// Current mood (nil if no mood selected)
    let mood: MoodType?
    
    /// Drag progress: -1 (fully left/bad) to +1 (fully right/good)
    /// 0 = center/mid, negative = transitioning to bad, positive = transitioning to good
    let dragProgress: CGFloat
    
    /// Size of the octopus
    let size: CGFloat
    
    /// Whether the octopus is currently being dragged
    let isDragging: Bool
    
    /// Animated frame for smooth button transitions
    let animatedFrame: Int?
    
    // 161 frames with transparent backgrounds for beautiful glow effect
    // Frame distribution: 0-17 (Happy), 18-109 (Transition), 110-160 (Sad)
    private let totalFrames: Int = 160 // 0-indexed (0 to 160 = 161 frames)
    
    var body: some View {
        // The octopus - GPU accelerated for maximum smoothness
        octopusImage
            .resizable()
            .interpolation(.high) // High-quality image scaling
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .drawingGroup() // Render on GPU for maximum performance
            .rotationEffect(.degrees(isDragging ? Double(dragProgress) * 5 : 0))
            .scaleEffect(isDragging ? 1.1 : 1.0)
            .background(
                // Glow behind octopus - doesn't affect layout!
                Group {
                    if isDragging || animatedFrame != nil {
                        Circle()
                            .fill(octopusGlowColor)
                            .frame(width: size * 1.4, height: size * 1.4)
                            .blur(radius: 50)
                            .opacity(0.5)
                    }
                }
            )
            .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.85), value: isDragging)
            .animation(.linear(duration: 0.016), value: animatedFrame) // Fast, smooth frame updates
    }
    
    /// Determines which octopus frame to show based on mood and drag progress
    /// Frame distribution: 0-17 (Happy), 18-109 (Transition), 110-160 (Sad)
    private var octopusFrame: String {
        // If we're in an animated transition (button click), use that frame
        if let animatedFrame = animatedFrame {
            return "octopus-\(animatedFrame.clamped(to: 0...totalFrames))"
        }
        
        // If we have a saved mood and not dragging, show the final state
        if let mood = mood, !isDragging {
            switch mood {
            case .good:
                return "octopus-0" // Frame 0 (fully happy/pink)
            case .bad:
                return "octopus-160" // Frame 160 (fully sad/blue)
            case .mid:
                return "octopus-64" // Frame 64 (middle of transition)
            }
        }
        
        // Calculate frame based on drag progress
        // dragProgress: -1 (sad) to +1 (happy)
        // Map to frames: 160 (sad) to 0 (happy)
        let normalizedProgress = (dragProgress + 1) / 2 // Convert -1...1 to 0...1
        let rawFrameIndex = CGFloat(totalFrames) - (normalizedProgress * CGFloat(totalFrames))
        
        // Round to nearest frame for smooth transitions
        let frameIndex = Int(rawFrameIndex.rounded())
        
        return "octopus-\(frameIndex.clamped(to: 0...totalFrames))"
    }
    
    /// Glow color based on current frame or drag direction
    private var octopusGlowColor: Color {
        // Determine current frame for color calculation
        let currentFrameIndex: Int
        
        if let animatedFrame = animatedFrame {
            currentFrameIndex = animatedFrame
        } else if let mood = mood, !isDragging {
            switch mood {
            case .good: currentFrameIndex = 0
            case .bad: currentFrameIndex = 160
            case .mid: currentFrameIndex = 64
            }
        } else {
            let normalizedProgress = (dragProgress + 1) / 2
            currentFrameIndex = Int((CGFloat(totalFrames) - (normalizedProgress * CGFloat(totalFrames))).rounded())
        }
        
        // Color based on frame position
        // Frames 0-17: Happy (emerald glow)
        // Frames 18-50: Transition (emerald to yellow)
        // Frames 51-77: Mid (yellow glow) - includes frame 64
        // Frames 78-109: Transition (yellow to coral)
        // Frames 110-160: Sad (coral glow)
        
        let emerald = Color(red: 51/255, green: 199/255, blue: 140/255)
        let yellow = Color(red: 255/255, green: 204/255, blue: 51/255)
        let coral = Color(red: 242/255, green: 115/255, blue: 115/255)
        
        if currentFrameIndex <= 17 {
            // Happy - Emerald glow
            return emerald
        } else if currentFrameIndex >= 18 && currentFrameIndex <= 50 {
            // Transition from emerald to yellow
            let progress = CGFloat(currentFrameIndex - 18) / CGFloat(50 - 18)
            return progress < 0.5 ? emerald : yellow
        } else if currentFrameIndex >= 51 && currentFrameIndex <= 77 {
            // Mid - Yellow glow
            return yellow
        } else if currentFrameIndex >= 78 && currentFrameIndex <= 109 {
            // Transition from yellow to coral
            let progress = CGFloat(currentFrameIndex - 78) / CGFloat(109 - 78)
            return progress < 0.5 ? yellow : coral
        } else {
            // Sad - Coral glow
            return coral
        }
    }
    
    /// Returns the appropriate octopus image
    private var octopusImage: Image {
        // Check if asset exists, fallback to SF Symbol if not
        if let _ = UIImage(named: octopusFrame) {
            return Image(octopusFrame)
        } else {
            // Fallback to emoji-based representation
            return Image(systemName: "circle.fill")
        }
    }
}

// Helper extension to clamp integers
private extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        return Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - Preview
struct OctopusView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            // Happy octopus
            VStack {
                Text("Happy (Good)")
                    .font(.caption)
                OctopusView(mood: .good, dragProgress: 1.0, size: 200, isDragging: false, animatedFrame: nil)
            }
            
            // Mid octopus
            VStack {
                Text("Mid")
                    .font(.caption)
                OctopusView(mood: .mid, dragProgress: 0.0, size: 200, isDragging: false, animatedFrame: nil)
            }
            
            // Sad octopus
            VStack {
                Text("Sad (Bad)")
                    .font(.caption)
                OctopusView(mood: .bad, dragProgress: -1.0, size: 200, isDragging: false, animatedFrame: nil)
            }
        }
        .padding()
    }
}

