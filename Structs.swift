//
//  SavedData.swift
//  AjiwaiCardApp
//
//  Created by 山口昂大 on 2024/03/19.
//

import SwiftUI
//画面遷移用の列挙型
enum Homepath{
    case home,ajiwaiCard,reward

}
struct SavedData: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var saveDay: String
    var ajiwaiText: String
    var taste: String
    var tactile: String
    var sight: String
    var smell: String
    var hearing: String
    var menu:[String]
    var image: URL = .init(fileURLWithPath: "/Users/yamaguchikouta/AjiwaiCardApp/AjiwaiCardApp/Assets.xcassets")

    init(saveDay: String, ajiwaiText: String, taste: String, tactile: String, sight: String, smell: String, hearing: String, menu: [String], image: URL) {
        self.saveDay = saveDay
        self.ajiwaiText = ajiwaiText
        self.taste = taste
        self.tactile = tactile
        self.sight = sight
        self.smell = smell
        self.hearing = hearing
        self.menu = menu
        self.image = image
    }
    
    static func == (lhs: SavedData, rhs: SavedData) -> Bool {
            return 
                   lhs.saveDay == rhs.saveDay &&
                   lhs.ajiwaiText == rhs.ajiwaiText &&
                   lhs.taste == rhs.taste &&
                   lhs.tactile == rhs.tactile &&
                   lhs.sight == rhs.sight &&
                   lhs.smell == rhs.smell &&
                   lhs.hearing == rhs.hearing &&
                   lhs.menu == rhs.menu &&
                   lhs.image == rhs.image
        }
}
struct Product:Identifiable{
    let id = UUID()
    let name:String
    let price:Int
    let img:String
  
    init(name: String, price: Int, img: String) {
        self.name = name
        self.price = price
        self.img = img
    }
}
struct Profile: Identifiable {
    var id = UUID()
    var charaName: String
    var charaImage: String
    var mainStatus: String
    var subStatus: String
}

