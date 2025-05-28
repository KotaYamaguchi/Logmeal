import SwiftUI
struct NewCharacterView: View {
    @Binding var showCharacterView:Bool
    @EnvironmentObject var userData :UserData
    
    // GIF表示に関する変数
    @State var gifData:Data? = NSDataAsset(name: "")?.data
    @State var gifArray:[String] = []
    @State var playGif:Bool = true
    @State private var gifPosition:CGPoint = CGPoint(x: 500, y: 550)
    @State private var baseGifPosition:CGPoint = CGPoint(x: 600, y: 600)
    @State private var gifOffset:Double = 0.0
    @State private var isDrag:Bool = false
    @State private var timer: Timer? = nil
    @State private var boughtProducts:[Product] = []
    @State private var toglleHouseImage:Bool = false
    @State private var toglleBalloonImage:Bool = false
    
    //家の写真のサイズと位置を設定するための変数
    @State private var houseSize:CGFloat = 0
    @State private var houseOffsetX:CGFloat = 0
    @State private var houseOffsetY:CGFloat = 0
    private func setHouseSize() -> CGFloat{
        switch userData.selectedCharacter{
        case "Dog":
            return 590
        case "Cat":
            return 590
        case "Rabbit":
            return 590
        default:
            return 400
        }
    }
    private func setHouseOffsetX() -> CGFloat{
        switch userData.selectedCharacter{
        case "Dog":
            return -40
        case "Cat":
            return -50
        case "Rabbit":
            return -50
        default:
            return 0
        }
    }
    private func setHouseOffsetY() -> CGFloat{
        switch userData.selectedCharacter{
        case "Dog":
            return 130
        case "Cat":
            return 135
        case "Rabbit":
            return 130
        default:
            return 0
        }
    }
    var body: some View {
        GeometryReader{ geometry in
        NavigationStack{
            ZStack{
                Image("bg_homeView")
                    .resizable()
                    .ignoresSafeArea()
                VStack(alignment:.trailing,spacing:0){
                    NavigationLink{
                        NewShopView()
                       
                    }label:{
                        Image("bt_toShop_\(userData.selectedCharacter)")
                            .resizable()
                            .scaledToFit()
                            .frame(width:300)
                    }
                    NavigationLink{
                        NewCharacterDetailView()
                          
                    }label:{
                        Image("bt_toCharaSelect_\(userData.selectedCharacter)")
                            .resizable()
                            .scaledToFit()
                            .frame(width:350)
                    }
                }
                .position(x:1000,y:600)
                ZStack{
                    ZStack{
                        Image("House_\(userData.selectedCharacter)")
                            .resizable()
                            .scaledToFit()
                            .frame(height:setHouseSize())
                            .offset(x:houseOffsetX,y:houseOffsetY)
                    }
                    .onAppear(){
                        self.houseSize = setHouseSize()
                        self.houseOffsetX = setHouseOffsetX()
                        self.houseOffsetY = setHouseOffsetY()
                        userData.gifWidth = geometry.size.width*0.2
                        userData.gifHeight = geometry.size.width*0.2
                        self.baseGifPosition = CGPoint(x: 600, y: 600)
                        self.gifPosition = baseGifPosition
                        changeGifData()
                        startGifTimer()
                        self.boughtProducts = userData.loadProducts(key: "boughtItem")
                    }
                    .onChange(of: userData.selectedCharacter, { oldValue, newValue in
                        self.houseSize = setHouseSize()
                        userData.gifWidth = geometry.size.width*0.2
                        userData.gifHeight = geometry.size.width*0.2
                        self.baseGifPosition = CGPoint(x: 600, y: 600)
                        self.gifPosition = baseGifPosition
                        changeGifData()
                        startGifTimer()
                    })
                    HStack(spacing:20){
                        Image("mt_PointBadge")
                            .resizable()
                            .scaledToFit()
                            .frame(width:50)
                        Text("\(userData.point)")
                            .foregroundStyle(.green)
                            .font(.custom("GenJyuuGothicX-Bold", size: 40))
                        Text("pt")
                            .foregroundStyle(.green)
                            .font(.custom("GenJyuuGothicX-Bold", size: 35))
                    }
                    .offset(x:-80,y:-80)
                    VStack(spacing:0){
                        Text("\(userData.name)のレーク")
                            .foregroundStyle(.white)
                            .font(.custom("GenJyuuGothicX-Bold", size: 35))
                        HStack(spacing:0){
                            Image("mt_LvBadge")
                                .resizable()
                                .scaledToFit()
                                .frame(width:50)
                            ZStack(alignment:.leading){
                                RoundedRectangle(cornerRadius: 20)
                                    .frame(width:260,height: 15)
                                    .foregroundStyle(.white)
                                
                                RoundedRectangle(cornerRadius: 20)
                                    .frame(width:CGFloat(userData.exp)/260,height: 15)
                                    .foregroundStyle(.red)
                            }
                            Text("LV.\(userData.level)")
                                .foregroundStyle(.white)
                                .font(.custom("GenJyuuGothicX-Bold", size: 35))
                                .padding(.horizontal)
                        }
                    }
                    .offset(x:-25,y:40)
                }
                .position(x:350,y:300)
                VStack{
                    HStack{
                        Spacer()
                        Button{
                            withAnimation {
                                showCharacterView = false
                            }
                        }label: {
                            Image("bt_toHome_\(userData.selectedCharacter)")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80)
                            
                        }
                        .padding(.horizontal)
                    }
                    Spacer()
                }
                
                AllGIFView(geometry: geometry)
                }
            }
        }
    }
    
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
        switch userData.growthStage {
        case 1:
            switch userData.selectedCharacter {
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
            switch userData.selectedCharacter {
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
            switch userData.selectedCharacter {
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
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                isDrag = true
                playGif = false
                gifData = NSDataAsset(name: "\(userData.selectedCharacter)\(userData.growthStage)_Drag")?.data
                // 遅延アニメーションで位置を更新
                withAnimation(.easeOut(duration: 0.2)) {
                    gifPosition = value.location
                }
            }
            .onEnded { value in
                let velocity = CGPoint(
                    x: value.predictedEndLocation.x - value.location.x,
                    y: value.predictedEndLocation.y - value.location.y
                )
                
                // オブジェクトが飛んでいくアニメーションを実行
                withAnimation(.easeOut(duration: 0.5)) {
                    gifPosition.x += velocity.x * 0.5
                    gifPosition.y += velocity.y * 0.5
                }
                
                // 画面サイズの外に行きそうな場合に跳ね返す
                let screenWidth = UIScreen.main.bounds.width
                let screenHeight = UIScreen.main.bounds.height
                let gifHalfWidth = userData.gifWidth / 2
                let gifHalfHeight = userData.gifHeight / 2
                
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
    private func AllGIFView(geometry:GeometryProxy) -> some View {
        
        ZStack{
            bg_cloudImage(size: geometry.size)
            gifView(size: geometry.size, gif: gifData)
        }
    }
    @ViewBuilder func gifView(size: CGSize, gif: Data?) -> some View {
        
        if let gifData = gif {
            GIFImage(data: gifData,loopCount: 3, playGif: $playGif) {
                print("GIF animation finished!")
                self.gifData = NSDataAsset(name: gifArray.randomElement()! )?.data
            }
            .frame(width: userData.gifWidth,height: userData.gifHeight)
            .onTapGesture {
                self.gifData = NSDataAsset(name: gifArray.randomElement()! )?.data
            }
            .position(gifPosition)
            .gesture(dragGesture)
        }
    }
    @ViewBuilder private func bg_cloudImage(size:CGSize) -> some View{
        ZStack {
            GIFImage(data: NSDataAsset(name: "cloud_04")!.data, playGif: $playGif)
                .scaledToFit()
                .frame(width: size.width * 0.3)
                .position(x: size.width * 0.087, y: size.height * 0.285)
            GIFImage(data: NSDataAsset(name: "cloud_01")!.data, playGif: $playGif)
                .scaledToFit()
                .frame(width: size.width * 0.3)
                .position(x: size.width * 0.235, y: size.height * 0.1)
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
}



#Preview(body: {
    NewCharacterView(showCharacterView: .constant(true))
        .environmentObject(UserData())
})

struct NewCharacterDetailView:View {
    @State private var selectedTab:Int = 0
    @State private var isSelected:Bool = false
    @EnvironmentObject var userData:UserData
    var body: some View {
        ZStack{
            switch selectedTab {
            case 0:
                Image("bg_charactarDetailView_dog")
                    .resizable()
                    .ignoresSafeArea()
            case 1:
                Image("bg_charactarDetailView_rabbit")
                    .resizable()
                    .ignoresSafeArea()
            case 2:
                Image("bg_charactarDetailView_cat")
                    .resizable()
                    .ignoresSafeArea()
            default:
                Image("bg_charactarDetailView_tomato")
                    .resizable()
                    .ignoresSafeArea()
            }
            
            VStack {
                RoundedRectangle(cornerRadius: 50)
                    .frame(width: 280, height: 90)
                    .foregroundStyle(.white)
                    .overlay {
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(Color.gray, lineWidth: 3)
                    }
                    .overlay {
                        HStack {
                            Button {
                                withAnimation{
                                    selectedTab = 0
                                }
                                
                            } label: {
                                Image("Dog_normal_1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: selectedTab == 0 ? 70 : 60)
                                    .colorMultiply(selectedTab == 0 ? .white : .gray) // 選択されていない場合にグレー
                            }
                            Button {
                                withAnimation{
                                    selectedTab = 1
                                }
                            } label: {
                                Image("Rabbit_normal_1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: selectedTab == 1 ? 70 : 60)
                                    .colorMultiply(selectedTab == 1 ? .white : .gray)
                            }
                            Button {
                                withAnimation{
                                    selectedTab = 2
                                }
                            } label: {
                                Image("Cat_normal_1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: selectedTab == 2 ? 70 : 60)
                                    .colorMultiply(selectedTab == 2 ? .white : .gray)
                            }
                        }
                    }
                Spacer()
                if selectedTab == 0 {
                    VStack{
                        HStack(alignment: .bottom, spacing: 1) {
                            Spacer()
                            Image("Dog_normal_1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200)
                            Image("arrow_symbol")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80)
                                .offset(y: -50)
                            Image("img_dog_applause")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300)
                            Image("arrow_symbol")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80)
                                .offset(y: -50)
                            Image("img_dog_applause")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 400)
                            Spacer()
                        }
                        if userData.selectedCharacter != "Dog"{
                            Button{
                                userData.selectedCharacter = "Dog"
                            }label:{
                                RoundedRectangle(cornerRadius: 50)
                                    .frame(width:400,height: 80)
                                    .foregroundStyle(.green)
                                    .overlay{
                                        Text("このキャラにする！")
                                            .foregroundStyle(.white)
                                            .font(.system(size: 40))
                                    }
                            }
                        }else{
                            Button{
                                
                            }label:{
                                RoundedRectangle(cornerRadius: 50)
                                    .frame(width:300,height: 80)
                                    .foregroundStyle(.gray)
                                    .overlay{
                                        Text("選択中")
                                            .foregroundStyle(.white)
                                            .font(.system(size: 40))
                                    }
                            }
                        }
                    }
                } else if selectedTab == 1 {
                    Text("うさぎ")
                    if userData.selectedCharacter != "Rabbit"{
                        Button{
                            userData.selectedCharacter = "Rabbit"
                        }label:{
                            RoundedRectangle(cornerRadius: 50)
                                .frame(width:400,height: 80)
                                .foregroundStyle(.green)
                                .overlay{
                                    Text("このキャラにする！")
                                        .foregroundStyle(.white)
                                        .font(.system(size: 40))
                                }
                        }
                    }else{
                        Button{
                            
                        }label:{
                            RoundedRectangle(cornerRadius: 50)
                                .frame(width:300,height: 80)
                                .foregroundStyle(.gray)
                                .overlay{
                                    Text("選択中")
                                        .foregroundStyle(.white)
                                        .font(.system(size: 40))
                                }
                        }
                    }
                } else if selectedTab == 2 {
                    Text("ねこ")
                    if userData.selectedCharacter != "Cat"{
                        Button{
                            userData.selectedCharacter = "Cat"
                        }label:{
                            RoundedRectangle(cornerRadius: 50)
                                .frame(width:400,height: 80)
                                .foregroundStyle(.green)
                                .overlay{
                                    Text("このキャラにする！")
                                        .foregroundStyle(.white)
                                        .font(.system(size: 40))
                                }
                        }
                    }else{
                        Button{
                            
                        }label:{
                            RoundedRectangle(cornerRadius: 50)
                                .frame(width:300,height: 80)
                                .foregroundStyle(.gray)
                                .overlay{
                                    Text("選択中")
                                        .foregroundStyle(.white)
                                        .font(.system(size: 40))
                                }
                        }
                    }
                }
                
                
            }
            
        }
    }
}

