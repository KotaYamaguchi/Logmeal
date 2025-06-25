import SwiftUI

struct NewCharacterView: View {
    @Binding var showCharacterView: Bool
    @EnvironmentObject var userData: UserData

    // GIF-related state
    @State private var gifData: Data? = nil
    @State private var gifArray: [String] = []
    @State private var playGif: Bool = true
    @State private var gifPosition: CGPoint = .zero
    @State private var baseGifPosition: CGPoint = .zero
    @State private var timer: Timer? = nil
    @State private var boughtProducts: [Product] = []

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
                        growthStage: userData.currentCharacter.growthStage
                    )
                    .position(
                        x: geo.size.width * (1000 / baseSize.width),
                        y: geo.size.height * (600 / baseSize.height)
                    )

                    CharacterInfoView(
                        size: geo.size,
                        characterData: userData.currentCharacter
                    )
                    .onAppear(){
                        userData.setCurrentCharacter()
                    }
                    .position(
                        x: geo.size.width * (350 / baseSize.width),
                        y: geo.size.height * (300 / baseSize.height)
                    )

                    AllGIFView(
                        geometry: geo,
                        character: userData.selectedCharacter,
                        growthStage: userData.currentCharacter.growthStage,
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
                    .id(refreshID)

                    CloseButton(
                        size: geo.size,
                        character: userData.selectedCharacter,
                        showCharacterView: $showCharacterView
                    )
//                    ─────────────────────────────────────────
                    // デバッグ用パネルを左上に追加
                    DebugOverlay()
                        .environmentObject(userData)
                        .position(
                            x: geo.size.width * 0.5,
                            y: geo.size.height * 0.5
                        )
                    // ─────────────────────────────────────────

                }
                .onAppear {
                    userData.setCurrentCharacter()
                    boughtProducts = userData.loadProducts(key: "boughtItem")
                    setupGIF(in: geo.size)
                    refreshID = UUID()
                }
                .onChange(of: userData.selectedCharacter) { _, _ in
                    userData.setCurrentCharacter()
                    boughtProducts = userData.loadProducts(key: "boughtItem")
                    setupGIF(in: geo.size)
                }
            }
        }
    }

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
        let char = userData.selectedCharacter
        let stage = userData.currentCharacter.growthStage
        let baseName = "\(char)\(stage)_animation_breath"
        let sleepName = "\(char)\(stage)_animation_sleep"
        gifArray = [baseName, sleepName]
        if stage == 3 {
            gifArray += boughtProducts.map { $0.name }
        }
        gifData = NSDataAsset(name: gifArray.randomElement() ?? baseName)?.data
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
            bgClouds(size: geometry.size)
            gifView(size: geometry.size)
        }
        .onAppear {
            initializeGif(size: geometry.size)
        }
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
        baseGifPosition = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
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
    let characterData: Character
    @EnvironmentObject var userData: UserData
    private let baseSize = CGSize(width: 1210, height: 785)

    var body: some View {
        ZStack {
            Image("House_\(characterData.name)")
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
                        .foregroundStyle(.green)
                        .font(.custom("GenJyuuGothicX-Bold", size: 35))
                    Text("pt")
                        .foregroundStyle(.green)
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
                            .font(.custom("GenJyuuGothicX-Bold", size: 30))
                            .padding(.horizontal)
                    }
                }
                .offset(x: -35 * (size.width / baseSize.width),
                        y: -1 * (size.height / baseSize.height))
            }
        }
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
    @EnvironmentObject var userData: UserData
    @State private var isExpanded = true
    @State private var dragOffset = CGSize.zero
    @State private var position = CGPoint(x: 50, y: 100)
    
    var body: some View {
        VStack(spacing: 0) {
            // ヘッダー部分（常に表示）
            headerView
            
            // 展開可能なコンテンツ
            if isExpanded {
                debugContent
                    .transition(.opacity.combined(with: .scale(scale: 0.9, anchor: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: dragOffset)
    }
    
    private var headerView: some View {
        HStack {
            Image(systemName: "ladybug.circle.fill")
                .foregroundColor(.orange)
                .font(.title2)
            
            Text("Debug Panel")
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                    .foregroundColor(.secondary)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.clear)
    }
    
    private var debugContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Divider()
            
            // キャラクター基本情報
            characterBasicSection
            
            Divider()
            
            // 成長段階コントロール
            growthStageSection
            
            Divider()
            
            // アクションボタン
            actionButtonsSection
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    private var characterBasicSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("📊 Character Stats")
            
            VStack(spacing: 8) {
                stepperRow(
                    label: "Level",
                    value: userData.currentCharacter.level,
                    range: 0...50,
                    onChange: { userData.currentCharacter.level = $0 }
                )
                
                stepperRow(
                    label: "EXP",
                    value: userData.currentCharacter.exp,
                    range: 0...1000,
                    onChange: { userData.currentCharacter.exp = $0 }
                )
            }
        }
    }
    
    private var growthStageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("🌱 Growth Stages")
            
            VStack(spacing: 8) {
                // Dog
                stepperRow(
                    label: "🐕 Dog",
                    value: userData.DogData.growthStage,
                    range: 0...3,
                    onChange: { newValue in
                        userData.DogData.growthStage = newValue
                        if userData.selectedCharacter == "Dog" {
                            userData.currentCharacter.growthStage = newValue
                        }
                    }
                )
                
                // Rabbit
                stepperRow(
                    label: "🐰 Rabbit",
                    value: userData.RabbitData.growthStage,
                    range: 0...3,
                    onChange: { newValue in
                        userData.RabbitData.growthStage = newValue
                        if userData.selectedCharacter == "Rabbit" {
                            userData.currentCharacter.growthStage = newValue
                        }
                    }
                )
                
                // Cat
                stepperRow(
                    label: "🐱 Cat",
                    value: userData.CatData.growthStage,
                    range: 0...3,
                    onChange: { newValue in
                        userData.CatData.growthStage = newValue
                        if userData.selectedCharacter == "Cat" {
                            userData.currentCharacter.growthStage = newValue
                        }
                    }
                )
            }
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 8) {
            Button(action: { userData.saveAllCharacter() }) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Save All Characters")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.2))
                .foregroundColor(.blue)
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            
            // 追加のデバッグアクション
            HStack(spacing: 8) {
                Button("Reset") {
                    userData.currentCharacter.level = 1
                    userData.currentCharacter.exp = 0
                }
                .buttonStyle(compactButtonStyle(color: .red))
                
                Button("Max Level") {
                    userData.currentCharacter.level = 50
                    userData.currentCharacter.exp = 1000
                }
                .buttonStyle(compactButtonStyle(color: .green))
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
                .frame(width: 60, alignment: .leading)
            
            Spacer()
            
            Text("\(value)")
                .font(.caption.monospacedDigit())
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .trailing)
            
            Stepper("", value: Binding(
                get: { value },
                set: onChange
            ), in: range)
            .labelsHidden()
            .scaleEffect(0.8)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(6)
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
                
                // 画面境界内に収める
                let screenWidth = UIScreen.main.bounds.width
                let screenHeight = UIScreen.main.bounds.height
                
                position.x = max(75, min(screenWidth - 75, position.x))
                position.y = max(100, min(screenHeight - 100, position.y))
                
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
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(configuration.isPressed ? 0.3 : 0.2))
            .foregroundColor(color)
            .cornerRadius(6)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

