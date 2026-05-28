import SwiftUI
import Lottie

struct RobotAnimationView: View {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    var loopMode: LottieLoopMode = .loop

    var body: some View {
        ZStack {
            // Blue glow in dark mode only
            if isDarkMode {
                Circle()
                    .fill(Color.blue.opacity(0.30))
                    .blur(radius: 20)
                    .frame(width: 60, height: 60)
            }
            _LottieNSView(loopMode: loopMode)
                .frame(width: 80, height: 80)
        }
        .frame(width: 80, height: 80)
    }
}

private struct _LottieNSView: NSViewRepresentable {
    var loopMode: LottieLoopMode = .loop

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeNSView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: "robot")
        view.contentMode = .scaleAspectFit
        view.loopMode = loopMode
        view.play()
        context.coordinator.observe(animationView: view)
        return view
    }

    func updateNSView(_ nsView: LottieAnimationView, context: Context) {
        nsView.loopMode = loopMode
        if !nsView.isAnimationPlaying {
            nsView.play()
        }
    }

    // MARK: - Coordinator

    final class Coordinator {
        private var observer: NSObjectProtocol?
        private weak var animationView: LottieAnimationView?

        func observe(animationView: LottieAnimationView) {
            self.animationView = animationView
            observer = NotificationCenter.default.addObserver(
                forName: .init("PlayRobotWave"),
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let view = self?.animationView else { return }
                view.loopMode = .playOnce
                view.play { _ in
                    view.loopMode = .loop
                    view.play()
                }
            }
        }

        deinit {
            if let observer {
                NotificationCenter.default.removeObserver(observer)
            }
        }
    }
}
