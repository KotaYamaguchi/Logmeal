import Foundation

/// キャラクター情報
struct Character: Codable, Equatable, Identifiable {
    let id = UUID()
    var name: String
    var level: Int
    var exp: Int
    var growthStage: Int
    
    init(name: String, level: Int, exp: Int, growthStage: Int) {
        self.name = name
        self.level = level
        self.exp = exp
        self.growthStage = growthStage
    }
    
    /// レベル閾値（元のUserDataから移行）
    static let levelThresholds: [Int] = [0, 10, 20, 30, 50, 70, 90, 110, 130, 150, 170, 200, 220, 250, 290, 350]
    
    /// 次のレベルまでの経験値を取得
    func expToNextLevel() -> Int {
        guard level < Self.levelThresholds.count - 1 else { return 0 }
        let nextLevelThreshold = Self.levelThresholds[level + 1]
        return max(0, nextLevelThreshold - exp)
    }
    
    /// 経験値の進捗率を取得（0-100%）
    func expProgressPercentage() -> Double {
        guard level < Self.levelThresholds.count - 1 else { return 100.0 }
        
        let currentLevelThreshold = Self.levelThresholds[level]
        let nextLevelThreshold = Self.levelThresholds[level + 1]
        let totalExpForCurrentLevel = nextLevelThreshold - currentLevelThreshold
        
        guard totalExpForCurrentLevel > 0 else { return 0.0 }
        
        let expGainedInCurrentLevel = max(0, exp - currentLevelThreshold)
        return Double(expGainedInCurrentLevel) / Double(totalExpForCurrentLevel) * 100.0
    }
    
    /// レベルアップが可能かチェック
    func canLevelUp() -> Bool {
        guard level < Self.levelThresholds.count - 1 else { return false }
        return exp >= Self.levelThresholds[level + 1]
    }
    
    /// 最大レベルに達しているかチェック
    var isMaxLevel: Bool {
        return level >= Self.levelThresholds.count - 1
    }
}

/// キャラクター種別
enum CharacterType: String, CaseIterable, Codable {
    case dog = "Dog"
    case cat = "Cat"
    case rabbit = "Rabbit"
    
    var displayName: String {
        switch self {
        case .dog: return "レーク"
        case .cat: return "ティナ"
        case .rabbit: return "ラン"
        }
    }
    
    var defaultCharacter: Character {
        Character(name: self.rawValue, level: 0, exp: 0, growthStage: 0)
    }
}

/// キャラクター切り替えステータス
enum SwitchStatus: String {
    case success
    case fails
}

/// キャラクター管理データ
struct CharacterData: Codable, Equatable {
    var selectedCharacter: CharacterType
    var inTrainingCharacter: CharacterType
    var characterName: String
    var isCharacterDataMigrated: Bool
    var isFirstCharacterChange: Bool
    
    var dogData: Character
    var catData: Character
    var rabbitData: Character
    var currentCharacter: Character
    
    init(
        selectedCharacter: CharacterType = .rabbit,
        inTrainingCharacter: CharacterType = .rabbit,
        characterName: String = "Rabbit",
        isCharacterDataMigrated: Bool = false,
        isFirstCharacterChange: Bool = true
    ) {
        self.selectedCharacter = selectedCharacter
        self.inTrainingCharacter = inTrainingCharacter
        self.characterName = characterName
        self.isCharacterDataMigrated = isCharacterDataMigrated
        self.isFirstCharacterChange = isFirstCharacterChange
        
        self.dogData = CharacterType.dog.defaultCharacter
        self.catData = CharacterType.cat.defaultCharacter
        self.rabbitData = CharacterType.rabbit.defaultCharacter
        self.currentCharacter = selectedCharacter.defaultCharacter
    }
    
    /// 選択されたキャラクターを現在のキャラクターとして設定
    mutating func updateCurrentCharacter() {
        switch selectedCharacter {
        case .dog:
            currentCharacter = dogData
        case .cat:
            currentCharacter = catData
        case .rabbit:
            currentCharacter = rabbitData
        }
    }
    
    /// 現在のキャラクターの変更をデータに反映
    mutating func saveCurrentCharacterChanges() {
        switch selectedCharacter {
        case .dog:
            dogData = currentCharacter
        case .cat:
            catData = currentCharacter
        case .rabbit:
            rabbitData = currentCharacter
        }
    }
}