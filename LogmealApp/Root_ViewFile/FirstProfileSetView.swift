//
//  FirstProfileSetView.swift
//  LogmealApp
//
//  Created by 山口昂大 on 2025/05/20.
//

import Foundation
import SwiftUI
import PhotosUI

struct ForstProfileSetView:View {
    @EnvironmentObject var userData:UserData
    @State var showSaveSuccess:Bool = false
    @State private var isAllProfileSet:Bool = false
    @State private var userName: String = ""
    @State private var userGrade: Int = 1
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
    @State private var currentPage:Int = 0
    
    @State private var rotationAngle: Double = 0 // 左右の傾き角度
    private func saveNewProfile(){
        if let userImage = self.userImage{
            userData.name = self.userName
            userData.age = self.userAge
            userData.yourClass = self.userClass
            userData.grade = String(self.userGrade)
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
    private func startWobbleAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 1.0)) {
                self.rotationAngle = 5 * sin(Date().timeIntervalSinceReferenceDate * 2) // 回転角度の計算
            }
        }
    }
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                Image("bg_AjiwaiCardView")
                    .resizable()
                    .ignoresSafeArea()
                if !showUserImagePicker{
                    Image("mt_callout")
                        .resizable()
                        .frame(width: geometry.size.width*0.6,height: geometry.size.height*0.5)
                        .position(x:geometry.size.width * 0.5, y:geometry.size.height * 0.5)
                }
                if isAllProfileSet{
                    if currentPage == 5{
                        HStack{
                            Spacer()
                            VStack{
                                Spacer()
                                TypeWriterTextView("それじゃあゲームを始めるよ\n準備はいい？", speed: 0.1, font: .custom("GenJyuuGothicX-Bold", size: 28), textColor: .textColor, onAnimationCompleted: {
                                    print("アニメーションが終了しました")
                                })
                                Spacer()
                                Button{
                                    currentPage = 6
                                }label: {
                                    Text("もちろん！")
                                        .font(.custom("GenJyuuGothicX-Bold",size:15))
                                        .frame(width: 200, height: 60)
                                        .background(Color.buttonColor)
                                        .foregroundStyle(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                        .overlay{
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color.buttonColor ,lineWidth: 4)
                                        }
                                }
                            }
                            Spacer()
                        }
                    }else if currentPage == 6{
                        TypeWriterTextView("よし！これからよろしくね！", speed: 0.1, font: .custom("GenJyuuGothicX-Bold", size: 28), textColor: .textColor, onAnimationCompleted: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                withAnimation {
                                    userData.isLogined = true
                                }
                            }
                        })
                        .offset(y:-geometry.size.height*0.05)
                    }
                }else{
                    VStack{
                        HStack{
                            Spacer()
                            Button{
                                if currentPage > 0 || currentPage < 4{
                                    currentPage -= 1
                                    print(currentPage)
                                }
                            }label: {
                                Text("もどる")
                                    .font(.custom("GenJyuuGothicX-Bold",size:15))
                                    .frame(width: 100, height: 50)
                                    .background(Color.white)
                                    .foregroundStyle(currentPage == 0 ? .gray : .red)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .overlay{
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(currentPage == 0 ? .gray : .red ,lineWidth: 4)
                                    }
                            }
                            .disabled(currentPage == 0)
                            progressBar(size: geometry.size)
                                .padding()
                            Button{
                                if currentPage < 4{
                                    currentPage += 1
                                    print(currentPage)
                                }else{
                                    saveNewProfile()
                                    currentPage = 5
                                    isAllProfileSet = true
                                }
                            }label: {
                                Text("スキップ")
                                    .font(.custom("GenJyuuGothicX-Bold",size:15))
                                    .frame(width: 100, height: 50)
                                    .background(Color.white)
                                    .foregroundStyle(currentPage == 4 ? .gray : .cyan)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .overlay{
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(currentPage == 4 ? .gray : .cyan ,lineWidth: 4)
                                    }
                            }
                            .disabled(currentPage == 4)
                            Spacer()
                        }
                        Spacer()
                        VStack{
                            switch currentPage{
                            case 0:
                                nameSetView(size: geometry.size)
                            case 1:
                                classSetView(size:geometry.size)
                            case 2:
                                gradeSetView(size: geometry.size)
                            case 3:
                                ageSetView(size: geometry.size)
                            case 4:
                                userImageSetView(size: geometry.size)
                            default:
                                Text("エラー")
                            }
                        }
                        .offset(y:-geometry.size.height*0.05)
                        Spacer()
                        Button{
                            if currentPage < 4{
                                currentPage += 1
                                print(currentPage)
                            }else{
                                saveNewProfile()
                                currentPage = 5
                                isAllProfileSet = true
                            }
                        }label: {
                            Text("つぎへ")
                                .font(.custom("GenJyuuGothicX-Bold",size:15))
                                .frame(width: 200, height: 60)
                                .background(Color.buttonColor)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .overlay{
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.buttonColor ,lineWidth: 4)
                                }
                        }
                        .disabled(isAnimating)
                    }
                    .padding(.vertical)
                    
                }
                Image("\(userData.selectedCharacter)_normal_1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180)
                    .rotationEffect(.degrees(rotationAngle))
                    .position(x:geometry.size.width * 0.75, y:geometry.size.height * 0.8)
                    .animation(.easeInOut(duration: 0.3), value: rotationAngle)
            }
            .onAppear(){
                startWobbleAnimation()
            }
        }
    }
    private func progressBar(size:CGSize) -> some View{
        ZStack(alignment:.leading){
            RoundedRectangle(cornerRadius: 30)
                .frame(width:size.width*0.6,height: size.height*0.05)
                .foregroundStyle(.gray)
            RoundedRectangle(cornerRadius: 30)
                .frame(width:size.width*0.3,height: size.height*0.05)
                .foregroundStyle(.green)
        }
    }
    private func nameSetView(size:CGSize) -> some View{
        VStack{
            TypeWriterTextView("あなたのお名前を教えてね？", speed: 0.1, font: .custom("GenJyuuGothicX-Bold", size: 30), textColor: .textColor, onAnimationCompleted: {
                print("アニメーションが終了しました")
            })
            HStack{
                Text("お名前")
                    .font(.custom("GenJyuuGothicX-Bold", size: 25))
                TextField("例）山田雄斗, やまだゆうと", text: $userName)
                    .font(.custom("GenJyuuGothicX-Bold", size: 30))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: size.width*0.43)
                    .foregroundStyle(nameTextColor)
                    .padding(.horizontal)
                    .multilineTextAlignment(TextAlignment.leading)
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
    }
    private func ageSetView(size:CGSize) -> some View{
        VStack{
            TypeWriterTextView("あなたの年齢を教えてね！", speed: 0.1, font: .custom("GenJyuuGothicX-Bold", size: 30), textColor: .textColor, onAnimationCompleted: {
                print("アニメーションが終了しました")
            })
            HStack{
                Text("年齢")
                    .font(.custom("GenJyuuGothicX-Bold", size: 25))
                TextField("例）10", value: $userAge,format: .number)
                    .font(.custom("GenJyuuGothicX-Bold", size: 30))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: size.width*0.43)
                    .foregroundStyle(.black)
                    .padding(.horizontal)
            }
        }
    }
    private func gradeSetView(size:CGSize) -> some View{
        VStack{
            TypeWriterTextView("あなたの学年を教えてね！", speed: 0.1, font: .custom("GenJyuuGothicX-Bold", size: 30), textColor: .textColor, onAnimationCompleted: {
                print("アニメーションが終了しました")
            })
            HStack{
                Text("学年")
                    .font(.custom("GenJyuuGothicX-Bold", size: 25))
                TextField("例）1", value: $userGrade,format: .number)
                    .font(.custom("GenJyuuGothicX-Bold", size: 30))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: size.width*0.43)
                    .foregroundStyle(.black)
                    .padding(.horizontal)
            }
        }
    }
    private func classSetView(size:CGSize) -> some View{
        VStack{
            TypeWriterTextView("あなたのクラスを教えてね！", speed: 0.1, font: .custom("GenJyuuGothicX-Bold", size: 30), textColor: .textColor, onAnimationCompleted: {
                print("アニメーションが終了しました")
            })
            HStack{
                Text("クラス")
                    .font(.custom("GenJyuuGothicX-Bold", size: 25))
                TextField("例）2, B", text: $userClass)
                    .font(.custom("GenJyuuGothicX-Bold", size: 30))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: size.width*0.43)
                    .foregroundStyle(.black)
                    .padding(.horizontal)
            }
        }
    }
    @State private var showUserImagePicker:Bool = false
    @State private var isAnimating = false
    private func userImageSetView(size:CGSize) -> some View{
        VStack{
            if showUserImagePicker{
                PhotosPicker(selection: $selectedPhotoItem) {
                    VStack{
                        if let userImage = self.userImage{
                            Image(uiImage: userImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: size.width*0.3)
                                .clipShape(Circle())
                        }else{
                            Image("mt_newSettingView_userImage")
                                .resizable()
                                .scaledToFit()
                                .frame(width: size.width*0.3)
                                .clipShape(Circle())
                                .overlay {
                                    Circle()
                                        .stroke(.gray, lineWidth: 5)
                                }
                        }
                        Label("写真を選ぶ", systemImage: "photo")
                            .font(.custom("GenJyuuGothicX-Bold", size: 25))
                    }
                }
            }else{
                TypeWriterTextView("あなたのアイコンを決めよう！", speed: 0.1, font: .custom("GenJyuuGothicX-Bold", size: 28), textColor: .textColor, onAnimationCompleted: {
                    print("アニメーションが終了しました")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        withAnimation {
                            showUserImagePicker = true
                            isAnimating = false
                        }
                    }
                })
            }
        }
        .onChange(of: selectedPhotoItem) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let userImage = UIImage(data: data) {
                    self.userImage = userImage
                }
            }
        }
        .onAppear(){
            isAnimating = true
        }
        .onDisappear(){
            isAnimating = false
            showUserImagePicker = false
        }
    }
}

#Preview {
    FirstLoginView()
        .environmentObject(UserData())
}
