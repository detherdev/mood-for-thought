import SwiftUI

struct GlassModifier: ViewModifier {
    var cornerRadius: CGFloat = 32
    var opacity: CGFloat = 0.4
    
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(.white.opacity(0.2), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}

extension View {
    func ios26Glass(radius: CGFloat = 32, opacity: CGFloat = 0.4) -> some View {
        self.modifier(GlassModifier(cornerRadius: radius, opacity: opacity))
    }
}

struct DepthBlob: View {
    let color: Color
    @State private var animate = false
    
    var body: some View {
        Circle()
            .fill(color.opacity(0.2))
            .blur(radius: 100)
            .scaleEffect(animate ? 1.2 : 0.8)
            .offset(x: animate ? 50 : -50, y: animate ? -30 : 30)
            .onAppear {
                withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                    animate.toggle()
                }
            }
    }
}

// MARK: - Shimmer Effect
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        .white.opacity(0.3),
                        .clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 400
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

