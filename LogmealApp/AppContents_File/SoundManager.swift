import AVFoundation

class SoundManager: ObservableObject {
    static let shared = SoundManager()

       private var player: AVAudioPlayer?
       @Published var soundVolume: Float {
           didSet {
               UserDefaults.standard.set(soundVolume, forKey: "soundVolume")
           }
       }
       @Published var isSoundOn: Bool {
           didSet {
               UserDefaults.standard.set(isSoundOn, forKey: "isSoundOn")
           }
       }

       private init() {
           // Load saved settings
           self.soundVolume = UserDefaults.standard.float(forKey: "soundVolume")
           self.isSoundOn = UserDefaults.standard.bool(forKey: "isSoundOn")
           
           // Set default values if not previously saved
           if self.soundVolume == 0 {
               self.soundVolume = 1.0
           }
           if (UserDefaults.standard.object(forKey: "isSoundOn") == nil) {
               self.isSoundOn = true
           }
       }
    func playSound(named soundName: String) {
        guard isSoundOn else { return }  // 効果音がOFFの場合、再生しない
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
    func toggleSound() {
        isSoundOn.toggle()
        if !isSoundOn {
            player?.stop()
        }
    }
}


