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

            Color.black.opacity(0.35)
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

            Spacer().frame(height: MRSpacing.xs)

            RobotAnimationView()
                .offset(x: robotOffset)

            Spacer().frame(height: MRSpacing.lg)

            Text("Meeting Robot")
                .font(.mrHeading)
                .foregroundColor(.white)

            Spacer()

            bottomStack
        }
        .onAppear {
            withAnimation(.spring(response: 2.5, dampingFraction: 0.8).delay(0.5)) {
                robotOffset = 0
            }
        }
        .onReceive(Timer.publish(every: 10, on: .main, in: .common).autoconnect()) { _ in
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
        .frame(maxWidth: 220, maxHeight: 60)
        .animation(.spring(response: 0.38, dampingFraction: 0.62), value: messageIndex)
    }

    // MARK: - App name + sign-in buttons

    private var bottomStack: some View {
        VStack(spacing: MRSpacing.sm) {
            appleButton
            googleButton
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
                Text("G")
                    .font(.system(.body, design: .default).weight(.bold))
                    .foregroundColor(Color(hex: "4285F4"))
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
                .font(.mrBubble)
                .foregroundColor(Color(hex: "1C1C2E"))
                .multilineTextAlignment(.center)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: MRRadius.sm)
                        .fill(Color.white)
                )

            BubblePointer()
                .fill(Color.white)
                .frame(width: 8, height: 6)
                .offset(y: -0.5)
        }
        .shadow(color: .black.opacity(0.18), radius: 6, x: 0, y: 3)
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


#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
        .frame(width: 600, height: 560)
}
