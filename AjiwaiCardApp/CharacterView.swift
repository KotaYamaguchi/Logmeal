import SwiftUI
import SwiftyGif
import BudouX

struct CharacterView: View {
    @EnvironmentObject var user: UserData
    let grid = [GridItem(spacing: 20), GridItem(spacing: 20), GridItem(spacing: 20)]
    @State var gifData = NSDataAsset(name: "cat_wavinghands")?.data
    @State var gifArray = ["cat_wavinghands","cat_walk","cat_jump"]
    @State var playGif = false
    @State private var selectedTab = 0
    private var charactarArray = ["Dog","Cat","Rabbit"]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { let size = $0.size
            ZStack(alignment:.topLeading){
                Image("bg_AjiwaiCardView")
                    .resizable()
                    .ignoresSafeArea()
                    .frame(width:size.width,height: size.height)
                    .position(x:size.width*0.5,y:size.height*0.5)
                Button{
                    print("オサレ")
                    dismiss()
                    
                }label: {
                    Image("bt_back")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                }
                .padding()
                .zIndex(2.0)
                .buttonStyle(PlainButtonStyle())
                // 左側: Gifの再生画面
                HStack{
                    if selectedTab == 1 {
                        VStack{
                            
                        }
                    }else{
                        //画像をつくって配置する
                        VStack(spacing:0){
                            HStack{
                                Image("\(user.selectedCharactar)_normal_1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width:size.width*0.2)
                                Text("1段階目")
                            }
                            HStack{
                                Text("2段階目")
                                Image("\(user.selectedCharactar)_normal_2")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width:size.width*0.18)
                            }
                            HStack{
                                Image("\(user.selectedCharactar)_normal_3")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width:size.width*0.15)
                                Text("3段階目")
                            }
                        }
                       
                    }
                    // 右側: 切り替え可能なビュー
                    VStack {
                        Picker("View Selection", selection: $selectedTab) {
                            Text("キャラクターについて").tag(0)
                            Text("集めたモーション").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        if selectedTab == 1 {
                            if user.growthStage >= 3 {
                                ScrollView {
                                    LazyVGrid(columns: grid, spacing: 20) {
                                        ForEach(gifArray, id: \.self) { item in
                                            Button {
                                                gifData = NSDataAsset(name: item)?.data
                                            } label: {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .frame(width: 120, height: 120)
                                                    .foregroundStyle(.blue)
                                                    .overlay {
                                                        Text(item)
                                                            .foregroundStyle(.white)
                                                    }
                                            }
                                        }
                                    }
                                    .padding(.top)
                                }
                                .frame(width:size.width*0.4,height: size.height*0.8)
                            } else {
                                Text("集めたモーションは成長段階3以上で閲覧できます。")
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .frame(width:size.width*0.4,height: size.height*0.8)
                            }
                        } else {
                            VStack(alignment:.leading){
                                Text("レーク")
                                    .font(.largeTitle)
                                Divider()
                                BudouXText("")
                                    .multilineTextAlignment(.leading)
                                
                            }
                            .frame(width:size.width*0.4,height: size.height*0.8)
                        }
                    }
                    .frame(width:size.width*0.4,height: size.height)
                    .padding()
                }
                .position(x:size.width*0.5,y:size.height*0.5)
            }
        }
    }
}

#Preview {
    CharacterView()
        .environmentObject(UserData())
}
