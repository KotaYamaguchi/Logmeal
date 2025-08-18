import Foundation
import SwiftUI
import Combine

/// 設定管理ViewModel
@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var showResetConfirmation: Bool = false
    @Published var showDataExportSheet: Bool = false
    
    private let userService: UserServiceProtocol
    private let characterService: CharacterServiceProtocol
    private let ajiwaiCardService: AjiwaiCardServiceProtocol
    private let shopService: ShopServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    var userProfile: UserProfile {
        userService.userProfile.value
    }
    
    init(
        userService: UserServiceProtocol = DIContainer.shared.resolve(UserServiceProtocol.self),
        characterService: CharacterServiceProtocol = DIContainer.shared.resolve(CharacterServiceProtocol.self),
        ajiwaiCardService: AjiwaiCardServiceProtocol = DIContainer.shared.resolve(AjiwaiCardServiceProtocol.self),
        shopService: ShopServiceProtocol = DIContainer.shared.resolve(ShopServiceProtocol.self)
    ) {
        self.userService = userService
        self.characterService = characterService
        self.ajiwaiCardService = ajiwaiCardService
        self.shopService = shopService
    }
    
    func resetAllData() {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            // 1. 味わいカードと画像をすべて削除
            try ajiwaiCardService.deleteAllCardsAndImages()
            
            // 2. キャラクターデータをリセット
            characterService.resetAllCharacterData()
            
            // 3. ユーザープロフィールをリセット
            let resetProfile = UserProfile()
            userService.updateProfile(resetProfile)
            
            // 4. ショップデータをリロード（初期状態に戻す）
            shopService.loadShopData()
            
            successMessage = "すべてのデータがリセットされました"
            
        } catch {
            errorMessage = "データのリセットに失敗しました: \(error.localizedDescription)"
            print("データのリセットに失敗しました: \(error)")
        }
        
        isLoading = false
        showResetConfirmation = false
    }
    
    func exportData() {
        showDataExportSheet = true
    }
    
    func toggleTeacherMode() {
        var updated = userProfile
        updated.isTeacher.toggle()
        userService.updateProfile(updated)
    }
    
    func toggleRecordingMode() {
        var updated = userProfile
        updated.onRecord.toggle()
        userService.updateProfile(updated)
    }
    
    func updateUserProfile(
        name: String? = nil,
        grade: String? = nil,
        yourClass: String? = nil,
        age: Int? = nil,
        gender: String? = nil
    ) {
        var updated = userProfile
        
        if let name = name { updated.name = name }
        if let grade = grade { updated.grade = grade }
        if let yourClass = yourClass { updated.yourClass = yourClass }
        if let age = age { updated.age = age }
        if let gender = gender { updated.gender = gender }
        
        userService.updateProfile(updated)
        successMessage = "プロフィールが更新されました"
    }
    
    func showResetConfirmationDialog() {
        showResetConfirmation = true
    }
    
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
    
    // アプリのバージョン情報を取得
    func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return "\(version) (\(build))"
        }
        return "不明"
    }
    
    // デバッグ情報を取得
    func getDebugInfo() -> String {
        let profile = userProfile
        let characterData = characterService.characterData.value
        
        return """
        === デバッグ情報 ===
        ユーザー名: \(profile.name)
        学年: \(profile.grade)
        クラス: \(profile.yourClass)
        年齢: \(profile.age)
        ポイント: \(profile.point)
        
        選択キャラクター: \(characterData.selectedCharacter.rawValue)
        現在レベル: \(characterData.currentCharacter.level)
        現在経験値: \(characterData.currentCharacter.exp)
        成長段階: \(characterData.currentCharacter.growthStage)
        
        アプリバージョン: \(getAppVersion())
        """
    }
}

/// QRスキャン機能管理ViewModel
@MainActor
final class QRScannerViewModel: ObservableObject {
    @Published var isScanning: Bool = false
    @Published var scannedCode: String?
    @Published var errorMessage: String?
    @Published var showResult: Bool = false
    
    func startScanning() {
        isScanning = true
        errorMessage = nil
    }
    
    func stopScanning() {
        isScanning = false
    }
    
