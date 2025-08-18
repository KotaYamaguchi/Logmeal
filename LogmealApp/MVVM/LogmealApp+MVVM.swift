import SwiftUI
import SwiftData

// MARK: - MVVM Integration Extension for LogmealApp

extension LogmealApp {
    
    // MARK: - MVVM Setup
    static func setupMVVM(modelContext: ModelContext, userData: UserData) {
        DIContainer.shared.setup(modelContext: modelContext, userData: userData)
        print("✅ MVVM architecture initialized successfully")
    }
}

// MARK: - MVVM App Entry Point

@MainActor
struct MVVMLogmealApp: View {
    @StateObject private var coordinator = AppCoordinator()
    @StateObject private var userData = UserData()
    @StateObject private var bgmManager = BGMManager.shared
    
    @Environment(\.modelContext) private var modelContext
    @Query private var allData: [AjiwaiCardData]
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            contentView
                .navigationDestination(for: AppView.self) { view in
                    destinationView(for: view)
                }
        }
        .sheet(item: $coordinator.presentedSheet) { sheet in
            sheetView(for: sheet)
        }
        .fullScreenCover(item: $coordinator.presentedFullScreen) { fullScreen in
            fullScreenView(for: fullScreen)
        }
        .alert("エラー", isPresented: $coordinator.showError) {
            Button("OK") {
                coordinator.dismissError()
            }
        } message: {
            Text(coordinator.errorMessage)
        }
        .onAppear {
            setupMVVMIfNeeded()
            performDataMigration()
            coordinator.initializeApp()
            setupBGM()
        }
        .onDisappear {
            bgmManager.stopBGM()
        }
        .environmentObject(coordinator)
        .environmentObject(userData)
    }
    
    // MARK: - Content View
    @ViewBuilder
    private var contentView: some View {
        switch coordinator.currentView {
        case .launch:
            LaunchScreen()
        case .title:
            TitleView()
        case .firstLogin:
            FirstLoginView()
        case .profileSetup:
            FirstProfileSetView()
        case .home:
            MVVMHomeView()
        case .profile:
            MVVMProfileView()
        case .character:
            MVVMCharacterView()
        case .shop:
            MVVMShopView()
        case .column:
            MVVMColumnView()
        case .settings:
            MVVMSettingsView()
        case .ajiwaiCardDetail(let card):
            AjiwaiCardDetailView(card: card)
        case .columnDetail(let column):
            ColumnDetailView(column: column)
        }
    }
    
    // MARK: - Navigation Destinations
    @ViewBuilder
    private func destinationView(for view: AppView) -> some View {
        switch view {
        case .home:
            MVVMHomeView()
        case .profile:
            MVVMProfileView()
        case .character:
            MVVMCharacterView()
        case .shop:
            MVVMShopView()
        case .column:
            MVVMColumnView()
        case .settings:
            MVVMSettingsView()
        case .ajiwaiCardDetail(let card):
            AjiwaiCardDetailView(card: card)
        case .columnDetail(let column):
            ColumnDetailView(column: column)
        default:
            EmptyView()
        }
    }
    
    // MARK: - Sheet Views
    @ViewBuilder
    private func sheetView(for sheet: AppSheet) -> some View {
        switch sheet {
        case .ajiwaiCardCreate:
            MVVMAjiwaiCardCreateView()
        case .characterSelection:
            MVVMCharacterSelectionView()
        case .characterDetail:
            MVVMCharacterDetailView()
        case .shopPurchase:
            MVVMShopPurchaseView()
        case .profileEditor:
            MVVMProfileEditorView()
        case .dataExport:
            MVVMDataExportView()
        case .privacyPolicy:
            PrivacyPolicyView()
        case .termsOfService:
            TermsOfServiceView()
        case .about:
            AboutAppView()
        }
    }
    
    // MARK: - Full Screen Views
    @ViewBuilder
    private func fullScreenView(for fullScreen: AppFullScreen) -> some View {
        switch fullScreen {
        case .qrScanner:
            MVVMQRScannerView()
        case .tutorial:
            TutorialView()
        case .characterAnimation:
            CharacterAnimationView()
        }
    }
    
    // MARK: - Setup Methods
    private func setupMVVMIfNeeded() {
        if !DIContainer.shared.modelContext != nil {
            LogmealApp.setupMVVM(modelContext: modelContext, userData: userData)
        }
    }
    
    private func performDataMigration() {
        // Perform any necessary data migration for existing users
        for card in allData {
            if card.uuid == nil {
                card.uuid = UUID()
                print("Migration: Added UUID to card")
            }
            if card.time == nil {
                card.time = .lunch
                print("Migration: Added default time to card")
            }
        }
        
        do {
            try modelContext.save()
            print("✅ Data migration completed successfully")
        } catch {
            print("❌ Data migration failed: \(error)")
        }
    }
    
    private func setupBGM() {
        if bgmManager.isBGMOn {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                bgmManager.playBGM()
            }
        }
    }
}

