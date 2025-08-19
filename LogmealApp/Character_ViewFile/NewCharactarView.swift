import SwiftUI
import SwiftData

struct NewCharacterView: View {
    @Binding var showCharacterView: Bool
    @EnvironmentObject var userData: UserData
    @Query private var characters: [Character]
    // GIF-related state
    @State private var gifData: Data? = nil
    @State private var gifArray: [String] = []
    @State private var playGif: Bool = true
    @State private var gifPosition: CGPoint = .zero
    @State private var baseGifPosition: CGPoint = .zero
    @State private var timer: Timer? = nil
    @State private var boughtProducts: [Product] = []
    @AppStorage("isProductMigrated") var isProductMigrated: Bool = false  // ★マイグレーションフラグ追加
    // Refresh ID
    @State private var refreshID = UUID()

    // Base dimensions
    private let baseSize = CGSize(width: 1210, height: 785)

    var body: some View {
        GeometryReader { geo in
            NavigationStack {
                ZStack {
                    Image("bg_homeView")
                        .resizable()
                        .ignoresSafeArea()

                    TopActionButtons(
                        size: geo.size,
                        character: userData.selectedCharacter,
                        growthStage: characters.first(where: {$0.isSelected})!.growthStage
                    )
                    .position(
                        x: geo.size.width * (1000 / baseSize.width),
                        y: geo.size.height * (600 / baseSize.height)
                    )
                    bgClouds(size: geo.size)
                    .id(refreshID)

                    CharacterInfoView(size: geo.size)
                    .onAppear(){
                        print("NewCharacterView: ", ObjectIdentifier(userData))
                        Task{
                            await migrateOldProductsIfNeeded()
                        }
                        
                    }
                    .position(
                        x: geo.size.width * (350 / baseSize.width),
                        y: geo.size.height * (300 / baseSize.height)
                    )
                    AllGIFView(
                        geometry: geo,
                        character: characters.first(where: {$0.isSelected})!.name,
                        growthStage: characters.first(where: {$0.isSelected})!.growthStage,
                        bought: boughtProducts,
                        gifWidth: $userData.gifWidth,
                        gifHeight: $userData.gifHeight,
                        gifData: $gifData,
                        playGif: $playGif,
                        gifArray: $gifArray,
                        timer: $timer,
                        gifPosition: $gifPosition,
                        baseGifPosition: $baseGifPosition
                    )
                    CloseButton(
                        size: geo.size,
                        character: userData.selectedCharacter,
                        showCharacterView: $showCharacterView
                    )
                    // ─────────────────────────────────────────
                    // debug
                    DebugOverlay()
                        .environmentObject(userData)
                        .position(
                            x: geo.size.width * 0.5,
                            y: geo.size.height * 0.5
                        )
                    // ─────────────────────────────────────────

                }
                .onAppear {
                    switch characters.first(where: {$0.isSelected})!.name{
                    case "Dog":
                        boughtProducts = userData.loadProducts(key: "Dog_boughtItem")
                        print("Dog bought products:",boughtProducts)
                    case "Cat":
                        boughtProducts = userData.loadProducts(key: "Cat_boughtItem")
                        print("Cat bought products:",boughtProducts)
                    case "Rabbit":
                        boughtProducts = userData.loadProducts(key: "Rabbit_boughtItem")
                        print("Rabbit bought products:",boughtProducts)
                    default:
                        boughtProducts = userData.loadProducts(key: "boughtProducts")
                    }
                    setupGIF(in: geo.size)
                    refreshID = UUID()
                }
                .onChange(of: userData.selectedCharacter) { _, _ in
                    boughtProducts = userData.loadProducts(key: "boughtItem")
                    setupGIF(in: geo.size)
                }
            }
        }
    }
    // MARK: Functions
    // Initialize GIF settings
    private func setupGIF(in size: CGSize) {
        userData.gifWidth = size.width * 0.2
        userData.gifHeight = size.width * 0.2
        baseGifPosition = CGPoint(
            x: size.width * (650 / baseSize.width),
            y: size.height * (600 / baseSize.height)
        )
        gifPosition = baseGifPosition
        updateGifArray()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            updateGifArray()
        }
    }

    // Update GIF data array based on growth stage and product
    private func updateGifArray() {
        let char = characters.first(where: {$0.isSelected})!.name
        let stage = characters.first(where: {$0.isSelected})!.growthStage
        let baseName = "\(char)\(stage)_animation_breath"
        let sleepName = "\(char)\(stage)_animation_sleep"
        gifArray = [baseName, sleepName]
        if stage == 3 {
            gifArray += boughtProducts.map { $0.name }
        }
        gifData = NSDataAsset(name: gifArray.randomElement() ?? baseName)?.data
    }
    private func migrateOldProductsIfNeeded() async {
        guard !isProductMigrated else { return }
        print("=== migrateOldProductsIfNeeded: Start ===")
        let oldProducts = userData.loadProducts(key: "products")
        let oldBoughtItems = userData.loadProducts(key: "boughtItem")
        let characterKeys = ["Dog", "Cat", "Rabbit"]

        // 商品をキャラごとに分配
        for char in characterKeys {
            let filteredProducts = oldProducts.filter { $0.name.contains(char) }
            let filteredBoughtItems = oldBoughtItems.filter { $0.name.contains(char) }
            userData.saveProducts(products: filteredProducts, key: "\(char)_products")
            userData.saveProducts(products: filteredBoughtItems, key: "\(char)_boughtItem")
            print("Migrated \(filteredProducts.count) products and \(filteredBoughtItems.count) boughtItems to \(char)_products / \(char)_boughtItem")
        }

        // 必要なら旧データを消す（任意）
        userData.saveProducts(products: [], key: "products")
        userData.saveProducts(products: [], key: "boughtItem")
        isProductMigrated = true
        print("=== migrateOldProductsIfNeeded: Complete ===")
    }
    // Background clouds
    private func bgClouds(size: CGSize) -> some View {
        ZStack {
            ForEach(["cloud_04", "cloud_01", "cloud_05", "cloud_03", "cloud_06", "cloud_02"], id: \.self) { name in
                GIFImage(data: NSDataAsset(name: name)!.data,
                         playGif: $playGif)
                    .scaledToFit()
                    .frame(width: size.width * 0.3)
                    .position(cloudPosition(name: name, size: size))
            }
        }
    }

    private func cloudPosition(name: String, size: CGSize) -> CGPoint {
        switch name {
        case "cloud_04": return CGPoint(x: size.width * 0.087, y: size.height * 0.285)
        case "cloud_01": return CGPoint(x: size.width * 0.235, y: size.height * 0.1)
        case "cloud_05": return CGPoint(x: size.width * 0.375, y: size.height * 0.1)
        case "cloud_03": return CGPoint(x: size.width * 0.49, y: size.height * 0.2)
        case "cloud_06": return CGPoint(x: size.width * 0.585, y: size.height * 0.07)
        case "cloud_02": return CGPoint(x: size.width * 0.8, y: size.height * 0.06)
        default: return .zero
        }
    }
}

