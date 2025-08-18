import Foundation
import SwiftUI
import Combine

// MARK: - Export ViewModel

@MainActor
class ExportViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isExporting: Bool = false
    @Published var exportProgress: Double = 0.0
    @Published var exportResult: ExportResult?
    @Published var showExportResult: Bool = false
    @Published var selectedFormat: ExportFormat = .json
    @Published var includeImages: Bool = true
    @Published var includeUserProfile: Bool = true
    @Published var includeCharacterData: Bool = true
    @Published var includeAjiwaiCards: Bool = true
    @Published var includeColumns: Bool = true
    @Published var dateRange: DateRange = .all
    @Published var customStartDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @Published var customEndDate: Date = Date()
    
    // MARK: - Services
    private let userService: UserServiceProtocol
    private let characterService: CharacterServiceProtocol
    private let ajiwaiCardService: AjiwaiCardServiceProtocol
    private let columnService: ColumnServiceProtocol
    private let menuService: MenuServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        let container = DIContainer.shared
        self.userService = container.userService
        self.characterService = container.characterService
        self.ajiwaiCardService = container.ajiwaiCardService
        self.columnService = container.columnService
        self.menuService = container.menuService
    }
    
    // MARK: - Export Operations
    func startExport() {
        guard !isExporting else { return }
        
        isExporting = true
        exportProgress = 0.0
        
        Task {
            do {
                let exportData = try await performExport()
                let exportURL = try await saveExportData(exportData)
                
                await MainActor.run {
                    self.exportResult = ExportResult(
                        success: true,
                        message: "データのエクスポートが完了しました",
                        filePath: exportURL,
                        fileSize: self.getFileSize(at: exportURL)
                    )
                    self.showExportResult = true
                    self.isExporting = false
                    print("✅ データエクスポートが完了しました: \(exportURL.path)")
                }
                
            } catch {
                await MainActor.run {
                    self.exportResult = ExportResult(
                        success: false,
                        message: "エクスポートに失敗しました: \(error.localizedDescription)",
                        filePath: nil,
                        fileSize: 0
                    )
                    self.showExportResult = true
                    self.isExporting = false
                    print("❌ データエクスポートに失敗しました: \(error)")
                }
            }
        }
    }
    
    private func performExport() async throws -> ExportData {
        // Update progress
        await updateProgress(0.1)
        
        var exportData = ExportData()
        
        // Export user profile
        if includeUserProfile {
            exportData.userProfile = userService.loadUserProfile()
            exportData.userPreferences = userService.loadUserPreferences()
            await updateProgress(0.2)
        }
        
        // Export character data
        if includeCharacterData {
            exportData.characterCollection = characterService.loadCharacterCollection()
            await updateProgress(0.3)
        }
        
        // Export AjiwaiCards
        if includeAjiwaiCards {
            let allCards = ajiwaiCardService.fetchAjiwaiCards()
            let filteredCards = filterCardsByDateRange(allCards)
            exportData.ajiwaiCardsData = filteredCards.map { card in
                ExportableAjiwaiCard(
                    uuid: card.uuid?.uuidString,
                    saveDay: card.saveDay,
                    time: card.time?.rawValue,
                    sight: card.sight,
                    taste: card.taste,
                    smell: card.smell,
                    tactile: card.tactile,
                    hearing: card.hearing,
                    imagePath: card.imagePath.path,
                    menu: card.menu
                )
            }
            
            // Export images if requested
            if includeImages {
                exportData.cardImages = try await exportCardImages(filteredCards)
            }
            await updateProgress(0.6)
        }
        
        // Export columns
        if includeColumns {
            let allColumns = columnService.fetchColumns()
            let filteredColumns = filterColumnsByDateRange(allColumns)
            exportData.columnsData = filteredColumns.map { column in
                ExportableColumn(
                    columnDay: column.columnDay,
                    title: column.title,
                    caption: column.caption,
                    isRead: column.isRead,
                    isExpanded: column.isExpanded
                )
            }
            await updateProgress(0.8)
        }
        
        // Export menus
        let allMenus = menuService.fetchMenus()
        let filteredMenus = filterMenusByDateRange(allMenus)
        exportData.menusData = filteredMenus.map { menu in
            ExportableMenu(
                day: menu.day,
                menu: menu.menu
            )
        }
        
        await updateProgress(1.0)
        
        return exportData
    }
    
    private func saveExportData(_ data: ExportData) async throws -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let timestamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
        let fileName = "logmeal_export_\(timestamp).\(selectedFormat.fileExtension)"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        switch selectedFormat {
        case .json:
            let jsonData = try JSONEncoder().encode(data)
            try jsonData.write(to: fileURL)
        case .csv:
            let csvData = try convertToCSV(data)
            try csvData.write(to: fileURL, atomically: true, encoding: .utf8)
        }
        
        return fileURL
    }
    
    // MARK: - Data Filtering
    private func filterCardsByDateRange(_ cards: [AjiwaiCardData]) -> [AjiwaiCardData] {
        switch dateRange {
        case .all:
            return cards
        case .lastMonth:
            let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            return cards.filter { $0.saveDay >= oneMonthAgo }
        case .lastThreeMonths:
            let threeMonthsAgo = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
            return cards.filter { $0.saveDay >= threeMonthsAgo }
        case .custom:
            return cards.filter { $0.saveDay >= customStartDate && $0.saveDay <= customEndDate }
        }
    }
    
    private func filterColumnsByDateRange(_ columns: [ColumnData]) -> [ColumnData] {
        switch dateRange {
        case .all:
            return columns
        case .lastMonth:
            let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let oneMonthAgoString = formatter.string(from: oneMonthAgo)
            return columns.filter { $0.columnDay >= oneMonthAgoString }
        case .lastThreeMonths:
            let threeMonthsAgo = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let threeMonthsAgoString = formatter.string(from: threeMonthsAgo)
            return columns.filter { $0.columnDay >= threeMonthsAgoString }
        case .custom:
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let startString = formatter.string(from: customStartDate)
            let endString = formatter.string(from: customEndDate)
            return columns.filter { $0.columnDay >= startString && $0.columnDay <= endString }
        }
    }
    
    private func filterMenusByDateRange(_ menus: [MenuData]) -> [MenuData] {
        switch dateRange {
        case .all:
            return menus
        case .lastMonth:
            let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let oneMonthAgoString = formatter.string(from: oneMonthAgo)
            return menus.filter { $0.day >= oneMonthAgoString }
        case .lastThreeMonths:
            let threeMonthsAgo = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let threeMonthsAgoString = formatter.string(from: threeMonthsAgo)
            return menus.filter { $0.day >= threeMonthsAgoString }
        case .custom:
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let startString = formatter.string(from: customStartDate)
            let endString = formatter.string(from: customEndDate)
            return menus.filter { $0.day >= startString && $0.day <= endString }
        }
    }
    
    // MARK: - Image Export
    private func exportCardImages(_ cards: [AjiwaiCardData]) async throws -> [String: Data] {
        var imageData: [String: Data] = [:]
        
        for card in cards {
            if let imageData = try? Data(contentsOf: card.imagePath) {
                let imageName = card.imagePath.lastPathComponent
                imageData[imageName] = imageData
            }
        }
        
        return imageData
    }
    
    // MARK: - CSV Conversion
    private func convertToCSV(_ data: ExportData) throws -> String {
        var csvContent = ""
        
        // CSV header for AjiwaiCards
        csvContent += "Date,Time,Sight,Taste,Smell,Tactile,Hearing,Menu\n"
        
        // CSV data for AjiwaiCards
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for card in data.ajiwaiCardsData {
            let dateString = dateFormatter.string(from: card.saveDay)
            let timeString = card.time ?? ""
            let menuString = card.menu.joined(separator: "; ")
            
            csvContent += "\(dateString),\(timeString),\(card.sight),\(card.taste),\(card.smell),\(card.tactile),\(card.hearing),\(menuString)\n"
        }
        
        return csvContent
    }
    
    // MARK: - Utility Methods
    private func updateProgress(_ progress: Double) async {
        await MainActor.run {
            self.exportProgress = progress
        }
    }
    
    private func getFileSize(at url: URL) -> Int64 {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int64 ?? 0
        } catch {
            return 0
        }
    }
    
    func dismissExportResult() {
        showExportResult = false
        exportResult = nil
        exportProgress = 0.0
    }
    
    // MARK: - Computed Properties
    var canStartExport: Bool {
        return !isExporting && (includeUserProfile || includeCharacterData || includeAjiwaiCards || includeColumns)
    }
    
    var exportProgressText: String {
        return "\(Int(exportProgress * 100))%"
    }
    
    var selectedItemsCount: Int {
        var count = 0
        if includeUserProfile { count += 1 }
        if includeCharacterData { count += 1 }
        if includeAjiwaiCards { count += 1 }
        if includeColumns { count += 1 }
        return count
    }
}

