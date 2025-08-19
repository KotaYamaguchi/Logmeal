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

