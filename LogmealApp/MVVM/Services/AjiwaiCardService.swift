import Foundation
import SwiftData
import UIKit
import Combine

/// 味わいカード管理サービス
protocol AjiwaiCardServiceProtocol: AnyObject {
    func createCard(
        date: Date,
        time: TimeStamp,
        sight: String,
        taste: String,
        smell: String,
        tactile: String,
        hearing: String,
        image: UIImage,
        menu: [String]
    ) throws -> AjiwaiCardData
    
    func updateCard(_ card: AjiwaiCardData, with updates: AjiwaiCardUpdateData) throws
    func deleteCard(_ card: AjiwaiCardData) throws
    func fetchCards() throws -> [AjiwaiCardData]
    func saveImage(_ image: UIImage) throws -> String
    func loadImage(fileName: String) -> UIImage?
    func deleteAllCardsAndImages() throws
}

/// 味わいカード更新データ
struct AjiwaiCardUpdateData {
    var sight: String?
    var taste: String?
    var smell: String?
    var tactile: String?
    var hearing: String?
    var image: UIImage?
    var menu: [String]?
    var time: TimeStamp?
}

final class AjiwaiCardService: AjiwaiCardServiceProtocol, Injectable {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    static func register(in container: DIContainer) {
        let modelContext = container.resolve(ModelContext.self)
        container.register(AjiwaiCardServiceProtocol.self, instance: AjiwaiCardService(modelContext: modelContext))
    }
    
    func createCard(
        date: Date,
        time: TimeStamp,
        sight: String,
        taste: String,
        smell: String,
        tactile: String,
        hearing: String,
        image: UIImage,
        menu: [String]
    ) throws -> AjiwaiCardData {
        
        // 画像を保存
        let imageFileName = try saveImage(image)
        
        // ドキュメントディレクトリのパスを取得
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imageURL = documentsURL.appendingPathComponent(imageFileName)
        
        // AjiwaiCardDataを作成
        let card = AjiwaiCardData(
            uuid: UUID(),
            saveDay: date,
            times: time,
            sight: sight,
            taste: taste,
            smell: smell,
            tactile: tactile,
            hearing: hearing,
            imagePath: imageURL,
            menu: menu,
            imageFileName: imageFileName
        )
        
        // SwiftDataに保存
        modelContext.insert(card)
        try modelContext.save()
        
        return card
    }
    
    func updateCard(_ card: AjiwaiCardData, with updates: AjiwaiCardUpdateData) throws {
        // テキストフィールドの更新
        if let sight = updates.sight { card.sight = sight }
        if let taste = updates.taste { card.taste = taste }
        if let smell = updates.smell { card.smell = smell }
        if let tactile = updates.tactile { card.tactile = tactile }
        if let hearing = updates.hearing { card.hearing = hearing }
        if let menu = updates.menu { card.menu = menu }
        if let time = updates.time { card.time = time }
        
        // 画像の更新
        if let newImage = updates.image {
            // 古い画像ファイルを削除
            if let oldFileName = card.imageFileName {
                try? deleteImageFile(fileName: oldFileName)
            }
            
            // 新しい画像を保存
            let newFileName = try saveImage(newImage)
            card.imageFileName = newFileName
            
            // imagePathも更新
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            card.imagePath = documentsURL.appendingPathComponent(newFileName)
        }
        
        try modelContext.save()
    }
    
    func deleteCard(_ card: AjiwaiCardData) throws {
        // 関連する画像ファイルを削除
        if let fileName = card.imageFileName {
            try? deleteImageFile(fileName: fileName)
        }
        
        // SwiftDataから削除
        modelContext.delete(card)
        try modelContext.save()
    }
    
    func fetchCards() throws -> [AjiwaiCardData] {
        let descriptor = FetchDescriptor<AjiwaiCardData>(
            sortBy: [SortDescriptor(\.saveDay, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func saveImage(_ image: UIImage) throws -> String {
        // UUIDでファイル名を生成
        let fileName = "\(UUID().uuidString).jpeg"
        
        // ドキュメントディレクトリのパスを取得
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        // JPEGデータに変換
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw AjiwaiCardServiceError.imageConversionFailed
        }
        
        // ファイルに保存
        try imageData.write(to: fileURL)
        
        return fileName
    }
    
    func loadImage(fileName: String) -> UIImage? {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL: URL
        
        // 拡張子がない場合は.jpegを追加
        if fileName.hasSuffix(".jpeg") {
            fileURL = documentsURL.appendingPathComponent(fileName)
        } else {
            fileURL = documentsURL.appendingPathComponent(fileName + ".jpeg")
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            return UIImage(data: data)
        } catch {
            print("画像の読み込みに失敗しました: \(error)")
            return nil
        }
    }
    
    func deleteAllCardsAndImages() throws {
        // SwiftDataのAjiwaiCardDataを全削除
        try modelContext.delete(model: AjiwaiCardData.self)
        
        // ドキュメントディレクトリの画像ファイルを全削除
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw AjiwaiCardServiceError.documentDirectoryNotFound
        }
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            for url in fileURLs where url.pathExtension.lowercased() == "jpeg" {
                try fileManager.removeItem(at: url)
            }
            print("ドキュメントディレクトリ内の全JPEG画像を削除しました。")
        } catch {
            print("画像ファイルの削除に失敗しました: \(error)")
            throw error
        }
        
        try modelContext.save()
    }
    
    // MARK: - Private Methods
    
    private func deleteImageFile(fileName: String) throws {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL: URL
        
        if fileName.hasSuffix(".jpeg") {
            fileURL = documentsURL.appendingPathComponent(fileName)
        } else {
            fileURL = documentsURL.appendingPathComponent(fileName + ".jpeg")
        }
        
        try FileManager.default.removeItem(at: fileURL)
    }
}

/// 味わいカードサービスのエラー
enum AjiwaiCardServiceError: Error, LocalizedError {
    case imageConversionFailed
    case documentDirectoryNotFound
    case fileNotFound
    
    var errorDescription: String? {
        switch self {
        case .imageConversionFailed:
            return "画像の変換に失敗しました"
        case .documentDirectoryNotFound:
            return "ドキュメントディレクトリが見つかりません"
        case .fileNotFound:
            return "ファイルが見つかりません"
        }
    }
}