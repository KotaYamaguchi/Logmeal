import SwiftUI
import AVFoundation

class SoundManager {
    static let shared = SoundManager()

    private var player: AVAudioPlayer?

    func playSound(named soundName: String) {
        if let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
            } catch {
                print("Error: Could not play sound \(soundName)")
            }
        } else {
            print("Error: Sound file \(soundName) not found")
        }
    }
}