// MARK: - Export Models

enum ExportFormat: CaseIterable {
    case json
    case csv
    
    var displayName: String {
        switch self {
        case .json: return "JSON"
        case .csv: return "CSV"
        }
    }
    
    var fileExtension: String {
        switch self {
        case .json: return "json"
        case .csv: return "csv"
        }
    }
}

enum DateRange: CaseIterable {
    case all
    case lastMonth
    case lastThreeMonths
    case custom
    
    var displayName: String {
        switch self {
        case .all: return "全期間"
        case .lastMonth: return "過去1ヶ月"
        case .lastThreeMonths: return "過去3ヶ月"
        case .custom: return "カスタム期間"
        }
    }
}

struct ExportData: Codable {
    var userProfile: UserProfile?
    var userPreferences: UserPreferences?
    var characterCollection: CharacterCollection?
    var ajiwaiCardsData: [ExportableAjiwaiCard] = []
    var columnsData: [ExportableColumn] = []
    var menusData: [ExportableMenu] = []
    var cardImages: [String: Data] = [:]
}

// Simplified exportable versions that don't rely on SwiftData
struct ExportableAjiwaiCard: Codable {
    var uuid: String?
    var saveDay: Date
    var time: String?
    var sight: String
    var taste: String
    var smell: String
    var tactile: String
    var hearing: String
    var imagePath: String
    var menu: [String]
}

struct ExportableColumn: Codable {
    var columnDay: String
    var title: String
    var caption: String
    var isRead: Bool
    var isExpanded: Bool
}

struct ExportableMenu: Codable {
    var day: String
    var menu: [String]
}

struct ExportResult {
    let success: Bool
    let message: String
    let filePath: URL?
    let fileSize: Int64
    
    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
}