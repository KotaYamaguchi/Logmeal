import Foundation
import SwiftUI
import Combine

/// ユーザープロフィール管理ViewModel
@MainActor
final class UserProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile = UserProfile()
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let userService: UserServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(userService: UserServiceProtocol = DIContainer.shared.resolve(UserServiceProtocol.self)) {
        self.userService = userService
        bindToService()
    }
    
    private func bindToService() {
        userService.userProfile
            .receive(on: DispatchQueue.main)
            .assign(to: \.userProfile, on: self)
            .store(in: &cancellables)
    }
    
    func updateProfile(
        name: String? = nil,
        grade: String? = nil,
        yourClass: String? = nil,
        age: Int? = nil,
        gender: String? = nil,
        userImage: String? = nil
    ) {
        var updated = userProfile
        
        if let name = name { updated.name = name }
        if let grade = grade { updated.grade = grade }
        if let yourClass = yourClass { updated.yourClass = yourClass }
        if let age = age { updated.age = age }
        if let gender = gender { updated.gender = gender }
        if let userImage = userImage { updated.userImage = userImage }
        
        userService.updateProfile(updated)
    }
    
    func addPoints(_ points: Int) {
        userService.addPoints(points)
    }
    
    func spendPoints(_ points: Int) -> Bool {
        return userService.spendPoints(points)
    }
    
    func checkTodayRewardLimit() -> Bool {
        return userService.checkTodayRewardLimit()
    }
    
    func markAsLoggedIn() {
        var updated = userProfile
        updated.isLogined = true
        userService.updateProfile(updated)
    }
    
    func setTeacherMode(_ isTeacher: Bool) {
        var updated = userProfile
        updated.isTeacher = isTeacher
        userService.updateProfile(updated)
    }
    
    func toggleRecordingMode() {
        var updated = userProfile
        updated.onRecord.toggle()
        userService.updateProfile(updated)
    }
    
    func setTitleMode(_ isTitle: Bool) {
        var updated = userProfile
        updated.isTitle = isTitle
        userService.updateProfile(updated)
    }
}