import SwiftUI
import Lottie

struct OverlayView: View {
    let meeting: Meeting
    let screenWidth: CGFloat
    let onFinished: () -> Void

    @State private var robotX: CGFloat = -100
    @State private var showBubble: Bool = false
    @State private var bubbleText: String = ""
    @State private var clickMessageIndex: Int = 0
    @State private var isClickMessage: Bool = false

    private let clickMessages = [
        "Yes yes, I know you're busy 😅",
        "Still here... tick tock ⏰",
        "Your meeting called, it misses you 📞",
        "I'm just a robot, don't shoot the messenger 🤖"
    ]

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color.clear
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                if showBubble {
                    bubbleView(text: bubbleText)
                        .transition(.scale(scale: 0.8)
                            .combined(with: .opacity))
                }
                Spacer().frame(height: 4)
                WalkingRobotView()
                    .frame(width: 80, height: 80)
                    .onTapGesture { handleTap() }
            }
            .frame(width: 200, height: 130, alignment: .bottom)
            .offset(x: robotX)
            .animation(.linear(duration: 0.1), value: robotX)
        }
        .frame(width: screenWidth, height: 140)
        .onAppear { startSequence() }
    }

    private func startSequence() {
        robotX = -100
        bubbleText = "\(meeting.title) in \(meeting.countdownLabel)!"

        // Phase 1: Walk from left edge to 30% of screen
        // Human walking pace — very slow and natural
        withAnimation(.linear(duration: 12)) {
            robotX = screenWidth * 0.30
        }

        // Show bubble when robot reaches 30%
        DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
            withAnimation(.spring(response: 0.5)) {
                showBubble = true
            }
        }

        // Phase 2: Stay at 30% for 12 seconds while bubble shows
        // Then continue walking to right edge — same slow pace
        DispatchQueue.main.asyncAfter(deadline: .now() + 24) {
            if !isClickMessage {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showBubble = false
                }
            }
            // Walk remaining 70% of screen at same pace
            withAnimation(.linear(duration: 28)) {
                robotX = screenWidth + 120
            }
        }

        // Clean up after robot exits
        DispatchQueue.main.asyncAfter(deadline: .now() + 55) {
            onFinished()
        }
    }

    private func handleTap() {
        isClickMessage = true
        bubbleText = clickMessages[
            clickMessageIndex % clickMessages.count
        ]
        clickMessageIndex += 1
        withAnimation(.spring(response: 0.3)) {
            showBubble = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            withAnimation(.easeInOut(duration: 0.4)) {
                showBubble = false
            }
            isClickMessage = false
        }
    }

    private func bubbleView(text: String) -> some View {
        VStack(spacing: 0) {
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: "1C1C2E"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.15),
                                radius: 6, y: 2)
                )
            BubbleTriangle()
                .fill(Color.white)
                .frame(width: 10, height: 7)
                .offset(y: -0.5)
        }
    }
}

private struct BubbleTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: 0))
        p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.maxX, y: 0))
        p.closeSubpath()
        return p
    }
}

struct WalkingRobotView: View {
    var body: some View {
        _WalkingRobotNSView()
            .frame(width: 346, height: 346)
            .scaleEffect(0.231)
            .frame(width: 80, height: 80)
            .clipped()
    }
}

struct _WalkingRobotNSView: NSViewRepresentable {
    func makeNSView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: "robot")
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        view.animationSpeed = 0.35
        view.play()
        return view
    }
    func updateNSView(_ nsView: LottieAnimationView,
                      context: Context) {}
}
