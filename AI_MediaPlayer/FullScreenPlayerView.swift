
import SwiftUI
import AVKit

struct FullScreenPlayerView: View {
    @ObservedObject var playerManager: PlayerManager
    @Binding var isFullScreen: Bool

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let player = playerManager.getPlayer() {
                VideoPlayerView(player: player)
                    .ignoresSafeArea()
            }

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        isFullScreen = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
                PlayerControlsView(playerManager: playerManager, isFullScreen: $isFullScreen)
                    .padding(.bottom, 30)
            }
        }
    }
}
