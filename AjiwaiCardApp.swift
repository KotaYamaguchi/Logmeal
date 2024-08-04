//
//  Gohan_Navigation_ver_1App.swift
//  Gohan_Navigation_ver.1
//
//  Created by 山口昂大 on 2023/12/15.
//

import SwiftUI
import SwiftData
@main
struct AjiwaiCardApp: App {
    @StateObject var user = UserData()
    var body: some Scene {
        WindowGroup {
            LaunchScreen()
                .environmentObject(user)
                .modelContainer(for:AjiwaiCardData.self)
        }
    }
}






