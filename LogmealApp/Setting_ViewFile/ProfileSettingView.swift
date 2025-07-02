import SwiftUI
import PhotosUI

struct ProfileSettingView: View {
    @EnvironmentObject var userData:UserData
    @State var showSaveSuccess:Bool = false
    @State private var userName: String = ""
    @State private var userGrade: String = ""
    @State private var userClass: String = ""
    @State private var userAge: Int = 6
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var userImage:UIImage? = nil
    @State private var showNameAlert = false
    @State private var nameTextColor = Color.black
    //AsyncImageをUIImageに変換して取得したサイズ
    @State private var asyncImageSize: CGSize? = nil
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
        GeometryReader{ geometry in
            ZStack {
                
                Image("bg_newSettingView.png")
                    .resizable()
                    .ignoresSafeArea()
                
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: geometry.size.width*0.8, height: geometry.size.height*0.9)
                    .foregroundStyle(Color(red: 220/255, green: 221/255, blue: 221/255))
                    .shadow(radius: 5)
                ScrollView{
                    if let userImage = self.userImage{
                        if userImage.size.width < userImage.size.height{
                            Image(uiImage: userImage)
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                                .frame(width: geometry.size.width * 0.2)
                                

                        }else{
                            Image(uiImage: userImage)
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                                .frame(width: geometry.size.width * 0.28)
                                .padding(.vertical,35)
                        }
                    }else{
                        AsyncImage(url: userData.userImage) { phase in
                            switch phase {
                            case .empty:
                                Image("no_user_image")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width * 0.2)
                                    .overlay {
                                        Circle()
                                            .stroke(Color(red: 236/255, green: 178/255, blue: 183/255), lineWidth: 5)
                                    }
                            case .success(let image):
                                // 画像サイズ取得用
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width:asyncImageSize?.width ?? 1 < asyncImageSize?.height ?? 0 ? geometry.size.width * 0.2 : geometry.size.width * 0.28)
                                    .clipShape(Circle())
                                    .padding(.vertical, asyncImageSize?.width ?? 1 < asyncImageSize?.height ?? 0 ? 0 :35)
                                    .background(
                                        GeometryReader { geo in
                                            Color.clear
                                                .onAppear {
                                                    if asyncImageSize == nil {
                                                        // UIImageを取得してサイズ判定
                                                        if let url = userData.userImage,
                                                            let data = try? Data(contentsOf: url),
                                                            let uiImage = UIImage(data: data) {
                                                            asyncImageSize = uiImage.size
                                                        }
                                                    }
                                                }
                                        }
                                    )
                            case .failure(_):
                                Image("no_user_image")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width * 0.2)
                                    .overlay {
                                        Circle()
                                            .stroke(Color(red: 236/255, green: 178/255, blue: 183/255), lineWidth: 5)
                                    }
                            @unknown default:
                                Image("no_user_image")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width * 0.2)
                                    .overlay {
                                        Circle()
                                            .stroke(Color(red: 236/255, green: 178/255, blue: 183/255), lineWidth: 5)
                                    }
                            }
                        }
                    }
                    
                    HStack{
                        PhotosPicker(selection: $selectedPhotoItem) {
                            Label("写真を選ぶ", systemImage: "photo")
                                .font(.custom("GenJyuuGothicX-Bold", size: 20))
                        }
                        if userImage != nil{
                            Button{
                                withAnimation {
                                    userImage = nil
                                }
                            }label:{
                                Text("写真をリセット")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                    
                            }
                            .padding(.horizontal)
                        }
                    }
                    Image("mt_newSettingView_profileHeadline")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width*0.63)
                    
                    // 名前入力
                    Rectangle()
                        .foregroundStyle(.white)
                        .frame(width: geometry.size.width*0.63,height: geometry.size.height*0.07)
                        .overlay {
                            HStack {
                                Text("名前")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 28))
                                    .padding(.leading)
                                Spacer()
                                TextField("ここに名前を入力してください", text: $userName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .font(.custom("GenJyuuGothicX-Bold", size: 18))
                                    .frame(width: geometry.size.width*0.43)
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
                    Rectangle()
                        .foregroundStyle(.white)
                        .frame(width: geometry.size.width*0.63,height: geometry.size.height*0.07)
                        .overlay {
                            HStack {
                                Text("学年")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 28))
                                    .padding(.leading)
                                Spacer()
                                
                                Picker("選択してください", selection: $userGrade) {
                                    ForEach(gradeArray, id: \.self) { grade in
                                        Text("\(grade)年").tag(grade)
                                            .font(.custom("GenJyuuGothicX-Bold", size: 18))
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .font(.custom("GenJyuuGothicX-Bold", size: 18))
                                .frame(width: 150)
                            }
                            
                        }
                    
                    // クラス選択
                    Rectangle()
                        .foregroundStyle(.white)
                        .frame(width: geometry.size.width*0.63,height: geometry.size.height*0.07)
                        .overlay {
                            HStack {
                                Text("クラス")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 28))
                                    .padding(.leading)
                                Spacer()
                                
                                Picker("選択してください", selection: $userClass) {
                                    ForEach(classArray, id: \.self) { classNum in
                                        Text("\(classNum)組").tag(classNum)
                                            .font(.custom("GenJyuuGothicX-Bold", size: 18))
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .font(.custom("GenJyuuGothicX-Bold", size: 18))
                                .frame(width: 150)
                            }
                            
                        }
                    
                    // 年齢選択
                    Rectangle()
                        .foregroundStyle(.white)
                        .frame(width: geometry.size.width*0.63,height: geometry.size.height*0.07)
                        .overlay {
                            HStack {
                                Text("年齢")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 28))
                                    .padding(.leading)
                                Spacer()
                                
                                Picker("選択してください", selection: $userAge) {
                                    ForEach(6...18, id: \.self) { age in
                                        Text("\(age)歳").tag(age)
                                            .font(.custom("GenJyuuGothicX-Bold", size: 18))
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .font(.custom("GenJyuuGothicX-Bold", size: 18))
                                .frame(width: 150)
                            }
                            
                        }
                }
                .frame(width: geometry.size.width*0.8, height: geometry.size.height*0.85)
                .padding()
                VStack{
                    HStack{
                        Spacer()
                        Button{
                            saveNewProfile()
                            showSaveSuccess = true
                            print("押された")
                        }label: {
                            Text("ほぞんする")
                                .font(.custom("GenJyuuGothicX-Bold",size:15))
                                .frame(width: 160, height: 50)
                                .background(Color.white)
                                .foregroundStyle(Color.cyan)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .overlay{
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.cyan ,lineWidth: 4)
                                }
                        }
                    }
                    Spacer()
                }
                .padding()
            }
            .onAppear(){
                print(geometry.size)
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
            .alert(isPresented: $showSaveSuccess) {
                Alert(
                    title: Text("プロフィールを更新しました").font(.custom("GenJyuuGothicX-Bold", size: 18)),
                    dismissButton: .default(Text("OK")) {
                        
                    }
                )
            }
        }
    }
}

#Preview{
    NewSettingView()
        .environmentObject(UserData())
}
#Preview{
    NewContentView()
        .environmentObject(UserData())
}
