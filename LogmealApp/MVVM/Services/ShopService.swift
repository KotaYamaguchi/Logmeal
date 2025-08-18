import Foundation
import Combine

/// ショップ管理サービス
protocol ShopServiceProtocol: AnyObject {
    var shopData: CurrentValueSubject<ShopData, Never> { get }
    
    func purchaseProduct(_ product: Product, userPoints: Int) -> PurchaseResult
    func getProducts(for category: ShopCategory) -> [Product]
    func getPurchasedProducts() -> [Product]
    func saveShopData()
    func loadShopData()
    func isPurchased(_ productId: UUID) -> Bool
}

final class ShopService: ShopServiceProtocol, Injectable {
    let shopData = CurrentValueSubject<ShopData, Never>(ShopData())
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadShopData()
    }
    
    static func register(in container: DIContainer) {
        container.register(ShopServiceProtocol.self, instance: ShopService())
    }
    
    func purchaseProduct(_ product: Product, userPoints: Int) -> PurchaseResult {
        var data = shopData.value
        
        // すでに購入済みかチェック
        if data.isPurchased(product.id) {
            return .alreadyPurchased
        }
        
        // ポイント不足チェック
        if userPoints < product.price {
            return .insufficientPoints
        }
        
        // 購入処理
        data.markAsPurchased(product.id)
        shopData.send(data)
        saveShopData()
        
        return .success
    }
    
    func getProducts(for category: ShopCategory) -> [Product] {
        return shopData.value.getProducts(for: category)
    }
    
    func getPurchasedProducts() -> [Product] {
        return shopData.value.getPurchasedProducts()
    }
    
    func isPurchased(_ productId: UUID) -> Bool {
        return shopData.value.isPurchased(productId)
    }
    
    func saveShopData() {
        let data = shopData.value
        let encoder = JSONEncoder()
        
        // 購入済み商品のIDを保存
        if let encoded = try? encoder.encode(Array(data.boughtProductIds)) {
            userDefaults.set(encoded, forKey: "boughtProductIds")
        }
        
        // 各カテゴリの商品を保存
        for category in ShopCategory.allCases {
            let products = data.getProducts(for: category)
            if let encoded = try? encoder.encode(products) {
                userDefaults.set(encoded, forKey: "shopProducts_\(category.rawValue)")
            }
        }
    }
    
    func loadShopData() {
        var data = ShopData()
        let decoder = JSONDecoder()
        
        // 購入済み商品IDを読み込み
        if let savedData = userDefaults.data(forKey: "boughtProductIds"),
           let boughtIds = try? decoder.decode([UUID].self, from: savedData) {
            data.boughtProductIds = Set(boughtIds)
        }
        
        // 各カテゴリの商品を読み込み（保存されていない場合はデフォルト商品を使用）
        for category in ShopCategory.allCases {
            if let savedData = userDefaults.data(forKey: "shopProducts_\(category.rawValue)"),
               let products = try? decoder.decode([Product].self, from: savedData) {
                data.products[category] = products
            }
        }
        
        // 購入済み状態を反映
        for category in data.products.keys {
            if let products = data.products[category] {
                data.products[category] = products.map { product in
                    var updatedProduct = product
                    updatedProduct.isBought = data.boughtProductIds.contains(product.id)
                    return updatedProduct
                }
            }
        }
        
        shopData.send(data)
    }
}