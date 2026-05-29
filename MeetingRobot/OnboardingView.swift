import SwiftUI
import EventKit

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @State private var showConfirmation = false
    @State private var messageIndex = 0
    @State private var showBubble = false
    @State private var bubbleVisible: Bool = false
    @State private var robotOffset: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    private let messages = [
        "Hey! I'm better than your alarm clock 🤖",
        "I promise I won't judge your meeting count 👀",
        "Let's get those meetings sorted ⚡",
        "I've been waiting for you... 👁️",
        "Never miss a standup again 🙌",
        "Beep boop... loading your schedule 🔄",
        "I walk so your meetings don't sneak up on you 🚶",
        "Your calendar, but make it smart 🧠",
        "Zero late arrivals guaranteed 🎯",
    ]

    var body: some View {
        ZStack {
            FluidGradientBackground()
            Rectangle().fill(.ultraThinMaterial).ignoresSafeArea()
            Color.black.opacity(0.35).ignoresSafeArea()

            if showConfirmation {
                ConfirmationView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .transition(.opacity)
            } else {
                mainContent.transition(.opacity)
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .animation(.easeInOut(duration: 0.5), value: showConfirmation)
        .overlay(alignment: .topTrailing) { modeToggle }
    }

    private var modeToggle: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) { isDarkMode.toggle() }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 14, weight: .medium))
                    .opacity(isDarkMode ? 0.35 : 1.0)
                    .accessibilityHidden(true)
                Image(systemName: "moon.fill")
                    .font(.system(size: 14, weight: .medium))
                    .opacity(isDarkMode ? 1.0 : 0.35)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 14)
            .frame(height: 36)
            .background(isDarkMode ? Color(white: 0.15) : Color.white)
            .foregroundColor(isDarkMode ? .white : .black)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(isDarkMode ? 0 : 0.12), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isDarkMode ? "Switch to light mode" : "Switch to dark mode")
        .padding(.top, 16)
        .padding(.trailing, 20)
    }

    private var mainContent: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(isDarkMode ? Color(hex: "1A1A1E") : Color.white)
                .shadow(color: isDarkMode ? .clear : .black.opacity(0.10), radius: 20, x: 0, y: 8)
                .overlay {
                    if isDarkMode {
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    }
                }
                .accessibilityHidden(true)
            cardContent
        }
        .frame(width: 400)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var cardContent: some View {
        VStack(spacing: 0) {
            VStack(spacing: -15) {
                speechBubble.opacity(bubbleVisible ? 1 : 0).accessibilityHidden(true)
                RobotAnimationView().padding(.bottom, -20)
                    .accessibilityLabel("Meetbot robot animation")
                    .accessibilityAddTraits(.isImage)
            }

            Spacer().frame(height: 8)

            Text("Meetbot")
                .font(.mrHeading)
                .foregroundColor(isDarkMode ? .white : .primary)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 4)

            Text("Your meeting assistant")
                .font(.subheadline)
                .foregroundColor(isDarkMode ? Color.white.opacity(0.55) : .secondary)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 4)

            Text("So I know when your meetings are and can prep you in time.")
                .font(.caption)
                .foregroundColor(isDarkMode ? Color.white.opacity(0.40) : .gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 24)

            Spacer().frame(height: 32)

            appleButton

            Spacer().frame(height: 20)

            Button(action: {
                NSApplication.shared.keyWindow?.close()
            }) {
                Text("Not Interested")
                    .font(.caption)
                    .foregroundColor(isDarkMode ? Color.white.opacity(0.40) : .gray)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Not interested, close setup")
            .accessibilityHint("Closes this window. You can set up later from the menu bar.")
            .padding(.bottom, 4)
        }
        .padding(.horizontal, 28)
        .padding(.top, 28)
        .padding(.bottom, 28)
        .onAppear {
            robotOffset = 0
            if !reduceMotion {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    NotificationCenter.default.post(name: .init("PlayRobotWave"), object: nil)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                startMessageCycle()
            }
        }
    }

    private var speechBubble: some View {
        ZStack {
            ForEach(messages.indices, id: \.self) { i in
                if i == messageIndex {
                    SpeechBubbleView(text: messages[i])
                        .transition(reduceMotion ? .opacity : .scale(scale: 0.8).combined(with: .opacity))
                }
            }
        }
        .frame(maxWidth: 280, maxHeight: 60)
        .animation(.spring(response: 0.38, dampingFraction: 0.62), value: messageIndex)
    }

    private var appleButton: some View {
        Button(action: requestCalendarAccess) {
            HStack(spacing: MRSpacing.sm) {
                Image(systemName: "apple.logo")
                    .font(.system(size: 22, weight: .medium))
                    .accessibilityHidden(true)
                Text("Continue with Apple Calendar")
                    .font(.system(.body, design: .default).weight(.medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, MRSpacing.md)
            .background(isDarkMode ? Color(hex: "F0F0F5") : Color.black)
            .foregroundColor(isDarkMode ? Color(hex: "111111") : .white)
            .clipShape(Capsule())
        }
        .buttonStyle(ScalePressStyle())
        .accessibilityLabel("Continue with Apple Calendar")
        .accessibilityHint("Grants calendar access so Meetbot can remind you before meetings")
    }

    private func requestCalendarAccess() {
        Task {
            let store = EKEventStore()
            do {
                let granted = try await store.requestFullAccessToEvents()
                if granted {
                    UserDefaults.standard.set("apple", forKey: "calendarProvider")
                    withAnimation(.easeInOut(duration: 0.4)) { showConfirmation = true }
                }
            } catch { }
        }
    }

    private func startMessageCycle() {
        func showNext() {
            withAnimation(.easeInOut(duration: 0.4)) { bubbleVisible = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                withAnimation(.easeInOut(duration: 0.4)) { bubbleVisible = false }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    messageIndex = (messageIndex + 1) % messages.count
                    showNext()
                }
            }
        }
        showNext()
    }
}

private struct SpeechBubbleView: View {
    let text: String
    var body: some View {
        VStack(spacing: 0) {
            Text(text)
                .font(.mrBubble)
                .foregroundColor(Color(hex: "1C1C2E"))
                .multilineTextAlignment(.center)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: MRRadius.sm).fill(Color.white))
            BubblePointer().fill(Color.white).frame(width: 8, height: 6).offset(y: -0.5)
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
        .frame(width: 600, height: 700)
}
