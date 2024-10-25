import SwiftUI
import Network
import WebKit
import AVKit

struct FirstLoginView: View {
    @EnvironmentObject var user: UserData
    @State private var isSelectedCharacter: Bool = true
    @State private var showFillName: Bool = false
    @State private var selectedName: String = ""
    @State private var selectedGrade:String = ""
    @State private var selectedClass: String = ""
    @State private var selectedAge: Int?
    @State private var showClassPicker: Bool = false
    @State private var showAgePicker: Bool = false
    @State private var showButtonCount: Int = 0
    @State private var isStart: Bool = false
    @State private var conversationCount: Int = 0
    @State private var isConnected: Bool = false
    @State private var showYouTube: Bool = true
    @State private var showAlert: Bool = false
    @State private var showGenderSelect: Bool = false
    @State private var currentGenderButton: Int?
    @State private var nameTextColor: Color = Color.textColor
    @State private var showNameAlert: Bool = false
    @State private var countdownTimer: Timer?
    @State private var countdownDuration: TimeInterval = 120.0
    private let soundManager = SoundManager.shared
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "Monitor")
    @StateObject private var bgmManager = BGMManager.shared
    @FocusState  var isActive:Bool
    @State private var rotationAngle: Double = 0 // 左右の傾き角度
    @State private var player = AVPlayer(url: Bundle.main.url(forResource: "prologue 2", withExtension: "mp4")!)
    //https://youtu.be/6SwhhYdYSm4?feature=shared
    
    @State private var bannedWords:[String] = ["死なす,死ね,しね,死,死ぬ,しぬ,殺す,殺,殺し,殺人,殺害,殺傷,ころす,ころし,きもい,きめえ,カス,変態,バカ,ファック,不細工,ブス,キチガイ,豚,くたばれ,エッチ,陰毛,いんもう,まんこ,ま○こ,マソコ,オメコ,ヴァギナ,クリトリス,ちんこ,ちんちん,チンポ,ペニス,きんたま,肉棒,勃起,ボッキ,精子,射精,ザーメン,●～,○～,セックス,体位,淫乱,初体験は,アナル,おっぱい,おっぱお,oppai,パイパイ,巨乳,貧乳,きょにゅう,ひんにゅう,きょにゅー,ひんにゅー,谷間,何カップ,手ぶら,ノーブラ,パンツ,乳首,ちくび,自慰,オナニ,オナ二,オナヌ,マスターベーション,しこって,しこしこ,脱げ,ぬげ,脱いで,喘いで,あえいで,クンニ,フェラ,まんぐり,パイズリ,ふうぞく,ふーぞく,風俗,ソープ,デリヘル,ヘルス,パンティ,姦,包茎,ほうけい,童貞,どうてい,どうてー,どーてー,性器,処女,やりまん,乱交,バイブ,ローター,パイパン,中出し,中田氏,スカトロ,糞,うんこ,パコパコ,ホモ,homo,きもい,きめえ,かす,変態,馬鹿,ばーか,baka,ファック,不細工,ぶさいく,ブス,基地外,気違い,ブタ,くたばれ,つまらない,つまんね,いらね,下手,潰せ,ビッチ,死す,死な,死ぬ,しぬ,死ね,しね,ﾀﾋね,氏ね,死の,死ん,殺,殺さ,殺し,殺せ,殺す,ころす,ころせ,殺そ,乞食,ばばあ,ばばぁ,BBA,くず,大麻,麻薬,レイプ,犯し,weed,(0|０)[0-9-０-９ー－]{9,},創価,■■■■■,☆☆☆☆,★★★★,整形,からきますた,反日,ௌ,BS,shii,SEX,S〇X,puss,dick,suck,jizz,sperm,semen,hentai,fuck f*ck,bitch,shine,nigger,nigro,tits,boob,boring,stupid,idiot,poop,ugly,shit,crap,butt,baka,heil,nazi,niga,moron,whore,weed,shii,まんこ,せっくす,裏筋,キンタマ,うんこ,くそ,クソ,糞,バカ,ちんこ,ちんちん,ぽこちん,ポコチン,カス,チンカス,オナニー,巨乳,あなる,マンコ,セックス,裏すじ,きんたま,おなにー,きょにゅう,アナル,sex,うらすじ,金玉,ウラスジ,オカマ,オナベ,オネエ,レズ,ホモ,障害者,めくら,おし,つんぼ,びっこ,知恵遅れ,ぎっちょ,どもり,かたわ,がちゃ目,痴呆,色盲,くろんぼ,支那,外人,土人,部落,キチガイ,ニガ,MDMA,覚醒剤,大麻,シャブ,コカイン,ヘロイン"]
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                if isSelectedCharacter {
                    CharacterSelectView(isSelectedCharacter: $isSelectedCharacter, showFillUserName: $showFillName)
                        .fullScreenCover(isPresented: $showYouTube) {
                            prologueView(geometry: geometry)
                        }
                } else {
                    ZStack{
                        Image("bg_AjiwaiCardView")
                            .resizable()
                            .ignoresSafeArea()
                            .onTapGesture {
                                isActive = false
                            }
                        if showFillName {
                            fillUserName()
                        } else if showClassPicker {
                            selectGradeAndClass()
                        } else if showAgePicker {
                            selectAge()
                        }else if showGenderSelect{
                            setUserGender()
                        }else if isStart {
                            gameStart(size: geometry.size)
                        }
                    }
                    .ignoresSafeArea()
                }
            }
        }
        .onAppear {
            startWobbleAnimation()
        }
    }
    
    private func startWobbleAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 1.0)) {
                self.rotationAngle = 5 * sin(Date().timeIntervalSinceReferenceDate * 2) // 回転角度の計算
            }
        }
    }
    
    private func monitorNetworkConnection() {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    isConnected = true
                }
            } else {
                DispatchQueue.main.async {
                    isConnected = false
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    private func startCountdown() {
        resetCountdown()  // Ensure any existing timer is reset
        countdownTimer = Timer.scheduledTimer(withTimeInterval: countdownDuration, repeats: false) { _ in
            showYouTube = false
            isSelectedCharacter = true
        }
    }
    
    private func resetCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
    
    @ViewBuilder private func prologueView(geometry:GeometryProxy) -> some View{
        //        if isConnected {
        //                YoutubeView()
        //                    .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.9)
        //                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
        //                    .onDisappear {
        //                        isSelectedCharacter = true
        //                        resetCountdown()
        //                        bgmManager.playBGM()
        //                    }
        //                    .onAppear {
        //                        startCountdown()
        //                        bgmManager.pauseBGM()
        //                    }
        //        } else {
        //            VStack {
        //                Text("インターネットに接続するとプロローグが再生されます。\nプロローグを再生せずに始める場合はボタンを押してください。")
        //                    .font(.custom("GenJyuuGothicX-Bold", size: 17))
        //                    .padding()
        //
        //                Button {
        //                    withAnimation {
        //                        showYouTube = false
        //                    }
        //                    soundManager.playSound(named: "se_positive")
        //                } label: {
        //                    Image("bt_base")
        //                        .resizable()
        //                        .scaledToFit()
        //                        .frame(height: 50)
        //                        .overlay {
        //                            Text("画面を閉じて次へ！")
        //                                .font(.custom("GenJyuuGothicX-Bold", size: 13))
        //                                .foregroundStyle(Color.buttonColor)
        //                        }
        //                }
        //                .buttonStyle(PlainButtonStyle())
        //            }
        //            .onAppear {
        //                monitorNetworkConnection()
        //            }
        //        }
        ZStack(alignment:.topLeading){
            VideoPlayer(player: player)
                .frame(width: geometry.size.width * 0.95, height: geometry.size.height * 0.95)
                .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
                .onDisappear {
                    player.pause()
                    isSelectedCharacter = true
                    resetCountdown()
                    bgmManager.playBGM()
                }
                .onAppear {
                    player.play()
                    player.volume = 0.5
                    startCountdown()
                    bgmManager.pauseBGM()
                }
                .onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: player.currentItem), perform: { _ in
                    showYouTube = false
                })
            Button {
                showYouTube = false
                resetCountdown()
            } label: {
                Image("bt_close")
                    .resizable()
                    .frame(width:50,height: 50)
            }
            .padding()
        }
        
    }
    @ViewBuilder func fillUserName() -> some View {
        GeometryReader{ let size = $0.size
            ZStack(alignment: .topLeading) {
                Image("\(user.selectedCharacter)_normal_1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180)
                    .rotationEffect(.degrees(rotationAngle))
                    .position(x:size.width * 0.75, y:size.height * 0.75)
                    .animation(.easeInOut(duration: 0.3), value: rotationAngle)
                Image("mt_callout")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 650)
                    .position(x:size.width * 0.5, y:size.height * 0.38)
                TypeWriterTextView("あなたの名前を教えてね", speed: 0.1, font: .custom("GenJyuuGothicX-Bold", size: 25), textColor: .textColor, onAnimationCompleted: {
                    print("アニメーションが終了しました")
                })
                .position(x: size.width * 0.5, y: size.height * 0.2)
                
                TextField("あなたの名前を入力しよう", text: $selectedName)
                    .foregroundStyle(nameTextColor)
                    .font(.custom("GenJyuuGothicX-Bold", size: 17))
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .frame(width: size.width * 0.4)
                    .position(x: size.width * 0.5, y: size.height * 0.3)
                    .focused($isActive)
                    .onChange(of: selectedName) { oldValue, newValue in
                        if newValue == "死なす" ||
                            newValue == "死ね" ||
                            newValue == "しね" ||
                            newValue == "死" ||
                            newValue == "死ぬ" ||
                            newValue == "しぬ" ||
                            newValue == "殺す" ||
                            newValue == "殺" ||
                            newValue == "殺し" ||
                            newValue == "殺人" ||
                            newValue == "殺害" ||
                            newValue == "殺傷" ||
                            newValue == "ころす" ||
                            newValue == "ころし" ||
                            newValue == "きもい" ||
                            newValue == "きめえ" ||
                            newValue == "カス" ||
                            newValue == "変態" ||
                            newValue == "バカ" ||
                            newValue == "ファック" ||
                            newValue == "不細工" ||
                            newValue == "ブス" ||
                            newValue == "キチガイ" ||
                            newValue == "豚" ||
                            newValue == "くたばれ" ||
                            newValue == "エッチ" ||
                            newValue == "陰毛" ||
                            newValue == "いんもう" ||
                            newValue == "まんこ" ||
                            newValue == "ま○こ" ||
                            newValue == "マソコ" ||
                            newValue == "オメコ" ||
                            newValue == "ヴァギナ" ||
                            newValue == "クリトリス" ||
                            newValue == "ちんこ" ||
                            newValue == "ちんちん" ||
                            newValue == "チンポ" ||
                            newValue == "ペニス" ||
                            newValue == "きんたま" ||
                            newValue == "肉棒" ||
                            newValue == "勃起" ||
                            newValue == "ボッキ" ||
                            newValue == "精子" ||
                            newValue == "射精" ||
                            newValue == "ザーメン" ||
                            newValue == "●～" ||
                            newValue == "○～" ||
                            newValue == "セックス" ||
                            newValue == "体位" ||
                            newValue == "淫乱" ||
                            newValue == "初体験は" ||
                            newValue == "アナル" ||
                            newValue == "おっぱい" ||
                            newValue == "おっぱお" ||
                            newValue == "oppai" ||
                            newValue == "パイパイ" ||
                            newValue == "巨乳" ||
                            newValue == "貧乳" ||
                            newValue == "きょにゅう" ||
                            newValue == "ひんにゅう" ||
                            newValue == "きょにゅー" ||
                            newValue == "ひんにゅー" ||
                            newValue == "谷間" ||
                            newValue == "何カップ" ||
                            newValue == "手ぶら" ||
                            newValue == "ノーブラ" ||
                            newValue == "パンツ" ||
                            newValue == "乳首" ||
                            newValue == "ちくび" ||
                            newValue == "自慰" ||
                            newValue == "オナニ" ||
                            newValue == "オナ二" ||
                            newValue == "オナヌ" ||
                            newValue == "マスターベーション" ||
                            newValue == "しこって" ||
                            newValue == "しこしこ" ||
                            newValue == "脱げ" ||
                            newValue == "ぬげ" ||
                            newValue == "脱いで" ||
                            newValue == "喘いで" ||
                            newValue == "あえいで" ||
                            newValue == "クンニ" ||
                            newValue == "フェラ" ||
                            newValue == "まんぐり" ||
                            newValue == "パイズリ" ||
                            newValue == "ふうぞく" ||
                            newValue == "ふーぞく" ||
                            newValue == "風俗" ||
                            newValue == "ソープ" ||
                            newValue == "デリヘル" ||
                            newValue == "ヘルス" ||
                            newValue == "パンティ" ||
                            newValue == "姦" ||
                            newValue == "包茎" ||
                            newValue == "ほうけい" ||
                            newValue == "童貞" ||
                            newValue == "どうてい" ||
                            newValue == "どうてー" ||
                            newValue == "どーてー" ||
                            newValue == "性器" ||
                            newValue == "処女" ||
                            newValue == "やりまん" ||
                            newValue == "乱交" ||
                            newValue == "バイブ" ||
                            newValue == "ローター" ||
                            newValue == "パイパン" ||
                            newValue == "中出し" ||
                            newValue == "中田氏" ||
                            newValue == "スカトロ" ||
                            newValue == "糞" ||
                            newValue == "うんこ" ||
                            newValue == "パコパコ" ||
                            newValue == "ホモ" ||
                            newValue == "homo" ||
                            newValue == "きもい" ||
                            newValue == "きめえ" ||
                            newValue == "かす" ||
                            newValue == "変態" ||
                            newValue == "馬鹿" ||
                            newValue == "ばーか" ||
                            newValue == "baka" ||
                            newValue == "ファック" ||
                            newValue == "不細工" ||
                            newValue == "ぶさいく" ||
                            newValue == "ブス" ||
                            newValue == "基地外" ||
                            newValue == "気違い" ||
                            newValue == "ブタ" ||
                            newValue == "くたばれ" ||
                            newValue == "つまらない" ||
                            newValue == "つまんね" ||
                            newValue == "いらね" ||
                            newValue == "下手" ||
                            newValue == "潰せ" ||
                            newValue == "ビッチ" ||
                            newValue == "死す" ||
                            newValue == "死な" ||
                            newValue == "死ぬ" ||
                            newValue == "しぬ" ||
                            newValue == "死ね" ||
                            newValue == "しね" ||
                            newValue == "ﾀﾋね" ||
                            newValue == "氏ね" ||
                            newValue == "死の" ||
                            newValue == "死ん" ||
                            newValue == "殺" ||
                            newValue == "殺さ" ||
                            newValue == "殺し" ||
                            newValue == "殺せ" ||
                            newValue == "殺す" ||
                            newValue == "ころす" ||
                            newValue == "ころせ" ||
                            newValue == "殺そ" ||
                            newValue == "乞食" ||
                            newValue == "ばばあ" ||
                            newValue == "ばばぁ" ||
                            newValue == "BBA" ||
                            newValue == "くず" ||
                            newValue == "大麻" ||
                            newValue == "麻薬" ||
                            newValue == "レイプ" ||
                            newValue == "犯し" ||
                            newValue == "weed" ||
                            newValue == "(0|０)[0-9-０-９ー－]{9,}" ||
                            newValue == "創価" ||
                            newValue == "■■■■■" ||
                            newValue == "☆☆☆☆" ||
                            newValue == "★★★★" ||
                            newValue == "整形" ||
                            newValue == "からきますた" ||
                            newValue == "反日" ||
                            newValue == "ௌ" ||
                            newValue == "BS" ||
                            newValue == "shii" ||
                            newValue == "SEX" ||
                            newValue == "S〇X" ||
                            newValue == "puss" ||
                            newValue == "dick" ||
                            newValue == "suck" ||
                            newValue == "jizz" ||
                            newValue == "sperm" ||
                            newValue == "semen" ||
                            newValue == "hentai" ||
                            newValue == "fuck" ||
                            newValue == "f*ck" ||
                            newValue == "bitch" ||
                            newValue == "shine" ||
                            newValue == "nigger" ||
                            newValue == "nigro" ||
                            newValue == "tits" ||
                            newValue == "boob" ||
                            newValue == "boring" ||
                            newValue == "stupid" ||
                            newValue == "idiot" ||
                            newValue == "poop" ||
                            newValue == "ugly" ||
                            newValue == "shit" ||
                            newValue == "crap" ||
                            newValue == "butt" ||
                            newValue == "baka" ||
                            newValue == "heil" ||
                            newValue == "nazi" ||
                            newValue == "niga" ||
                            newValue == "moron" ||
                            newValue == "whore" ||
                            newValue == "weed" ||
                            newValue == "shii" ||
                            newValue == "まんこ" ||
                            newValue == "せっくす" ||
                            newValue == "裏筋" ||
                            newValue == "キンタマ" ||
                            newValue == "うんこ" ||
                            newValue == "くそ" ||
                            newValue == "クソ" ||
                            newValue == "糞" ||
                            newValue == "バカ" ||
                            newValue == "ちんこ" ||
                            newValue == "ちんちん" ||
                            newValue == "ぽこちん" ||
                            newValue == "ポコチン" ||
                            newValue == "カス" ||
                            newValue == "チンカス" ||
                            newValue == "オナニー" ||
                            newValue == "巨乳" ||
                            newValue == "あなる" ||
                            newValue == "マンコ" ||
                            newValue == "セックス" ||
                            newValue == "裏すじ" ||
                            newValue == "きんたま" ||
                            newValue == "おなにー" ||
                            newValue == "きょにゅう" ||
                            newValue == "アナル" ||
                            newValue == "sex" ||
                            newValue == "Sex" ||
                            newValue == "うらすじ" ||
                            newValue == "金玉" ||
                            newValue == "ウラスジ" ||
                            newValue == "オカマ" ||
                            newValue == "オナベ" ||
                            newValue == "オネエ" ||
                            newValue == "レズ" ||
                            newValue == "ホモ" ||
                            newValue == "障害者" ||
                            newValue == "めくら" ||
                            newValue == "おし" ||
                            newValue == "つんぼ" ||
                            newValue == "びっこ" ||
                            newValue == "知恵遅れ" ||
                            newValue == "ぎっちょ" ||
                            newValue == "どもり" ||
                            newValue == "かたわ" ||
                            newValue == "がちゃ目" ||
                            newValue == "痴呆" ||
                            newValue == "色盲" ||
                            newValue == "くろんぼ" ||
                            newValue == "支那" ||
                            newValue == "外人" ||
                            newValue == "土人" ||
                            newValue == "部落" ||
                            newValue == "キチガイ" ||
                            newValue == "ニガ" ||
                            newValue == "MDMA" ||
                            newValue == "覚醒剤" ||
                            newValue == "大麻" ||
                            newValue == "シャブ" ||
                            newValue == "コカイン" ||
                            newValue == "ヘロイン"{
                            showNameAlert = true
                            nameTextColor = .red
                        }else{
                            showNameAlert = false
                            nameTextColor = .black
                        }
                    }
                if showNameAlert{
                    Text("使用できない言葉が含まれています。")
                        .foregroundStyle(.red)
                        .position(x: size.width * 0.5, y: size.height * 0.4)
                }
                Button {
                    if selectedName.isEmpty {
                        showAlert = true
                    } else {
                        user.name = selectedName
                        showFillName = false
                        withAnimation {
                            showClassPicker = true
                        }
                        soundManager.playSound(named: "se_positive")
                    }
                } label: {
                    Image("bt_base")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 100)
                        .overlay {
                            Text("決定!")
                                .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                .foregroundStyle(Color.buttonColor)
                        }
                }
                .disabled(showNameAlert)
                .opacity(selectedName.isEmpty ? 0.6 : 1)
                .position(x: size.width * 0.5, y: size.height * 0.8)
                .buttonStyle(PlainButtonStyle())
                .alert("注意！",isPresented: $showAlert) {
                    Button("OK"){
                        
                    }
                }message: {
                    Text("名前を入力してください")
                }
                
                Button {
                    withAnimation {
                        isSelectedCharacter = true
                        showFillName = false
                    }
                } label: {
                    Image("bt_back")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                .padding()
            }
        }
    }
    
    @ViewBuilder func selectGradeAndClass() -> some View {
        GeometryReader{ let size = $0.size
            ZStack(alignment: .topLeading) {
                Image("\(user.selectedCharacter)_normal_1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180)
                    .rotationEffect(.degrees(rotationAngle))
                    .position(x:size.width * 0.75, y:size.height * 0.75)
                    .animation(.easeInOut(duration: 0.3), value: rotationAngle)
                Image("mt_callout")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 650)
                    .position(x:size.width * 0.5, y:size.height * 0.38)
                Image("\(user.selectedCharacter)_normal_1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180)
                    .rotationEffect(.degrees(rotationAngle))
                    .position(x:size.width * 0.75, y:size.height * 0.75)
                    .animation(.easeInOut(duration: 0.3), value: rotationAngle)
                Image("mt_callout")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 650)
                    .position(x:size.width * 0.5, y:size.height * 0.38)
                TypeWriterTextView("学年とクラスを入力してね！", speed: 0.1, font: .custom("GenJyuuGothicX-Bold", size: 25), textColor: .textColor, onAnimationCompleted: {
                    print("アニメーションが終了しました")
                })
                .position(x: size.width * 0.5, y: size.height * 0.2)
                
                
                VStack(spacing: 20) {
                    TextField("学年：3年生なら 3 と入力してね", text: $selectedGrade)
                        .font(.custom("GenJyuuGothicX-Bold", size: 17))
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .frame(width: size.width * 0.4)
                        .keyboardType(.numberPad)
                        .focused($isActive)
                    
                    TextField("クラス：1組なら 1 と入力してね", text: $selectedClass)
                        .font(.custom("GenJyuuGothicX-Bold", size: 17))
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .frame(width: size.width * 0.4)
                        .keyboardType(.numberPad)
                        .focused($isActive)
                }
                .position(x: size.width * 0.5, y: size.height * 0.3)
                .ignoresSafeArea(.keyboard)
                Button {
                    if selectedGrade.isEmpty || selectedClass.isEmpty {
                        showAlert = true
                    } else {
                        user.grade = selectedGrade
                        user.yourClass = selectedClass
                        showClassPicker = false
                        soundManager.playSound(named: "se_positive")
                        withAnimation {
                            showAgePicker = true
                        }
                    }
                } label: {
                    Image("bt_base")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 100)
                        .overlay {
                            Text("決定！")
                                .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                .foregroundStyle(Color.buttonColor)
                        }
                }
                .opacity((selectedGrade.isEmpty || selectedClass.isEmpty) ? 0.6 : 1)
                .position(x: size.width * 0.5, y: size.height * 0.8)
                .buttonStyle(PlainButtonStyle())
                .alert("注意！",isPresented: $showAlert) {
                    Button("OK"){
                        
                    }
                }message: {
                    Text("学年とクラスを入力してください")
                }
                
                Button {
                    withAnimation {
                        showFillName = true
                        showClassPicker = false
                    }
                } label: {
                    Image("bt_back")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                .padding()
            }
        }
    }
    
    @ViewBuilder func selectAge() -> some View {
        GeometryReader{ let size = $0.size
            ZStack(alignment: .topLeading) {
                Image("\(user.selectedCharacter)_normal_1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180)
                    .rotationEffect(.degrees(rotationAngle))
                    .position(x:size.width * 0.75, y:size.height * 0.75)
                    .animation(.easeInOut(duration: 0.3), value: rotationAngle)
                Image("mt_callout")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 650)
                    .position(x:size.width * 0.5, y:size.height * 0.38)
                TypeWriterTextView("あなたの年齢を教えてね！", speed: 0.1, font: .custom("GenJyuuGothicX-Bold", size: 25), textColor: .textColor, onAnimationCompleted: {
                    print("アニメーションが終了しました")
                })
                .position(x: size.width * 0.5, y: size.height * 0.2)
                
                TextField("年齢を入力してね", value: $selectedAge, format: .number)
                    .font(.custom("GenJyuuGothicX-Bold", size: 17))
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .frame(width: size.width * 0.4)
                    .keyboardType(.numberPad)
                    .position(x: size.width * 0.5, y: size.height * 0.3)
                    .focused($isActive)
                Button {
                    if selectedAge == nil {
                        showAlert = true
                    } else {
                        user.age = selectedAge!
                        showAgePicker = false
                        soundManager.playSound(named: "se_positive")
                        withAnimation {
                            showGenderSelect = true
                        }
                    }
                } label: {
                    Image("bt_base")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 100)
                        .overlay {
                            Text("決定！")
                                .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                .foregroundStyle(Color.buttonColor)
                        }
                }
                .opacity(selectedAge == nil ? 0.6 : 1)
                .position(x: size.width * 0.5, y: size.height * 0.8)
                .buttonStyle(PlainButtonStyle())
                .alert("注意！",isPresented: $showAlert) {
                    Button("OK"){
                        
                    }
                }message: {
                    Text("年齢を入力してください")
                }
                
                Button {
                    withAnimation {
                        showClassPicker = true
                        showAgePicker = false
                    }
                } label: {
                    Image("bt_back")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                .padding()
            }
        }
    }
    @ViewBuilder func setUserGender() -> some View{
        GeometryReader{ let size = $0.size
            ZStack(alignment: .topLeading) {
                Image("\(user.selectedCharacter)_normal_1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180)
                    .rotationEffect(.degrees(rotationAngle))
                    .position(x:size.width * 0.75, y:size.height * 0.75)
                    .animation(.easeInOut(duration: 0.3), value: rotationAngle)
                Image("mt_callout")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 650)
                    .position(x:size.width * 0.5, y:size.height * 0.38)
                TypeWriterTextView("あなたの性別を教えてね", speed: 0.1, font: .custom("GenJyuuGothicX-Bold", size: 25), textColor: .textColor, onAnimationCompleted: {
                    print("アニメーションが終了しました")
                })
                .position(x: size.width * 0.5, y: size.height * 0.2)
                VStack{
                    HStack{
                        
                        Button{
                            user.gender = "男"
                            currentGenderButton = 1
                        }label: {
                            Text("男性")
                                .font(.custom("GenJyuuGothicX-Bold", size: 15))
                                .frame(width: 150, height: 50)
                                .background(currentGenderButton == 1 ? Color.orange : Color.white)
                                .foregroundStyle(currentGenderButton == 1 ? Color.white : Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .overlay{
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.orange ,lineWidth: 3)
                                }
                            
                        }
                        
                        Button{
                            user.gender = "女"
                            currentGenderButton = 2
                        }label: {
                            Text("女性")
                                .font(.custom("GenJyuuGothicX-Bold", size: 15))
                                .frame(width: 150, height: 50)
                                .background(currentGenderButton == 2 ? Color.orange : Color.white)
                                .foregroundStyle(currentGenderButton == 2 ? Color.white : Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .overlay{
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.orange ,lineWidth: 3)
                                }
                            
                        }
                    }
                    HStack{
                        Button{
                            user.gender = "その他"
                            currentGenderButton = 3
                        }label: {
                            Text("その他")
                                .font(.custom("GenJyuuGothicX-Bold", size: 15))
                                .frame(width: 150, height: 50)
                                .background(currentGenderButton == 3 ? Color.orange : Color.white)
                                .foregroundStyle(currentGenderButton == 3 ? Color.white : Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .overlay{
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.orange ,lineWidth: 3)
                                }
                            
                        }
                        
                        
                        
                    }
                }
                .position(x: size.width * 0.5, y: size.height * 0.4)
                HStack{
                    Button {
                        showGenderSelect = false
                        withAnimation {
                            isStart = true
                        }
                        soundManager.playSound(named: "se_positive")
                    } label: {
                        Image("bt_base")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 100)
                            .overlay {
                                Text("決定!")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                    .foregroundStyle(Color.buttonColor)
                            }
                    }
                    .disabled(currentGenderButton == nil)
                    .opacity(currentGenderButton == nil ? 0.6 : 1)
                    .buttonStyle(PlainButtonStyle())
                    Button{
                        user.gender = "答えない"
                        currentGenderButton = nil
                        showGenderSelect = false
                        withAnimation {
                            isStart = true
                        }
                        soundManager.playSound(named: "se_positive")
                    }label: {
                        Text("スキップ")
                            .font(.custom("GenJyuuGothicX-Bold", size: 15))
                            .frame(width: 180, height: 50)
                            .background(Color.white)
                            .foregroundStyle( Color.skipColor)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .overlay{
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.skipColor ,lineWidth: 4)
                            }
                        
                    }
                }
                .position(x: size.width * 0.5, y: size.height * 0.8)
                .buttonStyle(PlainButtonStyle())
                Button {
                    withAnimation {
                        showAgePicker = true
                        showGenderSelect = false
                    }
                } label: {
                    Image("bt_back")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                .padding()
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    @ViewBuilder func gameStart(size: CGSize) -> some View {
        ZStack(alignment: .topLeading) {
            Image("\(user.selectedCharacter)_normal_1")
                .resizable()
                .scaledToFit()
                .frame(width: 180)
                .rotationEffect(.degrees(rotationAngle))
                .position(x:size.width * 0.75, y:size.height * 0.75)
                .animation(.easeInOut(duration: 0.3), value: rotationAngle)
            Image("mt_callout")
                .resizable()
                .scaledToFit()
                .frame(width: 650)
                .position(x:size.width * 0.5, y:size.height * 0.38)
            
            VStack(alignment: .leading) {
                if conversationCount == 0 {
                    TypeWriterTextView("それじゃあゲームを始めるよ\n準備はいい？", speed: 0.1, font: .custom("GenJyuuGothicX-Bold", size: 17), textColor: .textColor, onAnimationCompleted: {
                        print("アニメーションが終了しました")
                        showButtonCount = 1
                    })
                } else if conversationCount == 1 {
                    TypeWriterTextView("よし！これからよろしくね！", speed: 0.1, font: .custom("GenJyuuGothicX-Bold", size: 17), textColor: .textColor, onAnimationCompleted: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            user.isLogined = true
                        }
                    })
                }
            }
            .position(x: size.width * 0.5, y: size.height * 0.35)
            
            Button {
                withAnimation {
                    showAgePicker = true
                    isStart = false
                }
            } label: {
                Image("bt_back")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            }
            .padding()
            .buttonStyle(PlainButtonStyle())
            if showButtonCount == 1 {
                Button {
                    conversationCount = 1
                    showButtonCount = 0
                    soundManager.playSound(named: "se_positive")
                } label: {
                    Image("bt_base")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 100)
                        .overlay {
                            Text("もちろん!")
                                .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                .foregroundStyle(Color.buttonColor)
                        }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 30)
                .position(x: size.width * 0.5, y: size.height * 0.8)
            }
        }
        .onAppear {
            showButtonCount = 0
        }
    }
}

