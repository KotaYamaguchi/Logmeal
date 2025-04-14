import SwiftUI
import PhotosUI

struct ProfileSettingView: View {
    @EnvironmentObject var userData:UserData
    @State var isFirst:Bool
    @State private var userName: String = ""
    @State private var userGrade: String = ""
    @State private var userClass: String = ""
    @State private var userAge: Int = 6
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var userImage:UIImage? = nil
    @State private var showNameAlert = false
    @State private var nameTextColor = Color.black
    let gradeArray = ["1","2","3","4","5","6"]
    let classArray = ["1","2","3","4","5","6","7","8","9","10"]
    let bannedWords: [String] = [
        "死なす",
        "死ね",
        "しね",
        "死",
        "死ぬ",
        "しぬ",
        "殺す",
        "殺",
        "殺し",
        "殺人",
        "殺害",
        "殺傷",
        "ころす",
        "ころし",
        "きもい",
        "きめえ",
        "カス",
        "変態",
        "バカ",
        "ファック",
        "不細工",
        "ブス",
        "キチガイ",
        "豚",
        "くたばれ",
        "エッチ",
        "陰毛",
        "いんもう",
        "まんこ",
        "ま○こ",
        "マソコ",
        "オメコ",
        "ヴァギナ",
        "クリトリス",
        "ちんこ",
        "ちんちん",
        "チンポ",
        "ペニス",
        "きんたま",
        "肉棒",
        "勃起",
        "ボッキ",
        "精子",
        "射精",
        "ザーメン",
        "●～",
        "○～",
        "セックス",
        "体位",
        "淫乱",
        "初体験は",
        "アナル",
        "おっぱい",
        "おっぱお",
        "oppai",
        "パイパイ",
        "巨乳",
        "貧乳",
        "きょにゅう",
        "ひんにゅう",
        "きょにゅー",
        "ひんにゅー",
        "谷間",
        "何カップ",
        "手ぶら",
        "ノーブラ",
        "パンツ",
        "乳首",
        "ちくび",
        "自慰",
        "オナニ",
        "オナ二",
        "オナヌ",
        "マスターベーション",
        "しこって",
        "しこしこ",
        "脱げ",
        "ぬげ",
        "脱いで",
        "喘いで",
        "あえいで",
        "クンニ",
        "フェラ",
        "まんぐり",
        "パイズリ",
        "ふうぞく",
        "ふーぞく",
        "風俗",
        "ソープ",
        "デリヘル",
        "ヘルス",
        "パンティ",
        "姦",
        "包茎",
        "ほうけい",
        "童貞",
        "どうてい",
        "どうてー",
        "どーてー",
        "性器",
        "処女",
        "やりまん",
        "乱交",
        "バイブ",
        "ローター",
        "パイパン",
        "中出し",
        "中田氏",
        "スカトロ",
        "糞",
        "うんこ",
        "パコパコ",
        "ホモ",
        "homo",
        "きもい",
        "きめえ",
        "かす",
        "変態",
        "馬鹿",
        "ばーか",
        "baka",
        "ファック",
        "不細工",
        "ぶさいく",
        "ブス",
        "基地外",
        "気違い",
        "ブタ",
        "くたばれ",
        "つまらない",
        "つまんね",
        "いらね",
        "下手",
        "潰せ",
        "ビッチ",
        "死す",
        "死な",
        "死ぬ",
        "しぬ",
        "死ね",
        "しね",
        "ﾀﾋね",
        "氏ね",
        "死の",
        "死ん",
        "殺",
        "殺さ",
        "殺し",
        "殺せ",
        "殺す",
        "ころす",
        "ころせ",
        "殺そ",
        "乞食",
        "ばばあ",
        "ばばぁ",
        "BBA",
        "くず",
        "大麻",
        "麻薬",
        "レイプ",
        "犯し",
        "weed",
        "(0|０)[0-9-０-９ー－]{9",
        "}",
        "創価",
        "■■■■■",
        "☆☆☆☆",
        "★★★★",
        "整形",
        "からきますた",
        "反日",
        "ௌ",
        "BS",
        "shii",
        "SEX",
        "S〇X",
        "puss",
        "dick",
        "suck",
        "jizz",
        "sperm",
        "semen",
        "hentai",
        "fuck f*ck",
        "bitch",
        "shine",
        "nigger",
        "nigro",
        "tits",
        "boob",
        "boring",
        "stupid",
        "idiot",
        "poop",
        "ugly",
        "shit",
        "crap",
        "butt",
        "baka",
        "heil",
        "nazi",
        "niga",
        "moron",
        "whore",
        "weed",
        "shii",
        "まんこ",
        "せっくす",
        "裏筋",
        "キンタマ",
        "うんこ",
        "くそ",
        "クソ",
        "糞",
        "バカ",
        "ちんこ",
        "ちんちん",
        "ぽこちん",
        "ポコチン",
        "カス",
        "チンカス",
        "オナニー",
        "巨乳",
        "あなる",
        "マンコ",
        "セックス",
        "裏すじ",
        "きんたま",
        "おなにー",
        "きょにゅう",
        "アナル",
        "sex",
        "うらすじ",
        "金玉",
        "ウラスジ",
        "オカマ",
        "オナベ",
        "オネエ",
        "レズ",
        "ホモ",
        "障害者",
        "めくら",
        "おし",
        "つんぼ",
        "びっこ",
        "知恵遅れ",
        "ぎっちょ",
        "どもり",
        "かたわ",
        "がちゃ目",
        "痴呆",
        "色盲",
        "くろんぼ",
        "支那",
        "外人",
        "土人",
        "部落",
        "キチガイ",
        "ニガ",
        "MDMA",
        "覚醒剤",
        "大麻",
        "シャブ",
        "コカイン",
        "ヘロイン"
    ]
    private func saveNewProfile(){
        if let userImage = self.userImage{
            userData.name = self.userName
            userData.age = self.userAge
            userData.yourClass = self.userClass
            userData.grade = self.userGrade
            userData.userImage = getDocumentPath(saveData: userImage, fileName: "userImage")
        }
    }
    private func getDocumentPath(saveData: UIImage, fileName: String) -> URL {
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentURL.appendingPathComponent(fileName + ".jpeg")
        do {
            try saveData.jpegData(compressionQuality: 1.0)?.write(to: fileURL)
        } catch {
            print("画像の保存に失敗しました: \(error)")
        }
        return fileURL
    }
    var body: some View {
        ZStack {
            if !isFirst{
                Image("bg_newSettingView.png")
                    .resizable()
                    .ignoresSafeArea()
            }
            ZStack{
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 650, height: 780)
                    .foregroundStyle(Color(red: 220/255, green: 221/255, blue: 221/255))
                    .shadow(radius: 5)
            }
            VStack{
                PhotosPicker(selection: $selectedPhotoItem) {
                    if let userImage = self.userImage{
                        Image(uiImage: userImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width:350)
                            .clipShape(Circle())
                    }else{
                        Image("mt_newSettingView_userImage")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 350)
                            .clipShape(Circle())
                    }
                }
                PhotosPicker(selection: $selectedPhotoItem) {
                    Label("写真を選ぶ", systemImage: "photo")
                }
                Image("mt_newSettingView_profileHeadline")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 550)
                
