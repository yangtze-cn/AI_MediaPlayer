
import SwiftUI
import SwiftData

struct PlaylistView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PlaylistItem.title) private var playlistItems: [PlaylistItem]

    var body: some View {
        NavigationView {
            List(playlistItems) { item in
                if let videoUrl = item.videoUrl {
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
            }
            .navigationTitle("Playlist")
            .onAppear {
                initializeDefaultPlaylistIfNeeded()
            }
        }
    }
    
    // MARK: - Default Data Initialization
    
    private func initializeDefaultPlaylistIfNeeded() {
        guard playlistItems.isEmpty else { return }
        
        // Add default videos on first launch
        let defaultVideos = [
            (title: "Big Buck Bunny", 
             description: "A classic open-source animation.", 
             url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"),
            (title: "Elephants Dream", 
             description: "Another great open-source movie.", 
             url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"),
            (title: "Sintel", 
             description: "A fantasy adventure from the Blender Foundation.", 
             url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4"),
            (title: "Tears of Steel", 
             description: "A sci-fi short film.", 
             url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4")
        ]
        
        for video in defaultVideos {
            if let url = URL(string: video.url) {
                let item = PlaylistItem(title: video.title, description: video.description, videoUrl: url)
                modelContext.insert(item)
            }
        }
        
        try? modelContext.save()
    }
}

struct PlayerView: View {
    let playlistItem: PlaylistItem
    @StateObject private var playerManager: PlayerManager
    @State private var isFullScreen = false
    
    // Control visibility
    @State private var showControls = true
    @State private var hideControlsTask: Task<Void, Never>?
    
    // Gesture states
    @State private var showGestureOverlay = false
    @State private var gestureType: GestureType = .volume
    @State private var gestureValue: Double = 0.0
    @State private var dragStartLocation: CGPoint = .zero
    @State private var dragStartValue: Double = 0.0
    @State private var isDragging = false

    init(playlistItem: PlaylistItem) {
        self.playlistItem = playlistItem
        // Safely unwrap videoUrl, use a default URL if nil
        let url = playlistItem.videoUrl ?? URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
        _playerManager = StateObject(wrappedValue: PlayerManager(url: url))
    }

    var body: some View {
        GeometryReader { geometry in
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
                
                // Gesture overlay
                if showGestureOverlay {
                    GestureOverlayView(gestureType: gestureType, value: gestureValue)
                        .transition(.opacity)
                }
                
                // Controls
                if showControls {
                    VStack {
                        Spacer()
                        PlayerControlsView(playerManager: playerManager, isFullScreen: $isFullScreen)
                            .padding(.bottom, 30)
                    }
                    .transition(.opacity)
                }
            }
            .gesture(
                // Single tap to toggle controls
                TapGesture(count: 1)
                    .onEnded { _ in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showControls.toggle()
                        }
                        if showControls {
                            resetHideControlsTimer()
                        }
                    }
            )
            .gesture(
                // Double tap gesture
                TapGesture(count: 2)
                    .onEnded { _ in
                        if playerManager.isPlaying {
                            playerManager.pause()
                        } else {
                            playerManager.play()
                        }
                        resetHideControlsTimer()
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
                        resetHideControlsTimer()
                    }
            )
        }
        .onAppear {
            playerManager.play()
            resetHideControlsTimer()
        }
        .onDisappear {
            playerManager.pause()
            hideControlsTask?.cancel()
        }
        .fullScreenCover(isPresented: $isFullScreen) {
            FullScreenPlayerView(playerManager: playerManager, isFullScreen: $isFullScreen)
        }
        .navigationTitle(playlistItem.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Control Visibility
    
    private func resetHideControlsTimer() {
        // Cancel existing task
        hideControlsTask?.cancel()
        
        // Show controls
        withAnimation(.easeInOut(duration: 0.2)) {
            showControls = true
        }
        
        // Start new timer
        hideControlsTask = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            if !Task.isCancelled {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showControls = false
                }
            }
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

#Preview {
    PlaylistView()
}
