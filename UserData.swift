import SwiftUI

class UserData:ObservableObject{
    @AppStorage("name") var name:String = ""
    @AppStorage("grade") var grade:Int = 1
    @AppStorage("class") var yourClass:Int = 1
    @AppStorage("age") var age:Int = 6
    @AppStorage("isLogined") var isLogined = false
    @Published var isTeacher:Bool = false
    //ナビゲーション管理用変数
    @Published var path: [Homepath] = []
    //カレンダーのイベント配列
    @Published var eventsDate: [Date] = []
    @Published var isDetailActive:Bool = false
    //日付をStringに変換する
    func dateFormatter(date:Date) -> String{
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ja_JP")
        let dateStr = formatter.string(from: date)
        
        return dateStr
    }
    func purchaseProduct(_ product: Product) -> Bool {
            if point >= product.price {
                point -= product.price
                return true
            }
            return false
        }
        
        func saveProducts(products: [Product], key: String) {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(products) {
                UserDefaults.standard.set(encoded, forKey: key)
            }
        }
        
        func loadProducts(key: String) -> [Product] {
            if let savedData = UserDefaults.standard.data(forKey: key) {
                let decoder = JSONDecoder()
                if let savedProducts = try? decoder.decode([Product].self, from: savedData) {
                    return savedProducts
                }
            }
            return []
        }
    //GameData
    @AppStorage("selectedCaractar") var selectedCharactar:String = "Rabbit"
    @AppStorage("level") var level:Int = 0
    @AppStorage("exp") var exp:Int = 0
    @AppStorage("appearExp") var appearExp:Int = 0
    @AppStorage("point") var point:Int = 0
    @Published var levelTable = [0,10,20,35,50,65,90,110,135,150,175,200,220,250,290,350]
    @Published var growthStage = 1
    @Published var gotEXP:Int = 0
    func checkLevel() -> Bool{
        var levelUped = false
        if exp <= levelTable.last!{
            if exp >= levelTable[level+1]{
                level += 1
                appearExp = 0
                levelUped = true
                print(level)
            }
            return levelUped
        }
        
        return levelUped
    }
    func growth() -> Bool{
        var growthed = false
        if level >= 12{
            growthStage = 3
            growthed = true
        }else if level >= 5{
            growthStage = 2
            growthed = true
        }
        return growthed
    }
    
}

import SwiftData

@Model class AjiwaiCardData{
    @Attribute(.unique) var saveDay:Date
    var lunchComments:String
    var sight:String
    var taste:String
    var smell:String
    var tactile:String
    var hearing:String
    var imagePath:URL
    var menu:[String]
    
    init(saveDay: Date, lunchComments: String, sight: String, taste: String, smell: String, tactile: String, hearing: String, imagePath: URL, menu: [String]) {
        self.saveDay = saveDay
        self.lunchComments = lunchComments
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
    
    init(columnDay: String, title: String, caption: String, isRead: Bool = false) {
        self.columnDay = columnDay
        self.title = title
        self.caption = caption
        self.isRead = isRead
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