// MARK: - MVVM View Placeholders

// These are placeholder views that will be implemented to use the MVVM ViewModels
// They will replace the existing views gradually

struct MVVMHomeView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel: AjiwaiCardViewModel
    @StateObject private var characterViewModel: CharacterViewModel
    
    init() {
        let container = DIContainer.shared
        self._viewModel = StateObject(wrappedValue: AjiwaiCardViewModel())
        self._characterViewModel = StateObject(wrappedValue: CharacterViewModel())
    }
    
    var body: some View {
        // This will use the existing NewHomeView but with MVVM ViewModels
        NewHomeView()
    }
}

struct MVVMProfileView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel: UserProfileViewModel
    
    init() {
        self._viewModel = StateObject(wrappedValue: UserProfileViewModel())
    }
    
    var body: some View {
        ProfileSettingView()
    }
}

struct MVVMCharacterView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel: CharacterViewModel
    
    init() {
        self._viewModel = StateObject(wrappedValue: CharacterViewModel())
    }
    
    var body: some View {
        NewCharactarView()
    }
}

struct MVVMShopView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel: ShopViewModel
    
    init() {
        self._viewModel = StateObject(wrappedValue: ShopViewModel())
    }
    
    var body: some View {
        NewShopView()
    }
}

struct MVVMColumnView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel: ColumnViewModel
    
    init() {
        self._viewModel = StateObject(wrappedValue: ColumnViewModel())
    }
    
    var body: some View {
        // This will be a new column list view
        Text("Column List View")
    }
}

struct MVVMSettingsView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel: SettingsViewModel
    
    init() {
        self._viewModel = StateObject(wrappedValue: SettingsViewModel())
    }
    
    var body: some View {
        NewSettingView()
    }
}

// Additional placeholder views
struct MVVMAjiwaiCardCreateView: View {
    var body: some View {
        // This will use LogWritingView with MVVM ViewModel
        Text("AjiwaiCard Create View")
    }
}

struct MVVMCharacterSelectionView: View {
    var body: some View {
        CharacterSelectedView()
    }
}

struct MVVMCharacterDetailView: View {
    var body: some View {
        CharacterDetailView()
    }
}

struct MVVMShopPurchaseView: View {
    var body: some View {
        Text("Shop Purchase View")
    }
}

struct MVVMProfileEditorView: View {
    var body: some View {
        ProfileSettingView()
    }
}

struct MVVMDataExportView: View {
    var body: some View {
        Text("Data Export View")
    }
}

struct MVVMQRScannerView: View {
    var body: some View {
        Text("QR Scanner View")
    }
}

struct AjiwaiCardDetailView: View {
    let card: AjiwaiCardData
    
    var body: some View {
        Text("AjiwaiCard Detail View")
    }
}

struct ColumnDetailView: View {
    let column: ColumnData
    
    var body: some View {
        Text("Column Detail View")
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        Text("Privacy Policy View")
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        Text("Terms of Service View")
    }
}

struct AboutAppView: View {
    var body: some View {
        Text("About App View")
    }
}