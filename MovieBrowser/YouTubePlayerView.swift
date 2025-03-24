import SwiftUI
import YouTubeiOSPlayerHelper

struct YouTubePlayerView: UIViewRepresentable {
    let videoID: String

    func makeUIView(context: Context) -> YTPlayerView {
        let playerView = YTPlayerView()
        playerView.delegate = context.coordinator
        playerView.load(withVideoId: videoID, playerVars: ["playsinline": 1])
        return playerView
    }

    func updateUIView(_ uiView: YTPlayerView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, YTPlayerViewDelegate {
        func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
            print("✅ YouTube Player is ready!")
            //playerView.playVideo() // ✅ Auto-Play
        }

        func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
            print("🎥 Player State Changed: \(state.rawValue)")
        }

        func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
            print("❌ YouTube Player Error: \(error.rawValue)")
        }
    }
}
