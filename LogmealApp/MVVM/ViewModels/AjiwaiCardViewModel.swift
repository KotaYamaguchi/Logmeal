import Foundation
import SwiftUI
import SwiftData
import Combine

// MARK: - AjiwaiCard ViewModel

@MainActor
class AjiwaiCardViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var ajiwaiCards: [AjiwaiCardData] = []
    @Published var selectedCard: AjiwaiCardData?
    @Published var showDetailView: Bool = false
    @Published var showCreateView: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    
    // MARK: - Services
    private let ajiwaiCardService: AjiwaiCardServiceProtocol
    private let characterService: CharacterServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        let container = DIContainer.shared
        self.ajiwaiCardService = container.ajiwaiCardService
        self.characterService = container.characterService
        
        // Subscribe to service updates
        setupSubscriptions()
        
        // Load initial data
        fetchAjiwaiCards()
    }
    
    // MARK: - Data Management
    func fetchAjiwaiCards() {
        isLoading = true
        
        DispatchQueue.main.async {
            self.ajiwaiCards = self.ajiwaiCardService.fetchAjiwaiCards()
            self.isLoading = false
        }
    }
    
    func saveAjiwaiCard(_ card: AjiwaiCardData) {
        do {
            try ajiwaiCardService.saveAjiwaiCard(card)
            
            // Award experience and points to current character
            awardExpAndPoints()
            
            print("✅ 味わいカードを保存しました")
        } catch {
            handleError("味わいカードの保存に失敗しました: \(error.localizedDescription)")
        }
    }
    
    func deleteAjiwaiCard(_ card: AjiwaiCardData) {
        do {
            try ajiwaiCardService.deleteAjiwaiCard(card)
            print("✅ 味わいカードを削除しました")
        } catch {
            handleError("味わいカードの削除に失敗しました: \(error.localizedDescription)")
        }
    }
    
    func deleteAllAjiwaiCards() {
        do {
            try ajiwaiCardService.deleteAllAjiwaiCards()
            print("✅ 全ての味わいカードを削除しました")
        } catch {
            handleError("味わいカードの全削除に失敗しました: \(error.localizedDescription)")
        }
    }
    
    func resetAllAjiwaiCardDataAndImages() {
        do {
            try ajiwaiCardService.resetAllAjiwaiCardDataAndImages()
            print("✅ 全ての味わいカードデータと画像を削除しました")
        } catch {
            handleError("データのリセットに失敗しました: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Card Selection and Navigation
    func selectCard(_ card: AjiwaiCardData) {
        selectedCard = card
        showDetailView = true
    }
    
    func selectCard(at index: Int) {
        guard index < ajiwaiCards.count else { return }
        selectCard(ajiwaiCards[index])
    }
    
    func dismissDetailView() {
        selectedCard = nil
        showDetailView = false
    }
    
    func showCreateCardView() {
        showCreateView = true
    }
    
    func dismissCreateView() {
        showCreateView = false
    }
    
    // MARK: - Data Queries
    func getAjiwaiCard(by uuid: UUID) -> AjiwaiCardData? {
        return ajiwaiCardService.getAjiwaiCard(by: uuid)
    }
    
    func getAjiwaiCards(for date: Date) -> [AjiwaiCardData] {
        return ajiwaiCardService.getAjiwaiCards(for: date)
    }
    
    func getAjiwaiCardsCount() -> Int {
        return ajiwaiCardService.getAjiwaiCardsCount()
    }
    
    // MARK: - Computed Properties
    var hasAjiwaiCards: Bool {
        return !ajiwaiCards.isEmpty
    }
    
    var logCount: Int {
        return ajiwaiCards.count
    }
    
    var recentCards: [AjiwaiCardData] {
        return Array(ajiwaiCards.prefix(5))
    }
    
    var todaysCards: [AjiwaiCardData] {
        let today = Date()
        return getAjiwaiCards(for: today)
    }
    
    var hasTodaysCards: Bool {
        return !todaysCards.isEmpty
    }
    
    // MARK: - Statistics
    func getCardsGroupedByDate() -> [String: [AjiwaiCardData]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return Dictionary(grouping: ajiwaiCards) { card in
            formatter.string(from: card.saveDay)
        }
    }
    
    func getCardsByMonth(_ month: Int, year: Int) -> [AjiwaiCardData] {
        let calendar = Calendar.current
        return ajiwaiCards.filter { card in
            let components = calendar.dateComponents([.month, .year], from: card.saveDay)
            return components.month == month && components.year == year
        }
    }
    
    func getUniqueDates() -> Set<Date> {
        let calendar = Calendar.current
        return Set(ajiwaiCards.map { card in
            calendar.startOfDay(for: card.saveDay)
        })
    }
    
    // MARK: - Private Methods
    private func setupSubscriptions() {
        ajiwaiCardService.ajiwaiCards
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cards in
                self?.ajiwaiCards = cards
            }
            .store(in: &cancellables)
    }
    
    private func awardExpAndPoints() {
        // Award 50 EXP and 10 points for creating a new card
        characterService.addExpToCharacter(named: characterService.loadCharacterCollection().selectedCharacterName, exp: 50)
        characterService.addPointsToCharacter(named: characterService.loadCharacterCollection().selectedCharacterName, points: 10)
    }
    
    private func handleError(_ message: String) {
        errorMessage = message
        showError = true
        print("❌ \(message)")
    }
    
    func dismissError() {
        showError = false
        errorMessage = ""
    }
}