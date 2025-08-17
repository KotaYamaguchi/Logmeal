import SwiftUI

class UserData:ObservableObject{
    @AppStorage("name") var name:String = ""
    @AppStorage("grade") var grade:String = ""
    @AppStorage("class") var yourClass:String = ""
    @AppStorage("age") var age:Int = 6
    @AppStorage("sex") var gender:String = ""
    @AppStorage("userImage") var userImage:String?
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
    let levelThresholds: [Int] = [0, 10, 20, 30, 50, 70, 90, 110, 130, 150, 170, 200, 220, 250, 290, 350]
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
    // 新しい経験値を追加し、レベルアップ判定も行う関数
        func gainExp(_ amount: Int) {
            print("--- 経験値追加処理を開始 ---")
            print("追加される経験値: \(amount)")

            // 経験値を追加
            currentCharacter.exp += amount

            // デバッグログ
            print("経験値が追加されました。現在の経験値: \(currentCharacter.exp)")

            // レベルアップ判定
            levelUpCheck()
            
            // データの保存
            saveAllCharacter()
            print("--- 経験値追加処理を終了 ---")
        }

        // レベルアップ判定と更新を行う関数
        private func levelUpCheck() {
            // 最大レベルに達している場合は何もしない
            guard currentCharacter.level < levelThresholds.count - 1 else {
                print("最大レベルのため、レベルアップ判定は行いません。")
                return
            }
            
            // whileループを使用して、複数のレベルアップを一気に処理する
            while currentCharacter.exp >= levelThresholds[currentCharacter.level + 1] {
                currentCharacter.level += 1
                print("レベルアップしました！現在のレベル: \(currentCharacter.level)")
                
                // 最大レベルに達した場合はループを終了
                if currentCharacter.level >= levelThresholds.count - 1 {
                    print("最大レベルに到達しました。")
                    break
                }
            }
        }
    // 現在のexpと次のレベルまでのexpの割合を表示
       func expProgressPercentage() -> Double {
           print("--- expProgressPercentage() 開始 ---")
           print("現在のキャラクター: \(currentCharacter.name), レベル: \(currentCharacter.level), 経験値: \(currentCharacter.exp)")

           // レベルが最大値に達している場合は100%を返す
           guard currentCharacter.level < levelThresholds.count - 1 else {
               print("最大レベルに到達しています。割合: 100.0%")
               print("--- expProgressPercentage() 終了 ---")
               return 100.0
           }

           // 現在のレベルの開始経験値閾値を取得
           let currentLevelThreshold = levelThresholds[currentCharacter.level]
           print("現在のレベルの開始閾値 (\(currentCharacter.level)レベル): \(currentLevelThreshold) EXP")

           // 次のレベルの開始経験値閾値を取得
           let nextLevelThreshold = levelThresholds[currentCharacter.level + 1]
           print("次のレベルの開始閾値 (\(currentCharacter.level + 1)レベル): \(nextLevelThreshold) EXP")

           // 現在のレベルで必要となる総経験値の範囲
           let totalExpForCurrentLevel = nextLevelThreshold - currentLevelThreshold
           print("現在のレベルで必要となる総経験値の範囲: \(totalExpForCurrentLevel) EXP")
           
           // 現在のレベルでキャラクターが獲得した経験値
           // 負の値にならないように0にクランプする（万が一、経験値が閾値を下回る場合を考慮）
           var expGainedInCurrentLevel = currentCharacter.exp - currentLevelThreshold
           print("クランプ前、現在のレベルで獲得した経験値: \(expGainedInCurrentLevel) EXP")
           expGainedInCurrentLevel = max(0, expGainedInCurrentLevel)
           print("クランプ後、現在のレベルで獲得した経験値: \(expGainedInCurrentLevel) EXP")

           // 分母が0になることを避ける（理論上は起こらないはずだが、安全のため）
           if totalExpForCurrentLevel == 0 {
               print("エラー: totalExpForCurrentLevel が0です。割合: 0.0%")
               print("--- expProgressPercentage() 終了 ---")
               return 0.0 // または特定のレベルで進捗バーを表示しないなどのロジック
           }
           
           // 進捗割合を計算して返す
           let progress = Double(expGainedInCurrentLevel) / Double(totalExpForCurrentLevel) * 100.0
           print("計算された進捗割合: \(progress)%")
           print("--- expProgressPercentage() 終了 ---")
           return progress
       }

       // 次のレベルアップまでに必要なexp
       func expToNextLevel() -> Int {
           print("--- expToNextLevel() 開始 ---")
           print("現在のキャラクター: \(currentCharacter.name), レベル: \(currentCharacter.level), 経験値: \(currentCharacter.exp)")

           // レベルが最大値に達している場合は0を返す
           guard currentCharacter.level < levelThresholds.count - 1 else {
               print("最大レベルに到達しています。残り経験値: 0 EXP")
               print("--- expToNextLevel() 終了 ---")
               return 0
           }

           let nextLevelThreshold = levelThresholds[currentCharacter.level + 1]
           print("次のレベルの開始閾値 (\(currentCharacter.level + 1)レベル): \(nextLevelThreshold) EXP")
           
           // 残り経験値が負にならないように0にクランプ
           let remainingExp = max(0, nextLevelThreshold - currentCharacter.exp)
           print("計算された残り経験値: \(remainingExp) EXP")
           print("--- expToNextLevel() 終了 ---")
           return remainingExp
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
