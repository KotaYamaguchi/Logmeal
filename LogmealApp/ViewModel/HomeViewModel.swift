
import SwiftUI
import SwiftData

@MainActor
class HomeViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var ajiwaiCards: [AjiwaiCardData] = []
    @Published var selectedIndex: Int? = nil
    @Published var showDetailView: Bool = false
    @Published var showWritingView: Bool = false
    
    // MARK: - Dependencies (Legacy & MVVM Compatible)
    private let modelContext: ModelContext?
    let userData: UserData?
    
    // MVVM Dependencies (optional for backward compatibility)
    private let ajiwaiCardService: AjiwaiCardServiceProtocol?
    private let characterService: CharacterServiceProtocol?
    
    // MARK: - Computed Properties
    var displayContentColor: Color {
        if let userData = userData {
            // Legacy mode
            switch userData.currentCharacter.name {
            case "Dog": return Color(red: 248/255, green: 201/255, blue: 201/255)
            case "Cat": return Color(red: 198/255, green: 166/255, blue: 208/255)
            case "Rabbit": return Color(red: 251/255, green: 233/255, blue: 184/255)
            default: return .white
            }
        } else if let characterService = characterService {
            // MVVM mode
            let currentCharacter = characterService.characterData.value.currentCharacter
            switch currentCharacter.name {
            case "Dog": return Color(red: 248/255, green: 201/255, blue: 201/255)
            case "Cat": return Color(red: 198/255, green: 166/255, blue: 208/255)
            case "Rabbit": return Color(red: 251/255, green: 233/255, blue: 184/255)
            default: return .white
            }
        }
        return .white
    }

    var backgroundImageName: String {
        let characterName: String
        if let userData = userData {
            characterName = userData.currentCharacter.name
        } else if let characterService = characterService {
            characterName = characterService.characterData.value.currentCharacter.name
        } else {
            characterName = "Dog"
        }
        return "bg_home_\(characterName)"
    }

    var addButtonImageName: String {
        let characterName: String
        if let userData = userData {
            characterName = userData.currentCharacter.name
        } else if let characterService = characterService {
            characterName = characterService.characterData.value.currentCharacter.name
        } else {
            characterName = "Dog"
        }
        return "bt_add_\(characterName)"
    }
    
    var logCount: Int {
        return ajiwaiCards.count
    }

    // MARK: - Initializers
    
    // Legacy initializer (backward compatibility)
    init(modelContext: ModelContext, userData: UserData) {
        self.modelContext = modelContext
        self.userData = userData
        self.ajiwaiCardService = nil
        self.characterService = nil
        fetchAjiwaiCards()
    }
    
    // MVVM initializer
    init(
        ajiwaiCardService: AjiwaiCardServiceProtocol = DIContainer.shared.resolve(AjiwaiCardServiceProtocol.self),
        characterService: CharacterServiceProtocol = DIContainer.shared.resolve(CharacterServiceProtocol.self)
    ) {
        self.modelContext = nil
        self.userData = nil
        self.ajiwaiCardService = ajiwaiCardService
        self.characterService = characterService
        fetchAjiwaiCards()
    }

    // MARK: - Public Methods
    func onAppear() {
        print("ーーーーーーーーーーーーホーム画面を表示しました！ーーーーーーーーーーーー")
        
        if let userData = userData {
            // Legacy mode
            userData.initCharacterData()
        } else if let characterService = characterService {
            // MVVM mode
            characterService.initCharacterData()
        }
        fetchAjiwaiCards() // 画面が表示されるたびにデータを再取得
    }
    
    func selectCard(at index: Int) {
        self.selectedIndex = index
        self.showDetailView = true
    }
    
    func dismissDetailView() {
        self.selectedIndex = nil
        self.showDetailView = false
    }

    func fetchAjiwaiCards() {
        if let modelContext = modelContext {
            // Legacy mode
            do {
                let descriptor = FetchDescriptor<AjiwaiCardData>(sortBy: [SortDescriptor(\AjiwaiCardData.saveDay, order: .reverse)])
                self.ajiwaiCards = try modelContext.fetch(descriptor)
            } catch {
                print("味わいカードのデータ取得に失敗しました: \(error)")
            }
        } else if let ajiwaiCardService = ajiwaiCardService {
            // MVVM mode
            do {
                self.ajiwaiCards = try ajiwaiCardService.fetchCards()
            } catch {
                print("味わいカードのデータ取得に失敗しました: \(error)")
            }
        }
    }

    // MARK: - Debugging Methods
    func resetAllAjiwaiCardDataAndImages() {
        if let modelContext = modelContext {
            // Legacy mode
            // 1. SwiftDataのAjiwaiCardDataを全削除
            do {
                try modelContext.delete(model: AjiwaiCardData.self)
                print("SwiftDataの全AjiwaiCardDataを削除しました。")
            } catch {
                print("SwiftDataのデータ削除に失敗しました: \(error)")
            }
            
            // 2. Documentディレクトリの画像ファイルを全削除
            let fileManager = FileManager.default
            guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            
            do {
                let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
                for url in fileURLs where url.pathExtension.lowercased() == "jpeg" {
                    try fileManager.removeItem(at: url)
                }
                print("ドキュメントディレクトリ内の全JPEG画像を削除しました。")
            } catch {
                print("画像ファイルの削除に失敗しました: \(error)")
            }
            
            // データを再取得してUIを更新
            fetchAjiwaiCards()
        } else if let ajiwaiCardService = ajiwaiCardService {
            // MVVM mode
            do {
                try ajiwaiCardService.deleteAllCardsAndImages()
                fetchAjiwaiCards()
                print("全AjiwaiCardDataと画像を削除しました。")
            } catch {
                print("データの削除に失敗しました: \(error)")
            }
        }
    }
}
