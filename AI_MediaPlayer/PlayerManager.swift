
import Foundation
import AVFoundation
import Combine
import UIKit

class PlayerManager: ObservableObject {
    
    private var player: AVPlayer?
    
    // MARK: - Published Properties
    
    @Published var isPlaying: Bool = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var playbackRate: Float = 1.0
    @Published var volume: Float = 1.0
    
    @Published var isMuted: Bool = false
    @Published var brightness: CGFloat = UIScreen.main.brightness
    
    let availableRates: [Float] = [0.75, 1.0, 1.25, 1.5, 1.75, 2.0]
    
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
        player?.rate = playbackRate
    }
    
    func pause() {
        player?.pause()
    }
    
    func seek(to time: Double, completion: (() -> Void)? = nil) {
        // Optimistically update the current time to update the UI immediately
        self.currentTime = time
        
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
    
    func cyclePlaybackRate() {
        guard let currentIndex = availableRates.firstIndex(of: playbackRate) else {
            playbackRate = 1.0
            return
        }
        let nextIndex = (currentIndex + 1) % availableRates.count
        playbackRate = availableRates[nextIndex]
    }
    
    func skipForward(by seconds: Double = 10) {
        let newTime = min(currentTime + seconds, duration)
        seek(to: newTime)
    }
    
    func skipBackward(by seconds: Double = 10) {
        let newTime = max(currentTime - seconds, 0)
        seek(to: newTime)
    }
    
    func toggleMute() {
        isMuted.toggle()
    }
    
    // MARK: - Private Setup
    
    private func setupPlayer(with url: URL) {
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: playerItem)
        self.player?.volume = volume
        self.player?.isMuted = isMuted
        
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
            
        // Observe playbackRate changes
        $playbackRate
            .sink { [weak self] rate in
                if self?.player?.rate != 0 {
                    self?.player?.rate = rate
                }
            }
            .store(in: &cancellables)
            
        // Observe volume changes
        $volume
            .sink { [weak self] volume in
                self?.player?.volume = volume
            }
            .store(in: &cancellables)
            
        // Observe mute changes
        $isMuted
            .sink { [weak self] isMuted in
                self?.player?.isMuted = isMuted
            }
            .store(in: &cancellables)
            
        // Observe brightness changes
        $brightness
            .sink { brightness in
                UIScreen.main.brightness = brightness
            }
            .store(in: &cancellables)
    }
    
    // This will be used later for the VideoPlayer view
    func getPlayer() -> AVPlayer? {
        return player
    }
}
