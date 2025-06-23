import SwiftUI
import SwiftyGif

struct GrowthAnimationView: View {
    let text1: String
    let text2: String
    let useBackGroundColor:Bool
    @EnvironmentObject var user: UserData
    @State private var showFirstGif = true
    @State private var showSecondGif = false
    @State private var showGrowthGif = false
    @State private var showText1 = true
    @State private var showText2 = false
    @State private var playGif: Bool = true
    
    private func getFirstGifName() -> String {
           switch user.growthStage {
           case 2:
               return "\(user.currentCharacter.name)1_animation_breath"
           case 3:
               return "\(user.currentCharacter.name)2_animation_breath"
           default:
               return "\(user.currentCharacter.name)\(user.currentCharacter.growthStage)_animation_breath"
           }
       }
       
       private func getSecondGifName() -> String {
           switch user.currentCharacter.growthStage {
           case 2:
               return "\(user.currentCharacter.name)2_animation_breath"
           case 3:
               return "\(user.currentCharacter.name)3_animation_breath"
           default:
               return "\(user.currentCharacter.name)\(user.currentCharacter.growthStage)_animation_breath"
           }
       }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if useBackGroundColor{
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                }
                if showFirstGif {
                    GIFImage(data: NSDataAsset(name: getFirstGifName())!.data, loopCount: 1, playGif: $playGif)
                        .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.7)
                        .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.65)
                }
                
                if showSecondGif {
                    GIFImage(data: NSDataAsset(name: getSecondGifName())!.data, loopCount: 1, playGif: $playGif)
                        .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.7)
                        .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.65)
                }
                
                if showGrowthGif {
                    GIFImage(data: NSDataAsset(name: "animation_growthLight")!.data, loopCount: 1, playGif: $playGif) {
                        showGrowthGif = false
                        showText2 = true
                    }
                    .scaledToFill()
                    .frame(width: geometry.size.width * 1.05, height: geometry.size.height * 1.05)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
                }
                
                if showText1 {
                    TypeWriterTextView(text1,
                                       speed: 0.1,
                                       font: .custom("GenJyuuGothicX-Bold", size: 17),
                                       textColor: useBackGroundColor ? .white : .textColor) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showText1 = false
                            playGrowthAnimation()
                        }
                    }
                                       .padding()
                                       .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.3)
                }
                
                if showText2 {
                    TypeWriterTextView(text2,
                                       speed: 0.1,
                                       font: .custom("GenJyuuGothicX-Bold", size: 17),
                                       textColor: useBackGroundColor ? .white : .textColor) {
                        // 完了アクション
                    }
                                       .padding()
                                       .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.3)
                }
            }
        }
    }
    
    func playGrowthAnimation() {
        showGrowthGif = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            showFirstGif = false
            showSecondGif = true
        }
    }
}
import SwiftUI
import SwiftyGif

struct LevelUpAnimationView: View {
    var characterGifName: String
    var text: String
    var backgroundImage: String = ""
    let useBackGroundColor:Bool
    @State private var showLevelUpGif = true
    @State private var playGif: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if useBackGroundColor{
                    Color.black.opacity(0.5) // 背景色を黒に設定
                        .ignoresSafeArea()
                }
                // キャラクターのGIF
                GIFImage(data: NSDataAsset(name: characterGifName)!.data, loopCount: -1, playGif: $playGif)
                    .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.7)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.6)
                
                // レベルアップのGIF (一度だけ再生)
                if showLevelUpGif {
                    GIFImage(data: NSDataAsset(name: "animation_levelUp")!.data, loopCount: 1, playGif: .constant(true)) {
                        showLevelUpGif = false
                    }
                    .scaledToFill()
                    .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.7)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.65)
                }
                
                // テキスト表示 (TypeWriterTextView)
                ZStack {
                    if !useBackGroundColor {
                        Image(backgroundImage)
                            .resizable()
                            .scaledToFit()
                    }
                    
                    TypeWriterTextView(text,
                                       speed: 0.1,
                                       font: .custom("GenJyuuGothicX-Bold", size: 17),
                                       textColor: useBackGroundColor ? .white : .textColor) {
                        // 完了アクション (必要に応じて)
                    }
                                       .padding()
                }
                .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.2)
                .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.3)
            }
        }
    }
}
import SwiftUI
import SwiftyGif

struct NormalAnimetionView: View {
    var characterGifName: String
    var text: String
    var backgroundImage: String = ""
    let useBackGroundColor:Bool 
    @State private var playGif: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if useBackGroundColor{
                    Color.black.opacity(0.5) // 背景色を黒に設定
                        .ignoresSafeArea()
                }
                // キャラクターのGIF
                GIFImage(data: NSDataAsset(name: characterGifName)!.data, loopCount: -1, playGif: $playGif)
                    .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.7)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.65)
                
                // テキスト表示 (TypeWriterTextView)
                ZStack {
                    if !useBackGroundColor {
                        Image(backgroundImage)
                            .resizable()
                            .scaledToFit()
                    }
                    
                    TypeWriterTextView(text,
                                       speed: 0.1,
                                       font: .custom("GenJyuuGothicX-Bold", size: 17),
                                       textColor: useBackGroundColor ? .white : .textColor) {
                        // 完了アクション (必要に応じて)
                    }
                                       .padding()
                }
                .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.2)
                .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.3)
            }
        }
    }
}


