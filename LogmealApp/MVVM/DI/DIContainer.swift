import Foundation
import SwiftData

/// 依存注入コンテナ - アプリ全体の依存関係を管理
final class DIContainer {
    static let shared = DIContainer()
    
    private var services: [ObjectIdentifier: Any] = [:]
    private var factories: [ObjectIdentifier: () -> Any] = [:]
    
    private init() {}
    
    /// サービスをシングルトンとして登録
    func register<T>(_ type: T.Type, instance: T) {
        let key = ObjectIdentifier(type)
        services[key] = instance
    }
    
    /// サービスをファクトリとして登録（呼び出すたびに新しいインスタンスを生成）
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = ObjectIdentifier(type)
        factories[key] = factory
    }
    
    /// サービスを解決（取得）
    func resolve<T>(_ type: T.Type) -> T {
        let key = ObjectIdentifier(type)
        
        // 既存のインスタンスがあればそれを返す
        if let service = services[key] as? T {
            return service
        }
        
        // ファクトリがあれば新しいインスタンスを作成
        if let factory = factories[key] {
            let instance = factory() as! T
            return instance
        }
        
        fatalError("Service of type \(T.self) not registered")
    }
    
    /// ModelContextを設定（SwiftDataとの統合）
    func setModelContext(_ context: ModelContext) {
        register(ModelContext.self, instance: context)
    }
    
    /// すべてのサービスをリセット（主にテスト用）
    func reset() {
        services.removeAll()
        factories.removeAll()
    }
}

/// DIContainer用のプロトコル
protocol Injectable {
    static func register(in container: DIContainer)
}