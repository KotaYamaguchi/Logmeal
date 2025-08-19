import SwiftUI
import SwiftData
class UserData:ObservableObject{
    @AppStorage("name") var name:String = ""
    @AppStorage("grade") var grade:String = ""
    @AppStorage("class") var yourClass:String = ""
    @AppStorage("age") var age:Int = 6
    @AppStorage("sex") var gender:String = ""
    @AppStorage("userImage") var userImage:String?
    @AppStorage("isLogined") var isLogined:Bool = false
    @AppStorage("point") var point:Int = 0
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
    func purchaseProduct(_ product: Product, ) -> Bool {
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
  
    
    //Character
    @AppStorage("selectedCharactar") var selectedCharacter:String = "Rabbit"
    @AppStorage("inTrainingCharactar") var inTrainingCharactar:String = "Rabbit"
    @AppStorage("CharactarName") var characterName:String = "Rabbit"
    
    @AppStorage("level") var level:Int = 0
    @AppStorage("exp") var exp:Int = 10
    @AppStorage("growthStage") var growthStage = 1
    
    @AppStorage("appearExp") var appearExp:Int = 0
   
    @Published var gotEXP:Int = 0
    
    @Published var isGrowthed:Bool = false
    @Published var isIncreasedLevel:Bool = false
    @Published var showGrowthAnimation:Bool = false
    @Published var showLevelUPAnimation:Bool = false
    @Published var showAnimation:Bool = false
    
    let levelThresholds: [Int] = [0, 10, 20, 30, 50, 70, 90, 110, 130, 150, 170, 200, 220, 250, 290, 350]
    //キャラ別管理
    @AppStorage("isCharacterDataMigrated") var isCharacterDataMigrated: Bool = false
    @AppStorage("isFirstCharacterChange") var isFirstCharacterChange: Bool = true
    func saveSwiftData(character:Character,context: ModelContext){
        do{
            context.insert(character)
            try context.save()
        }catch{
            print("Failed to save character data: \(error)")
        }
    }
    // マイグレーション処理
    func migrateLegacyData(context: ModelContext) {
        // 既に移行済みの場合は何もせず
        print("Before isCharacterDataMigrated: ",isCharacterDataMigrated)
        if !isCharacterDataMigrated {
            // 選択中のキャラクターに合わせて成長値をコピー
            switch selectedCharacter {
            case "Rabbit":
                let RabbitData = Character(
                    name: "Rabbit", level: level, exp: exp, growthStage: growthStage, isSelected: true
                )
                let DogData = Character(
                    name: "Dog", level: 0, exp: 0, growthStage: 1, isSelected: false
                )
                let CatData = Character(
                    name: "Cat", level: 0, exp: 0, growthStage: 1, isSelected: false
                )
                context.insert(RabbitData)
                context.insert(DogData)
                context.insert(CatData)
                
            case "Dog":
                let DogData = Character(
                    name: "Dog", level: level, exp: exp, growthStage: growthStage, isSelected: true
                )
                let RabbitData = Character(
                    name: "Rabbit", level: 0, exp: 0, growthStage: 1, isSelected: false
                )
                let CatData = Character(
                    name: "Cat", level: 0, exp: 0, growthStage: 1, isSelected: false
                )
                context.insert(RabbitData)
                context.insert(DogData)
                context.insert(CatData)
            case "Cat":
                let CatData = Character(
                    name: "Cat", level: level, exp: exp, growthStage: growthStage, isSelected: true
                )
                let DogData = Character(
                    name: "Dog", level: 0, exp: 0, growthStage: 1, isSelected: false
                )
                let RabbitData = Character(
                    name: "Rabbit", level: 0, exp: 0, growthStage: 1, isSelected: false
                )
                context.insert(RabbitData)
                context.insert(DogData)
                context.insert(CatData)
            default:
                break
            }
            do{
                try context.save()
            }catch{
                print("Failed to save character data during migration: \(error)")
            }
            // 移行済みフラグを立てる
            isCharacterDataMigrated = true
            print("Migration completed successfully.")
        }
    }
  //キャラクターが変更可能か判断する関数
    func canSwitchCharacter(currentharacter:Character) -> SwitchStatus {
        if currentharacter.growthStage == 3{
            return .success
        }else{
            return .fails
        }
    }
    /// キャラクターを切り替える
    func switchCharacter(current:Character?,to: String,array: [Character],context: ModelContext) {
        if let current = current {
            current.isSelected = false
        }
        if let next = array.first(where: { $0.name == to }) {
            next.isSelected = true
        }else{
            let nextCaharacter = Character(name: to, level: 0, exp: 0, growthStage: 1, isSelected: true)
            context.insert(nextCaharacter)
        }
        
        do{
            try context.save()
        }catch{
            print("Failed to switch character: \(error)")
        }
    }
    
    // 新しい経験値を追加し、レベルアップ判定も行う関数
    func gainExp(_ amount: Int,current:Character) {
            print("--- 経験値追加処理を開始 ---")
            print("追加される経験値: \(amount)")

            // 経験値を追加
            current.exp += amount

            // デバッグログ
            print("経験値が追加されました。現在の経験値: \(current.exp)")
            levelUpCheck(current: current)
            print("--- 経験値追加処理を終了 ---")
        }
    private func levelUpCheck(current:Character) {
        // 最大レベルに達している場合は何もしない
        guard current.level < levelThresholds.count - 1 else {
            print("最大レベルのため、レベルアップ判定は行いません。")
            return
        }
        
        // whileループを使用して、複数のレベルアップを一気に処理する
        while current.exp >= levelThresholds[current.level + 1] {
            current.level += 1
            print("レベルアップしました！現在のレベル: \(current.level)")
            
            // 最大レベルに達した場合はループを終了
            if current.level >= levelThresholds.count - 1 {
                print("最大レベルに到達しました。")
                break
            }
        }
    }
}

enum SwitchStatus:String{
    case success
    case fails
}