                // 名前入力
                Image("mt_newSettingView_name")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 550)
                    .overlay {
                        HStack {
                            Spacer()
                            TextField("ここに名前を入力してください", text: $userName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 400)
                                .foregroundStyle(nameTextColor)
                                .padding(.horizontal)
                                .multilineTextAlignment(TextAlignment.trailing)
                                .onChange(of: userName) { oldValue, newValue in
                                    let containsBannedWord = bannedWords.contains { word in
                                        newValue.localizedCaseInsensitiveContains(word)
                                    }

                                    if containsBannedWord {
                                        showNameAlert = true
                                        nameTextColor = .red
                                    } else {
                                        showNameAlert = false
                                        nameTextColor = .black
                                    }
                                }
                        }
                    }
                
                // 学年選択
                Image("mt_newSettingView_grade")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 550)
                    .overlay {
                        HStack {
                            Spacer()
                            
                            Picker("選択してください", selection: $userGrade) {
                                ForEach(gradeArray, id: \.self) { grade in
                                    Text("\(grade)年").tag(grade)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 150)
                        }
                        .padding(.horizontal)
                    }
                
                // クラス選択
                Image("mt_newSettingView_class")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 550)
                    .overlay {
                        HStack {
                            Spacer()
                            
                            Picker("選択してください", selection: $userClass) {
                                ForEach(classArray, id: \.self) { classNum in
                                    Text("\(classNum)組").tag(classNum)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 150)
                        }
                        .padding(.horizontal)
                    }
                
                // 年齢選択
                Image("mt_newSettingView_age")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 550)
                    .overlay {
                        HStack {
                            Spacer()
                            
                            Picker("選択してください", selection: $userAge) {
                                ForEach(6...18, id: \.self) { age in
                                    Text("\(age)歳").tag(age)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 150)
                        }
                        .padding(.horizontal)
                    }
            }
            .padding()
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    if !isFirst{
                        Button{
                            saveNewProfile()
                        }label:{
                            Text("保存する")
                                .font(.headline)
                                .padding()
                                .frame(width:150,height: 60)
                                .foregroundStyle(.white)
                                .background(RoundedRectangle(cornerRadius: 10))
                        }
                        .padding()
                    }
                }
            }
            .padding(.horizontal)
        }
        .onAppear(){
            userName = userData.name
            userGrade = userData.grade
            userAge = userData.age
            userClass = userData.yourClass
            
            print(userData.name)
            print(userData.age)
            print(userData.grade)
            print(userData.yourClass)
        }
        .onChange(of: selectedPhotoItem) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let userImage = UIImage(data: data) {
                    self.userImage = userImage
                }
            }
        }
    }
}

#Preview{
    ProfileSettingView(isFirst: false)
        .environmentObject(UserData())
}
#Preview{
    NewContentView()
        .environmentObject(UserData())
}
