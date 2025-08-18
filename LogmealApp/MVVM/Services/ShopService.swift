import Foundation
import Combine

// MARK: - Shop Service Protocol

protocol ShopServiceProtocol {
    var shopInventory: AnyPublisher<ShopInventory, Never> { get }
    var transactionHistory: AnyPublisher<[ShopTransaction], Never> { get }
    
    func loadShopInventory() -> ShopInventory
    func getProducts(for characterType: String) -> [ShopProduct]
    func getAvailableProducts(for characterType: String) -> [ShopProduct]
    func getPurchasedProducts(for characterType: String) -> [ShopProduct]
    func purchaseProduct(_ product: ShopProduct, for characterType: String, using characterService: CharacterServiceProtocol) -> Bool
    func canPurchaseProduct(_ product: ShopProduct, for characterType: String) -> Bool
    func resetShopData(for characterType: String)
    func getTotalSpent() -> Int
    func getTransactionHistory() -> [ShopTransaction]
}

// MARK: - Shop Service Implementation

@MainActor
class ShopServiceImpl: ObservableObject, ShopServiceProtocol {
    
    // MARK: - Published Properties
    @Published private var _shopInventory: ShopInventory
    
    // MARK: - Publishers
    var shopInventory: AnyPublisher<ShopInventory, Never> {
        $_shopInventory.eraseToAnyPublisher()
    }
    
    var transactionHistory: AnyPublisher<[ShopTransaction], Never> {
        $_shopInventory
            .map { $0.getTransactionHistory() }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Dependencies
    private let userData: UserData
    
    // MARK: - Initialization
    init(userData: UserData) {
        self.userData = userData
        self._shopInventory = ShopInventory()
        
        // Load existing data from UserData
        loadFromUserData()
    }
    
    // MARK: - Public Methods
    func loadShopInventory() -> ShopInventory {
        return _shopInventory
    }
    
    func getProducts(for characterType: String) -> [ShopProduct] {
        return _shopInventory.getProducts(for: characterType)
    }
    
    func getAvailableProducts(for characterType: String) -> [ShopProduct] {
        return _shopInventory.getAvailableProducts(for: characterType)
    }
    
    func getPurchasedProducts(for characterType: String) -> [ShopProduct] {
        return _shopInventory.getPurchasedProducts(for: characterType)
    }
    
    func purchaseProduct(_ product: ShopProduct, for characterType: String, using characterService: CharacterServiceProtocol) -> Bool {
        // Check if purchase is possible
        guard canPurchaseProduct(product, for: characterType) else {
            return false
        }
        
        // Check if character has enough points
        guard characterService.spendPointsFromCharacter(named: characterType, points: product.price) else {
            return false
        }
        
        // Purchase the product
        _shopInventory.purchaseProduct(product, for: characterType)
        
        // Unlock animation if it's an animation product
        if product.category == .animation {
            characterService.unlockAnimation(for: characterType, animationName: product.name)
        }
        
        saveToUserData()
        return true
    }
    
    func canPurchaseProduct(_ product: ShopProduct, for characterType: String) -> Bool {
        guard let character = DIContainer.shared.characterService.getCharacter(named: characterType) else {
            return false
        }
        
        return product.canPurchase && character.point >= product.price
    }
    
    func resetShopData(for characterType: String) {
        // Reset products for the character
        if var characterProducts = _shopInventory.products[characterType] {
            for index in characterProducts.indices {
                characterProducts[index].isBought = false
            }
            _shopInventory.products[characterType] = characterProducts
        }
        
        // Remove transactions for this character
        _shopInventory.transactions.removeAll { $0.characterType == characterType }
        
        saveToUserData()
    }
    
    func getTotalSpent() -> Int {
        return _shopInventory.getTotalSpent()
    }
    
    func getTransactionHistory() -> [ShopTransaction] {
        return _shopInventory.getTransactionHistory()
    }
    
    // MARK: - Private Methods
    private func loadFromUserData() {
        // Load products and purchases from UserData
        for characterType in ["Dog", "Cat", "Rabbit"] {
            loadProductsForCharacter(characterType)
            loadPurchasesForCharacter(characterType)
        }
    }
    
    private func loadProductsForCharacter(_ characterType: String) {
        let productsKey = "\(characterType)_products"
        let products = userData.loadProducts(key: productsKey)
        
        // Convert UserData Product to ShopProduct
        let shopProducts = products.map { product in
            ShopProduct(
                name: product.name,
                displayName: product.displayName ?? product.name,
                description: product.description ?? "",
                price: product.price,
                imageName: product.img,
                characterType: characterType,
                isBought: product.isBought
            )
        }
        
        _shopInventory.products[characterType] = shopProducts
    }
    
    private func loadPurchasesForCharacter(_ characterType: String) {
        let boughtKey = "\(characterType)_boughtItem"
        let boughtProducts = userData.loadProducts(key: boughtKey)
        
        // Mark products as bought
        guard var characterProducts = _shopInventory.products[characterType] else { return }
        
        for boughtProduct in boughtProducts {
            if let index = characterProducts.firstIndex(where: { $0.name == boughtProduct.name }) {
                characterProducts[index].isBought = true
            }
        }
        
        _shopInventory.products[characterType] = characterProducts
    }
    
    private func saveToUserData() {
        // Save products and purchases back to UserData
        for (characterType, products) in _shopInventory.products {
            saveProductsForCharacter(characterType, products: products)
        }
    }
    
    private func saveProductsForCharacter(_ characterType: String, products: [ShopProduct]) {
        let productsKey = "\(characterType)_products"
        let boughtKey = "\(characterType)_boughtItem"
        
        // Convert ShopProduct back to UserData Product
        let userDataProducts = products.map { shopProduct in
            userData.Product(
                name: shopProduct.name,
                displayName: shopProduct.displayName,
                description: shopProduct.description,
                price: shopProduct.price,
                img: shopProduct.imageName,
                isBought: shopProduct.isBought
            )
        }
        
        let boughtProducts = userDataProducts.filter { $0.isBought }
        
        userData.saveProducts(products: userDataProducts, key: productsKey)
        userData.saveProducts(products: boughtProducts, key: boughtKey)
    }
}