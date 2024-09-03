import SwiftUI
import AVFoundation

class SoundManager: ObservableObject {
    static let shared = SoundManager()

    private var player: AVAudioPlayer?
    @Published var soundVolume: Float = 1.0

    private init() {}

    func playSound(named soundName: String) {
        if let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.volume = soundVolume
                player?.play()
            } catch {
                print("Error: Could not play sound \(soundName)")
            }
        } else {
            print("Error: Sound file \(soundName) not found")
        }
    }

    func setSoundVolume(_ volume: Float) {
        if soundVolume != volume {  // 音量が変わらない場合には処理を行わない
            soundVolume = volume
            player?.volume = soundVolume
        }
    }
}

class BGMManager: ObservableObject {
    static let shared = BGMManager()

    @Published private var player: AVAudioPlayer?
    @Published private var bgmPlayer: AVAudioPlayer?
    var bgmVolume: Float = 0.5

    private init() {
        prepareBGM(named: "bgm_home")
    }

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

    func prepareBGM(named bgmName: String) {
        if let url = Bundle.main.url(forResource: bgmName, withExtension: "mp3") {
            do {
                bgmPlayer = try AVAudioPlayer(contentsOf: url)
                bgmPlayer?.numberOfLoops = -1
                bgmPlayer?.volume = bgmVolume
                bgmPlayer?.prepareToPlay()
            } catch {
                print("Error: Could not prepare BGM \(bgmName)")
            }
        } else {
            print("Error: BGM file \(bgmName) not found")
        }
    }

    func playBGM() {
        bgmPlayer?.play()
    }

    func stopBGM() {
        bgmPlayer?.stop()
    }

    func pauseBGM() {
        bgmPlayer?.pause()
    }

    func restartBGM() {
        bgmPlayer?.currentTime = 0
        bgmPlayer?.play()
    }

    func setBGMVolume(_ volume: Float) {
        if bgmVolume != volume {  // 音量が変わらない場合には処理を行わない
            bgmVolume = volume
            bgmPlayer?.volume = bgmVolume

            if bgmVolume == 0 {
                stopBGM()
            } else if bgmVolume > 0 && !(bgmPlayer?.isPlaying ?? false) {
                playBGM()
            }
        }
    }
}
