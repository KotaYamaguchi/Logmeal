import Foundation

// MARK: - Shop Models

/// Shop product model
struct ShopProduct: Codable, Equatable, Identifiable {
    let id: UUID
    var name: String
    var displayName: String
    var description: String
    var price: Int
    var imageName: String
    var characterType: String
    var category: ProductCategory
    var isBought: Bool
    var isAvailable: Bool
    var unlockRequirement: UnlockRequirement?
    
    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        name: String,
        displayName: String,
        description: String,
        price: Int,
        imageName: String,
        characterType: String,
        category: ProductCategory = .animation,
        isBought: Bool = false,
        isAvailable: Bool = true,
        unlockRequirement: UnlockRequirement? = nil
    ) {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.description = description
        self.price = price
        self.imageName = imageName
        self.characterType = characterType
        self.category = category
        self.isBought = isBought
        self.isAvailable = isAvailable
        self.unlockRequirement = unlockRequirement
    }
    
    // MARK: - Computed Properties
    var canPurchase: Bool {
        return !isBought && isAvailable
    }
    
    var formattedPrice: String {
        return "\(price)P"
    }
}

// MARK: - Product Category
enum ProductCategory: String, CaseIterable, Codable {
    case animation = "animation"
    case accessory = "accessory"
    case background = "background"
    case sound = "sound"
    
    var displayName: String {
        switch self {
        case .animation: return "アニメーション"
        case .accessory: return "アクセサリー"
        case .background: return "背景"
        case .sound: return "サウンド"
        }
    }
}

// MARK: - Unlock Requirement
struct UnlockRequirement: Codable, Equatable {
    let type: RequirementType
    let value: Int
    let description: String
    
    enum RequirementType: String, Codable {
        case level = "level"
        case cardCount = "cardCount"
        case characterGrowthStage = "growthStage"
        case daysPlayed = "daysPlayed"
    }
}

// MARK: - Shop Transaction
struct ShopTransaction: Codable, Identifiable {
    let id: UUID
    let productId: UUID
    let productName: String
    let price: Int
    let characterType: String
    let purchaseDate: Date
    let transactionType: TransactionType
    
    init(
        id: UUID = UUID(),
        productId: UUID,
        productName: String,
        price: Int,
        characterType: String,
        purchaseDate: Date = Date(),
        transactionType: TransactionType = .purchase
    ) {
        self.id = id
        self.productId = productId
        self.productName = productName
        self.price = price
        self.characterType = characterType
        self.purchaseDate = purchaseDate
        self.transactionType = transactionType
    }
    
    enum TransactionType: String, Codable {
        case purchase = "purchase"
        case refund = "refund"
        case gift = "gift"
    }
}

// MARK: - Shop Inventory
struct ShopInventory: Codable {
    var products: [String: [ShopProduct]] // Organized by character type
    var transactions: [ShopTransaction]
    var lastUpdated: Date
    
    init() {
        self.products = [:]
        self.transactions = []
        self.lastUpdated = Date()
        initializeDefaultProducts()
    }
    
    // MARK: - Default Products
    private mutating func initializeDefaultProducts() {
        // Dog products
        products["Dog"] = [
            ShopProduct(
                name: "Dog3_animation_sit",
                displayName: "おすわり",
                description: "かわいくおすわりするよ。",
                price: 300,
                imageName: "img_dog_sit",
                characterType: "Dog"
            ),
            ShopProduct(
                name: "Dog3_animation_eat",
                displayName: "食べる",
                description: "おいしくごはんを食べるよ。",
                price: 500,
                imageName: "img_dog_eat",
                characterType: "Dog"
            ),
            ShopProduct(
                name: "Dog3_animation_sleep",
                displayName: "ねる",
                description: "ぐっすりおやすみタイム。",
                price: 400,
                imageName: "img_dog_sleep",
                characterType: "Dog"
            )
        ]
        
        // Cat products
        products["Cat"] = [
            ShopProduct(
                name: "Cat3_animation_sit",
                displayName: "おすわり",
                description: "ちゃんとすわって待つよ。",
                price: 600,
                imageName: "img_cat_sit",
                characterType: "Cat"
            ),
            ShopProduct(
                name: "Cat3_animation_eat",
                displayName: "食べる",
                description: "おいしくごはんを食べるよ。",
                price: 1000,
                imageName: "img_cat_eat",
                characterType: "Cat"
            ),
            ShopProduct(
                name: "Cat3_animation_sleep",
                displayName: "ねる",
                description: "すやすやおやすみタイム。",
                price: 850,
                imageName: "img_cat_sleep",
                characterType: "Cat"
            )
        ]
        
        // Rabbit products
        products["Rabbit"] = [
            ShopProduct(
                name: "Rabbit3_animation_hop",
                displayName: "ぴょんぴょん",
                description: "元気にぴょんぴょん跳ねるよ。",
                price: 250,
                imageName: "img_rabbit_hop",
                characterType: "Rabbit"
            ),
            ShopProduct(
                name: "Rabbit3_animation_eat",
                displayName: "食べる",
                description: "にんじんをおいしく食べるよ。",
                price: 400,
                imageName: "img_rabbit_eat",
                characterType: "Rabbit"
            ),
            ShopProduct(
                name: "Rabbit3_animation_yell",
                displayName: "ぴょん！",
                description: "元気に「ぴょん！」と鳴くよ。",
                price: 500,
                imageName: "img_rabbit_yell",
                characterType: "Rabbit"
            )
        ]
    }
    
    // MARK: - Inventory Operations
    func getProducts(for characterType: String) -> [ShopProduct] {
        return products[characterType] ?? []
    }
    
    func getAvailableProducts(for characterType: String) -> [ShopProduct] {
        return getProducts(for: characterType).filter { $0.isAvailable && !$0.isBought }
    }
    
    func getPurchasedProducts(for characterType: String) -> [ShopProduct] {
        return getProducts(for: characterType).filter { $0.isBought }
    }
    
    mutating func purchaseProduct(_ product: ShopProduct, for characterType: String) {
        guard var characterProducts = products[characterType] else { return }
        
        if let index = characterProducts.firstIndex(where: { $0.id == product.id }) {
            characterProducts[index].isBought = true
            products[characterType] = characterProducts
            
            // Record transaction
            let transaction = ShopTransaction(
                productId: product.id,
                productName: product.displayName,
                price: product.price,
                characterType: characterType
            )
            transactions.append(transaction)
            lastUpdated = Date()
        }
    }
    
    mutating func updateProduct(_ product: ShopProduct, for characterType: String) {
        guard var characterProducts = products[characterType] else { return }
        
        if let index = characterProducts.firstIndex(where: { $0.id == product.id }) {
            characterProducts[index] = product
            products[characterType] = characterProducts
            lastUpdated = Date()
        }
    }
    
    func getTotalSpent() -> Int {
        return transactions.filter { $0.transactionType == .purchase }.reduce(0) { $0 + $1.price }
    }
    
    func getTransactionHistory() -> [ShopTransaction] {
        return transactions.sorted { $0.purchaseDate > $1.purchaseDate }
    }
}