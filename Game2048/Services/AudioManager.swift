import Foundation
import AVFoundation
import AudioToolbox

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    private var backgroundMusicPlayer: AVAudioPlayer?
    @Published var isSoundEnabled: Bool = true
    private var hasStartedPlaying: Bool = false
    
    private init() {
        configureAudioSession()
        setupBackgroundMusic()
    }
    
    private func configureAudioSession() {
        do {
            // Use .ambient with .mixWithOthers to allow sound effects and music to play together
            // Music will automatically stop when silent switch is on
            try AVAudioSession.sharedInstance().setCategory(
                .ambient,
                mode: .default,
                options: [.mixWithOthers]
            )
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
        guard isSoundEnabled else { return }
        
        if !hasStartedPlaying {
            hasStartedPlaying = true
        }
        
        backgroundMusicPlayer?.play()
    }
    
    func pauseBackgroundMusic() {
        backgroundMusicPlayer?.pause()
    }
    
    func toggleSound() {
        isSoundEnabled.toggle()
        
        if isSoundEnabled {
            // Resume music if it was playing before
            if hasStartedPlaying {
                playBackgroundMusic()
            }
        } else {
            // Pause music when sound is disabled
            pauseBackgroundMusic()
        }
    }
    
    func playSwipeSound() {
        guard isSoundEnabled else { return }
        
        // Pick a random swipe sound
        if let chosen = GameConstants.swipeSounds.randomElement(),
           let soundURL = Bundle.main.url(forResource: chosen, withExtension: GameConstants.audioExtension) {
            
            var soundID: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &soundID)
            AudioServicesPlaySystemSound(soundID)
        }
    }
    
    func setVolume(_ volume: Float) {
        backgroundMusicPlayer?.volume = min(max(volume, 0.0), 1.0)
    }
}

