import SwiftUI
import Lottie

struct RobotAnimationView: View {
    var loopMode: LottieLoopMode = .loop

    var body: some View {
        _LottieNSView(loopMode: loopMode)
            .frame(width: 120, height: 120)
            .scaleEffect(0.15)
            .frame(width: 120, height: 120)
            .clipped()
    }
}

private struct _LottieNSView: NSViewRepresentable {
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
