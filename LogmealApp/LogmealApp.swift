import SwiftUI
import SwiftData

@main
struct LogmealApp: App {
    @StateObject var user = UserData()
    @StateObject private var bgmManager = BGMManager.shared
    @StateObject private var coordinator = AppCoordinator()
    
    @Environment(\.modelContext) private var context
    @Query private var allData: [AjiwaiCardData]
    
    var body: some Scene {
        WindowGroup {
            LaunchScreen()
                .environmentObject(user)
                .environmentObject(coordinator)
                .modelContainer(for:[AjiwaiCardData.self,ColumnData.self,MenuData.self])
                .onAppear {
                    // Setup MVVM architecture
                    setupMVVMArchitecture()
                    
                    // Setup BGM
                    setupBGM()
                    
                    // Perform data migration
                    performDataMigration()
                }
                .onDisappear {
                    bgmManager.stopBGM()
                }
        }
    }
    
    // MARK: - MVVM Setup
    private func setupMVVMArchitecture() {
        // Get model context from environment
        let modelContext = context
        
        // Setup DI container with dependencies
        DIContainer.shared.setup(modelContext: modelContext, userData: user)
        
        // Initialize coordinator
        coordinator.initializeApp()
        
        print("✅ MVVM architecture initialized in LogmealApp")
    }
    
    // MARK: - BGM Setup
    private func setupBGM() {
        if bgmManager.isBGMOn {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                bgmManager.playBGM()
            }
        }
    }
    
    // MARK: - Data Migration
    private func performDataMigration() {
        for card in allData {
            if card.uuid == nil {
                card.uuid = UUID()
                print("Migration: Added UUID to card")
            }
            if card.time == nil {
                card.time = .lunch
                print("Migration: Added default time to card")
            }
        }
        
        do {
            try context.save()
            print("✅ Data migration completed successfully")
        } catch {
            print("❌ Data migration failed: \(error)")
        }
    }
}

