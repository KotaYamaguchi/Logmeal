import SwiftUI
import SwiftData
//画面遷移用の列挙型


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
    var imageFileName:String?
    
    @Transient
    var lunchComments:String = ""
    
    init(uuid: UUID? = nil,saveDay: Date, times: TimeStamp? = .lunch, sight: String, taste: String, smell: String, tactile: String, hearing: String, imagePath: URL, menu: [String],imageFileName: String? = nil) {
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
        self.imageFileName = imageFileName
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


@Model final class Character {
    @Attribute(.unique) var name: String
    var level: Int
    var exp: Int
    var growthStage: Int
    var isSelected: Bool

    init(name: String, level: Int, exp: Int, growthStage: Int, isSelected: Bool = false) {
        self.name = name
        self.level = level
        self.exp = exp
        self.growthStage = growthStage
        self.isSelected = isSelected
    }
}
struct CharacterSpeech: Identifiable {
    let id: Int
    let character: String
    let speech: String
    let timing: String
}

enum NavigationDestinations {
    case home
    case column
    case setting
}
enum Homepath: Hashable {
    case home
    case ajiwaiCard(AjiwaiCardData?)
    case reward
}

enum SwitchStatus:String{
    case success
    case fails
}
enum CharacterType: Int, CaseIterable, Identifiable {
    case dog, rabbit, cat
    var id: Int { rawValue }
    var rawValueString: String {
        switch self {
        case .dog: return "Dog"
        case .rabbit: return "Rabbit"
        case .cat: return "Cat"
        }
    }
    var iconName: String {
        switch self {
        case .dog: return "Dog_normal_1"
        case .rabbit: return "Rabbit_normal_1"
        case .cat: return "Cat_normal_1"
        }
    }
    var displayName: String {
        switch self {
        case .dog: return "犬"
        case .rabbit: return "うさぎ"
        case .cat: return "ねこ"
        }
    }
}
