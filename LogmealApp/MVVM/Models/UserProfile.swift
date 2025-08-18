import Foundation

/// ユーザープロフィール情報
struct UserProfile: Codable, Equatable {
    var name: String
    var grade: String
    var yourClass: String
    var age: Int
    var gender: String
    var userImage: String?
    var isLogined: Bool
    var isTeacher: Bool
    var point: Int
    var lastRewardGotDate: String
    var onRecord: Bool
    var isTitle: Bool
    
    init(
        name: String = "",
        grade: String = "",
        yourClass: String = "",
        age: Int = 6,
        gender: String = "",
        userImage: String? = nil,
        isLogined: Bool = false,
        isTeacher: Bool = false,
        point: Int = 0,
        lastRewardGotDate: String = "",
        onRecord: Bool = false,
        isTitle: Bool = true
    ) {
        self.name = name
        self.grade = grade
        self.yourClass = yourClass
        self.age = age
        self.gender = gender
        self.userImage = userImage
        self.isLogined = isLogined
        self.isTeacher = isTeacher
        self.point = point
        self.lastRewardGotDate = lastRewardGotDate
        self.onRecord = onRecord
        self.isTitle = isTitle
    }
    
    /// 日付フォーマッター
    static func dateFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    /// 今日のリワード制限チェック
    func checkTodayRewardLimit() -> Bool {
        let today = UserProfile.dateFormatter(date: Date())
        return lastRewardGotDate != today
    }
}