import Foundation
import SwiftUI
import Combine

// MARK: - App Coordinator

@MainActor
class AppCoordinator: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentView: AppView = .launch
    @Published var isInitialized: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    // MARK: - Navigation State
    @Published var navigationPath: [AppView] = []
    @Published var presentedSheet: AppSheet?
    @Published var presentedFullScreen: AppFullScreen?
    
    // MARK: - ViewModels
    @Published var userProfileViewModel: UserProfileViewModel?
    @Published var characterViewModel: CharacterViewModel?
    @Published var shopViewModel: ShopViewModel?
    @Published var ajiwaiCardViewModel: AjiwaiCardViewModel?
    @Published var columnViewModel: ColumnViewModel?
    @Published var qrScannerViewModel: QRScannerViewModel?
    @Published var settingsViewModel: SettingsViewModel?
    @Published var exportViewModel: ExportViewModel?
    
    // MARK: - Dependencies
    private let container = DIContainer.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        setupViewModelObservation()
    }
    
    // MARK: - App Lifecycle
    func initializeApp() {
        guard !isInitialized else { return }
        
        // Initialize all ViewModels
        initializeViewModels()
        
        // Check if user is logged in
        let userProfile = container.userService.loadUserProfile()
        
        if userProfile.isLogined {
            navigateToHome()
        } else {
            navigateToFirstLogin()
        }
        
        isInitialized = true
        print("✅ AppCoordinator: アプリケーションが初期化されました")
    }
    
    private func initializeViewModels() {
        userProfileViewModel = UserProfileViewModel()
        characterViewModel = CharacterViewModel()
        shopViewModel = ShopViewModel()
        ajiwaiCardViewModel = AjiwaiCardViewModel()
        columnViewModel = ColumnViewModel()
        qrScannerViewModel = QRScannerViewModel()
        settingsViewModel = SettingsViewModel()
        exportViewModel = ExportViewModel()
    }
    
    // MARK: - Navigation Methods
    func navigateToLaunch() {
        currentView = .launch
        clearNavigation()
    }
    
    func navigateToTitle() {
        currentView = .title
        clearNavigation()
    }
    
    func navigateToFirstLogin() {
        currentView = .firstLogin
        clearNavigation()
    }
    
    func navigateToHome() {
        currentView = .home
        clearNavigation()
    }
    
    func navigateToProfile() {
        currentView = .profile
        clearNavigation()
    }
    
    func navigateToCharacter() {
        currentView = .character
        clearNavigation()
    }
    
    func navigateToShop() {
        currentView = .shop
        clearNavigation()
    }
    
    func navigateToColumn() {
        currentView = .column
        clearNavigation()
    }
    
    func navigateToSettings() {
        currentView = .settings
        clearNavigation()
    }
    
    func pushView(_ view: AppView) {
        navigationPath.append(view)
    }
    
    func popView() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    func popToRoot() {
        navigationPath.removeAll()
    }
    
    private func clearNavigation() {
        navigationPath.removeAll()
        presentedSheet = nil
        presentedFullScreen = nil
    }
    
    // MARK: - Sheet Presentation
    func presentSheet(_ sheet: AppSheet) {
        presentedSheet = sheet
    }
    
    func dismissSheet() {
        presentedSheet = nil
    }
    
    // MARK: - Full Screen Presentation
    func presentFullScreen(_ fullScreen: AppFullScreen) {
        presentedFullScreen = fullScreen
    }
    
    func dismissFullScreen() {
        presentedFullScreen = nil
    }
    
    // MARK: - AjiwaiCard Creation Flow
    func startAjiwaiCardCreation() {
        presentSheet(.ajiwaiCardCreate)
    }
    
    func completeAjiwaiCardCreation() {
        dismissSheet()
        // Refresh home view or show success animation
        characterViewModel?.showAnimation = true
    }
    
    // MARK: - Character Actions
    func selectCharacter(_ characterName: String) {
        characterViewModel?.selectCharacter(named: characterName)
        navigateToHome()
    }
    
    func showCharacterDetail() {
        presentSheet(.characterDetail)
    }
    
    // MARK: - Shop Actions
    func openShop() {
        navigateToShop()
    }
    
    func purchaseProduct(_ product: ShopProduct) {
        shopViewModel?.selectProduct(product)
    }
    
    // MARK: - QR Scanner
    func startQRScanning() {
        presentFullScreen(.qrScanner)
    }
    
    func handleQRScanResult() {
        dismissFullScreen()
        // Show success message or navigate to appropriate view
    }
    
    // MARK: - Settings Actions
    func openSettings() {
        navigateToSettings()
    }
    
    func showDataExport() {
        presentSheet(.dataExport)
    }
    
    func showPrivacyPolicy() {
        presentSheet(.privacyPolicy)
    }
    
    func showTermsOfService() {
        presentSheet(.termsOfService)
    }
    
    // MARK: - Error Handling
    func handleError(_ error: Error, message: String? = nil) {
        errorMessage = message ?? error.localizedDescription
        showError = true
        print("❌ AppCoordinator Error: \(errorMessage)")
    }
    
    func dismissError() {
        showError = false
        errorMessage = ""
    }
    
    // MARK: - User Login Flow
    func completeUserLogin() {
        var profile = container.userService.loadUserProfile()
        profile.isLogined = true
        container.userService.updateUserProfile(profile)
        
        navigateToHome()
        print("✅ ユーザーログインが完了しました")
    }
    
    func logout() {
        var profile = container.userService.loadUserProfile()
        profile.isLogined = false
        container.userService.updateUserProfile(profile)
        
        navigateToTitle()
        print("✅ ユーザーがログアウトしました")
    }
    
    // MARK: - Private Methods
    private func setupViewModelObservation() {
        // This can be used to observe ViewModel changes and react accordingly
        // For example, navigating when certain conditions are met
    }
}

// MARK: - App Navigation Types

enum AppView: Hashable {
    case launch
    case title
    case firstLogin
    case profileSetup
    case home
    case profile
    case character
    case shop
    case column
    case settings
    case ajiwaiCardDetail(AjiwaiCardData)
    case columnDetail(ColumnData)
}

enum AppSheet: Identifiable {
    case ajiwaiCardCreate
    case characterSelection
    case characterDetail
    case shopPurchase
    case profileEditor
    case dataExport
    case privacyPolicy
    case termsOfService
    case about
    
    var id: String {
        return String(describing: self)
    }
}

enum AppFullScreen: Identifiable {
    case qrScanner
    case tutorial
    case characterAnimation
    
    var id: String {
        return String(describing: self)
    }
}