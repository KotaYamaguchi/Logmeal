import Foundation
import SwiftUI
import Combine

// MARK: - UserData Bridge for Legacy Compatibility

/// Bridge class that maintains compatibility with existing UserData while integrating with MVVM
/// This allows for gradual migration without breaking existing functionality
@MainActor
class UserDataBridge: ObservableObject {
    
    // MARK: - Dependencies
    private let userService: UserServiceProtocol
    private let characterService: CharacterServiceProtocol
    private let originalUserData: UserData
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(userService: UserServiceProtocol, characterService: CharacterServiceProtocol, originalUserData: UserData) {
        self.userService = userService
        self.characterService = characterService
        self.originalUserData = originalUserData
        
        setupBidirectionalSync()
    }
    
    // MARK: - Bidirectional Sync Setup
    private func setupBidirectionalSync() {
        // Sync from MVVM services to UserData
        syncFromServicesToUserData()
        
        // Sync from UserData to MVVM services
        syncFromUserDataToServices()
        
        print("✅ UserDataBridge: Bidirectional sync established")
    }
    
    // MARK: - Service to UserData Sync
    private func syncFromServicesToUserData() {
        // User profile changes
        userService.userProfile
            .sink { [weak self] profile in
                self?.updateUserDataFromProfile(profile)
            }
            .store(in: &cancellables)
        
        // Character collection changes
        characterService.characterCollection
            .sink { [weak self] collection in
                self?.updateUserDataFromCharacterCollection(collection)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - UserData to Service Sync
    private func syncFromUserDataToServices() {
        // Monitor UserData changes and sync to services
        // This is done through manual sync calls for now
        // Could be enhanced with Publishers if UserData is modified
    }
    
    // MARK: - Profile Sync Methods
    private func updateUserDataFromProfile(_ profile: UserProfile) {
        guard profile != convertUserDataToProfile() else { return }
        
        originalUserData.name = profile.name
        originalUserData.grade = profile.grade
        originalUserData.yourClass = profile.yourClass
        originalUserData.age = profile.age
        originalUserData.gender = profile.gender
        originalUserData.userImage = profile.userImage
        originalUserData.isLogined = profile.isLogined
        originalUserData.isTeacher = profile.isTeacher
        originalUserData.onRecord = profile.onRecord
        originalUserData.selectedCharacter = profile.selectedCharacter
        originalUserData.lastRewardGotDate = profile.lastRewardGotDate
        
        print("🔄 UserDataBridge: Profile synced to UserData")
    }
    
    private func convertUserDataToProfile() -> UserProfile {
        return UserProfile(
            name: originalUserData.name,
            grade: originalUserData.grade,
            yourClass: originalUserData.yourClass,
            age: originalUserData.age,
            gender: originalUserData.gender,
            userImage: originalUserData.userImage,
            isLogined: originalUserData.isLogined,
            isTeacher: originalUserData.isTeacher,
            onRecord: originalUserData.onRecord,
            selectedCharacter: originalUserData.selectedCharacter,
            lastRewardGotDate: originalUserData.lastRewardGotDate
        )
    }
    
    // MARK: - Character Sync Methods
    private func updateUserDataFromCharacterCollection(_ collection: CharacterCollection) {
        guard collection != convertUserDataToCharacterCollection() else { return }
        
        // Update character data
        if let dog = collection.characters["Dog"] {
            originalUserData.DogData = originalUserData.Character(
                name: dog.name,
                level: dog.level,
                exp: dog.exp,
                growthStage: dog.growthStage
            )
        }
        
        if let cat = collection.characters["Cat"] {
            originalUserData.CatData = originalUserData.Character(
                name: cat.name,
                level: cat.level,
                exp: cat.exp,
                growthStage: cat.growthStage
            )
        }
        
        if let rabbit = collection.characters["Rabbit"] {
            originalUserData.RabbitData = originalUserData.Character(
                name: rabbit.name,
                level: rabbit.level,
                exp: rabbit.exp,
                growthStage: rabbit.growthStage
            )
        }
        
        // Update selected character and points
        originalUserData.selectedCharacter = collection.selectedCharacterName
        originalUserData.point = collection.selectedCharacter.point
        
        // Update current character
        originalUserData.setCurrentCharacter()
        originalUserData.saveAllCharacter()
        
        print("🔄 UserDataBridge: Characters synced to UserData")
    }
    
    private func convertUserDataToCharacterCollection() -> CharacterCollection {
        var collection = CharacterCollection()
        
        collection.characters["Dog"] = Character(
            name: "Dog",
            level: originalUserData.DogData.level,
            exp: originalUserData.DogData.exp,
            growthStage: originalUserData.DogData.growthStage,
            point: originalUserData.point
        )
        
        collection.characters["Cat"] = Character(
            name: "Cat",
            level: originalUserData.CatData.level,
            exp: originalUserData.CatData.exp,
            growthStage: originalUserData.CatData.growthStage,
            point: originalUserData.point
        )
        
        collection.characters["Rabbit"] = Character(
            name: "Rabbit",
            level: originalUserData.RabbitData.level,
            exp: originalUserData.RabbitData.exp,
            growthStage: originalUserData.RabbitData.growthStage,
            point: originalUserData.point
        )
        
        collection.selectedCharacterName = originalUserData.selectedCharacter
        
        return collection
    }
    
    // MARK: - Manual Sync Methods
    func syncUserDataToServices() {
        // Force sync from UserData to services
        let profile = convertUserDataToProfile()
        userService.updateUserProfile(profile)
        
        let characterCollection = convertUserDataToCharacterCollection()
        characterService.updateCharacterCollection(characterCollection)
        
        print("🔄 UserDataBridge: Manual sync from UserData to services completed")
    }
    
    func syncServicesToUserData() {
        // Force sync from services to UserData
        let profile = userService.loadUserProfile()
        updateUserDataFromProfile(profile)
        
        let characterCollection = characterService.loadCharacterCollection()
        updateUserDataFromCharacterCollection(characterCollection)
        
        print("🔄 UserDataBridge: Manual sync from services to UserData completed")
    }
    
    // MARK: - Legacy Method Wrappers
    /// Wrapper methods that maintain the original UserData interface while using MVVM services
    
    func initCharacterData() {
        originalUserData.initCharacterData()
        syncUserDataToServices()
    }
    
    func saveAllCharacter() {
        originalUserData.saveAllCharacter()
        syncUserDataToServices()
    }
    
    func migrateLegacyData() {
        originalUserData.migrateLegacyData()
        syncUserDataToServices()
    }
    
    func checkTodayRewardLimit() -> Bool {
        return userService.checkTodayRewardLimit()
    }
    
    func dateFormatter(date: Date) -> String {
        return originalUserData.dateFormatter(date: date)
    }
    
    // MARK: - Bridge Status
    var isSynced: Bool {
        let currentProfile = convertUserDataToProfile()
        let serviceProfile = userService.loadUserProfile()
        
        let currentCharacters = convertUserDataToCharacterCollection()
        let serviceCharacters = characterService.loadCharacterCollection()
        
        return currentProfile == serviceProfile && 
               currentCharacters.selectedCharacterName == serviceCharacters.selectedCharacterName
    }
    
    func validateSync() -> [String] {
        var issues: [String] = []
        
        let currentProfile = convertUserDataToProfile()
        let serviceProfile = userService.loadUserProfile()
        
        if currentProfile != serviceProfile {
            issues.append("Profile data is out of sync")
        }
        
        let currentCharacters = convertUserDataToCharacterCollection()
        let serviceCharacters = characterService.loadCharacterCollection()
        
        if currentCharacters.selectedCharacterName != serviceCharacters.selectedCharacterName {
            issues.append("Character selection is out of sync")
        }
        
        return issues
    }
}

// MARK: - Bridge Factory

class UserDataBridgeFactory {
    static func createBridge(for userData: UserData) -> UserDataBridge {
        let container = DIContainer.shared
        let userService = container.userService
        let characterService = container.characterService
        
        return UserDataBridge(
            userService: userService,
            characterService: characterService,
            originalUserData: userData
        )
    }
}

// MARK: - Equatable Extensions for Comparison

extension UserProfile: Equatable {
    public static func == (lhs: UserProfile, rhs: UserProfile) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.grade == rhs.grade &&
               lhs.yourClass == rhs.yourClass &&
               lhs.age == rhs.age &&
               lhs.gender == rhs.gender &&
               lhs.userImage == rhs.userImage &&
               lhs.isLogined == rhs.isLogined &&
               lhs.isTeacher == rhs.isTeacher &&
               lhs.onRecord == rhs.onRecord &&
               lhs.selectedCharacter == rhs.selectedCharacter &&
               lhs.lastRewardGotDate == rhs.lastRewardGotDate
    }
}

extension CharacterCollection: Equatable {
    public static func == (lhs: CharacterCollection, rhs: CharacterCollection) -> Bool {
        return lhs.selectedCharacterName == rhs.selectedCharacterName &&
               lhs.characters.keys.sorted() == rhs.characters.keys.sorted() &&
               lhs.characters.allSatisfy { key, value in
                   rhs.characters[key] == value
               }
    }
}