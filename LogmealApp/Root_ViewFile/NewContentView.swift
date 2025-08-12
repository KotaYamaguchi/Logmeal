import SwiftUI
import SwiftData

enum NavigationDestinations {
    case home
    case column
    case setting
}
struct CharacterSpeech: Identifiable {
    let id: Int
    let character: String
    let speech: String
    let timing: String
}
struct NewContentView: View {
    @EnvironmentObject var user: UserData
    let headLineTitles: [String] = ["ホーム", "コラム", "せってい"]
    @State private var isShowSelectedView: [Bool] = [true, false, false]
    @State private var showCharactarView: Bool = false
    @State private var navigationFlag: Bool = false
    @State private var navigationDestination: NavigationDestinations = .home
    @State private var navigationDestinations: [NavigationDestinations] = [.home, .column, .setting]

    // 吹き出し表示制御
    @State private var showBubble: Bool = false
    let bubbleSpeeches = [
        "好きなメニューが出たらテンション上がるばい、書いてみよう",
        "今日もお疲れさま！",
        "何か新しいことにチャレンジしよう！",
        "水分補給も忘れずにね！",
        "応援してるよ！"
    ]
    @State private var currentBubbleSpeech: String = "好きなメニューが出たらテンション上がるばい、書いてみよう"
    @State private var bubbleTimer: Timer?
    @State private var hideTimer: Timer?
    let characterSpeechList: [CharacterSpeech] = [
        CharacterSpeech(id: 1, character: "Dog", speech: "今日の食事はどうだった？", timing: "常時"),
        CharacterSpeech(id: 2, character: "Dog", speech: "昨日の感想、とても良かったけん！今日も聞かせてね！", timing: "常時"),
        CharacterSpeech(id: 3, character: "Dog", speech: "君の感想を読むの、いつもワクワクするけん！", timing: "常時"),
        CharacterSpeech(id: 4, character: "Dog", speech: "今日も感想を書いてくれてありがとう！", timing: "常時"),
        CharacterSpeech(id: 5, character: "Dog", speech: "10ろぐ達成だけん！", timing: "常時"),
        CharacterSpeech(id: 6, character: "Dog", speech: "毎日記録するとキャラクターが進化するけん！", timing: "常時"),
        CharacterSpeech(id: 7, character: "Dog", speech: "成長の様子はキャラクター画面から見ることができるけん", timing: "常時"),
        CharacterSpeech(id: 8, character: "Dog", speech: "もう少しでレベルアップするけん！", timing: "レベルアップ"),
        CharacterSpeech(id: 9, character: "Dog", speech: "ショップが開放されたけんキャラクターの画面から見てみよう！！", timing: "レベル3時"),
        CharacterSpeech(id: 10, character: "Dog", speech: "ショップではポーズをゲットすることができるけん！", timing: "レベル3時"),
        CharacterSpeech(id: 11, character: "Dog", speech: "ショップでは他のキャラクターもゲットできるけん！", timing: "レベル3時"),
        CharacterSpeech(id: 12, character: "Rabbit", speech: "今日の食事を教えて欲しいばい", timing: "常時"),
        CharacterSpeech(id: 13, character: "Rabbit", speech: "好きなメニューが出たら、テンション上がるばい、書いてみよう", timing: "常時"),
        CharacterSpeech(id: 14, character: "Rabbit", speech: "感想を書くと、味わう力もアップするばい", timing: "常時"),
        CharacterSpeech(id: 15, character: "Rabbit", speech: "今日も感想を書いてくれてありがとう！", timing: "常時"),
        CharacterSpeech(id: 16, character: "Rabbit", speech: "10ろぐ達成ばい！", timing: "常時"),
        CharacterSpeech(id: 17, character: "Rabbit", speech: "毎日記録するとキャラクターが進化するばい", timing: "常時"),
        CharacterSpeech(id: 18, character: "Rabbit", speech: "進化の過程はキャラクター画面から見ることができるばい", timing: "常時"),
        CharacterSpeech(id: 19, character: "Rabbit", speech: "もう少しでレベルアップするばい", timing: "レベルアップ"),
        CharacterSpeech(id: 20, character: "Rabbit", speech: "ショップが開放されたばい、キャラクターの画面から見てみよう", timing: "レベル3時"),
        CharacterSpeech(id: 21, character: "Rabbit", speech: "ショップではポーズをゲットすることができるばい", timing: "レベル3時"),
        CharacterSpeech(id: 22, character: "Rabbit", speech: "ショップでは他のキャラクターもゲットできるばい", timing: "レベル3時"),
        CharacterSpeech(id: 23, character: "Cat", speech: "今日の感想を書いて私に教えるたい", timing: "常時"),
        CharacterSpeech(id: 24, character: "Cat", speech: "お気に入りのメニューはその日の楽しみになるよね、一言残してみるたい", timing: "常時"),
        CharacterSpeech(id: 25, character: "Cat", speech: "言葉にすると、給食がもっとおいしく感じるみたい", timing: "常時"),
        CharacterSpeech(id: 26, character: "Cat", speech: "今日も感想を書いてくれてありがとう！", timing: "常時"),
        CharacterSpeech(id: 27, character: "Cat", speech: "10ろぐ達成たい", timing: "常時"),
        CharacterSpeech(id: 28, character: "Cat", speech: "毎日記録するとキャラクターが進化するたい", timing: "常時"),
        CharacterSpeech(id: 29, character: "Cat", speech: "進化の過程はキャラクター画面から見ることができるたい", timing: "常時"),
        CharacterSpeech(id: 30, character: "Cat", speech: "もう少しでレベルアップするたい", timing: "レベルアップ"),
        CharacterSpeech(id: 31, character: "Cat", speech: "ショップが開放されたたいキャラクターの画面から見てみよう", timing: "レベル3時"),
        CharacterSpeech(id: 32, character: "Cat", speech: "ショップではポーズをゲットすることができるたい", timing: "レベル3時"),
        CharacterSpeech(id: 33, character: "Cat", speech: "ショップでは他のキャラクターもゲットできるたい", timing: "レベル3時")
    ]
    @Query private var allData: [AjiwaiCardData]
    
