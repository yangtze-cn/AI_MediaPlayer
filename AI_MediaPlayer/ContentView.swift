//
//  ContentView.swift
//  MediaPlayer
//
//  Created by yangtze on 2025/6/26.
//

import SwiftUI
import AVKit

struct ContentView: View {
    
    // We use @StateObject to create and manage the PlayerManager instance.
    // The view will now react to any changes published by the PlayerManager.
    //
    // IMPORTANT:
    // Replace this URL with a real video/audio URL to test.
    // This example uses an Apple HLS stream for demonstration.
    private static let mediaURL = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8")!
    
    @StateObject private var playerManager = PlayerManager(url: mediaURL)
    @State private var isFullScreen = false
    
    var body: some View {
        ZStack {
            // The VideoPlayer view from AVKit handles the video rendering.
            // We pass it the AVPlayer instance from our PlayerManager.
            if let player = playerManager.getPlayer() {
                VideoPlayerView(player: player)
                    .ignoresSafeArea()
            } else {
                // Fallback view if the player fails to initialize
                Color.black
                    .ignoresSafeArea()
                Text("Player Error")
                    .foregroundColor(.white)
            }
            
            // We overlay our custom controls on top of the video.
            VStack {
                Spacer()
                PlayerControlsView(playerManager: playerManager, isFullScreen: $isFullScreen)
                    .padding(.bottom, 30) // Add some padding from the bottom edge
            }
        }
        .onAppear {
            // When the view appears, we can optionally start playback automatically.
            // For now, we'll let the user press play.
        }
        .onDisappear {
            // When the view disappears, pause the player to save resources.
            playerManager.pause()
        }
        .fullScreenCover(isPresented: $isFullScreen) {
            FullScreenPlayerView(playerManager: playerManager, isFullScreen: $isFullScreen)
        }
    }
}

#Preview {
    ContentView()
}
