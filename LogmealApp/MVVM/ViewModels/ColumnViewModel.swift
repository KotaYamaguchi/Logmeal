import Foundation
import SwiftUI
import Combine

// MARK: - Column ViewModel

@MainActor
class ColumnViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var columns: [ColumnData] = []
    @Published var selectedColumn: ColumnData?
    @Published var showDetailView: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    @Published var unreadCount: Int = 0
    
    // MARK: - Services
    private let columnService: ColumnServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        let container = DIContainer.shared
        self.columnService = container.columnService
        
        // Subscribe to service updates
        setupSubscriptions()
        
        // Load initial data
        fetchColumns()
        updateUnreadCount()
    }
    
    // MARK: - Data Management
    func fetchColumns() {
        isLoading = true
        
        DispatchQueue.main.async {
            self.columns = self.columnService.fetchColumns()
            self.updateUnreadCount()
            self.isLoading = false
        }
    }
    
    func addColumn(title: String, caption: String, for date: String) {
        do {
            try columnService.addMonthlyColumn(title: title, caption: caption, for: date)
            print("✅ コラムを追加しました: \(title)")
        } catch {
            handleError("コラムの追加に失敗しました: \(error.localizedDescription)")
        }
    }
    
    func markColumnAsRead(_ column: ColumnData) {
        do {
            try columnService.markColumnAsRead(column)
            updateUnreadCount()
            print("✅ コラムを既読にマークしました: \(column.title)")
        } catch {
            handleError("コラムの既読マークに失敗しました: \(error.localizedDescription)")
        }
    }
    
    func toggleColumnExpanded(_ column: ColumnData) {
        do {
            try columnService.toggleColumnExpanded(column)
            print("✅ コラムの展開状態を変更しました: \(column.title)")
        } catch {
            handleError("コラムの展開状態変更に失敗しました: \(error.localizedDescription)")
        }
    }
    
    func deleteColumn(_ column: ColumnData) {
        do {
            try columnService.deleteColumn(column)
            updateUnreadCount()
            print("✅ コラムを削除しました: \(column.title)")
        } catch {
            handleError("コラムの削除に失敗しました: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Column Selection and Navigation
    func selectColumn(_ column: ColumnData) {
        selectedColumn = column
        showDetailView = true
        
        // Mark as read when opened
        if !column.isRead {
            markColumnAsRead(column)
        }
    }
    
    func dismissDetailView() {
        selectedColumn = nil
        showDetailView = false
    }
    
    // MARK: - Data Queries
    func getColumn(for date: String) -> ColumnData? {
        return columnService.getColumn(for: date)
    }
    
    func getUnreadColumns() -> [ColumnData] {
        return columns.filter { !$0.isRead }
    }
    
    func getReadColumns() -> [ColumnData] {
        return columns.filter { $0.isRead }
    }
    
    // MARK: - Computed Properties
    var hasColumns: Bool {
        return !columns.isEmpty
    }
    
    var hasUnreadColumns: Bool {
        return unreadCount > 0
    }
    
    var recentColumns: [ColumnData] {
        return Array(columns.prefix(5))
    }
    
    var sortedColumns: [ColumnData] {
        return columns.sorted { column1, column2 in
            // Sort by read status (unread first), then by date
            if column1.isRead != column2.isRead {
                return !column1.isRead && column2.isRead
            }
            return column1.columnDay > column2.columnDay
        }
    }
    
    // MARK: - Statistics
    func getColumnsGroupedByMonth() -> [String: [ColumnData]] {
        return Dictionary(grouping: columns) { column in
            String(column.columnDay.prefix(7)) // YYYY-MM format
        }
    }
    
    func getColumnsByMonth(_ month: String) -> [ColumnData] {
        return columns.filter { $0.columnDay.hasPrefix(month) }
    }
    
    func getTotalReadColumns() -> Int {
        return columns.filter { $0.isRead }.count
    }
    
    func getReadingProgress() -> Double {
        guard !columns.isEmpty else { return 0.0 }
        return Double(getTotalReadColumns()) / Double(columns.count)
    }
    
    // MARK: - Private Methods
    private func setupSubscriptions() {
        columnService.columns
            .receive(on: DispatchQueue.main)
            .sink { [weak self] columns in
                self?.columns = columns
                self?.updateUnreadCount()
            }
            .store(in: &cancellables)
    }
    
    private func updateUnreadCount() {
        unreadCount = columnService.getUnreadColumnsCount()
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