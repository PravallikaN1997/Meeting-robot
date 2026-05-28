import SwiftUI
import Lottie

struct OverlayView: View {
    let meeting: Meeting
    let onDismiss: () -> Void
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @State private var robotOffset: CGFloat = 60

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            // Robot
            ZStack(alignment: .top) {
                // Speech bubble above robot
                VStack(spacing: 0) {
                    speechBubble
                    Spacer().frame(height: 4)
                }
                .offset(y: -70)

                // Robot animation
                OverlayRobotView()
                    .frame(width: 70, height: 70)
                    .offset(y: robotOffset)
            }
            .frame(width: 80, height: 140)
            .onAppear {
                withAnimation(.spring(
                    response: 0.6,
                    dampingFraction: 0.7
                )) {
                    robotOffset = 0
                }
            }

            // Info card
            VStack(alignment: .leading, spacing: 6) {
                Text("Starting soon")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.orange)
                    .textCase(.uppercase)

                Text(meeting.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(
                        isDarkMode ? .white : Color(hex: "1C1C2E")
                    )
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                    Text(meeting.countdownLabel)
                        .font(.system(size: 11))
                    if let loc = meeting.location, !loc.isEmpty {
                        Text("·")
                        Text(loc)
                            .font(.system(size: 11))
                            .lineLimit(1)
                    }
                }
                .foregroundColor(.secondary)

                Button(action: onDismiss) {
                    Text("Dismiss")
                        .font(.system(size: 11, weight: .medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.secondary.opacity(0.15))
                        )
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.leading, 8)
            .padding(.bottom, 12)
        }
        .padding(.horizontal, 12)
        .padding(.top, 70)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isDarkMode ?
                      Color(hex: "1A1A1E") : Color.white)
                .shadow(
                    color: .black.opacity(0.18),
                    radius: 12,
                    y: 4
                )
        )
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    private var speechBubble: some View {
        VStack(spacing: 0) {
            Text("You have a meeting \(meeting.countdownLabel)!")
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "1C1C2E"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .shadow(
                            color: .black.opacity(0.1),
                            radius: 4
                        )
                )
            // Bubble pointer
            Triangle()
                .fill(Color.white)
                .frame(width: 8, height: 5)
                .offset(y: -0.5)
        }
    }
}

// MARK: - Triangle shape

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        path.closeSubpath()
        return path
    }
}

// MARK: - Overlay Robot (smaller version)

private struct OverlayRobotView: View {
    var body: some View {
        _OverlayLottieView()
            .frame(width: 346, height: 346)
            .scaleEffect(0.202)
            .frame(width: 70, height: 70)
            .clipped()
    }
}

private struct _OverlayLottieView: NSViewRepresentable {
    func makeNSView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: "robot")
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        view.animationSpeed = 1.0
        view.play()
        return view
    }
    func updateNSView(_ nsView: LottieAnimationView,
                      context: Context) {}
}
