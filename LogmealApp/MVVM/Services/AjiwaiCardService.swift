import Foundation
import SwiftData
import Combine

// MARK: - AjiwaiCard Service Protocol

protocol AjiwaiCardServiceProtocol {
    var ajiwaiCards: AnyPublisher<[AjiwaiCardData], Never> { get }
    
    func fetchAjiwaiCards() -> [AjiwaiCardData]
    func saveAjiwaiCard(_ card: AjiwaiCardData) throws
    func deleteAjiwaiCard(_ card: AjiwaiCardData) throws
    func deleteAllAjiwaiCards() throws
    func getAjiwaiCard(by uuid: UUID) -> AjiwaiCardData?
    func getAjiwaiCards(for date: Date) -> [AjiwaiCardData]
    func getAjiwaiCardsCount() -> Int
    func resetAllAjiwaiCardDataAndImages() throws
}

// MARK: - AjiwaiCard Service Implementation

@MainActor
class AjiwaiCardServiceImpl: ObservableObject, AjiwaiCardServiceProtocol {
    
    // MARK: - Published Properties
    @Published private var _ajiwaiCards: [AjiwaiCardData] = []
    
    // MARK: - Publishers
    var ajiwaiCards: AnyPublisher<[AjiwaiCardData], Never> {
        $_ajiwaiCards.eraseToAnyPublisher()
    }
    
    // MARK: - Dependencies
    private let modelContext: ModelContext
    
    // MARK: - Initialization
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadAjiwaiCards()
    }
    
    // MARK: - Public Methods
    func fetchAjiwaiCards() -> [AjiwaiCardData] {
        loadAjiwaiCards()
        return _ajiwaiCards
    }
    
    func saveAjiwaiCard(_ card: AjiwaiCardData) throws {
        modelContext.insert(card)
        try modelContext.save()
        loadAjiwaiCards()
        
        print("✅ 味わいカードを保存しました: \(card.uuid?.uuidString ?? "No UUID")")
    }
    
    func deleteAjiwaiCard(_ card: AjiwaiCardData) throws {
        modelContext.delete(card)
        try modelContext.save()
        loadAjiwaiCards()
        
        print("✅ 味わいカードを削除しました: \(card.uuid?.uuidString ?? "No UUID")")
    }
    
    func deleteAllAjiwaiCards() throws {
        try modelContext.delete(model: AjiwaiCardData.self)
        try modelContext.save()
        loadAjiwaiCards()
        
        print("✅ 全ての味わいカードを削除しました")
    }
    
    func getAjiwaiCard(by uuid: UUID) -> AjiwaiCardData? {
        let descriptor = FetchDescriptor<AjiwaiCardData>(
            predicate: #Predicate { card in
                card.uuid == uuid
            }
        )
        
        do {
            let cards = try modelContext.fetch(descriptor)
            return cards.first
        } catch {
            print("❌ 味わいカードの取得に失敗しました: \(error)")
            return nil
        }
    }
    
    func getAjiwaiCards(for date: Date) -> [AjiwaiCardData] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<AjiwaiCardData>(
            predicate: #Predicate { card in
                card.saveDay >= startOfDay && card.saveDay < endOfDay
            },
            sortBy: [SortDescriptor(\AjiwaiCardData.saveDay, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("❌ 指定日の味わいカード取得に失敗しました: \(error)")
            return []
        }
    }
    
    func getAjiwaiCardsCount() -> Int {
        return _ajiwaiCards.count
    }
    
    func resetAllAjiwaiCardDataAndImages() throws {
        // 1. SwiftDataの全AjiwaiCardDataを削除
        try deleteAllAjiwaiCards()
        
        // 2. Documentディレクトリの画像ファイルを全削除
        try deleteAllImages()
        
        print("✅ 全ての味わいカードデータと画像を削除しました")
    }
    
    // MARK: - Private Methods
    private func loadAjiwaiCards() {
        do {
            let descriptor = FetchDescriptor<AjiwaiCardData>(
                sortBy: [SortDescriptor(\AjiwaiCardData.saveDay, order: .reverse)]
            )
            _ajiwaiCards = try modelContext.fetch(descriptor)
        } catch {
            print("❌ 味わいカードのデータ取得に失敗しました: \(error)")
            _ajiwaiCards = []
        }
    }
    
    private func deleteAllImages() throws {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("❌ Documentsディレクトリの取得に失敗しました")
            return
        }
        
        let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
        for url in fileURLs where url.pathExtension.lowercased() == "jpeg" {
            try fileManager.removeItem(at: url)
        }
        
        print("✅ ドキュメントディレクトリ内の全JPEG画像を削除しました")
    }
}