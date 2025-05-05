import SwiftUI

struct NewContentView: View {
    @EnvironmentObject var user:UserData
    let headLineTitles: [String] = ["ホーム", "コラム", "せってい"]
    @State private var isShowSelectedView: [Bool] = [true, false, false] // 初期状態で1つ目を選択
    @State private var showCharactarView:Bool = false
    var body: some View {
        ZStack{
            NavigationSplitView {
                leftSideSection()
                    .toolbar(removing: .sidebarToggle)
            } detail: {
                
                rightSideSection()
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
        VStack(alignment: .leading) {
            ForEach(0..<headLineTitles.count, id: \.self) { index in
                Button {
                    // 他のすべての状態をリセットし、現在のものだけを true に
                    isShowSelectedView = Array(repeating: false, count: headLineTitles.count)
                    isShowSelectedView[index] = true
                } label: {
                    headlineItem(
                        text: headLineTitles[index],
                        icon: "bt_HomeVIew_Cat_2",
                        isSelected: isShowSelectedView[index]
                    )
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(isShowSelectedView[index] ? Color(red: 255/255, green: 235/255, blue: 200/255) : Color.clear)
                    }
                }
                Divider()
            }
            Spacer()
        }
        .padding(.top)
        .background(Color(red: 255/255, green: 254/255, blue: 245/255))
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
    
    private func rightSideSection() -> some View {
        ZStack {
            if isShowSelectedView[0] {
                NavigationStack{
                    NewHomeView()
                }
                
            } else if isShowSelectedView[1] {
                NavigationStack{
                    NewColumnView()
                }
                
            } else if isShowSelectedView[2] {
                
                NavigationStack{
                    NewSettingView()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        //        .background(Color.blue.opacity(0.1))
    }
}

#Preview {
    NewContentView()
        .environmentObject(UserData())
        .modelContainer(for: [AjiwaiCardData.self,MenuData.self,ColumnData.self])
}
