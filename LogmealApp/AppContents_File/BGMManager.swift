//
//  BGMManager.swift
//  LogmealApp
//
//  Created by Kota Yamaguchi on 2025/08/19.
//

import AVFoundation
class BGMManager: ObservableObject {
    static let shared = BGMManager()

        @Published private var player: AVAudioPlayer?
        @Published private var bgmPlayer: AVAudioPlayer?
        @Published var bgmVolume: Float {
            didSet {
                UserDefaults.standard.set(bgmVolume, forKey: "bgmVolume")
            }
        }
        @Published var isBGMOn: Bool {
            didSet {
                UserDefaults.standard.set(isBGMOn, forKey: "isBGMOn")
            }
        }

        private init() {
            // Load saved settings
            self.bgmVolume = UserDefaults.standard.float(forKey: "bgmVolume")
            self.isBGMOn = UserDefaults.standard.bool(forKey: "isBGMOn")
            
            // Set default values if not previously saved
            if self.bgmVolume == 0 {
                self.bgmVolume = 0.3
            }
            if (UserDefaults.standard.object(forKey: "isBGMOn") == nil) {
                self.isBGMOn = true
            }

            prepareBGM(named: "bgm_home")
            
            // Apply saved settings
            setBGMVolume(bgmVolume)
            if isBGMOn {
                playBGM()
            }
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
        let clampedVolume = max(0, min(volume, 1)) // 音量を0から1の範囲に制限

        if bgmVolume != clampedVolume {  // 音量が変わらない場合には処理を行わない
            bgmVolume = clampedVolume

            // 非同期に音量変更処理を行う
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                self.bgmPlayer?.volume = self.bgmVolume

                // BGMの再生または停止の処理も非同期で行う
                DispatchQueue.main.async {
                    if self.bgmVolume == 0 {
                        self.stopBGM()
                    } else if self.bgmVolume > 0 && !(self.bgmPlayer?.isPlaying ?? false) {
                        self.playBGM()
                    }
                }
            }
        }
    }

    func toggleBGM() {
        isBGMOn.toggle()
        if isBGMOn {
            playBGM()
        } else {
            stopBGM()
        }
    }
}
