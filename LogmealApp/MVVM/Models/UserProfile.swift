import Foundation

// MARK: - User Profile Models

/// User profile information model
struct UserProfile: Codable, Equatable {
    let id: UUID
    var name: String
    var grade: String
    var yourClass: String
    var age: Int
    var gender: String
    var userImage: String?
    var isLogined: Bool
    var isTeacher: Bool
    var onRecord: Bool
    var selectedCharacter: String
    var lastRewardGotDate: String
    
    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        name: String = "",
        grade: String = "",
        yourClass: String = "",
        age: Int = 6,
        gender: String = "",
        userImage: String? = nil,
        isLogined: Bool = false,
        isTeacher: Bool = false,
        onRecord: Bool = false,
        selectedCharacter: String = "Rabbit",
        lastRewardGotDate: String = ""
    ) {
        self.id = id
        self.name = name
        self.grade = grade
        self.yourClass = yourClass
        self.age = age
        self.gender = gender
        self.userImage = userImage
        self.isLogined = isLogined
        self.isTeacher = isTeacher
        self.onRecord = onRecord
        self.selectedCharacter = selectedCharacter
        self.lastRewardGotDate = lastRewardGotDate
    }
    
    // MARK: - Computed Properties
    var displayName: String {
        return name.isEmpty ? "未設定" : name
    }
    
    var gradeDisplayText: String {
        return grade.isEmpty ? "未設定" : "\(grade)年生"
    }
    
    var classDisplayText: String {
        return yourClass.isEmpty ? "未設定" : "\(yourClass)組"
    }
    
    var canReceiveTodayReward: Bool {
        let today = dateFormatter(date: Date())
        return lastRewardGotDate != today
    }
    
    // MARK: - Helper Methods
    private func dateFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    func withUpdatedRewardDate() -> UserProfile {
        var updated = self
        updated.lastRewardGotDate = dateFormatter(date: Date())
        return updated
    }
}

// MARK: - User Preferences
struct UserPreferences: Codable, Equatable {
    var isBGMOn: Bool
    var isSoundEffectOn: Bool
    var isNotificationEnabled: Bool
    var preferredLanguage: String
    var isFirstLaunch: Bool
    var hasCompletedTutorial: Bool
    
    init(
        isBGMOn: Bool = true,
        isSoundEffectOn: Bool = true,
        isNotificationEnabled: Bool = false,
        preferredLanguage: String = "ja_JP",
        isFirstLaunch: Bool = true,
        hasCompletedTutorial: Bool = false
    ) {
        self.isBGMOn = isBGMOn
        self.isSoundEffectOn = isSoundEffectOn
        self.isNotificationEnabled = isNotificationEnabled
        self.preferredLanguage = preferredLanguage
        self.isFirstLaunch = isFirstLaunch
        self.hasCompletedTutorial = hasCompletedTutorial
    }
}

// MARK: - User Statistics
struct UserStatistics: Codable, Equatable {
    var totalAjiwaiCards: Int
    var totalPlayDays: Int
    var favoriteCharacter: String
    var lastActiveDate: Date?
    var streakDays: Int
    
    init(
        totalAjiwaiCards: Int = 0,
        totalPlayDays: Int = 0,
        favoriteCharacter: String = "Rabbit",
        lastActiveDate: Date? = nil,
        streakDays: Int = 0
    ) {
        self.totalAjiwaiCards = totalAjiwaiCards
        self.totalPlayDays = totalPlayDays
        self.favoriteCharacter = favoriteCharacter
        self.lastActiveDate = lastActiveDate
        self.streakDays = streakDays
    }
}