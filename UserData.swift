//
//  SharedValueClass.swift
//  Gohan_Navigation_ver.1
//
//  Created by 山口昂大 on 2024/01/30.
//

import Foundation
import SwiftUI

class UserData:ObservableObject{
    @AppStorage("name") var name:String = "サンプルネーム"
    @AppStorage("grade") var grade:Int = 1
    @AppStorage("age") var age:Int = 6
    @AppStorage("isLogined") var isLogined = false
    @Published var isTeacher:Bool = false
    
    //AppData
    //ナビゲーション管理用変数
    @Published var path: [Homepath] = []
    var userDefaults = UserDefaults.standard
    //カレンダーのイベント配列
    @Published var eventsDate: [Date] = []
    @Published var isDetailActive:Bool = false
    //給食の写真用変数
    @Published var uiimage = UIImage(named: "mt_No_Image")
    //味わいカード用変数
    @Published var ajiwaiText = ""
    @Published var GokanTexts = ["","","","",""]
    @Published var saveDay = Date()
    //1ヶ月分のメニューリスト
    @Published var monthlyMenu: [String:[String]] = [:]
    @Published var monthlyColumnTitle: [String:String] = [:]
    @Published var monthlyColumnCaption: [String:String] = [:]
    @Published var todayMenu:[String] = []
    //App内で参照するデータ配列
    @Published var savedDatas:[String:SavedData] = [:]
    //1日分のデータ
    @Published var dailyData:[String] = []
    //コラム表示用変数
    
    //カンマ区切りで配列を結合
    func commaSeparatedCombine(dailyData:[String]) -> String{
        let commaSaparated = dailyData.joined(separator: ",")
        return commaSaparated
    }
    //日付をStringに変換する
    func dateFormatter(date:Date) -> String{
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ja_JP")
        let dateStr = formatter.string(from: date)
        
        return dateStr
    }
    func combineDailyData(saveDay:Date,ajiwaiText:String,textFields:[String]) -> String{
        let combinedDailyData = dateFormatter(date:saveDay)  + "," +  ajiwaiText  + "," +  textFields.joined(separator: ",")
        return combinedDailyData
    }
    func writeSavedData(userData:[String:SavedData]){
        let jsonEncoder = JSONEncoder()
        guard let data = try? jsonEncoder.encode(userData) else {
            return
        }
        userDefaults.set(data, forKey: "saveDatas")
    }
    func readSavedDatas() -> [String:SavedData]? {
        let jsonDecoder = JSONDecoder()
        guard let data = userDefaults.data(forKey: "saveDatas"),
              let userData = try? jsonDecoder.decode([String:SavedData].self, from: data) else {
            return nil
        }
        return userData
    }
    func writeDataFromQR(userData:[String:[[String]]],key:String){
        let jsonEncoder = JSONEncoder()
        guard let data = try? jsonEncoder.encode(userData) else {
            return
        }
        userDefaults.set(data, forKey: key)
    }
    func readDataFromQR(key:String)-> [String:[[String]]]{
        let jsonDecoder = JSONDecoder()
        guard let data = userDefaults.data(forKey: key),
              let userData = try? jsonDecoder.decode( [String:[[String]]].self, from: data) else {
            return [:]
        }
        return userData
    }
    func writeEventData(datas:[Date],key:String){
        userDefaults.set(datas, forKey: key)
    }
    func readEventDatas(key:String) -> [Date]? {
        let data = userDefaults.array(forKey: key) as? [Date] ?? []
        return data
    }
    func writeDailyData(datas:[String],key:String){
        userDefaults.set(datas, forKey: key)
    }
    func readDailyDatas(key:String) -> [String]? {
        let data = userDefaults.array(forKey: key) as? [String] ?? []
        return data
    }
    func writeStringDictionary(_ dictionary: [String:String], forKey key: String) {
        userDefaults.set(dictionary, forKey: key)
    }
    
    func readStringDictionary(forKey key: String) -> [String:String] {
        return userDefaults.dictionary(forKey: key) as? [String:String] ?? [:]
    }
    
    // 新しいメソッド: String型の辞書をUserDefaultsに保存
    func saveStringDictionary(_ dictionary: [String: String], forKey key: String) {
        userDefaults.set(dictionary, forKey: key)
    }
    
    // 新しいメソッド: UserDefaultsからString型の辞書を読み込む
    func loadStringDictionary(forKey key: String) -> [String: String] {
        return userDefaults.dictionary(forKey: key) as? [String: String] ?? [:]
    }
     func saveMonthlyMenu() {
           if let encoded = try? JSONEncoder().encode(monthlyMenu) {
               UserDefaults.standard.set(encoded, forKey: "monthlyMenu")
           }
       }
     func loadMonthlyMenu() -> [String:[String]] {
            if let data = UserDefaults.standard.data(forKey: "monthlyMenu"),
               let decoded = try? JSONDecoder().decode([String:[String]].self, from: data) {
                return decoded
            }
            return [:] // データがない場合は空の辞書を返す
        }
    //ファイルに画像を保存してURLを取得
    func getDocumentPath(saveData:UIImage,fileName:String) -> URL{
        @State var showAlert = false
        //ドキュメントファイルのパスを取得
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        //ファイルネームを付け加えてURLを作成
        let fileURL = documentURL.appendingPathComponent(fileName + ".jpeg")
        //JPEGデータに変換してドキュメントファイルに保存
        try!saveData.jpegData(compressionQuality: 0.25)?.write(to: fileURL)
        //ファイルURLを返す
        return fileURL
    }
    //GameData
    @AppStorage("selectedCaractar") var selectedCharactar:String = "Rabbit"
    @AppStorage("level") var level:Int = 0
    @AppStorage("exp") var exp:Int = 0
    @AppStorage("appearExp") var appearExp:Int = 0
    @AppStorage("point") var point:Int = 1000
    @Published var levelTable = [0,10,20,35,50,70,100,130,160,190,210,240,270,300,330,360]
    @Published var growthStage = 3
    
    func checkLevel(){
        if exp <= levelTable.last!{
            if exp >= levelTable[level+1]{
                level += 1
                appearExp = 0
                print(level)
            }
        }
    }
    func growth(){
        if level <= 0{
            growthStage = 1
        }else if level <= 5{
            growthStage = 2
        }else if level <= 12{
            growthStage = 3
        }
    }
    func purchaseProduct(_ product: Product) -> Bool {
        // 商品の価格をポイントと比較
        if point >= product.price {
            // ポイントが十分なら商品を購入してポイントを減らす
            point -= product.price
            return true // 購入成功
        } else {
            return false // ポイント不足で購入失敗
        }
    }
}



class CounterManager: ObservableObject {
    @Published var count: Int = 0
    private let lastDateKey = "lastDate"
    
    init() {
        resetCountIfNeeded()
    }
    
    func incrementCount() {
        count += 1
        saveCurrentDate()
    }
    
    private func saveCurrentDate() {
        let currentDate = Date()
        UserDefaults.standard.set(currentDate, forKey: lastDateKey)
    }
    
    private func resetCountIfNeeded() {
        let currentDate = Date()
        let lastDate = UserDefaults.standard.object(forKey: lastDateKey) as? Date ?? Date.distantPast
        
        let calendar = Calendar.current
        if !calendar.isDate(currentDate, inSameDayAs: lastDate) {
            count = 0
            saveCurrentDate()
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
