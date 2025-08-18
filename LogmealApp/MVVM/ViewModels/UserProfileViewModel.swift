import Foundation
import SwiftUI
import Combine

// MARK: - User Profile ViewModel

@MainActor
class UserProfileViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var userProfile: UserProfile
    @Published var userPreferences: UserPreferences
    @Published var userStatistics: UserStatistics
    @Published var isEditing: Bool = false
    @Published var showingImagePicker: Bool = false
    @Published var validationMessage: String = ""
    @Published var showValidationAlert: Bool = false
    
    // MARK: - Services
    private let userService: UserServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        let container = DIContainer.shared
        self.userService = container.userService
        
        // Initialize with current data
        self.userProfile = userService.loadUserProfile()
        self.userPreferences = userService.loadUserPreferences()
        self.userStatistics = userService.loadUserStatistics()
        
        // Subscribe to service updates
        setupSubscriptions()
    }
    
    // MARK: - Public Methods
    func startEditing() {
        isEditing = true
    }
    
    func cancelEditing() {
        isEditing = false
        // Reload current data
        userProfile = userService.loadUserProfile()
    }
    
    func saveProfile() {
        guard validateProfile() else { return }
        
        userService.updateUserProfile(userProfile)
        isEditing = false
        
        print("✅ プロフィールを保存しました")
    }
    
    func updatePreferences() {
        userService.updateUserPreferences(userPreferences)
        print("✅ 設定を更新しました")
    }
    
    func resetUserData() {
        userService.resetUserData()
        print("✅ ユーザーデータをリセットしました")
    }
    
    func canReceiveTodayReward() -> Bool {
        return userService.checkTodayRewardLimit()
    }
    
    func updateRewardDate() {
        userService.updateRewardDate()
        userProfile = userService.loadUserProfile()
    }
    
    // MARK: - Computed Properties
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
    
    var displayName: String {
        return userProfile.displayName
    }
    
    var displayGrade: String {
        return userProfile.gradeDisplayText
    }
    
    var displayClass: String {
        return userProfile.classDisplayText
    }
    
    // MARK: - Validation
    private func validateProfile() -> Bool {
        var errors: [String] = []
        
        if userProfile.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("名前を入力してください")
        }
        
        if userProfile.grade.isEmpty {
            errors.append("学年を選択してください")
        }
        
        if userProfile.yourClass.isEmpty {
            errors.append("クラスを選択してください")
        }
        
        if userProfile.gender.isEmpty {
            errors.append("性別を選択してください")
        }
        
        if userProfile.age < 1 || userProfile.age > 100 {
            errors.append("正しい年齢を入力してください")
        }
        
        if !errors.isEmpty {
            validationMessage = errors.joined(separator: "\n")
            showValidationAlert = true
            return false
        }
        
        return true
    }
    
    // MARK: - Private Methods
    private func setupSubscriptions() {
        userService.userProfile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                if self?.isEditing == false {
                    self?.userProfile = profile
                }
            }
            .store(in: &cancellables)
        
        userService.userPreferences
            .receive(on: DispatchQueue.main)
            .sink { [weak self] preferences in
                self?.userPreferences = preferences
            }
            .store(in: &cancellables)
        
        userService.userStatistics
            .receive(on: DispatchQueue.main)
            .sink { [weak self] statistics in
                self?.userStatistics = statistics
            }
            .store(in: &cancellables)
    }
}