// MARK: - GIF Container
private struct AllGIFView: View {
    let geometry: GeometryProxy
    let character: String
    let growthStage: Int
    let bought: [Product]
    @Binding var gifWidth: CGFloat
    @Binding var gifHeight: CGFloat
    @Binding var gifData: Data?
    @Binding var playGif: Bool
    @Binding var gifArray: [String]
    @Binding var timer: Timer?
    @Binding var gifPosition: CGPoint
    @Binding var baseGifPosition: CGPoint

    @State private var isDrag = false

    var body: some View {
        ZStack {
            gifView(size: geometry.size)
        }
        .onAppear {
            initializeGif(size: geometry.size)
        }
    }



    // GIF character
    @ViewBuilder
    private func gifView(size: CGSize) -> some View {
        if let data = gifData {
            GIFImage(data: data,
                     loopCount: 3,
                     playGif: $playGif) {
                // completion
                self.gifData = NSDataAsset(name: gifArray.randomElement() ?? "")?.data
            }
            .frame(width: gifWidth, height: gifHeight)
            .position(gifPosition)
            .gesture(dragGesture(size: size))
            .onTapGesture {
                gifData = NSDataAsset(name: gifArray.randomElement() ?? "")?.data
            }
        }
    }

    private func initializeGif(size: CGSize) {
        gifWidth = size.width * 0.2
        gifHeight = size.width * 0.2
        baseGifPosition = CGPoint(x: size.width * 0.5, y: size.height * 0.55)
        gifPosition = baseGifPosition
        // reset array handled by parent
    }

