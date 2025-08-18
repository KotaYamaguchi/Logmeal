import Foundation
import SwiftUI
import Combine

/// ショップ機能管理ViewModel
@MainActor
final class ShopViewModel: ObservableObject {
    @Published var shopData: ShopData = ShopData()
    @Published var selectedCategory: ShopCategory = .poses
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var purchaseMessage: String?
    @Published var showPurchaseAlert: Bool = false
    
    private let shopService: ShopServiceProtocol
    private let userService: UserServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    var userPoints: Int {
        userService.userProfile.value.point
    }
    
    var currentCategoryProducts: [Product] {
        shopData.getProducts(for: selectedCategory)
    }
    
    var purchasedProducts: [Product] {
        shopData.getPurchasedProducts()
    }
    
    init(
        shopService: ShopServiceProtocol = DIContainer.shared.resolve(ShopServiceProtocol.self),
        userService: UserServiceProtocol = DIContainer.shared.resolve(UserServiceProtocol.self)
    ) {
        self.shopService = shopService
        self.userService = userService
        bindToService()
    }
    
    private func bindToService() {
        shopService.shopData
            .receive(on: DispatchQueue.main)
            .assign(to: \.shopData, on: self)
            .store(in: &cancellables)
    }
    
    func selectCategory(_ category: ShopCategory) {
        selectedCategory = category
    }
    
    func purchaseProduct(_ product: Product) {
        isLoading = true
        errorMessage = nil
        
        let result = shopService.purchaseProduct(product, userPoints: userPoints)
        
        switch result {
        case .success:
            // ユーザーのポイントを減算
            let success = userService.spendPoints(product.price)
            if success {
                purchaseMessage = "\(product.displayName ?? product.name)を購入しました！"
                showPurchaseAlert = true
            } else {
                errorMessage = "ポイントの処理に失敗しました"
            }
            
        case .insufficientPoints:
            errorMessage = "ポイントが不足しています"
            
        case .alreadyPurchased:
            errorMessage = "すでに購入済みです"
            
        case .error(let message):
            errorMessage = message
        }
        
        isLoading = false
    }
    
    func canPurchase(_ product: Product) -> Bool {
        return !product.isBought && userPoints >= product.price
    }
    
    func isPurchased(_ productId: UUID) -> Bool {
        return shopService.isPurchased(productId)
    }
    
    func getProductDisplayName(_ product: Product) -> String {
        return product.displayName ?? product.name
    }
    
    func getProductDescription(_ product: Product) -> String {
        return product.description ?? "説明なし"
    }
    
    func clearErrorMessage() {
        errorMessage = nil
    }
    
    func clearPurchaseMessage() {
        purchaseMessage = nil
        showPurchaseAlert = false
    }
    
    // デバッグ用：ショップデータリロード
    func reloadShopData() {
        shopService.loadShopData()
    }
    
    // カテゴリ別の商品数を取得
    func getProductCount(for category: ShopCategory) -> Int {
        return shopData.getProducts(for: category).count
    }
    
    // 購入済み商品数を取得
    func getPurchasedProductCount(for category: ShopCategory) -> Int {
        return shopData.getProducts(for: category).filter { $0.isBought }.count
    }
    
    // カテゴリの進捗率を取得（購入済み/全体）
    func getCategoryProgress(for category: ShopCategory) -> Double {
        let total = getProductCount(for: category)
        let purchased = getPurchasedProductCount(for: category)
        
        guard total > 0 else { return 0.0 }
        return Double(purchased) / Double(total)
    }
}