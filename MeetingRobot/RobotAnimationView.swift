import SwiftUI
import Lottie

struct RobotAnimationView: NSViewRepresentable {
    var loopMode: LottieLoopMode = .loop

    func makeNSView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: "robot")
        view.contentMode = .scaleAspectFit
        view.loopMode = loopMode
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
