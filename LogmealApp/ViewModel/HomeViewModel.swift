
import SwiftUI
import SwiftData

@MainActor
class HomeViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var ajiwaiCards: [AjiwaiCardData] = []
    @Published var selectedIndex: Int? = nil
    @Published var showDetailView: Bool = false
    @Published var showWritingView: Bool = false
    
    // MARK: - Dependencies
    private let modelContext: ModelContext
    let userData: UserData

    // MARK: - Computed Properties
    var displayContentColor: Color {
        switch userData.currentCharacter.name {
        case "Dog": return Color(red: 248/255, green: 201/255, blue: 201/255)
        case "Cat": return Color(red: 198/255, green: 166/255, blue: 208/255)
        case "Rabbit": return Color(red: 251/255, green: 233/255, blue: 184/255)
        default: return .white
        }
    }

    var backgroundImageName: String {
        return "bg_home_\(userData.currentCharacter.name)"
    }

    var addButtonImageName: String {
        return "bt_add_\(userData.currentCharacter.name)"
    }
    
    var logCount: Int {
        return ajiwaiCards.count
    }

    // MARK: - Initializer
    init(modelContext: ModelContext, userData: UserData) {
        self.modelContext = modelContext
        self.userData = userData
        fetchAjiwaiCards()
    }

    // MARK: - Public Methods
    func onAppear() {
        print("ーーーーーーーーーーーーホーム画面を表示しました！ーーーーーーーーーーーー")
        userData.initCharacterData()
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
        do {
            let descriptor = FetchDescriptor<AjiwaiCardData>(sortBy: [SortDescriptor(\AjiwaiCardData.saveDay, order: .reverse)])
            self.ajiwaiCards = try modelContext.fetch(descriptor)
        } catch {
            print("味わいカードのデータ取得に失敗しました: \(error)")
        }
    }

    // MARK: - Debugging Methods
    func resetAllAjiwaiCardDataAndImages() {
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
    }
}
