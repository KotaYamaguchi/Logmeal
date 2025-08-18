import Foundation
import SwiftUI
import SwiftData
import Combine

/// コラム表示管理ViewModel
@MainActor
final class ColumnViewModel: ObservableObject {
    @Published var columns: [ColumnData] = []
    @Published var filteredColumns: [ColumnData] = []
    @Published var searchQuery: String = ""
    @Published var sortOption: ColumnSortOption = .dateDescending
    @Published var showQRScanner: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let columnService: ColumnServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(columnService: ColumnServiceProtocol = DIContainer.shared.resolve(ColumnServiceProtocol.self)) {
        self.columnService = columnService
        setupSearchObserver()
        fetchColumns()
    }
    
    private func setupSearchObserver() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }
    
    func fetchColumns() {
        isLoading = true
        errorMessage = nil
        
        do {
            columns = try columnService.fetchColumns()
            applyFiltersAndSort()
        } catch {
            errorMessage = "コラムの取得に失敗しました: \(error.localizedDescription)"
            print("コラムの取得に失敗しました: \(error)")
        }
        
        isLoading = false
    }
    
    func markAsRead(_ column: ColumnData) {
        do {
            try columnService.markAsRead(column)
            fetchColumns()
        } catch {
            errorMessage = "コラムの既読状態の更新に失敗しました: \(error.localizedDescription)"
            print("コラムの既読状態の更新に失敗しました: \(error)")
        }
    }
    
    func toggleExpanded(_ column: ColumnData) {
        do {
            try columnService.toggleExpanded(column)
            fetchColumns()
        } catch {
            errorMessage = "コラムの展開状態の更新に失敗しました: \(error.localizedDescription)"
            print("コラムの展開状態の更新に失敗しました: \(error)")
        }
    }
    
    func setSortOption(_ option: ColumnSortOption) {
        sortOption = option
        applyFiltersAndSort()
    }
    
    func getTodayColumns() {
        isLoading = true
        errorMessage = nil
        
        do {
            columns = try columnService.getTodayColumns()
            applyFiltersAndSort()
        } catch {
            errorMessage = "今日のコラムの取得に失敗しました: \(error.localizedDescription)"
            print("今日のコラムの取得に失敗しました: \(error)")
        }
        
        isLoading = false
    }
    
    func getColumnsByDateRange(from startDate: Date, to endDate: Date) {
        isLoading = true
        errorMessage = nil
        
        do {
            columns = try columnService.getColumnsByDate(from: startDate, to: endDate)
            applyFiltersAndSort()
        } catch {
            errorMessage = "指定期間のコラムの取得に失敗しました: \(error.localizedDescription)"
            print("指定期間のコラムの取得に失敗しました: \(error)")
        }
        
        isLoading = false
    }
    
    func showQRScannerView() {
        showQRScanner = true
    }
    
    func dismissQRScanner() {
        showQRScanner = false
    }
    
    func clearErrorMessage() {
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    
    private func performSearch(query: String) {
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            applyFiltersAndSort()
            return
        }
        
        do {
            let searchResults = try columnService.searchColumns(query: query)
            filteredColumns = applySorting(to: searchResults)
        } catch {
            errorMessage = "検索に失敗しました: \(error.localizedDescription)"
            print("検索に失敗しました: \(error)")
        }
    }
    
    private func applyFiltersAndSort() {
        filteredColumns = applySorting(to: columns)
    }
    
    private func applySorting(to columns: [ColumnData]) -> [ColumnData] {
        switch sortOption {
        case .dateAscending:
            return columns.sorted { $0.columnDay < $1.columnDay }
        case .dateDescending:
            return columns.sorted { $0.columnDay > $1.columnDay }
        case .title:
            return columns.sorted { $0.title < $1.title }
        case .readStatus:
            return columns.sorted { !$0.isRead && $1.isRead }
        }
    }
}

/// コラムソートオプション
enum ColumnSortOption: String, CaseIterable {
    case dateDescending = "dateDesc"
    case dateAscending = "dateAsc"
    case title = "title"
    case readStatus = "readStatus"
    
    var displayName: String {
        switch self {
        case .dateDescending: return "新しい順"
        case .dateAscending: return "古い順"
        case .title: return "タイトル順"
        case .readStatus: return "未読優先"
        }
    }
}