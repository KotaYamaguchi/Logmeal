import SwiftUI

class UserData:ObservableObject{
    @AppStorage("name") var name:String = ""
    @AppStorage("grade") var grade:Int = 1
    @AppStorage("class") var yourClass:Int = 1
    @AppStorage("age") var age:Int = 6
    @AppStorage("isLogined") var isLogined:Bool = false
    @Published var isTeacher:Bool = false
    
    @Published var isDataSaved: Bool = false
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
    @Published var levelTable = [0,10,20,30,50,70,90,110,130,150,170,200,220,250,290,350]
    @AppStorage("growthStage") var growthStage = 1
    @Published var gotEXP:Int = 0

    func checkLevel() -> Bool {
        var levelUped = false
        
        while level + 1 < levelTable.count && exp >= levelTable[level + 1] {
            level += 1
            levelUped = true
        }
        
        return levelUped
    }

    func growth() -> Bool{
        var growthed = false
        if level == 12{
            growthStage = 3
            growthed = true
        }else if level == 5{
            growthStage = 2
            growthed = true
        }
        return growthed
    }
    func setGrowthStage(){
        if level >= 12{
            growthStage = 3
        }else if level >= 5{
            growthStage = 2
        }
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
