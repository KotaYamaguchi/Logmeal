import SwiftUI
import SwiftData
@main
struct LogmealApp: App {
    @StateObject var user = UserData()
    @StateObject private var bgmManager = BGMManager.shared
    @Environment(\.modelContext) private var context
    @Query private var allData: [AjiwaiCardData]
    var body: some Scene {
        WindowGroup {
            LaunchScreen()
                .environmentObject(user)
                .modelContainer(for:[AjiwaiCardData.self,ColumnData.self,MenuData.self])
                .onAppear {
                    if bgmManager.isBGMOn {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            bgmManager.playBGM()  // アプリ起動時にBGMを再生
                        }
                    }
                    for card in allData{
                        if card.uuid == nil{
                            card.uuid = UUID()
                            print("card.uuid", card.uuid)
                        }
                        if card.time == nil{
                            card.time = .lunch
                            print("card.time", card.time)
                        }
                        do{
                            try context.save()
                        } catch {
                            print("マイグレーションエラー")
                        }
                    }
                }
                .onDisappear {
                    bgmManager.stopBGM()  // 必要ならアプリ終了時にBGMを停止
                }
        }
    }
}

