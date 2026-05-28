import SwiftUI
import Lottie

struct ConfirmationView: View {
    @Binding var hasCompletedOnboarding: Bool
    @AppStorage("isDarkMode") var isDarkMode: Bool = false

    var body: some View {
        ZStack {
            // Same background as onboarding
            LoopingVideoView(videoName: "robot-bg", videoExtension: "mp4")
                .ignoresSafeArea()

            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            Color.black.opacity(0.35)
                .ignoresSafeArea()

            // Card
            VStack(spacing: 0) {
                Spacer().frame(height: 32)

                // Celebration Lottie
                CelebrationView()
                    .frame(width: 160, height: 200)

                Spacer().frame(height: 8)

                // Title
                HStack(spacing: 6) {
                    Text("⭐")
                        .font(.system(size: 22))
                    Text("You're all set!")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(isDarkMode ? .white : .primary)
                }

                Spacer().frame(height: 8)

                // Subtitle
                Text("I'll remind you before every meeting.")
                    .font(.system(size: 14))
                    .foregroundColor(isDarkMode ?
                        Color.white.opacity(0.55) : .secondary)
                    .multilineTextAlignment(.center)

                Spacer().frame(height: 32)

                // Get Started button
                Button(action: {
                    UserDefaults.standard.set(true,
                        forKey: "hasCompletedOnboarding")
                    withAnimation(.easeInOut(duration: 0.4)) {
                        hasCompletedOnboarding = true
                    }
                }) {
                    Text("Get Started")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            isDarkMode ?
                            Color(hex: "F0F0F5") : Color.black
                        )
                        .foregroundColor(
                            isDarkMode ? Color(hex: "111111") : .white
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(ScalePressStyle())
                .padding(.horizontal, 28)

                Spacer().frame(height: 28)
            }
            .frame(width: 400)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(isDarkMode ?
                          Color(hex: "1A1A1E") : Color.white)
                    .shadow(color: .black.opacity(0.12),
                            radius: 20, y: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        isDarkMode ?
                        Color.white.opacity(0.06) : Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

// MARK: - Celebration Lottie

private struct CelebrationView: View {
    var body: some View {
        _CelebrationNSView()
            .frame(width: 160, height: 200)
    }
}

private struct _CelebrationNSView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let allFiles = Bundle.main.paths(forResourcesOfType: "json",
                                          inDirectory: nil)
        print("All JSON files in bundle: \(allFiles)")
        let container = NSView()
        container.wantsLayer = true

        guard let url = Bundle.main.url(
            forResource: "celebrate",
            withExtension: "json"
        ) else {
            print("❌ celebrate.json not found in bundle")
            return container
        }

        print("✅ celebrate.json found at: \(url)")

        let animation = LottieAnimation.filepath(url.path)
        let lottieView = LottieAnimationView(
            animation: animation
        )
        lottieView.contentMode = .scaleAspectFit
        lottieView.loopMode = .loop
        lottieView.animationSpeed = 1.0
        lottieView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(lottieView)

        NSLayoutConstraint.activate([
            lottieView.leadingAnchor.constraint(
                equalTo: container.leadingAnchor),
            lottieView.trailingAnchor.constraint(
                equalTo: container.trailingAnchor),
            lottieView.topAnchor.constraint(
                equalTo: container.topAnchor),
            lottieView.bottomAnchor.constraint(
                equalTo: container.bottomAnchor)
        ])

        lottieView.play()
        return container
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

// ScalePressStyle is private in OnboardingView.swift (file-scoped),
// so this is a separate declaration — no duplicate at module level.
private struct ScalePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    ConfirmationView(hasCompletedOnboarding: .constant(false))
        .frame(width: 600, height: 540)
}
