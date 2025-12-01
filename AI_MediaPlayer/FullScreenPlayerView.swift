
import SwiftUI
import AVKit

struct FullScreenPlayerView: View {
    @ObservedObject var playerManager: PlayerManager
    @Binding var isFullScreen: Bool
    
    // Gesture states
    @State private var showGestureOverlay = false
    @State private var gestureType: GestureType = .volume
    @State private var gestureValue: Double = 0.0
    @State private var dragStartLocation: CGPoint = .zero
    @State private var dragStartValue: Double = 0.0
    @State private var isDragging = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()

                if let player = playerManager.getPlayer() {
                    VideoPlayerView(player: player)
                        .ignoresSafeArea()
                }
                
                // Gesture overlay
                if showGestureOverlay {
                    GestureOverlayView(gestureType: gestureType, value: gestureValue)
                        .transition(.opacity)
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
            .gesture(
                // Double tap gesture
                TapGesture(count: 2)
                    .onEnded { _ in
                        if playerManager.isPlaying {
                            playerManager.pause()
                        } else {
                            playerManager.play()
                        }
                    }
            )
            .simultaneousGesture(
                // Drag gesture for volume/brightness/progress
                DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        handleDragGesture(value: value, in: geometry)
                    }
                    .onEnded { _ in
                        endDragGesture()
                    }
            )
        }
    }
    
    // MARK: - Gesture Handlers
    
    private func handleDragGesture(value: DragGesture.Value, in geometry: GeometryProxy) {
        if !isDragging {
            // First drag event - determine gesture type
            isDragging = true
            dragStartLocation = value.startLocation
            
            let horizontalDistance = abs(value.translation.width)
            let verticalDistance = abs(value.translation.height)
            
            if horizontalDistance > verticalDistance {
                // Horizontal drag - progress control
                gestureType = .progress(currentTime: playerManager.currentTime, totalTime: playerManager.duration)
                dragStartValue = playerManager.currentTime
            } else {
                // Vertical drag - volume or brightness
                let screenWidth = geometry.size.width
                if dragStartLocation.x > screenWidth / 2 {
                    // Right side - volume
                    gestureType = .volume
                    dragStartValue = Double(playerManager.volume)
                } else {
                    // Left side - brightness
                    gestureType = .brightness
                    dragStartValue = Double(playerManager.brightness)
                }
            }
            
            showGestureOverlay = true
        }
        
        // Update gesture value
        switch gestureType {
        case .volume:
            let delta = -value.translation.height / 300.0 // Negative because drag down should decrease
            let newVolume = max(0.0, min(1.0, dragStartValue + delta))
            playerManager.volume = Float(newVolume)
            gestureValue = newVolume
            
        case .brightness:
            let delta = -value.translation.height / 300.0
            let newBrightness = max(0.0, min(1.0, dragStartValue + delta))
            playerManager.brightness = CGFloat(newBrightness)
            gestureValue = newBrightness
            
        case .progress:
            let delta = value.translation.width / geometry.size.width * playerManager.duration
            let newTime = max(0.0, min(playerManager.duration, dragStartValue + delta))
            gestureValue = playerManager.duration > 0 ? newTime / playerManager.duration : 0
            gestureType = .progress(currentTime: newTime, totalTime: playerManager.duration)
        }
    }
    
    private func endDragGesture() {
        isDragging = false
        
        // Apply progress change if needed
        if case .progress(let currentTime, _) = gestureType {
            playerManager.seek(to: currentTime)
        }
        
        // Hide overlay after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                showGestureOverlay = false
            }
        }
    }
}

