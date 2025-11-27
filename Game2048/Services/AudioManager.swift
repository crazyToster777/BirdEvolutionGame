import Foundation
import AVFoundation

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    private var backgroundMusicPlayer: AVAudioPlayer?
    @Published var isMusicPlaying: Bool = false
    
    private init() {
        configureAudioSession()
        setupBackgroundMusic()
    }
    
    private func configureAudioSession() {
        do {
            // Use .ambient category to respect silent mode
            // Music will automatically stop when silent switch is on
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
    
    private func setupBackgroundMusic() {
        guard let url = Bundle.main.url(forResource: "background_music", withExtension: "mp3") else {
            print("Background music file not found")
            return
        }
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1 // Infinite loop
            backgroundMusicPlayer?.volume = 0.3 // 30% volume
            backgroundMusicPlayer?.prepareToPlay()
        } catch {
            print("Error loading background music: \(error.localizedDescription)")
        }
    }
    
    func playBackgroundMusic() {
        backgroundMusicPlayer?.play()
        isMusicPlaying = true
    }
    
    func pauseBackgroundMusic() {
        backgroundMusicPlayer?.pause()
        isMusicPlaying = false
    }
    
    func toggleBackgroundMusic() {
        if isMusicPlaying {
            pauseBackgroundMusic()
        } else {
            playBackgroundMusic()
        }
    }
    
    func setVolume(_ volume: Float) {
        backgroundMusicPlayer?.volume = min(max(volume, 0.0), 1.0)
    }
}
