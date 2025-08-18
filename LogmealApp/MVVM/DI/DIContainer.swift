import Foundation
import SwiftData
import Combine

/// Dependency Injection Container for managing app dependencies
/// Provides centralized service registration and resolution
@MainActor
class DIContainer: ObservableObject {
    
    // MARK: - Singleton
    static let shared = DIContainer()
    
    // MARK: - Core Dependencies
    private(set) var modelContext: ModelContext?
    private(set) var userData: UserData?
    
    // MARK: - Services
    private var services: [String: Any] = [:]
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Setup
    func setup(modelContext: ModelContext, userData: UserData) {
        self.modelContext = modelContext
        self.userData = userData
        
        // Register core services
        registerServices()
    }
    
    // MARK: - Service Registration
    private func registerServices() {
        guard let modelContext = modelContext, let userData = userData else {
            print("❌ DIContainer: Cannot register services - missing dependencies")
            return
        }
        
        // Register all services
        register(UserServiceImpl(userData: userData) as UserServiceProtocol)
        register(CharacterServiceImpl(userData: userData) as CharacterServiceProtocol)
        register(ShopServiceImpl(userData: userData) as ShopServiceProtocol)
        register(AjiwaiCardServiceImpl(modelContext: modelContext) as AjiwaiCardServiceProtocol)
        register(ColumnServiceImpl(modelContext: modelContext) as ColumnServiceProtocol)
        register(MenuServiceImpl(modelContext: modelContext) as MenuServiceProtocol)
        
        print("✅ DIContainer: All services registered successfully")
    }
    
    // MARK: - Generic Service Registration
    private func register<T>(_ service: T) {
        let key = String(describing: T.self)
        services[key] = service
    }
    
    // MARK: - Service Resolution
    func resolve<T>() -> T {
        let key = String(describing: T.self)
        guard let service = services[key] as? T else {
            fatalError("❌ DIContainer: Service \(key) not registered")
        }
        return service
    }
    
    // MARK: - Optional Service Resolution
    func resolveOptional<T>() -> T? {
        let key = String(describing: T.self)
        return services[key] as? T
    }
    
    // MARK: - Core Dependencies Access
    func getModelContext() -> ModelContext {
        guard let modelContext = modelContext else {
            fatalError("❌ DIContainer: ModelContext not available")
        }
        return modelContext
    }
    
    func getUserData() -> UserData {
        guard let userData = userData else {
            fatalError("❌ DIContainer: UserData not available")
        }
        return userData
    }
    
    // MARK: - Reset (for testing)
    func reset() {
        services.removeAll()
        modelContext = nil
        userData = nil
    }
}

// MARK: - Convenience Extensions
extension DIContainer {
    
    // Easy access to commonly used services
    var userService: UserServiceProtocol {
        return resolve()
    }
    
    var characterService: CharacterServiceProtocol {
        return resolve()
    }
    
    var shopService: ShopServiceProtocol {
        return resolve()
    }
    
    var ajiwaiCardService: AjiwaiCardServiceProtocol {
        return resolve()
    }
    
    var columnService: ColumnServiceProtocol {
        return resolve()
    }
    
    var menuService: MenuServiceProtocol {
        return resolve()
    }
}