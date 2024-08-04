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
                HStack{
                        Image("\(user.selectedCharactar)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.7)
                    

                }
                .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.65)

                Image("mt_RewardView_callout_\(user.selectedCharactar)")
                    .resizable()
                    .frame(width: geometry.size.width*0.65,height: geometry.size.height*0.36)
                    .position(x:geometry.size.width*0.5,y:geometry.size.height*0.2)
                    .overlay{
                        VStack(alignment:.leading){
                            TypeWriterTextView("10expを獲得！！\n今日もしっかり味わいカードが書けたよ！\n明日も書いてね！！", speed: 0.05,font:.system(size: 30),textColor: .black) {
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
                user.exp += 10
                user.appearExp += 10
                user.point += 100
                user.checkLevel()
                //pathの中身を全て削除して大元のビューに戻る
                user.path.removeAll()
                //ホームビューに行きたいので.homeを追加
                user.path.append(.home)
            } label: {
                Image("bt_backHome")
                    .frame(width: 350, height: 100)
                    .shadow(radius: 10)
            }
            .position(x:geometry.size.width*0.75,y:geometry.size.height*0.8)
            .buttonStyle(PlainButtonStyle())
            .disabled(buttondisable)

            .onAppear {
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
