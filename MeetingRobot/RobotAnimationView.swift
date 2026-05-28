import SwiftUI
import Lottie

struct RobotAnimationView: View {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    var loopMode: LottieLoopMode = .loop

    var body: some View {
        ZStack {
            if isDarkMode {
                Circle()
                    .fill(Color.blue.opacity(0.30))
                    .blur(radius: 28)
                    .frame(width: 80, height: 80)
            }
            _LottieNSView(loopMode: loopMode)
                .frame(width: 346, height: 346)
                .scaleEffect(0.347)
                .frame(width: 120, height: 120)
                .clipped()
        }
        .frame(width: 120, height: 120)
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
