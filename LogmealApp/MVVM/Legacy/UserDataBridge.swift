import Foundation
import SwiftUI
import Combine

/// 既存UserDataクラスとの互換性を保つためのブリッジクラス
/// 既存のViewが段階的にMVVMに移行できるように、既存のUserDataのAPIを維持
@MainActor
final class UserDataBridge: ObservableObject {
    
    // MARK: - Published Properties (既存UserDataと同じ)
    @Published var name: String = ""
    @Published var grade: String = ""
    @Published var yourClass: String = ""
    @Published var age: Int = 6
    @Published var gender: String = ""
    @Published var userImage: String?
    @Published var isLogined: Bool = false
    @Published var isTeacher: Bool = false
    @Published var lastRewardGotDate: String = ""
    @Published var onRecord: Bool = false
    @Published var isTitle: Bool = true
    @Published var point: Int = 0
    
    // ナビゲーション関連
    @Published var isDataSaved: Bool = false
    @Published var path: [Homepath] = []
    @Published var eventsDate: [Date] = []
    @Published var isDetailActive: Bool = false
    
    // キャラクター関連
    @Published var selectedCharacter: String = "Rabbit"
    @Published var inTrainingCharacter: String = "Rabbit"
    @Published var characterName: String = "Rabbit"
    @Published var level: Int = 0
    @Published var exp: Int = 10
    @Published var appearExp: Int = 0
    @Published var growthStage: Int = 1
    @Published var gotEXP: Int = 0
    @Published var isGrowthed: Bool = false
    @Published var isIncreasedLevel: Bool = false
    @Published var showGrowthAnimation: Bool = false
    @Published var showLevelUPAnimation: Bool = false
    @Published var showAnimation: Bool = false
    @Published var isCharacterDataMigrated: Bool = false
    @Published var isFirstCharacterChange: Bool = true
    
    @Published var RabbitData: Character = Character(name: "Rabbit", level: 0, exp: 0, growthStage: 0)
    @Published var DogData: Character = Character(name: "Dog", level: 0, exp: 0, growthStage: 0)
    @Published var CatData: Character = Character(name: "Cat", level: 0, exp: 0, growthStage: 0)
    @Published var currentCharacter: Character = Character(name: "Rabbit", level: 0, exp: 0, growthStage: 0)
    
    // アニメーション関連
    @Published var gifWidth: CGFloat = 0
    @Published var gifHeight: CGFloat = 0
    
    // MARK: - Constants (既存UserDataと同じ)
    let levelThresholds: [Int] = [0, 10, 20, 30, 50, 70, 90, 110, 130, 150, 170, 200, 220, 250, 290, 350]
    
