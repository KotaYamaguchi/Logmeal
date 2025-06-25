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
    @AppStorage("inTrainingCharactar") var inTrainingCharactar:String = "Rabbit"
    @AppStorage("CharactarName") var characterName:String = "Rabbit"
    @AppStorage("level") var level:Int = 0
    @AppStorage("exp") var exp:Int = 10
    @AppStorage("appearExp") var appearExp:Int = 0
    @AppStorage("point") var point:Int = 0
    @AppStorage("growthStage") var growthStage = 1
    @Published var gotEXP:Int = 0
    @Published var isGrowthed:Bool = false
    @Published var isIncreasedLevel:Bool = false
    @Published var showGrowthAnimation:Bool = false
    @Published var showLevelUPAnimation:Bool = false
    @Published var showAnimation:Bool = false
    
    //キャラ別管理
    @AppStorage("isCharacterDataMigrated") var isCharacterDataMigrated: Bool = false
    @AppStorage("isFirstCharacterChange") var isFirstCharacterChange: Bool = true
    @Published var RabbitData:Character = Character(name: "Rabbit", level: 0, exp: 0, growthStage: 0)
    @Published var DogData:Character = Character(name: "Dog", level: 0, exp: 0, growthStage: 0)
    @Published var CatData:Character = Character(name: "Cat", level: 0, exp: 0, growthStage: 0)
    @Published var currentCharacter: Character = Character(name: "Rabbit", level: 0, exp: 0, growthStage: 0)
    init(){
        initCharacterData()
    }
    func initCharacterData(){
        loadAllharacterData()
        setCurrentCharacter()
        saveAllCharacter()
    }
    func setCurrentCharacter() {
        switch selectedCharacter {
        case "Rabbit":
            currentCharacter = RabbitData
        case "Dog":
            currentCharacter = DogData
        case "Cat":
            currentCharacter = CatData
        default:
            currentCharacter = DogData
        }
    }
        
    // ユーザーデフォルトのキャラクターデータを全てロード
    func loadAllharacterData(){
        RabbitData = loadCharacterata(key: "RabbitData") ?? Character(name: "Rabbit", level: 0, exp: 0, growthStage: 0)
        DogData = loadCharacterata(key: "DogData") ?? Character(name: "Dog", level: 0, exp: 0, growthStage: 0)
        CatData = loadCharacterata(key: "CatData") ?? Character(name: "Cat", level: 0, exp: 0, growthStage: 0)
        switch selectedCharacter{
        case "Rabbit":
            currentCharacter = RabbitData
        case "Dog":
            currentCharacter = DogData
        case "Cat":
            currentCharacter = CatData
        default:
            currentCharacter = DogData
        }
        print("=== Loaded Character Data ===\n")
        print("=== Current Character Debug Info ===")
        print("  Name: \(currentCharacter.name)")
        print("  Level: \(currentCharacter.level)")
        print("  EXP: \(currentCharacter.exp)")
        print("  Growth Stage: \(currentCharacter.growthStage)")

        print("=== Current Dog Debug Info ===")
        print("  Level: \(DogData.level)")
        print("  EXP: \(DogData.exp)")
        print("  Growth Stage: \(DogData.growthStage)")

        print("=== Current Rabbit Debug Info ===")
        print("  Level: \(RabbitData.level)")
        print("  EXP: \(RabbitData.exp)")
        print("  Growth Stage: \(RabbitData.growthStage)")

        print("=== Current Cat Debug Info ===")
        print("  Level: \(CatData.level)")
        print("  EXP: \(CatData.exp)")
        print("  Growth Stage: \(CatData.growthStage)")

    }
    /// すべてのキャラクターデータを初期値にリセットする
    func resetAllCharacterData() {
        self.DogData = Character(name: "Dog", level: 0, exp: 0, growthStage: 0)
        self.RabbitData = Character(name: "Rabbit", level: 0, exp: 0, growthStage: 0)
        self.CatData = Character(name: "Cat", level: 0, exp: 0, growthStage: 0)
    }
    // 全てのキャラクターデータを保存
    func saveAllCharacter(){
        saveCharacterData(data: currentCharacter, key: "currentCharacter")
        saveCharacterData(data: DogData, key: "DogData")
        saveCharacterData(data: CatData, key: "CatData")
        saveCharacterData(data: RabbitData, key: "RabbitData")
//        print("=== Saved Character Data ===\n")
//        print("=== Current Character Debug Info ===")
//        print("  Name: \(currentCharacter.name)")
//        print("  Level: \(currentCharacter.level)")
//        print("  EXP: \(currentCharacter.exp)")
//        print("  Growth Stage: \(currentCharacter.growthStage)")
//
//        print("=== Current Dog Debug Info ===")
//        print("  Level: \(DogData.level)")
//        print("  EXP: \(DogData.exp)")
//        print("  Growth Stage: \(DogData.growthStage)")
//
//        print("=== Current Rabbit Debug Info ===")
//        print("  Level: \(RabbitData.level)")
//        print("  EXP: \(RabbitData.exp)")
//        print("  Growth Stage: \(RabbitData.growthStage)")
//
//        print("=== Current Cat Debug Info ===")
//        print("  Level: \(CatData.level)")
//        print("  EXP: \(CatData.exp)")
//        print("  Growth Stage: \(CatData.growthStage)")

    }

    // マイグレーション処理
    func migrateLegacyData() {
        // 既に移行済みの場合は何もせず
        print("Before isCharacterDataMigrated: ",isCharacterDataMigrated)
        if isCharacterDataMigrated {
        loadAllharacterData()
        }else{
            // 選択中のキャラクターに合わせて成長値をコピー
            switch selectedCharacter {
            case "Rabbit":
                RabbitData.name = "Rabbit"
                RabbitData.growthStage = growthStage
                RabbitData.level = level
                RabbitData.exp = exp
        
                saveCharacterData(data: RabbitData,key: "RabbitData")
            case "Dog":
                DogData.name = "Dog"
                DogData.growthStage = growthStage
                DogData.level = level
                DogData.exp = exp
           
                saveCharacterData(data: DogData, key: "DogData")
            case "Cat":
                CatData.name = "Cat"
                CatData.growthStage = growthStage
                CatData.level = level
                CatData.exp = exp
      
                saveCharacterData(data: CatData, key: "CatData")
            default:
                DogData.growthStage = growthStage
                DogData.level = level
                DogData.exp = exp

                saveCharacterData(data: DogData, key: "DogData")
            }
            // 移行済みフラグを立てる
            isCharacterDataMigrated = true
            print("Migration completed successfully.")
        }
    }
    // キャラクターデータを保存する関数
    func saveCharacterData(data:Character,key:String){
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(data) {
            UserDefaults.standard.set(encoded, forKey: key)
        }else{
            print("一時保存に失敗しました")
        }
    }
    func loadCharacterata(key:String) -> Character? {
        if let savedData = UserDefaults.standard.data(forKey: key) {
            let decoder = JSONDecoder()
            if let savedCharacterData = try? decoder.decode(Character.self, from: savedData) {
                return savedCharacterData
            }
        }
        return nil
    }

  //キャラクターが変更可能か判断する関数
    func canSwitchCharacter(currentharacter:Character) -> SwitchStatus {
        if currentharacter.growthStage == 3{
            return .success
        }else{
            return .fails
        }
    }
    func switchCharacter(switchStatus: SwitchStatus,targetCharacter: Character) {
      print("targetCharacter.name: \(targetCharacter.name)")
        if switchStatus == .success{
            if targetCharacter.growthStage == 0{
               switch targetCharacter.name{
               case "Dog":
                   DogData.growthStage = 1
               case "Cat":
                   CatData.growthStage = 1
               case "Rabbit":
                   RabbitData.growthStage = 1
               default:
                   break
               }
            }
            switch targetCharacter.name{
            case "Dog":
                currentCharacter = DogData
                selectedCharacter = "Dog"
            case "Cat":
                currentCharacter = CatData
                selectedCharacter = "Cat"
            case "Rabbit":
                currentCharacter = RabbitData
                selectedCharacter = "Rabbit"
            default:
                break
            }
            print("=== switchCharacter ===")
            print("=== SwitchStatus\(switchStatus) ===")
            print("=== Current Character Debug Info ===")
            print("  Name: \(currentCharacter.name)")
            print("  Level: \(currentCharacter.level)")
            print("  EXP: \(currentCharacter.exp)")
            print("  Growth Stage: \(currentCharacter.growthStage)")

            print("=== Current Dog Debug Info ===")
            print("  Name: \(DogData.name)")
            print("  Level: \(DogData.level)")
            print("  EXP: \(DogData.exp)")
            print("  Growth Stage: \(DogData.growthStage)")

            print("=== Current Rabbit Debug Info ===")
            print("  Name: \(RabbitData.name)")
            print("  Level: \(RabbitData.level)")
            print("  EXP: \(RabbitData.exp)")
            print("  Growth Stage: \(RabbitData.growthStage)")

            print("=== Current Cat Debug Info ===")
            print("  Name: \(CatData.name)")
            print("  Level: \(CatData.level)")
            print("  EXP: \(CatData.exp)")
            print("  Growth Stage: \(CatData.growthStage)")
        }else{
            print("エラーが発生しました。")
        }
        saveAllCharacter()
    }
}


struct Character:Codable,Equatable{
    var name: String
    var level:Int
    var exp:Int
    var growthStage:Int
    
    init(name: String, level: Int, exp: Int, growthStage: Int) {
        self.name = name
        self.level = level
        self.exp = exp
        self.growthStage = growthStage
    }
    
}

enum SwitchStatus:String{
    case success
    case fails
}
