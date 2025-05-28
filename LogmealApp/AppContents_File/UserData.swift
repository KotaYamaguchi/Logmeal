import SwiftUI

class UserData:ObservableObject{
    @AppStorage("name") var name:String = ""
    @AppStorage("grade") var grade:String = ""
    @AppStorage("class") var yourClass:String = ""
    @AppStorage("age") var age:Int = 6
    @AppStorage("sex") var gender:String = ""
    @AppStorage("userImage") var userImage:URL?
    @AppStorage("isLogined") var isLogined:Bool = false
    @Published var isTeacher:Bool = false
    @AppStorage("lastPointAddedDate") var lastRewardGotDate: String = ""
    @AppStorage("onRecord")var onRecord:Bool = false
    @Published var isTitle:Bool = true
    func checkTodayRewardLimit() -> Bool{
        let today = dateFormatter(date: Date())
        // 最後にポイントを加算した日付が今日でない場合のみポイントを加算
        if lastRewardGotDate != today {
            lastRewardGotDate = today // 加算した日付を保存
            print("ポイントが加算されました。現在のポイント: \(point)")
            return true
        } else {
            print("本日は既にポイントを加算済みです。")
            return false
            
        }
    }
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
    func saveEscapedData(data:[EscapeData]){
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(data) {
            UserDefaults.standard.set(encoded, forKey: "escapedData")
        }else{
            print("一時保存に失敗しました")
        }
    }
    func loadEscapeData() -> [EscapeData]? {
        if let savedData = UserDefaults.standard.data(forKey: "escapedData") {
            let decoder = JSONDecoder()
            if let savedEscapeData = try? decoder.decode([EscapeData].self, from: savedData) {
                return savedEscapeData
            }
        }
        return []
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
    
    @Published var gifWidth:CGFloat = 0
    @Published var gifHeight:CGFloat = 0
    //GameData
    @AppStorage("selectedCharactar") var selectedCharacter:String = "Rabbit"
    @AppStorage("CharactarName") var characterName:String = "Rabbit"
    @AppStorage("level") var level:Int = 0
    @AppStorage("exp") var exp:Int = 10
    @AppStorage("appearExp") var appearExp:Int = 0
    @AppStorage("point") var point:Int = 0
    @AppStorage("growthStage") var growthStage = 3
    @Published var gotEXP:Int = 0
    @Published var isGrowthed:Bool = false
    @Published var isIncreasedLevel:Bool = false
    @Published var showGrowthAnimation:Bool = false
    @Published var showLevelUPAnimation:Bool = false
    @Published var showAnimation:Bool = false
}
