import Foundation

/// ショップ商品
struct Product: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var displayName: String?
    var description: String?
    var price: Int
    var img: String
    var isBought: Bool
    
    init(
        name: String,
        displayName: String? = nil,
        description: String? = nil,
        price: Int,
        img: String,
        isBought: Bool = false
    ) {
        self.name = name
        self.displayName = displayName
        self.description = description
        self.price = price
        self.img = img
        self.isBought = isBought
    }
}

/// ショップカテゴリ
enum ShopCategory: String, CaseIterable {
    case poses = "poses"
    case characters = "characters"
    case items = "items"
    
    var displayName: String {
        switch self {
        case .poses: return "ポーズ"
        case .characters: return "キャラクター"
        case .items: return "アイテム"
        }
    }
}

/// 購入結果
enum PurchaseResult {
    case success
    case insufficientPoints
    case alreadyPurchased
    case error(String)
    
    var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }
    
    var errorMessage: String? {
        switch self {
        case .success:
            return nil
        case .insufficientPoints:
            return "ポイントが不足しています"
        case .alreadyPurchased:
            return "すでに購入済みです"
        case .error(let message):
            return message
        }
    }
}

/// ショップデータ管理
struct ShopData: Codable {
    var products: [ShopCategory: [Product]]
    var boughtProductIds: Set<UUID>
    
    init() {
        self.products = [:]
        self.boughtProductIds = Set()
        
        // デフォルト商品を初期化
        setupDefaultProducts()
    }
    
    private mutating func setupDefaultProducts() {
        // ポーズ商品
        products[.poses] = [
            Product(name: "basic_pose", displayName: "基本ポーズ", price: 10, img: "pose_basic"),
            Product(name: "happy_pose", displayName: "ハッピーポーズ", price: 20, img: "pose_happy"),
            Product(name: "cool_pose", displayName: "クールポーズ", price: 30, img: "pose_cool")
        ]
        
        // キャラクター商品
        products[.characters] = [
            Product(name: "premium_dog", displayName: "プレミアム犬", price: 100, img: "char_premium_dog"),
            Product(name: "premium_cat", displayName: "プレミアム猫", price: 100, img: "char_premium_cat"),
            Product(name: "premium_rabbit", displayName: "プレミアムうさぎ", price: 100, img: "char_premium_rabbit")
        ]
        
        // アイテム商品
        products[.items] = [
            Product(name: "food_bowl", displayName: "特製フードボウル", price: 50, img: "item_food_bowl"),
            Product(name: "toy_ball", displayName: "おもちゃボール", price: 25, img: "item_toy_ball")
        ]
    }
    
    /// 商品を購入済みにする
    mutating func markAsPurchased(_ productId: UUID) {
        boughtProductIds.insert(productId)
        
        // products内の対応する商品も更新
        for category in products.keys {
            if let index = products[category]?.firstIndex(where: { $0.id == productId }) {
                products[category]?[index].isBought = true
                break
            }
        }
    }
    
    /// 商品が購入済みかチェック
    func isPurchased(_ productId: UUID) -> Bool {
        return boughtProductIds.contains(productId)
    }
    
    /// カテゴリ別の商品を取得
    func getProducts(for category: ShopCategory) -> [Product] {
        return products[category] ?? []
    }
    
    /// 購入済み商品を取得
    func getPurchasedProducts() -> [Product] {
        var purchased: [Product] = []
        for products in products.values {
            purchased.append(contentsOf: products.filter { $0.isBought })
        }
        return purchased
    }
}