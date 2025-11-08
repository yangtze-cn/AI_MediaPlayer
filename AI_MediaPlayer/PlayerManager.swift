
import Foundation
import AVFoundation
import Combine

class PlayerManager: ObservableObject {
    
    private var player: AVPlayer?
    
    // MARK: - Published Properties
    
    @Published var isPlaying: Bool = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    
    private var timeObserverToken: Any?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(url: URL) {
        setupPlayer(with: url)
    }
    
    deinit {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }
    
    // MARK: - Public Methods
    
    func play() {
        player?.play()
        isPlaying = true
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func seek(to time: Double, completion: (() -> Void)? = nil) {
        let targetTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] finished in
            // When the seek operation is finished, call the completion handler on the main thread.
            if finished {
                DispatchQueue.main.async {
                    completion?()
                }
            }
        }
    }
    
    // MARK: - Private Setup
    
    private func setupPlayer(with url: URL) {
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: playerItem)
        
        addObservers()
    }
    
    private func addObservers() {
        // Observe player's time
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
        }
        
        // Observe player item duration
        player?.currentItem?.publisher(for: \.duration)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newDuration in
                self?.duration = newDuration.seconds
            }
            .store(in: &cancellables)
            
        // Observe play/pause status
        player?.publisher(for: \.rate)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rate in
                self?.isPlaying = rate > 0
            }
            .store(in: &cancellables)
    }
    
    // This will be used later for the VideoPlayer view
    func getPlayer() -> AVPlayer? {
        return player
    }
}
