import SwiftUI
import ConfettiSwiftUI

struct AjiwaiThirdView: View {
    @EnvironmentObject var user: UserData
    var menuList: [String] = []
    @State var escapeDailyData: [String] = []
    @State var escapeEventsDate: [String] = []
    @State var escapeSavedData: [String: SavedData] = [:]
    @State private var counter1: Int = 0
    @State private var counter2: Int = 0
    @State private var lastTapTime: Date = Date.distantPast
    @State private var scaleFlag:Bool = false
    @State private var buttondisable = true
    private let tapInterval: TimeInterval = 1.5 // 3秒間隔
    @State var gifData = NSDataAsset(name: "Rabbit1_animation_breath")?.data
    @State var levelUpGifData = NSDataAsset(name: "animation_levelUp")?.data
    @State var growthGifData = NSDataAsset(name: "animation_growthLight")?.data
    @State var playGif = true
    @State var playlevelupGif = false
    @State var playgrowthGif = false
    @State private var levelUped:Bool = false
    @State private var growthed:Bool = false
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("bg_RewardView")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
                Image("mt_Border_RewardView")
                    .resizable()
                    .frame(width: geometry.size.width*0.97,height: geometry.size.height*0.97)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
                Image("mt_vegetables")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width*0.1)
                    .position(x: geometry.size.width * 0.06, y: geometry.size.height * 0.1)
                
                if let gifData = gifData {
                    GIFImage(data: gifData, playGif: $playGif) {
                        //    print("GIF animation finished!")
                        playGif = false
                        growthed = user.growth()
                    }
                    .frame(width:geometry.size.width * 2)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
                }
                if levelUped{
                    if let gifData = levelUpGifData {
                        GIFImage(data: gifData,loopCount: 1, playGif: $playlevelupGif) {
                            //    print("GIF animation finished!")
                            playGif = false
                            growthed = user.growth()
                        }
                        .frame(width:geometry.size.width * 0.8)
                        .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.6)
                        
                    }
                }
                if growthed{
                    if let gifData = growthGifData{
                        GIFImage(data:gifData,loopCount:1, playGif: $playgrowthGif)
                            .ignoresSafeArea()
                            .frame(height: geometry.size.height*2.0)
                            .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
                        
                    }
                }
                
                Image("mt_RewardView_callout_\(user.selectedCharactar)")
                    .resizable()
                    .frame(width: geometry.size.width*0.65,height: geometry.size.height*0.36)
                    .position(x:geometry.size.width*0.5,y:geometry.size.height*0.2)
                    .overlay{
                        VStack(alignment:.leading){
                            TypeWriterTextView("\(user.gotEXP)expを獲得！！\n今日もしっかり味わいカードが書けたよ！\n明日も書いてね！！", speed: 0.05,font:.custom("GenJyuuGothicX-Bold", size: 17),textColor: .black) {
                                buttondisable = false
                            }
                            
                        }
                        .position(x:geometry.size.width*0.5,y:geometry.size.height*0.2)
                    }
                HStack{
                    Image("mt_cracker")
                        .scaleEffect(scaleFlag ? 0.2 : 1)
                        .rotationEffect(.degrees(60))
                        .confettiCannon(counter: $counter2, num: 50, confettiSize: 10, rainHeight: 100, fadesOut: true, openingAngle: Angle.degrees(0), closingAngle: Angle.degrees(90), radius: 800)
                    Spacer()
                        .frame(width: geometry.size.width*0.75)
                    Image("mt_cracker")
                        .scaleEffect(scaleFlag ? 0.2 : 1)
                        .confettiCannon(counter: $counter1, num: 50, confettiSize: 10, rainHeight: 100, fadesOut: true, openingAngle: Angle.degrees(90), closingAngle: Angle.degrees(180), radius: 800)
                    
                }
                .position(x:geometry.size.width*0.5,y:geometry.size.height*0.9)
            }
            Button {
                //pathの中身を全て削除して大元のビューに戻る
                user.path.removeAll()
                //ホームビューに行きたいので.homeを追加
                user.path.append(.home)
            } label: {
                Image("bt_backHome")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width*0.15)
                    .shadow(radius: 10)
            }
            .position(x:geometry.size.width*0.93,y:geometry.size.height*0.98)
            .buttonStyle(PlainButtonStyle())
            .disabled(buttondisable)
            .onChange(of: growthed) { oldValue, newValue in
                if newValue {  // 成長が確認された場合
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        if user.growthStage == 3 {
                            gifData = NSDataAsset(name: "\(user.selectedCharactar)_animation_applause")?.data
                        } else if user.growthStage == 2 {
                            gifData = NSDataAsset(name: "\(user.selectedCharactar)2_animation_breath")?.data
                        }
                        playGif = true  // GIFを再生
                    }
                }
            }
            
            .onAppear {
                levelUped = user.checkLevel()  // レベルアップのチェック
                if levelUped {
                    // レベルアップ時のGIF再生ロジック
                    levelUped = true
                }
                growthed = user.growth()  // 成長のチェック
                if growthed {
                    // 成長時のGIF再生ロジック
                    growthed = true
                }
                counter1 += 1
                counter2 += 1
                withAnimation {
                    scaleFlag = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.spring()) {
                        scaleFlag = false
                    }
                }
            }
            
            .onChange(of: user.exp) { oldValue, newValue in
                levelUped = user.checkLevel()  // レベルアップのチェック
                if levelUped {
                    // レベルアップ時のGIF再生ロジック
                    levelUped = true
                    growthed = user.growth()  // 成長のチェック
                    if growthed {
                        // 成長時のGIF再生ロジック
                        growthed = true
                    }
                }
            }
        }
    }
    
    private func handleTap() {
        withAnimation {
            scaleFlag.toggle()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring()) {
                scaleFlag = false
            }
        }
        let currentTime = Date()
        if currentTime.timeIntervalSince(lastTapTime) >= tapInterval {
            counter1 += 1
            counter2 += 1
            lastTapTime = currentTime
        }
    }
    //入力したデータを保存するメソッドをまとめたボタンビュー
    
    
}//View

#Preview{
    AjiwaiThirdView()
        .environmentObject(UserData())
}