    // Drag gesture
    private func dragGesture(size: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                isDrag = true
                playGif = false
                gifData = NSDataAsset(name: "\(character)\(growthStage)_Drag")?.data
                withAnimation(.easeOut(duration: 0.2)) {
                    gifPosition = value.location
                }
            }
            .onEnded { value in
                let velocity = CGPoint(
                    x: value.predictedEndLocation.x - value.location.x,
                    y: value.predictedEndLocation.y - value.location.y
                )
                withAnimation(.easeOut(duration: 0.5)) {
                    gifPosition.x += velocity.x * 0.5
                    gifPosition.y += velocity.y * 0.5
                }
                // Clamp to screen bounds
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
                // If y position is over 400, animate to a specified y
                let dropY: CGFloat = screenWidth * 0.45
                if gifPosition.y <= 400 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeIn(duration: 0.7)) {
                            gifPosition.y = dropY
                        }
                    }
                }
                isDrag = false
                // Restore GIF data to a random normal gif
                gifData = NSDataAsset(name: gifArray.randomElement() ?? "")?.data
                playGif = true
            }
    }
}

// MARK: - Top Buttons
private struct TopActionButtons: View {
    let size: CGSize
    let character: String
    let growthStage: Int

    private let baseSize = CGSize(width: 1210, height: 785)

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            NavigationLink(destination: NewShopView()) {
                Image("bt_toShop_\(character)")
                    .resizable()
                    .scaledToFit()
                    .brightness(growthStage < 3 ? -0.2 : 0)
                    .opacity(growthStage < 3 ? 0.7 : 1)
                    .frame(width: size.width * (300 / baseSize.width))
            }
            .disabled(growthStage < 3)

            NavigationLink(destination: NewCharacterDetailView()) {
                Image("bt_toCharaSelect_\(character)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.width * (350 / baseSize.width))
            }
        }
    }
}

