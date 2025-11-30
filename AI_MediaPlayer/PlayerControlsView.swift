
import SwiftUI

struct PlayerControlsView: View {
    
    @ObservedObject var playerManager: PlayerManager
    @Binding var isFullScreen: Bool
    
    // This state tracks whether the user is currently dragging the slider.
    @State private var isSeeking: Bool = false
    // This state holds the slider's value. It's updated by the player's time,
    // but can also be directly manipulated by the user while seeking.
    @State private var sliderValue: Double = 0
    
    var body: some View {
        VStack(spacing: 10) {
            
            // MARK: - Progress Bar
            
            HStack {
                Text(formatTime(sliderValue))
                    .font(.caption)
                    .foregroundColor(.white)
                
                Slider(value: $sliderValue, in: 0...(playerManager.duration > 0 ? playerManager.duration : 1), onEditingChanged: { editing in
                    if editing {
                        // When the user starts dragging, just set the flag.
                        self.isSeeking = true
                    } else {
                        // When the user stops dragging, call seek. The seeking flag will be set
                        // to false only inside the completion handler of the seek method,
                        // ensuring the UI doesn't jump back to the old time before the seek is complete.
                        playerManager.seek(to: sliderValue) {
                            self.isSeeking = false
                        }
                    }
                })
                .accentColor(.white)
                
                Text(formatTime(playerManager.duration))
                    .font(.caption)
                    .foregroundColor(.white)
            }
            
            // MARK: - Control Buttons
            
            HStack(spacing: 40) {
                // 快退按钮
                Button(action: {
                    playerManager.skipBackward()
                }) {
                    Image(systemName: "gobackward.10")
                        .font(.title)
                        .foregroundColor(.white)
                }
                
                // 播放/暂停按钮
                Button(action: {
                    if playerManager.isPlaying {
                        playerManager.pause()
                    } else {
                        playerManager.play()
                    }
                }) {
                    Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
                
                // 快进按钮
                Button(action: {
                    playerManager.skipForward()
                }) {
                    Image(systemName: "goforward.10")
                        .font(.title)
                        .foregroundColor(.white)
                }
                
                Button(action: {
                    playerManager.cyclePlaybackRate()
                }) {
                    Text("\(String(format: "%.2fx", playerManager.playbackRate))")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Button(action: {
                    isFullScreen.toggle()
                }) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.6))
        .cornerRadius(10)
        .onAppear {
            // Set the initial slider value.
            sliderValue = playerManager.currentTime
        }
        .onChange(of: playerManager.currentTime) { 
            // If the user is not dragging the slider, update the slider's value
            // to match the player's current time.
            if !isSeeking {
                sliderValue = playerManager.currentTime
            }
        }
    }
    
    private func formatTime(_ time: Double) -> String {
        // Add a guard to prevent crashing on NaN or infinite values
        guard !time.isNaN && !time.isInfinite else {
            return "--:--"
        }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    // To make the preview work, we need a dummy PlayerManager.
    // This requires a valid URL to a media file.
    // For now, we can't preview this directly without a sample URL.
    // A placeholder view is used instead.
    
    struct PreviewWrapper: View {
        // Replace with a valid remote or local URL for a real preview
        private static var dummyURL = URL(string: "https://example.com/video.mp4")!
        @StateObject private var playerManager = PlayerManager(url: dummyURL)
        @State private var isFullScreen = false
        
        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()
                PlayerControlsView(playerManager: playerManager, isFullScreen: $isFullScreen)
            }
        }
    }
    
    return PreviewWrapper()
}
