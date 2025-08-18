import Foundation
import SwiftData
import Combine

// MARK: - Column Service Protocol

protocol ColumnServiceProtocol {
    var columns: AnyPublisher<[ColumnData], Never> { get }
    
    func fetchColumns() -> [ColumnData]
    func saveColumn(_ column: ColumnData) throws
    func updateColumn(_ column: ColumnData) throws
    func deleteColumn(_ column: ColumnData) throws
    func getColumn(for date: String) -> ColumnData?
    func markColumnAsRead(_ column: ColumnData) throws
    func toggleColumnExpanded(_ column: ColumnData) throws
    func getUnreadColumnsCount() -> Int
    func addMonthlyColumn(title: String, caption: String, for date: String) throws
}

// MARK: - Column Service Implementation

@MainActor
class ColumnServiceImpl: ObservableObject, ColumnServiceProtocol {
    
    // MARK: - Published Properties
    @Published private var _columns: [ColumnData] = []
    
    // MARK: - Publishers
    var columns: AnyPublisher<[ColumnData], Never> {
        $_columns.eraseToAnyPublisher()
    }
    
    // MARK: - Dependencies
    private let modelContext: ModelContext
    
    // MARK: - Initialization
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadColumns()
    }
    
    // MARK: - Public Methods
    func fetchColumns() -> [ColumnData] {
        loadColumns()
        return _columns
    }
    
    func saveColumn(_ column: ColumnData) throws {
        modelContext.insert(column)
        try modelContext.save()
        loadColumns()
        
        print("✅ コラムを保存しました: \(column.title)")
    }
    
    func updateColumn(_ column: ColumnData) throws {
        try modelContext.save()
        loadColumns()
        
        print("✅ コラムを更新しました: \(column.title)")
    }
    
    func deleteColumn(_ column: ColumnData) throws {
        modelContext.delete(column)
        try modelContext.save()
        loadColumns()
        
        print("✅ コラムを削除しました: \(column.title)")
    }
    
    func getColumn(for date: String) -> ColumnData? {
        let descriptor = FetchDescriptor<ColumnData>(
            predicate: #Predicate { column in
                column.columnDay == date
            }
        )
        
        do {
            let columns = try modelContext.fetch(descriptor)
            return columns.first
        } catch {
            print("❌ 指定日のコラム取得に失敗しました: \(error)")
            return nil
        }
    }
    
    func markColumnAsRead(_ column: ColumnData) throws {
        column.isRead = true
        try updateColumn(column)
        
        print("✅ コラムを既読にマークしました: \(column.title)")
    }
    
    func toggleColumnExpanded(_ column: ColumnData) throws {
        column.isExpanded.toggle()
        try updateColumn(column)
        
        print("✅ コラムの展開状態を変更しました: \(column.title)")
    }
    
    func getUnreadColumnsCount() -> Int {
        return _columns.filter { !$0.isRead }.count
    }
    
    func addMonthlyColumn(title: String, caption: String, for date: String) throws {
        // Check if column already exists for this date
        if getColumn(for: date) != nil {
            print("⚠️ 指定日のコラムは既に存在します: \(date)")
            return
        }
        
        let newColumn = ColumnData(
            columnDay: date,
            title: title,
            caption: caption,
            isRead: false,
            isExpanded: false
        )
        
        try saveColumn(newColumn)
    }
    
    // MARK: - Private Methods
    private func loadColumns() {
        do {
            let descriptor = FetchDescriptor<ColumnData>(
                sortBy: [SortDescriptor(\ColumnData.columnDay, order: .reverse)]
            )
            _columns = try modelContext.fetch(descriptor)
        } catch {
            print("❌ コラムのデータ取得に失敗しました: \(error)")
            _columns = []
        }
    }
}

// MARK: - Menu Service Protocol

protocol MenuServiceProtocol {
    var menus: AnyPublisher<[MenuData], Never> { get }
    
    func fetchMenus() -> [MenuData]
    func saveMenu(_ menu: MenuData) throws
    func updateMenu(_ menu: MenuData) throws
    func deleteMenu(_ menu: MenuData) throws
    func getMenu(for date: String) -> MenuData?
    func addMenuForDate(_ menuItems: [String], for date: String) throws
    func updateMenuForDate(_ menuItems: [String], for date: String) throws
}

// MARK: - Menu Service Implementation

@MainActor
class MenuServiceImpl: ObservableObject, MenuServiceProtocol {
    
    // MARK: - Published Properties
    @Published private var _menus: [MenuData] = []
    
    // MARK: - Publishers
    var menus: AnyPublisher<[MenuData], Never> {
        $_menus.eraseToAnyPublisher()
    }
    
    // MARK: - Dependencies
    private let modelContext: ModelContext
    
    // MARK: - Initialization
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadMenus()
    }
    
    // MARK: - Public Methods
    func fetchMenus() -> [MenuData] {
        loadMenus()
        return _menus
    }
    
    func saveMenu(_ menu: MenuData) throws {
        modelContext.insert(menu)
        try modelContext.save()
        loadMenus()
        
        print("✅ メニューを保存しました: \(menu.day)")
    }
    
    func updateMenu(_ menu: MenuData) throws {
        try modelContext.save()
        loadMenus()
        
        print("✅ メニューを更新しました: \(menu.day)")
    }
    
    func deleteMenu(_ menu: MenuData) throws {
        modelContext.delete(menu)
        try modelContext.save()
        loadMenus()
        
        print("✅ メニューを削除しました: \(menu.day)")
    }
    
    func getMenu(for date: String) -> MenuData? {
        let descriptor = FetchDescriptor<MenuData>(
            predicate: #Predicate { menu in
                menu.day == date
            }
        )
        
        do {
            let menus = try modelContext.fetch(descriptor)
            return menus.first
        } catch {
            print("❌ 指定日のメニュー取得に失敗しました: \(error)")
            return nil
        }
    }
    
    func addMenuForDate(_ menuItems: [String], for date: String) throws {
        let newMenu = MenuData(day: date, menu: menuItems)
        try saveMenu(newMenu)
    }
    
    func updateMenuForDate(_ menuItems: [String], for date: String) throws {
        if let existingMenu = getMenu(for: date) {
            existingMenu.menu = menuItems
            try updateMenu(existingMenu)
        } else {
            try addMenuForDate(menuItems, for: date)
        }
    }
    
    // MARK: - Private Methods
    private func loadMenus() {
        do {
            let descriptor = FetchDescriptor<MenuData>(
                sortBy: [SortDescriptor(\MenuData.day, order: .reverse)]
            )
            _menus = try modelContext.fetch(descriptor)
        } catch {
            print("❌ メニューのデータ取得に失敗しました: \(error)")
            _menus = []
        }
    }
}