// MARK: - Info View
private struct CharacterInfoView: View {
    let size: CGSize
    @EnvironmentObject var userData: UserData
    private let baseSize = CGSize(width: 1210, height: 785)
    @Query private var characters: [Character]
    private func calculateProgress(for character: Character) -> CGFloat {
        let currentLevel = character.level
        let currentExp = Double(character.exp)
        let thresholds = userData.levelThresholds

        // 1. 最大レベルに達しているかチェック
        guard currentLevel < thresholds.count - 1 else {
            return 1.0 // 最大レベルならバーは100%
        }

        // 2. 現在のレベルと次のレベルに必要な経験値を取得
        let expForCurrentLevel = Double(thresholds[currentLevel])
        let expForNextLevel = Double(thresholds[currentLevel + 1])

        // 3. レベルアップに必要な経験値の総量を計算
        let totalExpForLevel = expForNextLevel - expForCurrentLevel
        
        // ゼロ除算を避ける
        guard totalExpForLevel > 0 else { return 0.0 }

        // 4. 現在のレベルで既に獲得した経験値を計算
        let progressInLevel = currentExp - expForCurrentLevel

        // 5. 割合を計算して返す (0.0〜1.0の範囲に収める)
        let percentage = progressInLevel / totalExpForLevel
        return max(0.0, min(1.0, percentage))
    }
    var body: some View {
        guard let selectedCharacter = characters.first(where: { $0.isSelected }) else {
            // 選択中のキャラクターがいない場合は何も表示しない（クラッシュを防止）
            return AnyView(EmptyView())
        }
        
        // プログレスを計算
        let progressBarWidth = calculateProgress(for: selectedCharacter)
        return AnyView(
            ZStack {
                Image("House_\(characters.first(where: {$0.isSelected})!.name)")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 590 * (size.width / baseSize.width))
                    .offset(x: -50 * (size.width / baseSize.width),
                            y: 130 * (size.height / baseSize.height))
                VStack {
                    HStack(spacing:20){
                        Image("mt_PointBadge")
                            .resizable()
                            .scaledToFit()
                            .frame(width:50)
                        Text("\(userData.point)")
                            .foregroundStyle(.white)
                            .font(.custom("GenJyuuGothicX-Bold", size: 35))
                        Text("pt")
                            .foregroundStyle(.white)
                            .font(.custom("GenJyuuGothicX-Bold", size: 30))
                    }
                    .offset(x: -95 * (size.width / baseSize.width),
                            y: -25 * (size.height / baseSize.height))
                    VStack(spacing:0){
                        Text("\(userData.name)のレーク")
                            .foregroundStyle(.white)
                            .font(.custom("GenJyuuGothicX-Bold", size: 30))
                        HStack(spacing:0){
                            Image("mt_LvBadge")
                                .resizable()
                                .scaledToFit()
                                .frame(width:50)
                            //経験値のプログレスバーの表示
                            ZStack(alignment:.leading){
                                RoundedRectangle(cornerRadius: 20)
                                    .frame(width:260,height: 15)
                                    .foregroundStyle(.white)
                                
                                // プログレスバー（赤色）
                                RoundedRectangle(cornerRadius: 20)
                                    .frame(width: 260 * progressBarWidth, height: 15) // パーセンテージを使用
                                    .foregroundStyle(.red)
                            }
                            Text("LV.\(characters.first(where: {$0.isSelected})!.level)") // currentCharacterのレベルを表示
                                .foregroundStyle(.white)
                                .font(.custom("GenJyuuGothicX-Bold", size: 30))
                                .padding(.horizontal)
                        }
                    }
                    .offset(x: -35 * (size.width / baseSize.width),
                            y: -1 * (size.height / baseSize.height))
                }
            }
        )
    }
    
}
// MARK: - Close Button
private struct CloseButton: View {
    let size: CGSize
    let character: String
    private let baseSize = CGSize(width: 1210, height: 785)
    @Binding var showCharacterView:Bool
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    showCharacterView = false
                } label: {
                    Image("bt_toHome_\(character)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: size.width * (80 / baseSize.width))
                }
                .padding(.horizontal)
            }
            Spacer()
        }
    }
}


// Dummy-Fallback for Preview
struct NewCharacterView_Previews: PreviewProvider {
    static var previews: some View {
        NewCharacterView(showCharacterView: .constant(true))
            .environmentObject(UserData())
    }
}


// MARK: - デバッグ用オーバーレイコントロール
private struct DebugOverlay: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject var userData: UserData
    @State private var isExpanded = true
    @State private var dragOffset = CGSize.zero
    @State private var position = CGPoint(x: 100, y: 200) // ★初期位置: 左寄せ
    @Query private var characters: [Character]
    // サイズを小さく、正方形に
    private let panelSize: CGFloat = 220

    var body: some View {
        VStack(spacing: 0) {
            headerView

            if isExpanded {
                ScrollView { // ★内容をスクロール可能に
                    debugContent
                        .frame(width: panelSize - 24) // パディング分を引く
                }
                .frame(width: panelSize, height: panelSize - 48) // header分を引く
                .clipped()
                .transition(.opacity.combined(with: .scale(scale: 0.9, anchor: .top)))
            }
        }
        .frame(width: panelSize, height: panelSize) // ★正方形
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.23), radius: 8, x: 0, y: 4)
        .position(x:500, y:200)
