import Foundation
import Combine

// MARK: - Character Service Protocol

protocol CharacterServiceProtocol {
    var characterCollection: AnyPublisher<CharacterCollection, Never> { get }
    var selectedCharacter: AnyPublisher<Character, Never> { get }
    
    func loadCharacterCollection() -> CharacterCollection
    func updateCharacterCollection(_ collection: CharacterCollection)
    func selectCharacter(named name: String)
    func getCharacter(named name: String) -> Character?
    func updateCharacter(_ character: Character)
    func addExpToCharacter(named name: String, exp: Int)
    func addPointsToCharacter(named name: String, points: Int)
    func spendPointsFromCharacter(named name: String, points: Int) -> Bool
    func growCharacter(named name: String) -> Bool
    func unlockAnimation(for characterName: String, animationName: String)
    func initCharacterData()
    func migrateFromUserData()
}

// MARK: - Character Service Implementation

@MainActor
class CharacterServiceImpl: ObservableObject, CharacterServiceProtocol {
    
    // MARK: - Published Properties
    @Published private var _characterCollection: CharacterCollection
    
    // MARK: - Publishers
    var characterCollection: AnyPublisher<CharacterCollection, Never> {
        $_characterCollection.eraseToAnyPublisher()
    }
    
    var selectedCharacter: AnyPublisher<Character, Never> {
        $_characterCollection
            .map { $0.selectedCharacter }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Dependencies
    private let userData: UserData
    
    // MARK: - Initialization
    init(userData: UserData) {
        self.userData = userData
        self._characterCollection = CharacterCollection()
        
        // Load existing data
        loadFromUserData()
    }
    
    // MARK: - Public Methods
    func loadCharacterCollection() -> CharacterCollection {
        return _characterCollection
    }
    
    func updateCharacterCollection(_ collection: CharacterCollection) {
        _characterCollection = collection
        syncToUserData()
    }
    
    func selectCharacter(named name: String) {
        _characterCollection.selectCharacter(name)
        userData.selectedCharacter = name
        userData.setCurrentCharacter()
        syncToUserData()
    }
    
    func getCharacter(named name: String) -> Character? {
        return _characterCollection.getCharacter(named: name)
    }
    
    func updateCharacter(_ character: Character) {
        _characterCollection.updateCharacter(character)
        syncToUserData()
    }
    
    func addExpToCharacter(named name: String, exp: Int) {
        guard let character = getCharacter(named: name) else { return }
        let updatedCharacter = character.addExp(exp)
        updateCharacter(updatedCharacter)
    }
    
    func addPointsToCharacter(named name: String, points: Int) {
        guard let character = getCharacter(named: name) else { return }
        let updatedCharacter = character.addPoints(points)
        updateCharacter(updatedCharacter)
    }
    
    func spendPointsFromCharacter(named name: String, points: Int) -> Bool {
        guard let character = getCharacter(named: name),
              let updatedCharacter = character.spendPoints(points) else {
            return false
        }
        updateCharacter(updatedCharacter)
        return true
    }
    
    func growCharacter(named name: String) -> Bool {
        guard let character = getCharacter(named: name),
              let updatedCharacter = character.growUp() else {
            return false
        }
        updateCharacter(updatedCharacter)
        return true
    }
    
    func unlockAnimation(for characterName: String, animationName: String) {
        guard let character = getCharacter(named: characterName) else { return }
        let updatedCharacter = character.unlockAnimation(animationName)
        updateCharacter(updatedCharacter)
    }
    
    func initCharacterData() {
        userData.initCharacterData()
        loadFromUserData()
    }
    
    func migrateFromUserData() {
        loadFromUserData()
    }
    
    // MARK: - Private Methods
    private func loadFromUserData() {
        // Create characters from UserData
        let dogCharacter = Character(
            name: "Dog",
            level: userData.DogData.level,
            exp: userData.DogData.exp,
            growthStage: userData.DogData.growthStage,
            point: userData.point
        )
        
        let catCharacter = Character(
            name: "Cat",
            level: userData.CatData.level,
            exp: userData.CatData.exp,
            growthStage: userData.CatData.growthStage,
            point: userData.point
        )
        
        let rabbitCharacter = Character(
            name: "Rabbit",
            level: userData.RabbitData.level,
            exp: userData.RabbitData.exp,
            growthStage: userData.RabbitData.growthStage,
            point: userData.point
        )
        
        var collection = CharacterCollection()
        collection.characters["Dog"] = dogCharacter
        collection.characters["Cat"] = catCharacter
        collection.characters["Rabbit"] = rabbitCharacter
        collection.selectedCharacterName = userData.selectedCharacter
        
        _characterCollection = collection
    }
    
    private func syncToUserData() {
        // Update UserData from collection
        let dog = _characterCollection.characters["Dog"] ?? Character(name: "Dog")
        let cat = _characterCollection.characters["Cat"] ?? Character(name: "Cat")
        let rabbit = _characterCollection.characters["Rabbit"] ?? Character(name: "Rabbit")
        
        userData.DogData = UserData.Character(
            name: dog.name,
            level: dog.level,
            exp: dog.exp,
            growthStage: dog.growthStage
        )
        
        userData.CatData = UserData.Character(
            name: cat.name,
            level: cat.level,
            exp: cat.exp,
            growthStage: cat.growthStage
        )
        
        userData.RabbitData = UserData.Character(
            name: rabbit.name,
            level: rabbit.level,
            exp: rabbit.exp,
            growthStage: rabbit.growthStage
        )
        
        userData.selectedCharacter = _characterCollection.selectedCharacterName
        userData.point = _characterCollection.selectedCharacter.point
        
        userData.setCurrentCharacter()
        userData.saveAllCharacter()
    }
}