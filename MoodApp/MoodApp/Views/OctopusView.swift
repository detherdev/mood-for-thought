import SwiftUI

/// Animated reversible octopus plush view - ULTRA SMOOTH 60 FRAME VERSION
/// Maps mood to octopus state: Good = Pink/Happy, Bad = Blue/Sad, Mid = Mixed
/// Cinema-quality 60fps animation with GPU acceleration
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
    
    // 60 frames for cinema-quality smoothness (subsampled from 231 original frames)
    private let totalFrames: Int = 60
    
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
            
            // The octopus - GPU accelerated for smooth 60fps performance
            octopusImage
                .resizable()
                .interpolation(.high) // High-quality image scaling
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .drawingGroup() // Render on GPU for maximum performance
                .rotationEffect(.degrees(isDragging ? Double(dragProgress) * 5 : 0))
                .scaleEffect(isDragging ? 1.1 : 1.0)
        }
        // Use interactive spring for natural, responsive feel
        .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.85), value: isDragging)
    }
    
    /// Determines which octopus frame to show based on mood and drag progress
    /// With 60 frames, each frame represents ~1.7% of the drag range for ultra-smooth animation
    private var octopusFrame: String {
        // If we have a saved mood, show the final state
        if let mood = mood, !isDragging {
            switch mood {
            case .good:
                return "octopus-1" // First frame (happy/pink)
            case .bad:
                return "octopus-\(totalFrames)" // Last frame (sad/blue) - frame 60
            case .mid:
                return "octopus-\(totalFrames / 2)" // Middle frame (neutral) - frame 30
            }
        }
        
        // Calculate frame based on drag progress
        // dragProgress: -1 (sad) to +1 (happy)
        // Map to frames: 60 (sad) to 1 (happy)
        let normalizedProgress = (dragProgress + 1) / 2 // Convert -1...1 to 0...1
        let rawFrameIndex = CGFloat(totalFrames) - (normalizedProgress * CGFloat(totalFrames - 1))
        
        // Round to nearest frame for smooth transitions
        let frameIndex = Int(rawFrameIndex.rounded())
        
        return "octopus-\(frameIndex.clamped(to: 1...totalFrames))"
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

