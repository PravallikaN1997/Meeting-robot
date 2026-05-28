import SwiftUI
import AVKit

struct FluidGradientBackground: View {
    var body: some View {
        LoopingVideoView(videoName: "robot-bg", videoExtension: "mp4")
            .ignoresSafeArea()
    }
}

struct LoopingVideoView: NSViewRepresentable {
    let videoName: String
    let videoExtension: String

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true

        guard let url = Bundle.main.url(
            forResource: videoName,
            withExtension: videoExtension
        ) else { return view }

        let playerItem = AVPlayerItem(url: url)
        let player = AVQueuePlayer(playerItem: playerItem)
        let looper = AVPlayerLooper(player: player, templateItem: playerItem)

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = view.bounds
        playerLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        view.layer?.addSublayer(playerLayer)

        // Store looper to prevent deallocation
        objc_setAssociatedObject(view, "looper", looper, .OBJC_ASSOCIATION_RETAIN)

        player.play()
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
