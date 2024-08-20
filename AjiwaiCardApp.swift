import SwiftUI
import SwiftData
@main
struct AjiwaiCardApp: App {
    @StateObject var user = UserData()
    var body: some Scene {
        WindowGroup {
            LaunchScreen()
                .environmentObject(user)
                .modelContainer(for:[AjiwaiCardData.self,ColumnData.self,MenuData.self])
                
        }
    }
}






