import SwiftUI
import SwiftData

/// LogmealAppのMVVM統合用拡張
extension LogmealApp {
    
    /// MVVM対応のメインAppビュー
    var mvvmBody: some Scene {
        WindowGroup {
            MVVMRootView()
                .modelContainer(for: [AjiwaiCardData.self, ColumnData.self, MenuData.self])
        }
    }
}

/// MVVM アーキテクチャ対応のルートビュー
struct MVVMRootView: View {
    @StateObject private var appCoordinator = AppCoordinator()
    @StateObject private var bgmManager = BGMManager.shared
    @Environment(\.modelContext) private var modelContext
    @Query private var allData: [AjiwaiCardData]
    
    var body: some View {
        Group {
            if appCoordinator.isInitialized {
                if appCoordinator.showLaunchScreen {
                    LaunchScreen()
                        .environmentObject(createUserDataBridge())
                        .onAppear {
                            // 2秒後にランチスクリーンを非表示
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                appCoordinator.hideLaunchScreen()
                            }
                        }
                } else {
                    MVVMContentView()
                        .environmentObject(appCoordinator)
                        .environmentObject(createUserDataBridge())
                }
            } else {
                LaunchScreen()
                    .environmentObject(createUserDataBridge())
            }
        }
        .onAppear {
            setupApp()
        }
        .onChange(of: allData) { _, newData in
            performDataMigrationIfNeeded(newData)
        }
    }
    
    private func setupApp() {
        // DIContainer の初期化
        appCoordinator.initialize(with: modelContext)
        
        // BGM設定
        setupBGM()
    }
    
    private func setupBGM() {
        if bgmManager.isBGMOn {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                bgmManager.playBGM()
            }
        }
    }
    
    private func performDataMigrationIfNeeded(_ data: [AjiwaiCardData]) {
        // 既存のデータマイグレーション処理
        for card in data {
            var needsSave = false
            
            if card.uuid == nil {
                card.uuid = UUID()
                needsSave = true
                print("card.uuid migrated: \(card.uuid?.uuidString ?? "nil")")
            }
            
            if card.time == nil {
                card.time = .lunch
                needsSave = true
                print("card.time migrated: \(card.time?.rawValue ?? "nil")")
            }
            
            if needsSave {
                do {
                    try modelContext.save()
                } catch {
                    print("マイグレーションエラー: \(error)")
                }
            }
        }
    }
    
    private func createUserDataBridge() -> UserDataBridge {
        // DIContainerが初期化されていれば、それを使用
        if appCoordinator.isInitialized {
            return UserDataBridge(
                userService: DIContainer.shared.resolve(UserServiceProtocol.self),
                characterService: DIContainer.shared.resolve(CharacterServiceProtocol.self)
            )
        } else {
            // 初期化前は仮のサービスを使用
            let userService = UserService()
            let characterService = CharacterService()
            return UserDataBridge(userService: userService, characterService: characterService)
        }
    }
}

/// MVVM対応のメインコンテンツビュー
struct MVVMContentView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var userDataBridge: UserDataBridge
    
    var body: some View {
        NavigationStack(path: $appCoordinator.navigationPath) {
            TabBasedContentView()
                .navigationDestination(for: AppDestination.self) { destination in
                    destinationView(for: destination)
                }
        }
    }
    
    @ViewBuilder
    private func destinationView(for destination: AppDestination) -> some View {
        switch destination {
        case .home:
            MVVMHomeView()
        case .ajiwaiCardCreate:
            MVVMAjiwaiCardCreateView()
        case .ajiwaiCardDetail(let card):
            MVVMAjiwaiCardDetailView(card: card)
        case .ajiwaiCardEdit(let card):
            MVVMAjiwaiCardEditView(card: card)
        case .characterSelect:
            MVVMCharacterSelectView()
        case .characterDetail(let character):
            MVVMCharacterDetailView(character: character)
        case .shop:
            MVVMShopView()
        case .shopCategory(let category):
            MVVMShopCategoryView(category: category)
        case .columnList:
            MVVMColumnListView()
        case .columnDetail(let column):
            MVVMColumnDetailView(column: column)
        case .settings:
            MVVMSettingsView()
        case .profileEdit:
            MVVMProfileEditView()
        case .dataExport:
            MVVMDataExportView()
        case .qrScanner:
            MVVMQRScannerView()
        }
    }
}

/// タブベースのコンテンツビュー（既存のNewContentViewをベースに）
struct TabBasedContentView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var userDataBridge: UserDataBridge
    
    var body: some View {
        // 既存のNewContentViewを再利用し、段階的にMVVM対応
        NewContentView()
    }
}

// MARK: - MVVM対応の各ビュー（プレースホルダー実装）

struct MVVMHomeView: View {
    var body: some View {
        Text("MVVM Home View")
            .navigationTitle("ホーム")
    }
}

struct MVVMAjiwaiCardCreateView: View {
    var body: some View {
        Text("MVVM Ajiwai Card Create View")
            .navigationTitle("カード作成")
    }
}

struct MVVMAjiwaiCardDetailView: View {
    let card: AjiwaiCardData
    
    var body: some View {
        Text("MVVM Ajiwai Card Detail View")
            .navigationTitle("カード詳細")
    }
}

struct MVVMAjiwaiCardEditView: View {
    let card: AjiwaiCardData
    
    var body: some View {
        Text("MVVM Ajiwai Card Edit View")
            .navigationTitle("カード編集")
    }
}

struct MVVMCharacterSelectView: View {
    var body: some View {
        Text("MVVM Character Select View")
            .navigationTitle("キャラクター選択")
    }
}

struct MVVMCharacterDetailView: View {
    let character: Character
    
    var body: some View {
        Text("MVVM Character Detail View")
            .navigationTitle("キャラクター詳細")
    }
}

struct MVVMShopView: View {
    var body: some View {
        Text("MVVM Shop View")
            .navigationTitle("ショップ")
    }
}

struct MVVMShopCategoryView: View {
    let category: ShopCategory
    
    var body: some View {
        Text("MVVM Shop Category View")
            .navigationTitle(category.displayName)
    }
}

struct MVVMColumnListView: View {
    var body: some View {
        Text("MVVM Column List View")
            .navigationTitle("コラム一覧")
    }
}

struct MVVMColumnDetailView: View {
    let column: ColumnData
    
    var body: some View {
        Text("MVVM Column Detail View")
            .navigationTitle("コラム詳細")
    }
}

struct MVVMSettingsView: View {
    var body: some View {
        Text("MVVM Settings View")
            .navigationTitle("設定")
    }
}

struct MVVMProfileEditView: View {
    var body: some View {
        Text("MVVM Profile Edit View")
            .navigationTitle("プロフィール編集")
    }
}

struct MVVMDataExportView: View {
    var body: some View {
        Text("MVVM Data Export View")
            .navigationTitle("データエクスポート")
    }
}

struct MVVMQRScannerView: View {
    var body: some View {
        Text("MVVM QR Scanner View")
            .navigationTitle("QRスキャナー")
    }
}