#Preview {
    FirstLoginView()
        .environmentObject(UserData())
}

struct TypeWriterTextView: View {
    private let text: String
    private let speed: TimeInterval
    private let font: Font
    private let textColor: Color
    private let onAnimationCompleted: () -> Void
    
    @State private var textArray: String = ""
    
    init(_ text: String, speed: TimeInterval = 0.1, font: Font = .body, textColor: Color = .primary, onAnimationCompleted: @escaping () -> Void) {
        self.text = text
        self.speed = speed
        self.font = font
        self.textColor = textColor
        self.onAnimationCompleted = onAnimationCompleted
    }
    
    var body: some View {
        Text(textArray)
            .font(font)
            .foregroundColor(textColor)
            .onAppear {
                startAnimation()
            }
    }
    
    private func startAnimation() {
        DispatchQueue.global().async {
            for character in text {
                Thread.sleep(forTimeInterval: speed)
                DispatchQueue.main.async {
                    textArray += String(character)
                }
            }
            DispatchQueue.main.async {
                onAnimationCompleted()
            }
        }
    }
}

struct YouTubeViewRepresentable: UIViewRepresentable {
    let videoID: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false  // Disable scrolling
        webView.contentMode = .scaleAspectFit  // Adjust content scaling
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let htmlString = """
        <html>
        <body style="margin:0;padding:0;">
        <iframe width="100%" height="100%" src="https://www.youtube.com/embed/\(videoID)?playsinline=1" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
        </body>
        </html>
        """
        uiView.loadHTMLString(htmlString, baseURL: nil)
    }
}
struct YoutubeView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack{
            YouTubeViewRepresentable(videoID: "6SwhhYdYSm4")
                .padding(.horizontal)
                .toolbar{
                    ToolbarItem{
                        Button{
                            dismiss()
                        }label: {
                            Image("bt_close")
                                .resizable()
                                .frame(width: 35,height: 35)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
        }
    }
}

#Preview {
    YoutubeView()
}
