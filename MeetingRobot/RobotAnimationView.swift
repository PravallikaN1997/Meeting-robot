import SwiftUI
import Lottie

struct RobotAnimationView: View {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    var loopMode: LottieLoopMode = .loop

    var body: some View {
        ZStack {
            if isDarkMode {
                ZStack {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.2, blue: 0.6).opacity(0.25))
                        .blur(radius: 30)
                        .frame(width: 110, height: 110)
                    Circle()
                        .fill(Color(red: 1.0, green: 0.3, blue: 0.7).opacity(0.15))
                        .blur(radius: 12)
                        .frame(width: 70, height: 70)
                    Circle()
                        .fill(Color.white.opacity(0.6))
                        .blur(radius: 2)
                        .frame(width: 4, height: 4)
                        .offset(x: -35, y: -30)
                    Circle()
                        .fill(Color.white.opacity(0.5))
                        .blur(radius: 2)
                        .frame(width: 3, height: 3)
                        .offset(x: 38, y: -25)
                    Circle()
                        .fill(Color.white.opacity(0.4))
                        .blur(radius: 1.5)
                        .frame(width: 3, height: 3)
                        .offset(x: -30, y: 32)
                    Circle()
                        .fill(Color.white.opacity(0.5))
                        .blur(radius: 2)
                        .frame(width: 4, height: 4)
                        .offset(x: 32, y: 28)
                }
            }
            _LottieNSView(loopMode: loopMode)
                .frame(width: 346, height: 346)
                .scaleEffect(0.405)
                .frame(width: 140, height: 140)
                .clipped()
        }
        .frame(width: 140, height: 140)
    }
}

private struct _LottieNSView: NSViewRepresentable {
    var loopMode: LottieLoopMode = .loop

    func makeNSView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: "robot")
        view.contentMode = .scaleAspectFit
        view.loopMode = loopMode
        view.animationSpeed = 1.0
        view.play()
        return view
    }

    func updateNSView(_ nsView: LottieAnimationView, context: Context) {
        nsView.loopMode = loopMode
        if !nsView.isAnimationPlaying {
            nsView.play()
        }
    }
}
