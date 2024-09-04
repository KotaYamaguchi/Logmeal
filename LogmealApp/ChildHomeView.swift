import SwiftUI
import SwiftData

struct ChildHomeView: View {
    @EnvironmentObject var user:UserData
    @Environment(\.modelContext) private var context
    @Query private var allColumn:[ColumnData]
    @Query private var allData:[AjiwaiCardData]
    private let soundManager = SoundManager.shared
    @State var isShowShareSheet:Bool = false
    @State var progressValue:CGFloat = 0.1
    @State var width:CGFloat = 300
    @State var showColumn:Bool = false
    @State var gifData:Data? = NSDataAsset(name: "")?.data
    @State var gifArray:[String] = []
    @State var playGif:Bool = true
    @State private var hasUnreadColumn:Bool = false
    @State private var gifPosition:CGPoint = CGPoint(x: 500, y: 550)
    @State private var baseGifPosition:CGPoint = CGPoint(x: 0, y: 0)
    @State private var gifOffset:Double = 0.0
    @State private var gifWidth:CGFloat = 0.0
    @State private var gifHeight:CGFloat = 0.0
    @State private var isDrag:Bool = false
    @State private var showNoColumnAlert:Bool = false
    @State private var showCardAlert:Bool = false
    @State private var showCardDetail:Bool = false
    @State private var selectedCardData: AjiwaiCardData? = nil
    @State private var isLoading:Bool = false
    @State private var showSettingView:Bool = false
    @State private var showHowToUseView:Bool = false
    @State private var timer: Timer? = nil
    @State private var boughtProducts:[Product] = []
    @State private var toglleHouseImage:Bool = false
    @State private var toglleBalloonImage:Bool = false
    @AppStorage("hasVisitedChildHomeView") var hasVisitedChildHomeView :Bool = false

    
    private func startGifTimer() {
        timer?.invalidate() // 既存のタイマーがあれば無効化する
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            updateGifData()
        }
    }
    
    private func updateGifData() {
        changeGifData()
        self.gifData = NSDataAsset(name: gifArray.randomElement()! )?.data
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
    
    private func checkForUnreadColumn() {
        let currentDate = getCurrentDate()
        if let todayColumn = allColumn.first(where: { $0.columnDay == currentDate }) {
            hasUnreadColumn = !todayColumn.isRead
        } else {
            hasUnreadColumn = false
        }
    }
    
    private func checkForTodayColumn() -> Bool {
        let currentDate = getCurrentDate()
        return allColumn.contains(where: { $0.columnDay == currentDate })
    }
    
    private func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }
    
    private var todayData: AjiwaiCardData? {
        let currentDate = getCurrentDate()
        return allData.first { user.dateFormatter(date: $0.saveDay) == currentDate }
    }
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                isDrag = true
                playGif = false
                gifData = NSDataAsset(name: "\(user.selectedCharacter)\(user.growthStage)_Drag")?.data
                // 遅延アニメーションで位置を更新
                withAnimation(.easeOut(duration: 0.2)) {
                    gifPosition = value.location
                }
            }
            .onEnded { value in
                let velocity = value.predictedEndLocation - value.location

                // オブジェクトが飛んでいくアニメーションを実行
                withAnimation(.easeOut(duration: 0.5)) {
                    gifPosition.x += velocity.x * 0.5
                    gifPosition.y += velocity.y * 0.5
                }
                
                // 画面サイズの外に行きそうな場合に跳ね返す
                let screenWidth = UIScreen.main.bounds.width
                let screenHeight = UIScreen.main.bounds.height
                let gifHalfWidth = gifWidth / 2
                let gifHalfHeight = gifHeight / 2
                
                if gifPosition.x - gifHalfWidth < 0 {
                    gifPosition.x = gifHalfWidth
                } else if gifPosition.x + gifHalfWidth > screenWidth {
                    gifPosition.x = screenWidth - gifHalfWidth
                }
                
                if gifPosition.y - gifHalfHeight < 0 {
                    gifPosition.y = gifHalfHeight
                } else if gifPosition.y + gifHalfHeight > screenHeight {
                    gifPosition.y = screenHeight - gifHalfHeight
                }
                
                // gifPosition.yが一定以上なら指定のY座標(例: 550)まで落とす
                if gifPosition.y <= 400 { // ここで条件を指定
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeIn(duration: 0.7)) {
                            gifPosition.y = UIScreen.main.bounds.width*0.45
                        }
                    }
                }
                isDrag = false
                changeGifData()
            }
    }

    var doubleTapGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded {
                gifPosition = baseGifPosition
            }
    }
    
    var body: some View {
        GeometryReader { geometry in
            if user.isLogined {
                ZStack {
                    childHome(size: geometry.size)
                        .navigationBarHidden(true)
                        .gesture(doubleTapGesture)
                    if showColumn {
                        Color.gray
                            .opacity(0.7)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation {
                                    showColumn = false
                                }
                                soundManager.playSound(named: "se_negative")
                            }
                    }
                    ColumnView()
                        .frame(width: 700, height: 500)
                        .position(showColumn ? CGPoint(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5) : CGPoint(x: geometry.size.width * 0.5, y: geometry.size.height * 2))
                }
                .ignoresSafeArea(.keyboard)
                .onChange(of: user.exp) { _, _ in
                    _ = user.growth()
                    changeGifData()
                }
                .onChange(of: user.selectedCharacter) { _, _ in
                    changeGifData()
                }
                .onAppear {
                    print("おとずれた？",hasVisitedChildHomeView)
                    if !hasVisitedChildHomeView{
                        showHowToUseView = true
                    }else{
                        showHowToUseView = false
                    }
                    user.setGrowthStage()
                    gifWidth = geometry.size.width*0.15
                    gifHeight = geometry.size.width*0.15
                    baseGifPosition = CGPoint(x: geometry.size.width*0.45, y: geometry.size.height*0.75)
                    gifPosition = baseGifPosition
                    changeGifData()
                    checkForUnreadColumn()
                    startGifTimer()
                    self.boughtProducts = user.loadProducts(key: "boughtItem")
                    print(user.selectedCharacter)
                    print(user.growthStage)
                }

                .onDisappear {
                    timer?.invalidate() // ビューが消えた時にタイマーを無効化する
                }
                
                .alert("コラムがありません", isPresented: $showNoColumnAlert) {
                    Button("OK") {}
                } message: {
                    Text("今日の日付に対応するコラムが見つかりませんでした。")
                }
                .alert("今日の味わいカードを編集しますか？", isPresented: $showCardAlert) {
                    Button("いいえ") {}
                    Button("はい") {
                        if let data = todayData {
                            selectedCardData = data
                            isLoading = true
                            showCardDetail = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                isLoading = false
                            }
                        }
                    }
                }
                .fullScreenCover(isPresented: $showCardDetail) {
                    if let data = selectedCardData {
                        if isLoading {
                            ProgressView() // ローディング中に表示
                        } else {
                            AjiwaiCardDetailView(selectedDate: Date(), data: data)
                                .onAppear(){
                                    isLoading = false
                                }
                        }
                    }
                }
                .sheet(isPresented:$showHowToUseView){
                    TutorialView(imageArray: ["HowToUseHome"])
                        .interactiveDismissDisabled()
                        .onDisappear(){
                            hasVisitedChildHomeView = true
                        }
                }
            } else {
                FirstLoginView()
            }
        }
    }
    
    @ViewBuilder func gifView(size: CGSize, gif: Data?) -> some View {
        if let gifData = gif {
            GIFImage(data: gifData,loopCount: 3, playGif: $playGif) {
                print("GIF animation finished!")
                self.gifData = NSDataAsset(name: gifArray.randomElement()! )?.data
            }
            .frame(width: gifWidth,height: gifHeight)
            .onTapGesture {
                self.gifData = NSDataAsset(name: gifArray.randomElement()! )?.data
            }
            .position(gifPosition)
            .gesture(dragGesture)
        }
    }
    
    @ViewBuilder private func bg_cloudImage(size:CGSize) -> some View{
        ZStack {
            Image("bg_homeview")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .frame(width: size.width, height: size.height)
                .position(x: size.width * 0.5, y: size.height * 0.5)
            GIFImage(data: NSDataAsset(name: "cloud_04")!.data, playGif: $playGif)
                .scaledToFit()
                .frame(width: size.width * 0.3)
                .position(x: size.width * 0.087, y: size.height * 0.285)
            GIFImage(data: NSDataAsset(name: "cloud_01")!.data, playGif: $playGif)
                .scaledToFit()
                .frame(width: size.width * 0.3)
                .position(x: size.width * 0.235, y: size.height * 0.155)
            GIFImage(data: NSDataAsset(name: "cloud_05")!.data, playGif: $playGif)
                .scaledToFit()
                .frame(width: size.width * 0.3)
                .position(x: size.width * 0.375, y: size.height * 0.1)  // 変更: 左へ移動
            GIFImage(data: NSDataAsset(name: "cloud_03")!.data, playGif: $playGif)
                .scaledToFit()
                .frame(width: size.width * 0.3)
                .position(x: size.width * 0.49, y: size.height * 0.2)  // 変更: 左へ移動
            GIFImage(data: NSDataAsset(name: "cloud_06")!.data, playGif: $playGif)
                .scaledToFit()
                .frame(width: size.width * 0.3)
                .position(x: size.width * 0.585, y: size.height * 0.07)  // 変更: 左へ移動
            GIFImage(data: NSDataAsset(name: "cloud_02")!.data, playGif: $playGif)
                .scaledToFit()
                .frame(width: size.width * 0.3)
                .position(x: size.width * 0.8, y: size.height * 0.06)

        }

    }
    
    @ViewBuilder func childHome(size: CGSize) -> some View {
        NavigationStack(path: $user.path) {
            ZStack {
                Image("bg_homeView")
                    .resizable()
                    .frame(width: size.width)
                    .ignoresSafeArea(.all)
                bg_cloudImage(size: size)
                Image(toglleHouseImage ?"mt_house_\(user.selectedCharacter)_open" : "mt_house_\(user.selectedCharacter)_close")
                    .position(x:size.width*0.2,y:size.height*0.685)
                    .onTapGesture {
                        soundManager.playSound(named: "se_door")
                        toglleHouseImage.toggle()
                    }

                GIFImage(data:toglleBalloonImage ? NSDataAsset(name: "balloon_\(user.selectedCharacter)_fire")!.data : NSDataAsset(name: "balloon_\(user.selectedCharacter)_normal")!.data)
                    .frame(width:size.width*0.2)
                    .position(x: size.width * 0.75, y: size.height * 0.3)
                    .onTapGesture {
                        soundManager.playSound(named: "se_fire")
                        toglleBalloonImage.toggle()
                    }
                Group{
                    NavigationLink {
                        ShopView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        Image("bt_HomeVIew_\(user.selectedCharacter)_2")
                            .resizable()
                            .scaledToFit()
                            .shadow(radius: 5, y: 20)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(width: size.width * 0.0884, height: size.height * 0.2333)
                    .position(x: size.width * 0.67, y: size.height * 0.72)
                    .disabled(user.growthStage < 3)
                    .simultaneousGesture(TapGesture().onEnded {
                        soundManager.playSound(named: "se_positive")
                    })
                    NavigationLink {
                        CharacterView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        Image("bt_HomeVIew_\(user.selectedCharacter)_3")
                            .resizable()
                            .scaledToFit()
                            .shadow(radius: 5, y: 20)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(width: size.width * 0.0884, height: size.height * 0.2333)
                    .position(x: size.width * 0.735, y: size.height * 0.60)
                    .simultaneousGesture(TapGesture().onEnded {
                        soundManager.playSound(named: "se_positive")
                    })
                    NavigationLink {
                        LookBackView(fromAjiwaiCard:false)
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        Image("bt_HomeVIew_\(user.selectedCharacter)_4")
                            .resizable()
                            .scaledToFit()
                            .shadow(radius: 5, y: 20)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(width: size.width * 0.0884, height: size.height * 0.2333)
                    .position(x: size.width * 0.84, y: size.height * 0.575)
                    .simultaneousGesture(TapGesture().onEnded {
                        soundManager.playSound(named: "se_positive")
                    })
                    NavigationLink {
                        ColumnListView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        Image("bt_HomeVIew_\(user.selectedCharacter)_5")
                            .resizable()
                            .scaledToFit()
                            .shadow(radius: 5, y: 20)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(width: size.width * 0.0884, height: size.height * 0.2333)
                    .position(x: size.width * 0.91, y: size.height * 0.69)
                    .simultaneousGesture(TapGesture().onEnded {
                        soundManager.playSound(named: "se_positive")
                    })
                    Button {
                        if todayData != nil {
                            showCardAlert = true
                            soundManager.playSound(named: "se_positive")
                        } else {
                            user.path.append(.ajiwaiCard(nil))
                            soundManager.playSound(named: "se_positive")
                        }
                    } label: {
                        Image("bt_HomeVIew_\(user.selectedCharacter)_1")
                            .resizable()
                            .scaledToFit()
                            .shadow(radius: 5, y: 20)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(width: size.width * 0.1764, height: size.height * 0.3672)
                    .position(x: size.width * 0.798, y: size.height * 0.752)
                }
                .offset(y:size.height*0.07)
                StatusBarVIew()
                    .position(x: size.width * 0.47, y: size.height * 0.49)
                
                VStack(spacing: 0) {
                    Button{
                       showSettingView = true
                        soundManager.playSound(named: "se_positive")
                    } label: {
                        Image("bt_gear")
                            .resizable()
                            .scaledToFit()
                            .frame(width: width * 0.8)
                    }
                    .fullScreenCover(isPresented:$showSettingView){
                        SettingView()
                    }
                    Button {
                        if checkForTodayColumn() {
                            withAnimation {
                                showColumn = true
                            }
                            soundManager.playSound(named: "se_positive")
                        } else {
                            showNoColumnAlert = true
                            soundManager.playSound(named: "se_negative")
                        }
                    } label: {
                        Image("bt_news")
                            .resizable()
                            .scaledToFit()
                            .frame(width: width * 0.8)
                            .overlay {
                                if hasUnreadColumn {
                                    Circle()
                                        .foregroundColor(.red)
                                        .scaledToFit()
                                        .frame(width: width * 0.1)
                                        .offset(x: -60, y: -23)
                                }
                            }
                    }
                }
                .frame(width: size.width * 0.08)
                .position(x: size.width * 0.92, y: size.height * 0.067)
                .buttonStyle(PlainButtonStyle())
                
                gifView(size: size, gif: gifData)
            }
            .navigationDestination(for: Homepath.self) { value in
                switch value {
                case .home:
                    ChildHomeView()
                        .navigationBarBackButtonHidden(true)
                case .ajiwaiCard(let data):
                    if let data = data {
                        AjiwaiCardDetailView(selectedDate: Date(), data: data)
                            .navigationBarBackButtonHidden(true)
                    } else {
                        WritingAjiwaiCardView(saveDay: Date())
                            .navigationBarBackButtonHidden(true)
                    }
                case .reward:
                    RewardView()
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}

struct ChildHomeView_Previews: PreviewProvider {
    static var previews: some View {
        let user = UserData()
        ChildHomeView()
            .environmentObject(user)
            .modelContainer(for: [AjiwaiCardData.self, MenuData.self, ColumnData.self])
    }
}
extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}


