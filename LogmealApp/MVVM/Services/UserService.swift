import Foundation
import Combine

// MARK: - User Service Protocol

protocol UserServiceProtocol {
    var userProfile: AnyPublisher<UserProfile, Never> { get }
    var userPreferences: AnyPublisher<UserPreferences, Never> { get }
    var userStatistics: AnyPublisher<UserStatistics, Never> { get }
    
    func loadUserProfile() -> UserProfile
    func updateUserProfile(_ profile: UserProfile)
    func loadUserPreferences() -> UserPreferences
    func updateUserPreferences(_ preferences: UserPreferences)
    func loadUserStatistics() -> UserStatistics
    func updateUserStatistics(_ statistics: UserStatistics)
    func checkTodayRewardLimit() -> Bool
    func updateRewardDate()
    func resetUserData()
}

// MARK: - User Service Implementation

@MainActor
class UserServiceImpl: ObservableObject, UserServiceProtocol {
    
    // MARK: - Published Properties
    @Published private var _userProfile: UserProfile
    @Published private var _userPreferences: UserPreferences
    @Published private var _userStatistics: UserStatistics
    
    // MARK: - Publishers
    var userProfile: AnyPublisher<UserProfile, Never> {
        $_userProfile.eraseToAnyPublisher()
    }
    
    var userPreferences: AnyPublisher<UserPreferences, Never> {
        $_userPreferences.eraseToAnyPublisher()
    }
    
    var userStatistics: AnyPublisher<UserStatistics, Never> {
        $_userStatistics.eraseToAnyPublisher()
    }
    
    // MARK: - Dependencies
    private let userData: UserData
    
    // MARK: - Initialization
    init(userData: UserData) {
        self.userData = userData
        
        // Initialize from UserData
        self._userProfile = UserProfile(
            name: userData.name,
            grade: userData.grade,
            yourClass: userData.yourClass,
            age: userData.age,
            gender: userData.gender,
            userImage: userData.userImage,
            isLogined: userData.isLogined,
            isTeacher: userData.isTeacher,
            onRecord: userData.onRecord,
            selectedCharacter: userData.selectedCharacter,
            lastRewardGotDate: userData.lastRewardGotDate
        )
        
        self._userPreferences = UserPreferences()
        self._userStatistics = UserStatistics()
        
        // Sync with UserData
        syncWithUserData()
    }
    
    // MARK: - Public Methods
    func loadUserProfile() -> UserProfile {
        return _userProfile
    }
    
    func updateUserProfile(_ profile: UserProfile) {
        _userProfile = profile
        syncToUserData()
    }
    
    func loadUserPreferences() -> UserPreferences {
        return _userPreferences
    }
    
    func updateUserPreferences(_ preferences: UserPreferences) {
        _userPreferences = preferences
    }
    
    func loadUserStatistics() -> UserStatistics {
        return _userStatistics
    }
    
    func updateUserStatistics(_ statistics: UserStatistics) {
        _userStatistics = statistics
    }
    
    func checkTodayRewardLimit() -> Bool {
        return userData.checkTodayRewardLimit()
    }
    
    func updateRewardDate() {
        let today = dateFormatter(date: Date())
        var updated = _userProfile
        updated.lastRewardGotDate = today
        updateUserProfile(updated)
    }
    
    func resetUserData() {
        let defaultProfile = UserProfile()
        let defaultPreferences = UserPreferences()
        let defaultStatistics = UserStatistics()
        
        updateUserProfile(defaultProfile)
        updateUserPreferences(defaultPreferences)
        updateUserStatistics(defaultStatistics)
        
        syncToUserData()
    }
    
    // MARK: - Private Methods
    private func syncWithUserData() {
        // Update profile from UserData
        var profile = _userProfile
        profile.name = userData.name
        profile.grade = userData.grade
        profile.yourClass = userData.yourClass
        profile.age = userData.age
        profile.gender = userData.gender
        profile.userImage = userData.userImage
        profile.isLogined = userData.isLogined
        profile.isTeacher = userData.isTeacher
        profile.onRecord = userData.onRecord
        profile.selectedCharacter = userData.selectedCharacter
        profile.lastRewardGotDate = userData.lastRewardGotDate
        
        _userProfile = profile
    }
    
    private func syncToUserData() {
        // Update UserData from profile
        userData.name = _userProfile.name
        userData.grade = _userProfile.grade
        userData.yourClass = _userProfile.yourClass
        userData.age = _userProfile.age
        userData.gender = _userProfile.gender
        userData.userImage = _userProfile.userImage
        userData.isLogined = _userProfile.isLogined
        userData.isTeacher = _userProfile.isTeacher
        userData.onRecord = _userProfile.onRecord
        userData.selectedCharacter = _userProfile.selectedCharacter
        userData.lastRewardGotDate = _userProfile.lastRewardGotDate
    }
    
    private func dateFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}