//        .offset(x: position.x + dragOffset.width - panelSize/2, y: position.y + dragOffset.height - panelSize/2)
//       .gesture(dragGesture)
//        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)
//        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: dragOffset)
        .zIndex(999)
        .onAppear(){
            print("DebugOverlay: ", ObjectIdentifier(userData))
        }
    }
    
    private var headerView: some View {
        HStack(spacing: 10) {
            Image(systemName: "ladybug.circle.fill")
                .foregroundColor(.orange)
                .font(.title2)
            
            Text("Debug")
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.clear)
    }
    
    private var debugContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
            characterBasicSection
            Divider()
            growthStageSection
            Divider()
            actionButtonsSection
        }
        .padding(.vertical, 8)
    }
    
    private var characterBasicSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("📊 Character Stats")
            stepperRow(
                label: "Level",
                value: characters.first(where: {$0.isSelected})!.level,
                range: 0...50,
                onChange: { characters.first(where: {$0.isSelected})!.level = $0 }
            )
            stepperRow(
                label: "EXP",
                value: characters.first(where: {$0.isSelected})!.exp,
                range: 0...1000,
                onChange: { characters.first(where: {$0.isSelected})!.exp = $0 }
            )
        }
    }
    
    private var growthStageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("🌱 Growth Stages")
            stepperRow(
                label: "選択中",
                value: characters.first(where: {$0.isSelected})!.growthStage,
                range: 0...3,
                onChange: { newValue in
                    characters.first(where: {$0.isSelected})!.growthStage = newValue
                }
            )
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 6) {
            Button{
                do{
                    try context.save()
                }catch{
                    print("Failed to save context: \(error)")
                }
            }label:{
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Save All")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.16))
                .foregroundColor(.blue)
                .cornerRadius(7)
            }
            .buttonStyle(PlainButtonStyle())
            
            HStack(spacing: 6) {
                Button("Reset") {
                    characters.first(where: {$0.isSelected})!.level = 1
                    characters.first(where: {$0.isSelected})!.exp = 0
                }
                .buttonStyle(compactButtonStyle(color: .red))
            }
        }
    }
    
    // MARK: - Helper Views
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundColor(.secondary)
    }
    
    private func stepperRow<T: BinaryInteger>(
        label: String,
        value: T,
        range: ClosedRange<T>,
        onChange: @escaping (T) -> Void
    ) -> some View {
        HStack {
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundColor(.primary)
                .frame(width: 50, alignment: .leading)
            Spacer()
            Text("\(value)")
                .font(.caption.monospacedDigit())
                .foregroundColor(.secondary)
                .frame(width: 28, alignment: .trailing)
            Stepper("", value: Binding(
                get: { value },
                set: onChange
            ), in: range)
            .labelsHidden()
            .scaleEffect(0.8)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Color.gray.opacity(0.07))
        .cornerRadius(5)
    }
    
    private func compactButtonStyle(color: Color) -> some ButtonStyle {
        CompactDebugButtonStyle(color: color)
    }
    
    // MARK: - Gestures
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
            }
            .onEnded { value in
                position.x += value.translation.width
                position.y += value.translation.height
                // 左寄せ・画面境界内に収める
                let screenWidth = UIScreen.main.bounds.width
                let screenHeight = UIScreen.main.bounds.height
                let minX = panelSize / 2 + 8
                let maxX = screenWidth / 2
                let minY = panelSize / 2 + 8
                let maxY = screenHeight - panelSize / 2 - 8
                position.x = min(max(position.x, minX), maxX)
                position.y = min(max(position.y, minY), maxY)
                dragOffset = .zero
            }
    }
}

// MARK: - カスタムボタンスタイル
private struct CompactDebugButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(configuration.isPressed ? 0.3 : 0.18))
            .foregroundColor(color)
            .cornerRadius(5)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
