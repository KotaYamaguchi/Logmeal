import Foundation
import SwiftUI
import Combine

// MARK: - Character ViewModel

@MainActor
class CharacterViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var characterCollection: CharacterCollection
    @Published var selectedCharacter: Character
    @Published var showCharacterDetail: Bool = false
    @Published var showCharacterSelection: Bool = false
    @Published var showAnimation: Bool = false
    @Published var currentAnimation: String = ""
    @Published var showGrowthAnimation: Bool = false
    
    // MARK: - Services
    private let characterService: CharacterServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        let container = DIContainer.shared
        self.characterService = container.characterService
        
        // Initialize with current data
        self.characterCollection = characterService.loadCharacterCollection()
        self.selectedCharacter = characterCollection.selectedCharacter
        
        // Subscribe to service updates
        setupSubscriptions()
    }
    
    // MARK: - Character Selection
    func selectCharacter(named name: String) {
        characterService.selectCharacter(named: name)
        print("✅ キャラクターを選択しました: \(name)")
    }
    
    func showCharacterSelectionView() {
        showCharacterSelection = true
    }
    
    func hideCharacterSelectionView() {
        showCharacterSelection = false
    }
    
    // MARK: - Character Development
    func addExpToCurrentCharacter(_ exp: Int) {
        addExpToCharacter(named: selectedCharacter.name, exp: exp)
    }
    
    func addExpToCharacter(named name: String, exp: Int) {
        characterService.addExpToCharacter(named: name, exp: exp)
        print("✅ 経験値を追加しました: \(name) +\(exp)EXP")
    }
    
    func addPointsToCurrentCharacter(_ points: Int) {
        addPointsToCharacter(named: selectedCharacter.name, points: points)
    }
    
    func addPointsToCharacter(named name: String, points: Int) {
        characterService.addPointsToCharacter(named: name, points: points)
        print("✅ ポイントを追加しました: \(name) +\(points)P")
    }
    
    func spendPointsFromCurrentCharacter(_ points: Int) -> Bool {
        return spendPointsFromCharacter(named: selectedCharacter.name, points: points)
    }
    
    func spendPointsFromCharacter(named name: String, points: Int) -> Bool {
        let success = characterService.spendPointsFromCharacter(named: name, points: points)
        if success {
            print("✅ ポイントを消費しました: \(name) -\(points)P")
        } else {
            print("❌ ポイントが不足しています: \(name)")
        }
        return success
    }
    
    func growCurrentCharacter() -> Bool {
        return growCharacter(named: selectedCharacter.name)
    }
    
    func growCharacter(named name: String) -> Bool {
        let success = characterService.growCharacter(named: name)
        if success {
            showGrowthAnimation = true
            print("✅ キャラクターが成長しました: \(name)")
        } else {
            print("❌ 成長条件を満たしていません: \(name)")
        }
        return success
    }
    
    // MARK: - Animations
    func playAnimation(_ animationName: String) {
        currentAnimation = animationName
        showAnimation = true
        
        // Auto-hide animation after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.hideAnimation()
        }
    }
    
    func hideAnimation() {
        showAnimation = false
        currentAnimation = ""
    }
    
    func hideGrowthAnimation() {
        showGrowthAnimation = false
    }
    
    func unlockAnimation(for characterName: String, animationName: String) {
        characterService.unlockAnimation(for: characterName, animationName: animationName)
        print("✅ アニメーションをアンロックしました: \(characterName) - \(animationName)")
    }
    
    // MARK: - Character Info
    func getCharacter(named name: String) -> Character? {
        return characterService.getCharacter(named: name)
    }
    
    func getAllCharacters() -> [Character] {
        return characterCollection.allCharacters
    }
    
    func initCharacterData() {
        characterService.initCharacterData()
    }
    
    // MARK: - Computed Properties
    var currentCharacterName: String {
        return selectedCharacter.name
    }
    
    var currentCharacterDisplayName: String {
        return selectedCharacter.displayName
    }
    
    var currentCharacterLevel: Int {
        return selectedCharacter.level
    }
    
    var currentCharacterExp: Int {
        return selectedCharacter.exp
    }
    
    var currentCharacterPoints: Int {
        return selectedCharacter.point
    }
    
    var currentCharacterGrowthStage: Int {
        return selectedCharacter.growthStage
    }
    
    var currentCharacterThemeColor: Color {
        return selectedCharacter.themeColor
    }
    
    var currentCharacterImageName: String {
        return selectedCharacter.characterImageName
    }
    
    var currentCharacterBackgroundImageName: String {
        return selectedCharacter.backgroundImageName
    }
    
    var currentCharacterAddButtonImageName: String {
        return selectedCharacter.addButtonImageName
    }
    
    var expProgress: Double {
        return selectedCharacter.expProgress
    }
    
    var canGrow: Bool {
        return selectedCharacter.canGrow
    }
    
    var expRequiredForNextLevel: Int {
        return selectedCharacter.expRequiredForNextLevel
    }
    
    // MARK: - Private Methods
    private func setupSubscriptions() {
        characterService.characterCollection
            .receive(on: DispatchQueue.main)
            .sink { [weak self] collection in
                self?.characterCollection = collection
            }
            .store(in: &cancellables)
        
        characterService.selectedCharacter
            .receive(on: DispatchQueue.main)
            .sink { [weak self] character in
                self?.selectedCharacter = character
            }
            .store(in: &cancellables)
    }
}