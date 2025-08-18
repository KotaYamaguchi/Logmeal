import Foundation
import SwiftData
import Combine

/// ユーザープロフィールとポイント管理サービス
protocol UserServiceProtocol: AnyObject {
    var userProfile: CurrentValueSubject<UserProfile, Never> { get }
    
    func updateProfile(_ profile: UserProfile)
    func addPoints(_ points: Int)
    func spendPoints(_ points: Int) -> Bool
    func checkTodayRewardLimit() -> Bool
    func saveProfile()
    func loadProfile()
}

final class UserService: UserServiceProtocol, Injectable {
    let userProfile = CurrentValueSubject<UserProfile, Never>(UserProfile())
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadProfile()
    }
    
    static func register(in container: DIContainer) {
        container.register(UserServiceProtocol.self, instance: UserService())
    }
    
    func updateProfile(_ profile: UserProfile) {
        userProfile.send(profile)
        saveProfile()
    }
    
    func addPoints(_ points: Int) {
        var current = userProfile.value
        current.point += points
        userProfile.send(current)
        saveProfile()
    }
    
    func spendPoints(_ points: Int) -> Bool {
        let current = userProfile.value
        guard current.point >= points else { return false }
        
        var updated = current
        updated.point -= points
        userProfile.send(updated)
        saveProfile()
        return true
    }
    
    func checkTodayRewardLimit() -> Bool {
        let current = userProfile.value
        let canGetReward = current.checkTodayRewardLimit()
        
        if canGetReward {
            var updated = current
            updated.lastRewardGotDate = UserProfile.dateFormatter(date: Date())
            userProfile.send(updated)
            saveProfile()
        }
        
        return canGetReward
    }
    
    func saveProfile() {
        let profile = userProfile.value
        
        // AppStorageで使われていたキーを維持
        userDefaults.set(profile.name, forKey: "name")
        userDefaults.set(profile.grade, forKey: "grade")
        userDefaults.set(profile.yourClass, forKey: "class")
        userDefaults.set(profile.age, forKey: "age")
        userDefaults.set(profile.gender, forKey: "sex")
        userDefaults.set(profile.userImage, forKey: "userImage")
        userDefaults.set(profile.isLogined, forKey: "isLogined")
        userDefaults.set(profile.point, forKey: "point")
        userDefaults.set(profile.lastRewardGotDate, forKey: "lastPointAddedDate")
        userDefaults.set(profile.onRecord, forKey: "onRecord")
    }
    
    func loadProfile() {
        let profile = UserProfile(
            name: userDefaults.string(forKey: "name") ?? "",
            grade: userDefaults.string(forKey: "grade") ?? "",
            yourClass: userDefaults.string(forKey: "class") ?? "",
            age: userDefaults.integer(forKey: "age"),
            gender: userDefaults.string(forKey: "sex") ?? "",
            userImage: userDefaults.string(forKey: "userImage"),
            isLogined: userDefaults.bool(forKey: "isLogined"),
            isTeacher: false, // これはPublishedプロパティだったので保存しない
            point: userDefaults.integer(forKey: "point"),
            lastRewardGotDate: userDefaults.string(forKey: "lastPointAddedDate") ?? "",
            onRecord: userDefaults.bool(forKey: "onRecord"),
            isTitle: true // これもPublishedプロパティだったので保存しない
        )
        
        userProfile.send(profile)
    }
}