import SwiftUI
import SwiftData
//画面遷移用の列挙型
enum Homepath: Hashable {
    case home
    case ajiwaiCard(AjiwaiCardData?)
    case reward
}
struct Product: Identifiable, Codable {
    var id = UUID()
    var name: String
    var displayName: String?
    var description:String?
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
enum TimeStamp:String, Codable{
    case morning
    case lunch
    case dinner
}

@Model class AjiwaiCardData{
    @Attribute(.unique) var uuid: UUID?
    var saveDay:Date
    var time:TimeStamp?
    var sight:String
    var taste:String
    var smell:String
    var tactile:String
    var hearing:String
    var imagePath:URL
    var menu:[String]
    
    @Transient
    var lunchComments:String = ""
    
    init(uuid: UUID? = nil,saveDay: Date, times: TimeStamp? = .lunch, sight: String, taste: String, smell: String, tactile: String, hearing: String, imagePath: URL, menu: [String]) {
        self.uuid = uuid
        self.saveDay = saveDay
        self.time = times
        self.sight = sight
        self.taste = taste
        self.smell = smell
        self.tactile = tactile
        self.hearing = hearing
        self.imagePath = imagePath
        self.menu = menu
    }
}

@Model class ColumnData {
    @Attribute(.unique) var columnDay: String
    var title: String
    var caption: String
    var isRead: Bool = false
    var isExpanded:Bool = false
    init(columnDay: String, title: String, caption: String, isRead: Bool = false, isExpanded:Bool = false) {
        self.columnDay = columnDay
        self.title = title
        self.caption = caption
        self.isRead = isRead
        self.isExpanded = isExpanded
    }
}

@Model class MenuData{
    var day:String
    var menu:[String]
    init(day: String, menu: [String]) {
        self.day = day
        self.menu = menu
    }
}

