import SwiftUI
enum NavigationDestinations{
   case home
   case column
   case setting
}
struct NewContentView: View {
    @EnvironmentObject var user:UserData
    let headLineTitles: [String] = ["ホーム", "コラム", "せってい"]
    @State private var isShowSelectedView: [Bool] = [true, false, false] // 初期状態で1つ目を選択
    @State private var showCharactarView:Bool = false
    @State private var navigationFlag:Bool = false
    @State private var navigationDestination:NavigationDestinations = .home
    @State private var navigationDestinations:[NavigationDestinations] = [.home, .column, .setting]
    var body: some View {
        ZStack{
            NavigationSplitView {
                leftSideSection()
                    .toolbar(removing: .sidebarToggle)
            } detail: {
                NewHomeView()
//                rightSideSection()
            }
            if user.showAnimation{
                if user.showGrowthAnimation{
                    GrowthAnimationView(text1: "おや、\(user.characterName)のようすが…",
                                        text2: "おめでとう！\(user.characterName)が進化したよ！",
                                        useBackGroundColor: true)
                    .onTapGesture{
                        user.showGrowthAnimation = false
                        user.isGrowthed = false
                        user.showAnimation = false
                    }
                }else if user.showLevelUPAnimation{
                    LevelUpAnimationView(
                        characterGifName: "\(user.selectedCharacter)\(user.growthStage)_animation_breath",
                        text: "\(user.characterName)がレベルアップしたよ！",
                        backgroundImage: "mt_RewardView_callout_\(user.selectedCharacter)",
                        useBackGroundColor: true
                    )
                    .onTapGesture{
                        user.showLevelUPAnimation = false
                        user.isIncreasedLevel = false
                        user.showAnimation = false
                    }
                }else{
                    NormalAnimetionView(
                        characterGifName: "\(user.selectedCharacter)\(user.growthStage)_animation_breath",
                        text: "今日も記録してくれてありがとう！",
                        backgroundImage: "mt_RewardView_callout_\(user.selectedCharacter)",
                        useBackGroundColor: true
                    )
                    .onTapGesture {
                        user.showAnimation = false
                    }
                }
            }
        }
    }
    
    private func leftSideSection() -> some View {
        List{
            NavigationLink{
                NewHomeView()
            }label: {
                Text("ホーム")
            }
            
            NavigationLink{
                NewColumnView()
            }label: {
                Text("コラム")
            }
            NavigationLink{
                NewSettingView()
            }label: {
                Text("せってい")
            }
            Spacer()
        }
    }
    
    private func headlineItem(text: String, icon: String, isSelected: Bool) -> some View {
        HStack {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
            Text(text)
                .font(.system(size: 30))
            Spacer()
        }
        .padding()
    }
    
//    private func rightSideSection() -> some View {
//        ZStack {
//            if isShowSelectedView[0] {
//                NavigationStack{
//                    NewHomeView()
//                }
//                
//            } else if isShowSelectedView[1] {
//                NavigationStack{
//                    NewColumnView()
//                }
//                
//            } else if isShowSelectedView[2] {
//                
//                NavigationStack{
//                    NewSettingView()
//                }
//            }
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        //        .background(Color.blue.opacity(0.1))
//    }
}

#Preview {
    NewContentView()
        .environmentObject(UserData())
        .modelContainer(for: [AjiwaiCardData.self,MenuData.self,ColumnData.self])
}
