import SwiftUI
import SwiftData

struct GrowthAnimationView: View {
    @Query private var characters: [Character]
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
        switch characters.first(where: {$0.isSelected})!.growthStage {
        case 2:
            return "\(characters.first(where: {$0.isSelected})!.name)1_animation_breath"
        case 3:
            return "\(characters.first(where: {$0.isSelected})!.name)2_animation_breath"
        default:
            return "\(characters.first(where: {$0.isSelected})!.name)\(characters.first(where: {$0.isSelected})!.growthStage)_animation_breath"
        }
    }
    
    private func getSecondGifName() -> String {
        switch characters.first(where: {$0.isSelected})!.growthStage {
        case 2:
            return "\(characters.first(where: {$0.isSelected})!.name)2_animation_breath"
        case 3:
            return "\(characters.first(where: {$0.isSelected})!.name)3_animation_breath"
        default:
            return "\(characters.first(where: {$0.isSelected})!.name)\(characters.first(where: {$0.isSelected})!.growthStage)_animation_breath"
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
                }else if showSecondGif{
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
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

