import Foundation
import SwiftUI
import SwiftData

/// アプリ全体のナビゲーションと状態を調整するコーディネーター
@MainActor
final class AppCoordinator: ObservableObject {
    @Published var isInitialized: Bool = false
    @Published var showLaunchScreen: Bool = true
    @Published var navigationPath: [AppDestination] = []
    @Published var currentTab: AppTab = .home
    
    private let container = DIContainer.shared
    
    func initialize(with modelContext: ModelContext) {
        guard !isInitialized else { return }
        
        // DIContainerにModelContextを設定
        container.setModelContext(modelContext)
        
        // 全サービスを登録
        registerServices()
        
        // 初期化完了
        isInitialized = true
        
        // レガシーデータの移行
        performLegacyDataMigration()
        
        print("AppCoordinator initialized successfully")
    }
    
    private func registerServices() {
        // Injectable protocolを実装したサービスを自動登録
        UserService.register(in: container)
        CharacterService.register(in: container)
        ShopService.register(in: container)
        AjiwaiCardService.register(in: container)
        ColumnService.register(in: container)
        MenuService.register(in: container)
        
        print("All services registered successfully")
    }
    
    private func performLegacyDataMigration() {
        let characterService = container.resolve(CharacterServiceProtocol.self)
        characterService.migrateLegacyData()
        
        print("Legacy data migration completed")
    }
    
    func navigateTo(_ destination: AppDestination) {
        navigationPath.append(destination)
    }
    
    func navigateBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    func navigateToRoot() {
        navigationPath.removeAll()
    }
    
    func switchTab(to tab: AppTab) {
        currentTab = tab
        navigateToRoot() // タブ切り替え時はナビゲーションスタックをクリア
    }
    
    func hideLaunchScreen() {
        withAnimation(.easeInOut(duration: 0.5)) {
            showLaunchScreen = false
        }
    }
}

/// アプリ内の画面遷移先を定義
enum AppDestination: Hashable {
    case home
    case ajiwaiCardCreate
    case ajiwaiCardDetail(AjiwaiCardData)
    case ajiwaiCardEdit(AjiwaiCardData)
    case characterSelect
    case characterDetail(Character)
    case shop
    case shopCategory(ShopCategory)
    case columnList
    case columnDetail(ColumnData)
    case settings
    case profileEdit
    case dataExport
    case qrScanner
}

/// アプリのタブを定義
enum AppTab: String, CaseIterable {
    case home = "home"
    case column = "column"
    case settings = "settings"
    
    var displayName: String {
        switch self {
        case .home: return "ホーム"
        case .column: return "コラム"
        case .settings: return "せってい"
        }
    }
    
    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .column: return "book.fill"
        case .settings: return "gearshape.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .home: return .pink
        case .column: return .orange
        case .settings: return .blue
        }
    }
}