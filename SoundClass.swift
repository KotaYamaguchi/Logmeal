import SwiftUI
import AVFoundation

struct Sound {
    
    let aVAudioPlayer: AVAudioPlayer
    
    init(_ name: String) {
        self.aVAudioPlayer = try! AVAudioPlayer(data: NSDataAsset(name: name)!.data)
    }
  
    //    頭から再生
    func play(){
        aVAudioPlayer.currentTime = 0.0
        aVAudioPlayer.play()
    }
    
    func stop(){
        aVAudioPlayer.stop()
    }
    
    //    ループ再生、stop()するまで鳴り続けます
    func playLoop(){
        aVAudioPlayer.numberOfLoops = -1
        aVAudioPlayer.play()
    }
}

