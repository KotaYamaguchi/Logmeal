import SwiftUI
//画面遷移用の列挙型
enum Homepath: Hashable {
    case home
    case ajiwaiCard(AjiwaiCardData?)
    case reward
}
struct Product: Identifiable, Codable {
    var id = UUID()
    var name: String
    var price: Int
    var img: String
    var isBought: Bool
}


struct Profile: Identifiable {
    var id = UUID()
    var charaName: String
    var charaImage: String
    var mainStatus: String
    var subStatus: String
}

struct EscapeData:Codable{
    var saveDay:Date
    var lunchComments:String
    var sight:String
    var taste:String
    var smell:String
    var tactile:String
    var hearing:String
    var imagePath:URL
    var menu:[String]
}