    func handleScannedCode(_ code: String) {
        scannedCode = code
        showResult = true
        stopScanning()
        
        // ここで必要に応じてQRコードの処理を行う
        processQRCode(code)
    }
    
    func handleScanError(_ error: Error) {
        errorMessage = "QRコードの読み取りに失敗しました: \(error.localizedDescription)"
        stopScanning()
    }
    
    func clearResult() {
        scannedCode = nil
        showResult = false
        errorMessage = nil
    }
    
    private func processQRCode(_ code: String) {
        // QRコードの内容に応じた処理を実装
        // 例：特定のURLの場合はWebViewを開く、データの場合は解析するなど
        print("QRコードが読み取られました: \(code)")
    }
}

/// エクスポート機能管理ViewModel
@MainActor
final class ExportViewModel: ObservableObject {
    @Published var isExporting: Bool = false
    @Published var exportProgress: Double = 0.0
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var exportedFileURL: URL?
    
    private let ajiwaiCardService: AjiwaiCardServiceProtocol
    private let userService: UserServiceProtocol
    private let characterService: CharacterServiceProtocol
    
    init(
        ajiwaiCardService: AjiwaiCardServiceProtocol = DIContainer.shared.resolve(AjiwaiCardServiceProtocol.self),
        userService: UserServiceProtocol = DIContainer.shared.resolve(UserServiceProtocol.self),
        characterService: CharacterServiceProtocol = DIContainer.shared.resolve(CharacterServiceProtocol.self)
    ) {
        self.ajiwaiCardService = ajiwaiCardService
        self.userService = userService
        self.characterService = characterService
    }
    
    func exportAllData() {
        isExporting = true
        exportProgress = 0.0
        errorMessage = nil
        successMessage = nil
        
        Task {
            do {
                // 1. データを収集
                await updateProgress(0.2, message: "データを収集中...")
                let cards = try ajiwaiCardService.fetchCards()
                let userProfile = userService.userProfile.value
                let characterData = characterService.characterData.value
                
                // 2. エクスポート用データ構造を作成
                await updateProgress(0.4, message: "エクスポートデータを作成中...")
                let exportData = ExportData(
                    userProfile: userProfile,
                    characterData: characterData,
                    cards: cards.map { card in
                        ExportCardData(
                            uuid: card.uuid,
                            saveDay: card.saveDay,
                            time: card.time,
                            sight: card.sight,
                            taste: card.taste,
                            smell: card.smell,
                            tactile: card.tactile,
                            hearing: card.hearing,
                            menu: card.menu,
                            imageFileName: card.imageFileName
                        )
                    },
                    exportDate: Date()
                )
                
                // 3. JSONファイルを生成
                await updateProgress(0.6, message: "ファイルを生成中...")
                let jsonData = try JSONEncoder().encode(exportData)
                
                // 4. ドキュメントディレクトリに保存
                await updateProgress(0.8, message: "ファイルを保存中...")
                let fileName = "LogmealExport_\(DateFormatter().string(from: Date())).json"
                let fileURL = try saveToDocuments(data: jsonData, fileName: fileName)
                
                await updateProgress(1.0, message: "エクスポート完了")
                
                DispatchQueue.main.async {
                    self.exportedFileURL = fileURL
                    self.successMessage = "データのエクスポートが完了しました"
                    self.isExporting = false
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "エクスポートに失敗しました: \(error.localizedDescription)"
                    self.isExporting = false
                }
            }
        }
    }
    
    private func updateProgress(_ progress: Double, message: String) async {
        DispatchQueue.main.async {
            self.exportProgress = progress
        }
        // 進捗表示のために少し待つ
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
    }
    
    private func saveToDocuments(data: Data, fileName: String) throws -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)
        try data.write(to: fileURL)
        return fileURL
    }
    
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
        exportedFileURL = nil
    }
}

/// エクスポート用データ構造
struct ExportData: Codable {
    let userProfile: UserProfile
    let characterData: CharacterData
    let cards: [ExportCardData]
    let exportDate: Date
}

struct ExportCardData: Codable {
    let uuid: UUID?
    let saveDay: Date
    let time: TimeStamp?
    let sight: String
    let taste: String
    let smell: String
    let tactile: String
    let hearing: String
    let menu: [String]
    let imageFileName: String?
}