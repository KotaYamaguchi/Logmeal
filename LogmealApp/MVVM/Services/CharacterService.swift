import Foundation
import Combine

/// キャラクター管理サービス
protocol CharacterServiceProtocol: AnyObject {
    var characterData: CurrentValueSubject<CharacterData, Never> { get }
    var showAnimation: CurrentValueSubject<Bool, Never> { get }
    var showGrowthAnimation: CurrentValueSubject<Bool, Never> { get }
    var showLevelUpAnimation: CurrentValueSubject<Bool, Never> { get }
    
    func initCharacterData()
    func gainExp(_ amount: Int)
    func switchCharacter(to character: CharacterType) -> SwitchStatus
    func canSwitchCharacter(_ character: Character) -> SwitchStatus
    func saveAllCharacterData()
    func loadAllCharacterData()
    func migrateLegacyData()
    func resetAllCharacterData()
}

final class CharacterService: CharacterServiceProtocol, Injectable {
    let characterData = CurrentValueSubject<CharacterData, Never>(CharacterData())
    let showAnimation = CurrentValueSubject<Bool, Never>(false)
    let showGrowthAnimation = CurrentValueSubject<Bool, Never>(false)
    let showLevelUpAnimation = CurrentValueSubject<Bool, Never>(false)
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        initCharacterData()
    }
    
    static func register(in container: DIContainer) {
        container.register(CharacterServiceProtocol.self, instance: CharacterService())
    }
    
    func initCharacterData() {
        loadAllCharacterData()
        var data = characterData.value
        data.updateCurrentCharacter()
        characterData.send(data)
        saveAllCharacterData()
    }
    
    func gainExp(_ amount: Int) {
        print("--- 経験値追加処理を開始 ---")
        print("追加される経験値: \(amount)")
        
        var data = characterData.value
        data.currentCharacter.exp += amount
        
        print("経験値が追加されました。現在の経験値: \(data.currentCharacter.exp)")
        
        // レベルアップ判定
        let (leveledUp, grewUp) = performLevelUpCheck(&data.currentCharacter)
        
        if leveledUp {
            showLevelUpAnimation.send(true)
        }
        
        if grewUp {
            showGrowthAnimation.send(true)
        }
        
        if leveledUp || grewUp {
            showAnimation.send(true)
        }
        
        // データを保存
        data.saveCurrentCharacterChanges()
        characterData.send(data)
        saveAllCharacterData()
        
        print("--- 経験値追加処理を終了 ---")
    }
    
    func switchCharacter(to character: CharacterType) -> SwitchStatus {
        let data = characterData.value
        let targetCharacter: Character
        
        switch character {
        case .dog: targetCharacter = data.dogData
        case .cat: targetCharacter = data.catData
        case .rabbit: targetCharacter = data.rabbitData
        }
        
        let status = canSwitchCharacter(targetCharacter)
        
        if status == .success {
            var newData = data
            
            // 新しいキャラクターが初期状態の場合、growthStageを1に設定
            if targetCharacter.growthStage == 0 {
                switch character {
                case .dog:
                    newData.dogData.growthStage = 1
                case .cat:
                    newData.catData.growthStage = 1
                case .rabbit:
                    newData.rabbitData.growthStage = 1
                }
            }
            
            newData.selectedCharacter = character
            newData.characterName = character.rawValue
            newData.updateCurrentCharacter()
            
            characterData.send(newData)
            saveAllCharacterData()
            
            // UserDefaultsの既存キーも更新（互換性のため）
            userDefaults.set(character.rawValue, forKey: "selectedCharactar")
            userDefaults.set(character.rawValue, forKey: "CharactarName")
        }
        
        return status
    }
    
    func canSwitchCharacter(_ character: Character) -> SwitchStatus {
        return character.growthStage == 3 ? .success : .fails
    }
    
    func saveAllCharacterData() {
        let data = characterData.value
        
        saveCharacterData(data.currentCharacter, key: "currentCharacter")
        saveCharacterData(data.dogData, key: "DogData")
        saveCharacterData(data.catData, key: "CatData")
        saveCharacterData(data.rabbitData, key: "RabbitData")
        
        // その他の設定も保存
        userDefaults.set(data.selectedCharacter.rawValue, forKey: "selectedCharactar")
        userDefaults.set(data.inTrainingCharacter.rawValue, forKey: "inTrainingCharactar")
        userDefaults.set(data.characterName, forKey: "CharactarName")
        userDefaults.set(data.isCharacterDataMigrated, forKey: "isCharacterDataMigrated")
        userDefaults.set(data.isFirstCharacterChange, forKey: "isFirstCharacterChange")
    }
    
    func loadAllCharacterData() {
        let selectedCharacterString = userDefaults.string(forKey: "selectedCharactar") ?? "Rabbit"
        let selectedCharacter = CharacterType(rawValue: selectedCharacterString) ?? .rabbit
        
        let inTrainingCharacterString = userDefaults.string(forKey: "inTrainingCharactar") ?? "Rabbit"
        let inTrainingCharacter = CharacterType(rawValue: inTrainingCharacterString) ?? .rabbit
        
        let characterName = userDefaults.string(forKey: "CharactarName") ?? "Rabbit"
        let isCharacterDataMigrated = userDefaults.bool(forKey: "isCharacterDataMigrated")
        let isFirstCharacterChange = userDefaults.bool(forKey: "isFirstCharacterChange")
        
        let rabbitData = loadCharacterData(key: "RabbitData") ?? Character(name: "Rabbit", level: 0, exp: 0, growthStage: 0)
        let dogData = loadCharacterData(key: "DogData") ?? Character(name: "Dog", level: 0, exp: 0, growthStage: 0)
        let catData = loadCharacterData(key: "CatData") ?? Character(name: "Cat", level: 0, exp: 0, growthStage: 0)
        
        var data = CharacterData(
            selectedCharacter: selectedCharacter,
            inTrainingCharacter: inTrainingCharacter,
            characterName: characterName,
            isCharacterDataMigrated: isCharacterDataMigrated,
            isFirstCharacterChange: isFirstCharacterChange
        )
        
        data.dogData = dogData
        data.catData = catData
        data.rabbitData = rabbitData
        data.updateCurrentCharacter()
        
        characterData.send(data)
        
        print("=== Loaded Character Data ===")
        print("Selected Character: \(data.selectedCharacter.rawValue)")
        print("Current Character: \(data.currentCharacter.name), Level: \(data.currentCharacter.level), EXP: \(data.currentCharacter.exp), Growth: \(data.currentCharacter.growthStage)")
    }
    
    func migrateLegacyData() {
        var data = characterData.value
        
        print("Before isCharacterDataMigrated: \(data.isCharacterDataMigrated)")
        
        if data.isCharacterDataMigrated {
            loadAllCharacterData()
        } else {
            // 既存のUserDefaultsからデータを移行
            let level = userDefaults.integer(forKey: "level")
            let exp = userDefaults.integer(forKey: "exp")
            let growthStage = userDefaults.integer(forKey: "growthStage")
            
            switch data.selectedCharacter {
            case .rabbit:
                data.rabbitData.level = level
                data.rabbitData.exp = exp
                data.rabbitData.growthStage = growthStage
            case .dog:
                data.dogData.level = level
                data.dogData.exp = exp
                data.dogData.growthStage = growthStage
            case .cat:
                data.catData.level = level
                data.catData.exp = exp
                data.catData.growthStage = growthStage
            }
            
            data.isCharacterDataMigrated = true
            data.updateCurrentCharacter()
            characterData.send(data)
            saveAllCharacterData()
            
            print("Migration completed successfully.")
        }
    }
    
    func resetAllCharacterData() {
        var data = characterData.value
        data.dogData = Character(name: "Dog", level: 0, exp: 0, growthStage: 0)
        data.catData = Character(name: "Cat", level: 0, exp: 0, growthStage: 0)
        data.rabbitData = Character(name: "Rabbit", level: 0, exp: 0, growthStage: 0)
        data.updateCurrentCharacter()
        characterData.send(data)
        saveAllCharacterData()
    }
    
    // MARK: - Private Methods
    
    private func saveCharacterData(_ character: Character, key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(character) {
            userDefaults.set(encoded, forKey: key)
        } else {
            print("キャラクターデータの保存に失敗しました: \(key)")
        }
    }
    
    private func loadCharacterData(key: String) -> Character? {
        if let savedData = userDefaults.data(forKey: key) {
            let decoder = JSONDecoder()
            if let character = try? decoder.decode(Character.self, from: savedData) {
                return character
            }
        }
        return nil
    }
    
    private func performLevelUpCheck(_ character: inout Character) -> (leveledUp: Bool, grewUp: Bool) {
        var leveledUp = false
        var grewUp = false
        
        // 最大レベルに達している場合は何もしない
        guard !character.isMaxLevel else {
            print("最大レベルのため、レベルアップ判定は行いません。")
            return (false, false)
        }
        
        // レベルアップ処理
        while character.canLevelUp() {
            character.level += 1
            leveledUp = true
            print("レベルアップしました！現在のレベル: \(character.level)")
            
            // 特定レベルでの成長段階アップ
            if character.level == 5 && character.growthStage == 1 {
                character.growthStage = 2
                grewUp = true
                print("成長段階が2になりました！")
            } else if character.level == 10 && character.growthStage == 2 {
                character.growthStage = 3
                grewUp = true
                print("成長段階が3になりました！")
            }
            
            // 最大レベルに達した場合はループを終了
            if character.isMaxLevel {
                print("最大レベルに到達しました。")
                break
            }
        }
        
        return (leveledUp, grewUp)
    }
}