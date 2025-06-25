import AVFoundation
import MediaPlayer

class AudioPlayer: ObservableObject {
    static let shared = AudioPlayer()
    
    private var player: AVPlayer?
    private var timeObserver: Any?
    
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var currentTrack: Track?
    
    private init() {
        setupRemoteTransportControls()
        setupAudioSession()
    }
    
    // MARK: - Setup
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: []
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Play Command
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.play()
            return .success
        }
        
        // Pause Command
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
        
        // Skip Forward Command
        commandCenter.skipForwardCommand.addTarget { [weak self] _ in
            self?.seek(by: 15)
            return .success
        }
        
        // Skip Backward Command
        commandCenter.skipBackwardCommand.addTarget { [weak self] _ in
            self?.seek(by: -15)
            return .success
        }
    }
    
    // MARK: - Playback Control
    
    func play(track: Track? = nil) {
        if let track = track {
            // New track to play
            guard let streamUrl = track.streamUrl else { return }
            
            // Create new player
            player = AVPlayer(url: streamUrl)
            currentTrack = track
            
            // Update Now Playing info
            updateNowPlayingInfo()
            
            // Add time observer
            addPeriodicTimeObserver()
        }
        
        player?.play()
        isPlaying = true
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func stop() {
        player?.pause()
        player = nil
        isPlaying = false
        currentTime = 0
        duration = 0
        currentTrack = nil
        
        // Remove time observer
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }
    
    func seek(to time: Double) {
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 1000))
        currentTime = time
        updateNowPlayingInfo()
    }
    
    func seek(by offset: Double) {
        guard let currentItem = player?.currentItem else { return }
        let targetTime = CMTimeGetSeconds(currentItem.currentTime()) + offset
        seek(to: targetTime)
    }
    
    // MARK: - Time Observation
    
    private func addPeriodicTimeObserver() {
        // Remove existing observer
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        
        // Add new observer
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            
            self.currentTime = CMTimeGetSeconds(time)
            
            if let duration = self.player?.currentItem?.duration {
                self.duration = CMTimeGetSeconds(duration)
            }
            
            self.updateNowPlayingInfo()
        }
    }
    
    // MARK: - Now Playing Info
    
    private func updateNowPlayingInfo() {
        guard let track = currentTrack else { return }
        
        var nowPlayingInfo = [String: Any]()
        
        // Title
        nowPlayingInfo[MPMediaItemPropertyTitle] = track.title
        
        // Artist
        nowPlayingInfo[MPMediaItemPropertyArtist] = track.user.username
        
        // Duration
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        
        // Current time
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        
        // Playback rate
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        
        // Artwork
        if let artworkUrl = track.artworkUrl {
            // Load artwork asynchronously
            URLSession.shared.dataTask(with: artworkUrl) { data, _, _ in
                if let data = data, let image = NSImage(data: data) {
                    let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                    nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                }
            }.resume()
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}

// MARK: - Error Handling
extension AudioPlayer {
    enum PlaybackError: Error {
        case invalidURL
        case playbackFailed
    }
}
