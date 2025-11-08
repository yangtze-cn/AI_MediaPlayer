
import SwiftUI

struct PlaylistView: View {
    // Sample playlist data
    let playlistItems: [PlaylistItem] = [
        PlaylistItem(title: "Big Buck Bunny", description: "A classic open-source animation.", videoUrl: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!),
        PlaylistItem(title: "Elephants Dream", description: "Another great open-source movie.", videoUrl: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!),
        PlaylistItem(title: "Sintel", description: "A fantasy adventure from the Blender Foundation.", videoUrl: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4")!),
        PlaylistItem(title: "Tears of Steel", description: "A sci-fi short film.", videoUrl: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4")!)
    ]

    var body: some View {
        NavigationView {
            List(playlistItems) { item in
                NavigationLink(destination: PlayerView(playlistItem: item)) {
                    VStack(alignment: .leading) {
                        Text(item.title)
                            .font(.headline)
                        Text(item.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Playlist")
        }
    }
}

struct PlayerView: View {
    let playlistItem: PlaylistItem
    @StateObject private var playerManager: PlayerManager
    @State private var isFullScreen = false

    init(playlistItem: PlaylistItem) {
        self.playlistItem = playlistItem
        _playerManager = StateObject(wrappedValue: PlayerManager(url: playlistItem.videoUrl))
    }

    var body: some View {
        ZStack {
            if let player = playerManager.getPlayer() {
                VideoPlayerView(player: player)
                    .ignoresSafeArea()
            } else {
                Color.black
                    .ignoresSafeArea()
                Text("Player Error")
                    .foregroundColor(.white)
            }
            
            VStack {
                Spacer()
                PlayerControlsView(playerManager: playerManager, isFullScreen: $isFullScreen)
                    .padding(.bottom, 30)
            }
        }
        .onAppear {
            playerManager.play()
        }
        .onDisappear {
            playerManager.pause()
        }
        .fullScreenCover(isPresented: $isFullScreen) {
            FullScreenPlayerView(playerManager: playerManager, isFullScreen: $isFullScreen)
        }
        .navigationTitle(playlistItem.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    PlaylistView()
}
