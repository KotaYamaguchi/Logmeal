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
        if showCharactarView{
            NewCharacterView(showCharacterView: $showCharactarView)
        }else{
            ZStack{
                NavigationSplitView{
                    leftSideSection()
                        .toolbar(removing: .sidebarToggle)
                } detail: {
                    NewHomeView()
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
    }
    
    private func leftSideSection() -> some View {
        VStack(spacing: 15) {
            NavigationLink {
                NewHomeView()
            } label: {
                navigationButton(
                    title: "ホーム",
                    color: .pink,
                    icon: "house.fill"
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            NavigationLink {
                NewColumnView()
            } label: {
                navigationButton(
                    title: "コラム",
                    color: .orange,
                    icon: "book.fill"
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            NavigationLink {
                NewSettingView()
            } label: {
                navigationButton(
                    title: "せってい",
                    color: .blue,
                    icon: "gearshape.fill"
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            Button{
                withAnimation {
                    showCharactarView = true
                }
            }label: {
                Image("\(user.selectedCharacter)_window")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(lineWidth: 10)
                            .foregroundColor(Color(red: 149/255, green: 97/255, blue: 52/255))
                    }
            }
            
        }
        .padding()
        .background(Color(red: 255/255, green: 254/255, blue: 245/255))
    }

    private func changeName(name:String) -> String {
        switch name {
        case "Dog":
            return "dog"
        case "Cat":
            return "cat"
        case "Rabbit":
            return "rabbit"
            
        default:
            return "どうぶつ"
        }
    }
    private func navigationButton(title: String, color: Color, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(color)
                .clipShape(Circle())
            
            Text(title)
                .font(.custom("GenJyuuGothicX-Bold", size: 30))
                .foregroundColor(Color.primary)
                .padding(.leading, 8)
            
            Spacer()
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.5), lineWidth: 3)
        )
    }
    
    @State var gifData:Data? = NSDataAsset(name: "")?.data
    @State var gifArray:[String] = []
    @State private var boughtProducts:[Product] = []
    @State var playGif:Bool = false
    @ViewBuilder func gifView( gif: Data?) -> some View {
        
        if let gifData = gif {
            GIFImage(data: gifData,loopCount: 3, playGif: $playGif) {
                print("GIF animation finished!")
                self.gifData = NSDataAsset(name: gifArray.randomElement()! )?.data
            }
            .frame(width: 100,height: 100)
        }
    }
    private func changeGifData() {
        switch user.growthStage {
        case 1:
            switch user.selectedCharacter {
            case "Dog":
                gifData = NSDataAsset(name: "Dog1_animation_breath")?.data
                gifArray = ["Dog1_animation_breath",
                            "Dog1_animation_sleep"]
            case "Cat":
                gifData = NSDataAsset(name: "Cat1_animation_breath")?.data
                gifArray = ["Cat1_animation_breath",
                            "Cat1_animation_sleep"]
            case "Rabbit":
                gifData = NSDataAsset(name: "Rabbit1_animation_breath")?.data
                gifArray = ["Rabbit1_animation_breath",
                            "Rabbit1_animation_sleep"]
            default:
                gifData = nil
                gifArray = []
            }
        case 2:
            switch user.selectedCharacter {
            case "Dog":
                gifData = NSDataAsset(name: "Dog2_animation_breath")?.data
                gifArray = ["Dog2_animation_breath",
                            "Dog2_animation_sleep"]
            case "Cat":
                gifData = NSDataAsset(name: "Cat2_animation_breath")?.data
                gifArray = ["Cat2_animation_breath",
                            "Cat2_animation_sleep"]
            case "Rabbit":
                gifData = NSDataAsset(name: "Rabbit2_animation_breath")?.data
                gifArray = ["Rabbit2_animation_breath",
                            "Rabbit2_animation_sleep"]
            default:
                gifData = nil
                gifArray = []
            }
        case 3:
            switch user.selectedCharacter {
            case "Dog":
                gifData = NSDataAsset(name: "Dog3_animation_breath")?.data
                gifArray = [
                    "Dog3_animation_breath",
                    "Dog3_animation_sleep"
                ] + boughtProducts.map { $0.name }
            case "Cat":
                gifData = NSDataAsset(name: "Cat3_animation_breath")?.data
                gifArray = ["Cat3_animation_breath",
                            "Cat3_animation_sleep",
                ] + boughtProducts.map { $0.name }
            case "Rabbit":
                gifData = NSDataAsset(name: "Rabbit3_animation_breath")?.data
                gifArray = [
                    "Rabbit3_animation_breath",
                    "Rabbit3_animation_sleep"
                ] + boughtProducts.map { $0.name }
            default:
                gifData = nil
                gifArray = []
            }
        default:
            gifData = nil
            gifArray = []
        }
    }
}

#Preview {
    NewContentView()
        .environmentObject(UserData())
        .modelContainer(for: [AjiwaiCardData.self,MenuData.self,ColumnData.self])
}
