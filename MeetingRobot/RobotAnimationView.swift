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
                    .blur(radius: 20)
                    .frame(width: 60, height: 60)
            }
            _LottieNSView(loopMode: loopMode)
                .frame(width: 346, height: 346)
                .scaleEffect(0.231)
                .frame(width: 80, height: 80)
        }
        .frame(width: 80, height: 80)
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
