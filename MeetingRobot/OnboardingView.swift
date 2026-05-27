import SwiftUI
import Combine
import EventKit

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var showConfirmation = false
    @State private var messageIndex = 0
    @State private var robotOffset: CGFloat = -500

    private let messages = [
        "Hey! I'm better than your alarm clock 🤖",
        "I promise I won't judge your meeting count 👀",
        "Let's get those meetings sorted ⚡",
        "I've been waiting for you... 👁️",
        "Never miss a standup again 🙌",
        "Beep boop... loading your schedule 🔄",
        "I walk so your meetings don't sneak up on you 🚶",
    ]

    var body: some View {
        ZStack {
            FluidGradientBackground()

            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            if showConfirmation {
                ConfirmationView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .transition(.opacity)
            } else {
                mainContent
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showConfirmation)
    }

    // MARK: - Main content

    private var mainContent: some View {
        VStack(spacing: 0) {
            Spacer()

            speechBubble

            Spacer().frame(height: MRSpacing.lg)

            RobotAnimationView()
                .frame(width: 200, height: 200)
                .offset(x: robotOffset)

            Spacer()

            bottomStack
        }
        .onAppear {
            withAnimation(.spring(response: 1.1, dampingFraction: 0.72).delay(0.25)) {
                robotOffset = 0
            }
        }
        .onReceive(Timer.publish(every: 3, on: .main, in: .common).autoconnect()) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                messageIndex = (messageIndex + 1) % messages.count
            }
        }
    }

    // MARK: - Speech bubble

    private var speechBubble: some View {
        ZStack {
            ForEach(messages.indices, id: \.self) { i in
                if i == messageIndex {
                    SpeechBubbleView(text: messages[i])
                        .transition(
                            .scale(scale: 0.8).combined(with: .opacity)
                        )
                }
            }
        }
        .frame(height: 80)
        .padding(.horizontal, MRSpacing.xl)
        .animation(.spring(response: 0.38, dampingFraction: 0.62), value: messageIndex)
    }

    // MARK: - App name + sign-in buttons

    private var bottomStack: some View {
        VStack(spacing: MRSpacing.md) {
            Text("Meeting Robot")
                .font(.mrHeading)
                .foregroundColor(.white)

            Spacer().frame(height: MRSpacing.xs)

            VStack(spacing: MRSpacing.sm) {
                appleButton
                googleButton
            }
        }
        .padding(.horizontal, MRSpacing.xl)
        .padding(.bottom, MRSpacing.xl)
    }

    // MARK: - Buttons

    private var appleButton: some View {
        Button(action: requestCalendarAccess) {
            HStack(spacing: MRSpacing.sm) {
                Image(systemName: "apple.logo")
                    .font(.system(size: 16, weight: .medium))
                Text("Continue with Apple")
                    .font(.system(.body, design: .default).weight(.medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, MRSpacing.md)
            .background(Color.white)
            .foregroundColor(.black)
            .clipShape(Capsule())
        }
        .buttonStyle(ScalePressStyle())
    }

    private var googleButton: some View {
        Button(action: connectGoogleCalendar) {
            HStack(spacing: MRSpacing.sm) {
                GoogleGLogo(size: 18)
                Text("Continue with Google")
                    .font(.system(.body, design: .default).weight(.medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, MRSpacing.md)
            .background(Color.clear)
            .foregroundColor(.white)
            .overlay(Capsule().stroke(Color.white.opacity(0.65), lineWidth: 1.5))
        }
        .buttonStyle(ScalePressStyle())
    }

    // MARK: - Actions

    private func requestCalendarAccess() {
        Task {
            let store = EKEventStore()
            do {
                let granted = try await store.requestFullAccessToEvents()
                if granted {
                    UserDefaults.standard.set("apple", forKey: "calendarProvider")
                    withAnimation(.easeInOut(duration: 0.4)) { showConfirmation = true }
                }
            } catch {
                // Permission denied or restricted — user stays on onboarding
            }
        }
    }

    private func connectGoogleCalendar() {
        // TODO: Implement full Google OAuth flow in a future phase
        UserDefaults.standard.set("google", forKey: "calendarProvider")
        withAnimation(.easeInOut(duration: 0.4)) { showConfirmation = true }
    }
}

// MARK: - Supporting types (private to this file)

private struct SpeechBubbleView: View {
    let text: String

    var body: some View {
        VStack(spacing: 0) {
            Text(text)
                .font(.mrBody)
                .foregroundColor(Color(hex: "1C1C2E"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, MRSpacing.md + MRSpacing.xs)
                .padding(.vertical, MRSpacing.sm + MRSpacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: MRRadius.md)
                        .fill(Color.white)
                )

            BubblePointer()
                .fill(Color.white)
                .frame(width: 18, height: 10)
                .offset(y: -0.5) // close hairline gap between rect and triangle
        }
        .shadow(color: .black.opacity(0.18), radius: 10, x: 0, y: 4)
    }
}

private struct BubblePointer: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        path.closeSubpath()
        return path
    }
}

private struct ScalePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

private struct GoogleGLogo: View {
    var size: CGFloat = 18

    var body: some View {
        Canvas { ctx, sz in
            let cx = sz.width / 2
            let cy = sz.height / 2
            let r  = min(sz.width, sz.height) / 2 - 0.5
            let lw = r * 0.48

            // clockwise: true — angle 0=right, 90=bottom, 180=left, 270=top
            func arc(from: Double, to: Double, color: Color) {
                var p = Path()
                p.addArc(center: CGPoint(x: cx, y: cy),
                         radius: r - lw / 2,
                         startAngle: .degrees(from),
                         endAngle:   .degrees(to),
                         clockwise:  true)
                ctx.stroke(p, with: .color(color),
                           style: StrokeStyle(lineWidth: lw, lineCap: .butt))
            }

            // Arc segments (clockwise), gap from 315° → 45° (right side, where bar opens)
            arc(from:  45, to: 180, color: Color(hex: "4285F4")) // blue  — bottom half
            arc(from: 180, to: 235, color: Color(hex: "34A853")) // green — lower-left
            arc(from: 235, to: 260, color: Color(hex: "FBBC05")) // yellow— upper-left
            arc(from: 260, to: 315, color: Color(hex: "EA4335")) // red   — top

            // Horizontal crossbar (blue): center → right, at vertical midline
            var bar = Path()
            bar.move(to: CGPoint(x: cx + 1, y: cy))
            bar.addLine(to: CGPoint(x: sz.width - 0.5, y: cy))
            ctx.stroke(bar, with: .color(Color(hex: "4285F4")), lineWidth: lw * 0.88)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
        .frame(width: 600, height: 560)
}
