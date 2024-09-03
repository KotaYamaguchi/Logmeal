import SwiftUI
import SwiftData
@main
struct AjiwaiCardApp: App {
    @StateObject var user = UserData()
    @StateObject private var bgmManager = BGMManager.shared

    var body: some Scene {
        WindowGroup {
            LaunchScreen()
                .environmentObject(user)
                .modelContainer(for:[AjiwaiCardData.self,ColumnData.self,MenuData.self])
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        bgmManager.playBGM()  // アプリ起動時にBGMを再生
                    }
                }
                .onDisappear {
                    bgmManager.stopBGM()  // 必要ならアプリ終了時にBGMを停止
                }
        }
    }
}
