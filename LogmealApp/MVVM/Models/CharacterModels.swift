import Foundation
import SwiftUI

// MARK: - Character Models

/// Character data model
struct Character: Codable, Equatable, Identifiable {
    let id: UUID
    var name: String
    var level: Int
    var exp: Int
    var growthStage: Int
    var point: Int
    var isUnlocked: Bool
    var unlockedAnimations: Set<String>
    var purchasedItems: Set<String>
    
    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        name: String,
        level: Int = 0,
        exp: Int = 0,
        growthStage: Int = 0,
        point: Int = 0,
        isUnlocked: Bool = true,
        unlockedAnimations: Set<String> = [],
        purchasedItems: Set<String> = []
    ) {
        self.id = id
        self.name = name
        self.level = level
        self.exp = exp
        self.growthStage = growthStage
        self.point = point
        self.isUnlocked = isUnlocked
        self.unlockedAnimations = unlockedAnimations
        self.purchasedItems = purchasedItems
    }
    
    // MARK: - Computed Properties
    var displayName: String {
        switch name {
        case "Dog": return "いぬ"
        case "Cat": return "ねこ"
        case "Rabbit": return "うさぎ"
        default: return name
        }
    }
    
    var characterImageName: String {
        return "\(name)3"
    }
    
    var backgroundImageName: String {
        return "bg_home_\(name)"
    }
    
    var addButtonImageName: String {
        return "bt_add_\(name)"
    }
    
    var themeColor: Color {
        switch name {
        case "Dog": return Color(red: 248/255, green: 201/255, blue: 201/255)
        case "Cat": return Color(red: 198/255, green: 166/255, blue: 208/255)
        case "Rabbit": return Color(red: 251/255, green: 233/255, blue: 184/255)
        default: return .white
        }
    }
    
    var expRequiredForNextLevel: Int {
        return (level + 1) * 100 // Example calculation
    }
    
    var expProgress: Double {
        guard expRequiredForNextLevel > 0 else { return 0 }
        return Double(exp) / Double(expRequiredForNextLevel)
    }
    
    var maxGrowthStage: Int {
        return 3 // Assuming 3 growth stages
    }
    
    var canGrow: Bool {
        return growthStage < maxGrowthStage && level >= (growthStage + 1) * 10
    }
    
    // MARK: - Character Operations
    func addExp(_ amount: Int) -> Character {
        var updated = self
        updated.exp += amount
        
        // Level up if necessary
        while updated.exp >= updated.expRequiredForNextLevel {
            updated.exp -= updated.expRequiredForNextLevel
            updated.level += 1
        }
        
        return updated
    }
    
    func addPoints(_ amount: Int) -> Character {
        var updated = self
        updated.point = max(0, updated.point + amount)
        return updated
    }
    
    func spendPoints(_ amount: Int) -> Character? {
        guard point >= amount else { return nil }
        var updated = self
        updated.point -= amount
        return updated
    }
    
    func growUp() -> Character? {
        guard canGrow else { return nil }
        var updated = self
        updated.growthStage += 1
        return updated
    }
    
    func unlockAnimation(_ animationName: String) -> Character {
        var updated = self
        updated.unlockedAnimations.insert(animationName)
        return updated
    }
    
    func purchaseItem(_ itemName: String) -> Character {
        var updated = self
        updated.purchasedItems.insert(itemName)
        return updated
    }
}

// MARK: - Character Type
enum CharacterType: String, CaseIterable, Codable {
    case dog = "Dog"
    case cat = "Cat"
    case rabbit = "Rabbit"
    
    var displayName: String {
        switch self {
        case .dog: return "いぬ"
        case .cat: return "ねこ"
        case .rabbit: return "うさぎ"
        }
    }
    
    var defaultCharacter: Character {
        return Character(name: self.rawValue)
    }
    
    static var allCharacters: [Character] {
        return CharacterType.allCases.map { $0.defaultCharacter }
    }
}

// MARK: - Animation Model
struct CharacterAnimation: Codable, Equatable, Identifiable {
    let id: UUID
    var name: String
    var displayName: String
    var characterType: CharacterType
    var isUnlocked: Bool
    var imageName: String
    var gifFileName: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        displayName: String,
        characterType: CharacterType,
        isUnlocked: Bool = false,
        imageName: String = "",
        gifFileName: String? = nil
    ) {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.characterType = characterType
        self.isUnlocked = isUnlocked
        self.imageName = imageName
        self.gifFileName = gifFileName
    }
}

// MARK: - Character Evolution
struct CharacterEvolution: Codable {
    let stage: Int
    let requiredLevel: Int
    let requiredExp: Int
    let unlockMessage: String
    let newFeatures: [String]
    
    init(stage: Int, requiredLevel: Int, requiredExp: Int, unlockMessage: String, newFeatures: [String] = []) {
        self.stage = stage
        self.requiredLevel = requiredLevel
        self.requiredExp = requiredExp
        self.unlockMessage = unlockMessage
        self.newFeatures = newFeatures
    }
}

// MARK: - Character Collection
struct CharacterCollection: Codable {
    var characters: [String: Character]
    var selectedCharacterName: String
    
    init() {
        self.characters = [:]
        self.selectedCharacterName = "Rabbit"
        
        // Initialize default characters
        for type in CharacterType.allCases {
            characters[type.rawValue] = type.defaultCharacter
        }
    }
    
    var selectedCharacter: Character {
        get {
            return characters[selectedCharacterName] ?? CharacterType.rabbit.defaultCharacter
        }
        set {
            characters[selectedCharacterName] = newValue
        }
    }
    
    var allCharacters: [Character] {
        return Array(characters.values)
    }
    
    mutating func selectCharacter(_ name: String) {
        if characters[name] != nil {
            selectedCharacterName = name
        }
    }
    
    mutating func updateCharacter(_ character: Character) {
        characters[character.name] = character
    }
    
    func getCharacter(named name: String) -> Character? {
        return characters[name]
    }
}