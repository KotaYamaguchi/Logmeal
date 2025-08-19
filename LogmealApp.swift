import SwiftUI
import SwiftData
@main
struct LogmealApp: App {
    @StateObject var user = UserData()
    @StateObject private var bgmManager = BGMManager.shared

    var body: some Scene {
        WindowGroup {
            LaunchScreen()
                .environmentObject(user)
                .modelContainer(for:[AjiwaiCardData.self,ColumnData.self,MenuData.self,Character.self])
                .onDisappear {
                    bgmManager.stopBGM()  // 必要ならアプリ終了時にBGMを停止
                }
        }
    }
}

