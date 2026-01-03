import SwiftUI

/// Animated reversible octopus plush view
/// Maps mood to octopus state: Good = Pink/Happy, Bad = Blue/Sad, Mid = Mixed
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
    
    var body: some View {
        ZStack {
            // Background glow when dragging
            if isDragging {
                Circle()
                    .fill(octopusGlowColor)
                    .frame(width: size * 1.3, height: size * 1.3)
                    .blur(radius: 40)
                    .opacity(0.4)
            }
            
            // The octopus
            octopusImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .rotationEffect(.degrees(isDragging ? dragProgress * 5 : 0)) // Slight tilt when dragging
                .scaleEffect(isDragging ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDragging)
                .animation(.easeInOut(duration: 0.3), value: octopusFrame)
        }
    }
    
    /// Determines which octopus frame to show based on mood and drag progress
    private var octopusFrame: String {
        // If we have a saved mood, show the final state
        if let mood = mood, !isDragging {
            switch mood {
            case .good:
                return "octopus-happy-5" // Fully pink/happy
            case .bad:
                return "octopus-sad-5"   // Fully blue/sad
            case .mid:
                return "octopus-mid"     // Mixed state
            }
        }
        
        // Otherwise, show frame based on drag progress
        // dragProgress: -1 to +1
        // Map to frames: 0 (fully sad) to 10 (fully happy)
        let normalizedProgress = (dragProgress + 1) / 2 // Convert -1...1 to 0...1
        let frameIndex = Int(normalizedProgress * 10).clamped(to: 0...10)
        
        return octopusFrameName(for: frameIndex)
    }
    
    /// Maps frame index (0-10) to asset name
    private func octopusFrameName(for index: Int) -> String {
        switch index {
        case 0...2:   return "octopus-sad-5"     // Fully blue/sad
        case 3:       return "octopus-sad-4"     // Mostly blue
        case 4:       return "octopus-sad-3"     // Transitioning
        case 5:       return "octopus-mid"       // Half and half
        case 6:       return "octopus-happy-3"   // Transitioning
        case 7:       return "octopus-happy-4"   // Mostly pink
        case 8...10:  return "octopus-happy-5"   // Fully pink/happy
        default:      return "octopus-mid"
        }
    }
    
    /// Glow color based on drag direction
    private var octopusGlowColor: Color {
        if dragProgress > 0.3 {
            return Color(red: 51/255, green: 199/255, blue: 140/255) // Emerald (Good)
        } else if dragProgress < -0.3 {
            return Color(red: 242/255, green: 115/255, blue: 115/255) // Coral (Bad)
        } else {
            return Color(red: 153/255, green: 166/255, blue: 179/255) // Slate (Mid)
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
extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        return min(max(self, range.lowerBound), range.upperBound)
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
                OctopusView(mood: .good, dragProgress: 1.0, size: 200, isDragging: false)
            }
            
            // Mid octopus
            VStack {
                Text("Mid")
                    .font(.caption)
                OctopusView(mood: .mid, dragProgress: 0.0, size: 200, isDragging: false)
            }
            
            // Sad octopus
            VStack {
                Text("Sad (Bad)")
                    .font(.caption)
                OctopusView(mood: .bad, dragProgress: -1.0, size: 200, isDragging: false)
            }
        }
        .padding()
    }
}