    // MARK: - Dependencies
    private let userService: UserServiceProtocol
    private let characterService: CharacterServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        userService: UserServiceProtocol = DIContainer.shared.resolve(UserServiceProtocol.self),
        characterService: CharacterServiceProtocol = DIContainer.shared.resolve(CharacterServiceProtocol.self)
    ) {
        self.userService = userService
        self.characterService = characterService
        
        bindToServices()
        initCharacterData()
    }
    
    // MARK: - Service Binding
    private func bindToServices() {
        // UserServiceからの更新をPublishedプロパティに反映
        userService.userProfile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                self?.updateFromUserProfile(profile)
            }
            .store(in: &cancellables)
        
        // CharacterServiceからの更新をPublishedプロパティに反映
        characterService.characterData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.updateFromCharacterData(data)
            }
            .store(in: &cancellables)
        
        characterService.showAnimation
            .receive(on: DispatchQueue.main)
            .assign(to: \.showAnimation, on: self)
            .store(in: &cancellables)
        
        characterService.showGrowthAnimation
            .receive(on: DispatchQueue.main)
            .assign(to: \.showGrowthAnimation, on: self)
            .store(in: &cancellables)
        
        characterService.showLevelUpAnimation
            .receive(on: DispatchQueue.main)
            .assign(to: \.showLevelUpAnimation, on: self)
            .store(in: &cancellables)
    }
    
    private func updateFromUserProfile(_ profile: UserProfile) {
        name = profile.name
        grade = profile.grade
        yourClass = profile.yourClass
        age = profile.age
        gender = profile.gender
        userImage = profile.userImage
        isLogined = profile.isLogined
        isTeacher = profile.isTeacher
        point = profile.point
        lastRewardGotDate = profile.lastRewardGotDate
        onRecord = profile.onRecord
        isTitle = profile.isTitle
    }
    
    private func updateFromCharacterData(_ data: CharacterData) {
        selectedCharacter = data.selectedCharacter.rawValue
        inTrainingCharacter = data.inTrainingCharacter.rawValue
        characterName = data.characterName
        isCharacterDataMigrated = data.isCharacterDataMigrated
        isFirstCharacterChange = data.isFirstCharacterChange
        
        DogData = data.dogData
        CatData = data.catData
        RabbitData = data.rabbitData
        currentCharacter = data.currentCharacter
        
        // 個別プロパティも更新
        level = data.currentCharacter.level
        exp = data.currentCharacter.exp
        growthStage = data.currentCharacter.growthStage
    }
    
    // MARK: - 既存UserDataのメソッド互換性
    
    func checkTodayRewardLimit() -> Bool {
        return userService.checkTodayRewardLimit()
    }
    
    func dateFormatter(date: Date) -> String {
        UserProfile.dateFormatter(date: date)
    }
    
    func saveEscapedData(data: [EscapeData]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(data) {
            UserDefaults.standard.set(encoded, forKey: "escapedData")
        } else {
            print("一時保存に失敗しました")
        }
    }
    
    func loadEscapeData() -> [EscapeData]? {
        if let savedData = UserDefaults.standard.data(forKey: "escapedData") {
            let decoder = JSONDecoder()
            if let savedEscapeData = try? decoder.decode([EscapeData].self, from: savedData) {
                return savedEscapeData
            }
        }
        return []
    }
    
    func purchaseProduct(_ product: Product) -> Bool {
        return userService.spendPoints(product.price)
    }
    
    func saveProducts(products: [Product], key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(products) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func loadProducts(key: String) -> [Product] {
        if let savedData = UserDefaults.standard.data(forKey: key) {
            let decoder = JSONDecoder()
            if let savedProducts = try? decoder.decode([Product].self, from: savedData) {
                return savedProducts
            }
        }
        return []
    }
    
    func initCharacterData() {
        characterService.initCharacterData()
    }
    
    func setCurrentCharacter() {
        // CharacterServiceが自動的に処理するため、特に何もしない
    }
    
    func loadAllharacterData() {
        characterService.loadAllCharacterData()
    }
    
    func resetAllCharacterData() {
        characterService.resetAllCharacterData()
    }
    
    func saveAllCharacter() {
        characterService.saveAllCharacterData()
    }
    
    func migrateLegacyData() {
        characterService.migrateLegacyData()
    }
    
    func saveCharacterData(data: Character, key: String) {
        // CharacterServiceが自動的に処理するため、直接呼び出しは不要
    }
    
    func loadCharacterata(key: String) -> Character? {
        // CharacterServiceが自動的に処理するため、既存のデータを返す
        switch key {
        case "DogData": return DogData
        case "CatData": return CatData
        case "RabbitData": return RabbitData
        case "currentCharacter": return currentCharacter
        default: return nil
        }
    }
    
    func canSwitchCharacter(currentharacter: Character) -> SwitchStatus {
        return characterService.canSwitchCharacter(currentharacter)
    }
    
    func switchCharacter(switchStatus: SwitchStatus, targetCharacter: Character) {
        if switchStatus == .success {
            if let characterType = CharacterType(rawValue: targetCharacter.name) {
                let _ = characterService.switchCharacter(to: characterType)
            }
        }
    }
    
    func gainExp(_ amount: Int) {
        characterService.gainExp(amount)
    }
    
    func expProgressPercentage() -> Double {
        return currentCharacter.expProgressPercentage()
    }
    
    func expToNextLevel() -> Int {
        return currentCharacter.expToNextLevel()
    }
}

// MARK: - 互換性のための既存構造体定義（既にStructs.swiftにあるものと重複を避ける）
extension UserDataBridge {
    /// 互換性のため既存の構造を維持
    struct EscapeData: Codable {
        var saveDay: Date
        var lunchComments: String
        var sight: String
        var taste: String
        var smell: String
        var tactile: String
        var hearing: String
        var imagePath: URL
        var menu: [String]
    }
}