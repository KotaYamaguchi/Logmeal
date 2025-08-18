import Foundation
import SwiftUI
import Combine

// MARK: - Shop ViewModel

@MainActor
class ShopViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var shopInventory: ShopInventory
    @Published var selectedCharacterType: String = "Rabbit"
    @Published var availableProducts: [ShopProduct] = []
    @Published var purchasedProducts: [ShopProduct] = []
    @Published var transactionHistory: [ShopTransaction] = []
    @Published var showPurchaseConfirmation: Bool = false
    @Published var selectedProduct: ShopProduct?
    @Published var purchaseResult: PurchaseResult?
    @Published var showPurchaseResult: Bool = false
    @Published var characterPoints: Int = 0
    
    // MARK: - Services
    private let shopService: ShopServiceProtocol
    private let characterService: CharacterServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        let container = DIContainer.shared
        self.shopService = container.shopService
        self.characterService = container.characterService
        
        // Initialize with current data
        self.shopInventory = shopService.loadShopInventory()
        
        // Subscribe to service updates
        setupSubscriptions()
        
        // Load initial data
        updateProductsForCurrentCharacter()
        updateCharacterPoints()
    }
    
    // MARK: - Character Selection
    func selectCharacterType(_ characterType: String) {
        selectedCharacterType = characterType
        updateProductsForCurrentCharacter()
        updateCharacterPoints()
        print("✅ ショップキャラクターを変更しました: \(characterType)")
    }
    
    // MARK: - Product Management
    func selectProduct(_ product: ShopProduct) {
        selectedProduct = product
        showPurchaseConfirmation = true
    }
    
    func cancelPurchase() {
        selectedProduct = nil
        showPurchaseConfirmation = false
    }
    
    func confirmPurchase() {
        guard let product = selectedProduct else { return }
        
        let success = shopService.purchaseProduct(
            product,
            for: selectedCharacterType,
            using: characterService
        )
        
        purchaseResult = PurchaseResult(
            success: success,
            productName: product.displayName,
            message: success ? "購入しました！" : "ポイントが不足しています"
        )
        
        showPurchaseConfirmation = false
        showPurchaseResult = true
        
        if success {
            updateProductsForCurrentCharacter()
            updateCharacterPoints()
        }
    }
    
    func dismissPurchaseResult() {
        showPurchaseResult = false
        purchaseResult = nil
        selectedProduct = nil
    }
    
    // MARK: - Shop Management
    func resetShopData() {
        shopService.resetShopData(for: selectedCharacterType)
        updateProductsForCurrentCharacter()
        updateCharacterPoints()
        print("✅ ショップデータをリセットしました: \(selectedCharacterType)")
    }
    
    func canPurchaseProduct(_ product: ShopProduct) -> Bool {
        return shopService.canPurchaseProduct(product, for: selectedCharacterType)
    }
    
    // MARK: - Statistics
    func getTotalSpent() -> Int {
        return shopService.getTotalSpent()
    }
    
    func getTransactionHistory() -> [ShopTransaction] {
        return shopService.getTransactionHistory()
    }
    
    // MARK: - Computed Properties
    var currentCharacterDisplayName: String {
        switch selectedCharacterType {
        case "Dog": return "いぬ"
        case "Cat": return "ねこ"
        case "Rabbit": return "うさぎ"
        default: return selectedCharacterType
        }
    }
    
    var hasAvailableProducts: Bool {
        return !availableProducts.isEmpty
    }
    
    var hasPurchasedProducts: Bool {
        return !purchasedProducts.isEmpty
    }
    
    var formattedCharacterPoints: String {
        return "\(characterPoints)P"
    }
    
    var totalItemsPurchased: Int {
        return purchasedProducts.count
    }
    
    var canAffordAnyProduct: Bool {
        return availableProducts.contains { product in
            characterPoints >= product.price
        }
    }
    
    // MARK: - Private Methods
    private func setupSubscriptions() {
        shopService.shopInventory
            .receive(on: DispatchQueue.main)
            .sink { [weak self] inventory in
                self?.shopInventory = inventory
                self?.updateProductsForCurrentCharacter()
            }
            .store(in: &cancellables)
        
        shopService.transactionHistory
            .receive(on: DispatchQueue.main)
            .sink { [weak self] history in
                self?.transactionHistory = history
            }
            .store(in: &cancellables)
        
        characterService.selectedCharacter
            .receive(on: DispatchQueue.main)
            .sink { [weak self] character in
                self?.selectedCharacterType = character.name
                self?.updateProductsForCurrentCharacter()
                self?.updateCharacterPoints()
            }
            .store(in: &cancellables)
    }
    
    private func updateProductsForCurrentCharacter() {
        availableProducts = shopService.getAvailableProducts(for: selectedCharacterType)
        purchasedProducts = shopService.getPurchasedProducts(for: selectedCharacterType)
    }
    
    private func updateCharacterPoints() {
        if let character = characterService.getCharacter(named: selectedCharacterType) {
            characterPoints = character.point
        }
    }
}

// MARK: - Purchase Result Model

struct PurchaseResult {
    let success: Bool
    let productName: String
    let message: String
}