import Foundation
import SwiftUI
import SwiftData
import PhotosUI
import Combine
import UIKit

/// カード作成・編集管理ViewModel
@MainActor
final class AjiwaiCardViewModel: ObservableObject {
    @Published var cards: [AjiwaiCardData] = []
    @Published var selectedIndex: Int? = nil
    @Published var showDetailView: Bool = false
    @Published var showWritingView: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // カード作成フォーム用
    @Published var currentDate: Date = Date()
    @Published var selectedTime: TimeStamp = .lunch
    @Published var sight: String = ""
    @Published var taste: String = ""
    @Published var smell: String = ""
    @Published var tactile: String = ""
    @Published var hearing: String = ""
    @Published var selectedImage: UIImage?
    @Published var selectedMenu: [String] = []
    @Published var showValidationOverlay: Bool = false
    @Published var validationMessage: String = ""
    
    private let ajiwaiCardService: AjiwaiCardServiceProtocol
    private let characterService: CharacterServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    var logCount: Int {
        cards.count
    }
    
    var missingFields: [String] {
        var fields: [String] = []
        
        if sight.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            fields.append("「見た目」を入力してね")
        }
        if taste.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            fields.append("「味」を入力してね")
        }
        if smell.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            fields.append("「におい」を入力してね")
        }
        if tactile.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            fields.append("「食感」を入力してね")
        }
        if hearing.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            fields.append("「音」を入力してね")
        }
        if selectedMenu.isEmpty {
            fields.append("「あさ」か「ひる」か「よる」を選んでね")
        }
        if selectedImage == nil {
            fields.append("写真をとるかライブラリから選んでね")
        }
        
        return fields
    }
    
    init(
        ajiwaiCardService: AjiwaiCardServiceProtocol = DIContainer.shared.resolve(AjiwaiCardServiceProtocol.self),
        characterService: CharacterServiceProtocol = DIContainer.shared.resolve(CharacterServiceProtocol.self)
    ) {
        self.ajiwaiCardService = ajiwaiCardService
        self.characterService = characterService
        fetchCards()
    }
    
    func fetchCards() {
        isLoading = true
        errorMessage = nil
        
        do {
            cards = try ajiwaiCardService.fetchCards()
        } catch {
            errorMessage = "味わいカードの取得に失敗しました: \(error.localizedDescription)"
            print("味わいカードの取得に失敗しました: \(error)")
        }
        
        isLoading = false
    }
    
    func selectCard(at index: Int) {
        selectedIndex = index
        showDetailView = true
    }
    
    func dismissDetailView() {
        selectedIndex = nil
        showDetailView = false
    }
    
    func handlePhotoPicker(newItem: PhotosPickerItem?) {
        Task {
            if let data = try? await newItem?.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                self.selectedImage = image
            }
        }
    }
    
    func attemptToSave() {
        let missing = missingFields
        if missing.isEmpty {
            saveCurrentData()
        } else {
            validationMessage = missing.joined(separator: "\n")
            showValidationOverlay = true
        }
    }
    
    func saveCurrentData() {
        guard let image = selectedImage else {
            errorMessage = "画像が選択されていません"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let card = try ajiwaiCardService.createCard(
                date: currentDate,
                time: selectedTime,
                sight: sight,
                taste: taste,
                smell: smell,
                tactile: tactile,
                hearing: hearing,
                image: image,
                menu: selectedMenu
            )
            
            // 経験値を追加（味わいカード作成で10経験値）
            characterService.gainExp(10)
            
            // フォームをリセット
            resetForm()
            
            // カード一覧を更新
            fetchCards()
            
            print("味わいカードが保存されました: \(card.uuid?.uuidString ?? "UUID不明")")
            
        } catch {
            errorMessage = "味わいカードの保存に失敗しました: \(error.localizedDescription)"
            print("味わいカードの保存に失敗しました: \(error)")
        }
        
        isLoading = false
    }
    
    func updateCard(_ card: AjiwaiCardData, with updates: AjiwaiCardUpdateData) {
        isLoading = true
        errorMessage = nil
        
        do {
            try ajiwaiCardService.updateCard(card, with: updates)
            fetchCards()
        } catch {
            errorMessage = "味わいカードの更新に失敗しました: \(error.localizedDescription)"
            print("味わいカードの更新に失敗しました: \(error)")
        }
        
        isLoading = false
    }
    
    func deleteCard(_ card: AjiwaiCardData) {
        isLoading = true
        errorMessage = nil
        
        do {
            try ajiwaiCardService.deleteCard(card)
            fetchCards()
        } catch {
            errorMessage = "味わいカードの削除に失敗しました: \(error.localizedDescription)"
            print("味わいカードの削除に失敗しました: \(error)")
        }
        
        isLoading = false
    }
    
    func loadImage(from card: AjiwaiCardData) -> UIImage? {
        guard let fileName = card.imageFileName else { return nil }
        return ajiwaiCardService.loadImage(fileName: fileName)
    }
    
    func resetAllCardsAndImages() {
        isLoading = true
        errorMessage = nil
        
        do {
            try ajiwaiCardService.deleteAllCardsAndImages()
            fetchCards()
            print("すべての味わいカードと画像を削除しました")
        } catch {
            errorMessage = "データの削除に失敗しました: \(error.localizedDescription)"
            print("データの削除に失敗しました: \(error)")
        }
        
        isLoading = false
    }
    
    func resetForm() {
        currentDate = Date()
        selectedTime = .lunch
        sight = ""
        taste = ""
        smell = ""
        tactile = ""
        hearing = ""
        selectedImage = nil
        selectedMenu = []
        showValidationOverlay = false
        validationMessage = ""
    }
    
    func dateFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    func frameSize(for image: UIImage) -> CGSize {
        let aspectRatio = image.size.width / image.size.height
        let targetRatio: CGFloat = 3.0 / 4.0
        let tolerance: CGFloat = 0.01
        let width: CGFloat = abs(aspectRatio - targetRatio) < tolerance ? 300.0 : 400.0
        let height = width / aspectRatio
        return CGSize(width: width, height: height)
    }
    
    func clearErrorMessage() {
        errorMessage = nil
    }
    
    func clearValidationMessage() {
        showValidationOverlay = false
        validationMessage = ""
    }
}