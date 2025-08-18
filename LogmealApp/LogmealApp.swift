import SwiftUI
import SwiftData

@main
struct LogmealApp: App {
    @StateObject var user = UserData()
    @StateObject private var bgmManager = BGMManager.shared
    @StateObject private var coordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            LaunchScreen()
                .environmentObject(user)
                .environmentObject(coordinator)
                .modelContainer(for:[AjiwaiCardData.self,ColumnData.self,MenuData.self])
                .onAppear {
                    // BGM setup will be handled in LaunchScreen
                    if bgmManager.isBGMOn {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            bgmManager.playBGM()
                        }
                    }
                }
                .onDisappear {
                    bgmManager.stopBGM()
                }
        }
    }
}

