import Foundation
import SwiftUI
import Combine

// MARK: - Settings ViewModel

@MainActor
class SettingsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var userProfile: UserProfile
    @Published var userPreferences: UserPreferences
    @Published var showProfileEditor: Bool = false
    @Published var showResetConfirmation: Bool = false
    @Published var showDataExport: Bool = false
    @Published var showAboutApp: Bool = false
    @Published var showPrivacyPolicy: Bool = false
    @Published var showTermsOfService: Bool = false
    @Published var isResetting: Bool = false
    @Published var resetMessage: String = ""
    @Published var showResetResult: Bool = false
    
    // MARK: - Services
    private let userService: UserServiceProtocol
    private let ajiwaiCardService: AjiwaiCardServiceProtocol
    private let characterService: CharacterServiceProtocol
    private let shopService: ShopServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - App Information
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    // MARK: - Initialization
    init() {
        let container = DIContainer.shared
        self.userService = container.userService
        self.ajiwaiCardService = container.ajiwaiCardService
        self.characterService = container.characterService
        self.shopService = container.shopService
        
        // Initialize with current data
        self.userProfile = userService.loadUserProfile()
        self.userPreferences = userService.loadUserPreferences()
        
        // Subscribe to service updates
        setupSubscriptions()
    }
    
    // MARK: - Profile Management
    func showProfileEditor() {
        showProfileEditor = true
    }
    
    func hideProfileEditor() {
        showProfileEditor = false
    }
    
    // MARK: - Preferences Management
    func toggleBGM() {
        userPreferences.isBGMOn.toggle()
        userService.updateUserPreferences(userPreferences)
        
        // Apply BGM setting immediately
        if userPreferences.isBGMOn {
            BGMManager.shared.playBGM()
        } else {
            BGMManager.shared.stopBGM()
        }
        
        print("✅ BGM設定を変更しました: \(userPreferences.isBGMOn)")
    }
    
    func toggleSoundEffect() {
        userPreferences.isSoundEffectOn.toggle()
        userService.updateUserPreferences(userPreferences)
        print("✅ 効果音設定を変更しました: \(userPreferences.isSoundEffectOn)")
    }
    
    func toggleNotification() {
        userPreferences.isNotificationEnabled.toggle()
        userService.updateUserPreferences(userPreferences)
        print("✅ 通知設定を変更しました: \(userPreferences.isNotificationEnabled)")
    }
    
    // MARK: - Data Management
    func showResetConfirmation() {
        showResetConfirmation = true
    }
    
    func hideResetConfirmation() {
        showResetConfirmation = false
    }
    
    func resetAllData() {
        isResetting = true
        
        do {
            // Reset all user data
            userService.resetUserData()
            
            // Reset all character data
            characterService.initCharacterData()
            
            // Reset all shop data for each character
            shopService.resetShopData(for: "Dog")
            shopService.resetShopData(for: "Cat")
            shopService.resetShopData(for: "Rabbit")
            
            // Reset all AjiwaiCard data and images
            try ajiwaiCardService.resetAllAjiwaiCardDataAndImages()
            
            resetMessage = "全てのデータをリセットしました。"
            
            print("✅ 全てのデータをリセットしました")
            
        } catch {
            resetMessage = "データのリセットに失敗しました: \(error.localizedDescription)"
            print("❌ データのリセットに失敗しました: \(error)")
        }
        
        isResetting = false
        showResetConfirmation = false
        showResetResult = true
    }
    
    func dismissResetResult() {
        showResetResult = false
        resetMessage = ""
    }
    
    // MARK: - Export and Import
    func showDataExportView() {
        showDataExport = true
    }
    
    func hideDataExportView() {
        showDataExport = false
    }
    
    // MARK: - Information Views
    func showAboutAppView() {
        showAboutApp = true
    }
    
    func hideAboutAppView() {
        showAboutApp = false
    }
    
    func showPrivacyPolicyView() {
        showPrivacyPolicy = true
    }
    
    func hidePrivacyPolicyView() {
        showPrivacyPolicy = false
    }
    
    func showTermsOfServiceView() {
        showTermsOfService = true
    }
    
    func hideTermsOfServiceView() {
        showTermsOfService = false
    }
    
    // MARK: - Computed Properties
    var appDisplayVersion: String {
        return "バージョン \(appVersion) (\(buildNumber))"
    }
    
    var userDisplayName: String {
        return userProfile.displayName
    }
    
    var profileCompletionPercentage: Double {
        var completedFields = 0
        let totalFields = 5
        
        if !userProfile.name.isEmpty { completedFields += 1 }
        if !userProfile.grade.isEmpty { completedFields += 1 }
        if !userProfile.yourClass.isEmpty { completedFields += 1 }
        if !userProfile.gender.isEmpty { completedFields += 1 }
        if userProfile.userImage != nil { completedFields += 1 }
        
        return Double(completedFields) / Double(totalFields)
    }
    
    var profileCompletionText: String {
        let percentage = Int(profileCompletionPercentage * 100)
        return "プロフィール完成度: \(percentage)%"
    }
    
    var selectedCharacterName: String {
        return userProfile.selectedCharacter
    }
    
    var isProfileComplete: Bool {
        return profileCompletionPercentage >= 1.0
    }
    
    // MARK: - Statistics
    func getAppUsageStatistics() -> [String: Any] {
        return [
            "total_cards": ajiwaiCardService.getAjiwaiCardsCount(),
            "profile_completion": profileCompletionPercentage,
            "selected_character": userProfile.selectedCharacter,
            "days_since_registration": daysSinceRegistration(),
            "app_version": appVersion
        ]
    }
    
    private func daysSinceRegistration() -> Int {
        // This is a placeholder - you might want to track actual registration date
        return 0
    }
    
    // MARK: - Private Methods
    private func setupSubscriptions() {
        userService.userProfile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                self?.userProfile = profile
            }
            .store(in: &cancellables)
        
        userService.userPreferences
            .receive(on: DispatchQueue.main)
            .sink { [weak self] preferences in
                self?.userPreferences = preferences
            }
            .store(in: &cancellables)
    }
}