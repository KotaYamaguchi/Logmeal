import Foundation
import SwiftData
import Combine

/// コラム管理サービス
protocol ColumnServiceProtocol: AnyObject {
    func fetchColumns() throws -> [ColumnData]
    func markAsRead(_ column: ColumnData) throws
    func toggleExpanded(_ column: ColumnData) throws
    func searchColumns(query: String) throws -> [ColumnData]
    func getColumnsByDate(from startDate: Date, to endDate: Date) throws -> [ColumnData]
    func getTodayColumns() throws -> [ColumnData]
}

final class ColumnService: ColumnServiceProtocol, Injectable {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    static func register(in container: DIContainer) {
        let modelContext = container.resolve(ModelContext.self)
        container.register(ColumnServiceProtocol.self, instance: ColumnService(modelContext: modelContext))
    }
    
    func fetchColumns() throws -> [ColumnData] {
        let descriptor = FetchDescriptor<ColumnData>(
            sortBy: [SortDescriptor(\.columnDay, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func markAsRead(_ column: ColumnData) throws {
        column.isRead = true
        try modelContext.save()
    }
    
    func toggleExpanded(_ column: ColumnData) throws {
        column.isExpanded.toggle()
        try modelContext.save()
    }
    
    func searchColumns(query: String) throws -> [ColumnData] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedQuery.isEmpty {
            return try fetchColumns()
        }
        
        let predicate = #Predicate<ColumnData> { column in
            column.title.localizedStandardContains(trimmedQuery) ||
            column.caption.localizedStandardContains(trimmedQuery)
        }
        
        let descriptor = FetchDescriptor<ColumnData>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.columnDay, order: .reverse)]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    func getColumnsByDate(from startDate: Date, to endDate: Date) throws -> [ColumnData] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let startDateString = dateFormatter.string(from: startDate)
        let endDateString = dateFormatter.string(from: endDate)
        
        let predicate = #Predicate<ColumnData> { column in
            column.columnDay >= startDateString && column.columnDay <= endDateString
        }
        
        let descriptor = FetchDescriptor<ColumnData>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.columnDay, order: .reverse)]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    func getTodayColumns() throws -> [ColumnData] {
        let today = Date()
        return try getColumnsByDate(from: today, to: today)
    }
}

/// メニュー管理サービス
protocol MenuServiceProtocol: AnyObject {
    func fetchMenus() throws -> [MenuData]
    func getMenu(for date: Date) throws -> MenuData?
    func saveMenu(_ menu: MenuData) throws
    func updateMenu(for date: Date, menu: [String]) throws
    func deleteMenu(for date: Date) throws
}

final class MenuService: MenuServiceProtocol, Injectable {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    static func register(in container: DIContainer) {
        let modelContext = container.resolve(ModelContext.self)
        container.register(MenuServiceProtocol.self, instance: MenuService(modelContext: modelContext))
    }
    
    func fetchMenus() throws -> [MenuData] {
        let descriptor = FetchDescriptor<MenuData>(
            sortBy: [SortDescriptor(\.day, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func getMenu(for date: Date) throws -> MenuData? {
        let dateString = dateFormatter(date: date)
        
        let predicate = #Predicate<MenuData> { menuData in
            menuData.day == dateString
        }
        
        let descriptor = FetchDescriptor<MenuData>(predicate: predicate)
        let menus = try modelContext.fetch(descriptor)
        
        return menus.first
    }
    
    func saveMenu(_ menu: MenuData) throws {
        modelContext.insert(menu)
        try modelContext.save()
    }
    
    func updateMenu(for date: Date, menu: [String]) throws {
        let dateString = dateFormatter(date: date)
        
        if let existingMenu = try getMenu(for: date) {
            existingMenu.menu = menu
        } else {
            let newMenu = MenuData(day: dateString, menu: menu)
            modelContext.insert(newMenu)
        }
        
        try modelContext.save()
    }
    
    func deleteMenu(for date: Date) throws {
        if let menu = try getMenu(for: date) {
            modelContext.delete(menu)
            try modelContext.save()
        }
    }
    
    // MARK: - Private Methods
    
    private func dateFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}