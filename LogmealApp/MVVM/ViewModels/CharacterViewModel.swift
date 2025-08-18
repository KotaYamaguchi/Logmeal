import Foundation
import SwiftUI
import Combine

/// キャラクター状態管理ViewModel
@MainActor
final class CharacterViewModel: ObservableObject {
    @Published var characterData: CharacterData = CharacterData()
    @Published var showAnimation: Bool = false
    @Published var showGrowthAnimation: Bool = false
    @Published var showLevelUpAnimation: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let characterService: CharacterServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // UI用の計算プロパティ
    var currentCharacter: Character {
        characterData.currentCharacter
    }
    
    var displayContentColor: Color {
        switch currentCharacter.name {
        case "Dog": return Color(red: 248/255, green: 201/255, blue: 201/255)
        case "Cat": return Color(red: 198/255, green: 166/255, blue: 208/255)
        case "Rabbit": return Color(red: 251/255, green: 233/255, blue: 184/255)
        default: return .white
        }
    }
    
    var backgroundImageName: String {
        return "bg_home_\(currentCharacter.name)"
    }
    
    var addButtonImageName: String {
        return "bt_add_\(currentCharacter.name)"
    }
    
    var characterDisplayName: String {
        switch currentCharacter.name {
        case "Dog": return "レーク"
        case "Cat": return "ティナ"
        case "Rabbit": return "ラン"
        default: return "レーク"
        }
    }
    
    var expProgressPercentage: Double {
        currentCharacter.expProgressPercentage()
    }
    
    var expToNextLevel: Int {
        currentCharacter.expToNextLevel()
    }
    
    var canSwitchToOtherCharacters: Bool {
        currentCharacter.growthStage == 3
    }
    
    init(characterService: CharacterServiceProtocol = DIContainer.shared.resolve(CharacterServiceProtocol.self)) {
        self.characterService = characterService
        bindToService()
    }
    
    private func bindToService() {
        characterService.characterData
            .receive(on: DispatchQueue.main)
            .assign(to: \.characterData, on: self)
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
    
    func initCharacterData() {
        characterService.initCharacterData()
    }
    
    func gainExp(_ amount: Int) {
        characterService.gainExp(amount)
    }
    
    func switchCharacter(to character: CharacterType) -> SwitchStatus {
        return characterService.switchCharacter(to: character)
    }
    
    func canSwitchCharacter(_ character: Character) -> SwitchStatus {
        return characterService.canSwitchCharacter(character)
    }
    
    func dismissAnimation() {
        characterService.showAnimation.send(false)
        characterService.showGrowthAnimation.send(false)
        characterService.showLevelUpAnimation.send(false)
    }
    
    func dismissGrowthAnimation() {
        characterService.showGrowthAnimation.send(false)
        characterService.showAnimation.send(false)
    }
    
    func dismissLevelUpAnimation() {
        characterService.showLevelUpAnimation.send(false)
        characterService.showAnimation.send(false)
    }
    
    func resetAllCharacterData() {
        characterService.resetAllCharacterData()
    }
    
    // キャラクター別のGIFアニメーション名を取得
    func getCharacterGifName(animation: String = "breath") -> String {
        return "\(currentCharacter.name)\(currentCharacter.growthStage)_animation_\(animation)"
    }
    
    // キャラクター別の背景画像名を取得
    func getCharacterBackgroundImageName() -> String {
        return "mt_RewardView_callout_\(currentCharacter.name)"
    }
    
    // キャラクター別のウィンドウ画像名を取得
    func getCharacterWindowImageName() -> String {
        return "\(currentCharacter.name)_window_\(currentCharacter.growthStage)"
    }
    
    // 全キャラクターのデータを取得（キャラクター選択画面用）
    func getAllCharacters() -> [Character] {
        return [characterData.dogData, characterData.catData, characterData.rabbitData]
    }
    
    // レガシーデータの移行
    func migrateLegacyData() {
        characterService.migrateLegacyData()
    }
}