    func characterName(current: Character) -> String {
        switch current.name {
        case "Dog":
            return "レーク"
        case "Rabbit":
            return "ラン"
        case "Cat":
            return "ティナ"
        default:
            return "レーク"
        }
    }

    var body: some View {
        GeometryReader { geometry in
            if showCharactarView {
                NewCharacterView(showCharacterView: $showCharactarView)
            } else {
                ZStack {
                    NavigationSplitView {
                        leftSideSection(geometry: geometry)
                            .toolbar(removing: .sidebarToggle)
                    } detail: {
                        NewHomeView()
                    }
                    
                    if showBubble {
                        ZStack {
                            Image("bubble_main")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width < 500 ? geometry.size.width * 0.8 : 400)
                                .overlay {
                                    ZStack {
                                        Text(currentBubbleSpeech)
                                            .font(.custom("GenJyuuGothicX-Bold", size: geometry.size.width < 500 ? 12 : 19))
                                            .frame(width: geometry.size.width < 500 ? geometry.size.width * 0.54 : 270,
                                                   height: geometry.size.width < 500 ? geometry.size.height * 0.21 : 150)
                                            .offset(y: geometry.size.width < 500 ? -geometry.size.height * 0.09 : -65)
                                    }
                                }
//                                .onTapGesture {
//                                    startBubbleCycle()
//                                }
                        }
                        .offset(x: geometry.size.width < 700 ? -geometry.size.width * 0.23 : -150,
                                y: geometry.size.height < 700 ? geometry.size.height * 0.085 : 60)
                    }
                    
                    if user.showAnimation {
                        if user.showGrowthAnimation {
                            GrowthAnimationView(
                                text1: "おや、\(characterName(current: user.currentCharacter))のようすが…",
                                text2: "おめでとう！\(characterName(current: user.currentCharacter))が進化したよ！",
                                useBackGroundColor: true
                            )
                            .onTapGesture {
                                user.showGrowthAnimation = false
                                user.isGrowthed = false
                                user.showAnimation = false
                            }
                        } else if user.showLevelUPAnimation {
                            LevelUpAnimationView(
                                characterGifName: "\(user.currentCharacter.name)\(user.growthStage)_animation_breath",
                                text: "\(characterName(current: user.currentCharacter))がレベルアップしたよ！",
                                backgroundImage: "mt_RewardView_callout_\(user.currentCharacter.name)",
                                useBackGroundColor: true
                            )
                            .onTapGesture {
                                user.showLevelUPAnimation = false
                                user.isIncreasedLevel = false
                                user.showAnimation = false
                            }
                        } else {
                            NormalAnimetionView(
                                characterGifName: "\(user.currentCharacter.name)\(user.currentCharacter.growthStage)_animation_breath",
                                text: "今日も記録してくれてありがとう！",
                                backgroundImage: "mt_RewardView_callout_\(user.currentCharacter.name)",
                                useBackGroundColor: true
                            )
                            .onTapGesture {
                                user.showAnimation = false
                            }
                        }
                    }
                }
                .onAppear {
                    user.initCharacterData()
                    startBubbleCycle()
                }
                .onDisappear {
                    stopBubbleCycle()
                }
            }
        }
    }
    
    // 30秒ごとに5秒間だけ吹き出し表示
        private func startBubbleCycle() {
            showRandomBubble()
            bubbleTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
                showRandomBubble()
            }
        }
        private func stopBubbleCycle() {
            bubbleTimer?.invalidate()
            bubbleTimer = nil
            hideTimer?.invalidate()
            hideTimer = nil
        }
        private func showRandomBubble() {
            currentBubbleSpeech = pickRandomCharacterSpeech()
            withAnimation {
                showBubble = true
            }
            hideTimer?.invalidate()
            hideTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
                withAnimation {
                    showBubble = false
                }
            }
        }

    private func pickRandomCharacterSpeech() -> String {
        let characterName = user.currentCharacter.name
        let growthStage = user.currentCharacter.growthStage
        let exp = user.currentCharacter.exp
        let level = user.currentCharacter.level
        let levelThresholds = user.levelThresholds

        // SwiftDataのAjiwaiCardDataの件数取得
        // allDataの宣言例: @Query private var allData: [AjiwaiCardData]
        let logCount = allData.count

        // 1. キャラ一致
        let filtered = characterSpeechList.filter { $0.character == characterName }

        // 2. 常時
        var availableSpeech = filtered.filter { $0.timing == "常時" }

        // 2. レベル3時（growthStage==3）
        if growthStage == 3 {
            availableSpeech += filtered.filter { $0.timing == "レベル3時" }
        }

        // 3. レベルアップ条件
        let nextLevelIndex = level + 1
        if nextLevelIndex < levelThresholds.count {
            let threshold = levelThresholds[nextLevelIndex]
            if abs(threshold - exp) < 20 {
                availableSpeech += filtered.filter { $0.timing == "レベルアップ" }
            }
        }

        // 4. 10ろぐ達成セリフの数字差し替え
        availableSpeech = availableSpeech.map { speech in
            if (speech.id == 5 && speech.character == "Dog")
            || (speech.id == 16 && speech.character == "Rabbit")
            || (speech.id == 27 && speech.character == "Cat") {
                // "10ろぐ達成"部分を差し替え、他の表現にも対応
                let replaced = speech.speech.replacingOccurrences(of: "10", with: "\(logCount)")
                return CharacterSpeech(id: speech.id, character: speech.character, speech: replaced, timing: speech.timing)
            } else {
                return speech
            }
        }

        return availableSpeech.randomElement()?.speech ?? ""
    }
    private func leftSideSection(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height < 700 ? 8 : 15) {
            NavigationLink {
                NewHomeView()
            } label: {
                navigationButton(
                    title: "ホーム",
                    color: .pink,
                    icon: "house.fill",
                    geometry: geometry
                )
            }
            .buttonStyle(PlainButtonStyle())

            NavigationLink {
                NewColumnView()
            } label: {
                navigationButton(
                    title: "コラム",
                    color: .orange,
                    icon: "book.fill",
                    geometry: geometry
                )
            }
            .buttonStyle(PlainButtonStyle())

            NavigationLink {
                NewSettingView()
            } label: {
                navigationButton(
                    title: "せってい",
                    color: .blue,
                    icon: "gearshape.fill",
                    geometry: geometry
                )
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()

            Button {
                withAnimation {
                    showCharactarView = true
                }
            } label: {
                Image("\(user.currentCharacter.name)_window_\(user.currentCharacter.growthStage)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width < 500 ? geometry.size.width * 0.56 : 280)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(lineWidth: geometry.size.width < 500 ? 6 : 10)
                            .foregroundColor(Color(red: 149/255, green: 97/255, blue: 52/255))
                    }
            }
        }
        .onTapGesture {
            showBubble = false
        }
        .padding()
        .background(Color(red: 255/255, green: 254/255, blue: 245/255))
    }

    private func changeName(name: String) -> String {
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

    private func navigationButton(title: String, color: Color, icon: String, geometry: GeometryProxy) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: geometry.size.width < 500 ? 22 : 30, weight: .bold))
                .foregroundColor(.white)
                .frame(width: geometry.size.width < 500 ? 40 : 60, height: geometry.size.width < 500 ? 40 : 60)
                .background(color)
                .clipShape(Circle())

            Text(title)
                .font(.custom("GenJyuuGothicX-Bold", size: geometry.size.width < 500 ? 18 : 30))
                .foregroundColor(Color.primary)
                .padding(.leading, 8)

            Spacer()
        }
        .padding(.vertical, geometry.size.width < 500 ? 10 : 20)
        .padding(.horizontal, geometry.size.width < 500 ? 8 : 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.5), lineWidth: geometry.size.width < 500 ? 2 : 3)
        )
    }

    @State var gifData: Data? = NSDataAsset(name: "")?.data
    @State var gifArray: [String] = []
    @State private var boughtProducts: [Product] = []
    @State var playGif: Bool = false
    @ViewBuilder func gifView(gif: Data?) -> some View {

        if let gifData = gif {
            GIFImage(data: gifData, loopCount: 3, playGif: $playGif) {
                print("GIF animation finished!")
                self.gifData = NSDataAsset(name: gifArray.randomElement()!)?.data
            }
            .frame(width: 100, height: 100)
        }
    }

    private func changeGifData() {
        switch user.currentCharacter.growthStage {
        case 1:
            switch user.currentCharacter.name {
            case "Dog":
                gifData = NSDataAsset(name: "Dog1_animation_breath")?.data
                gifArray = ["Dog1_animation_breath", "Dog1_animation_sleep"]
            case "Cat":
                gifData = NSDataAsset(name: "Cat1_animation_breath")?.data
                gifArray = ["Cat1_animation_breath", "Cat1_animation_sleep"]
            case "Rabbit":
                gifData = NSDataAsset(name: "Rabbit1_animation_breath")?.data
                gifArray = ["Rabbit1_animation_breath", "Rabbit1_animation_sleep"]
            default:
                gifData = nil
                gifArray = []
            }
        case 2:
            switch user.currentCharacter.name {
            case "Dog":
                gifData = NSDataAsset(name: "Dog2_animation_breath")?.data
                gifArray = ["Dog2_animation_breath", "Dog2_animation_sleep"]
            case "Cat":
                gifData = NSDataAsset(name: "Cat2_animation_breath")?.data
                gifArray = ["Cat2_animation_breath", "Cat2_animation_sleep"]
            case "Rabbit":
                gifData = NSDataAsset(name: "Rabbit2_animation_breath")?.data
                gifArray = ["Rabbit2_animation_breath", "Rabbit2_animation_sleep"]
            default:
                gifData = nil
                gifArray = []
            }
        case 3:
            switch user.currentCharacter.name {
            case "Dog":
                gifData = NSDataAsset(name: "Dog3_animation_breath")?.data
                gifArray = [
                    "Dog3_animation_breath",
                    "Dog3_animation_sleep"
                ] + boughtProducts.map { $0.name }
            case "Cat":
                gifData = NSDataAsset(name: "Cat3_animation_breath")?.data
                gifArray = [
                    "Cat3_animation_breath",
                    "Cat3_animation_sleep"
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
        .modelContainer(for: [AjiwaiCardData.self, MenuData.self, ColumnData.self])
}
