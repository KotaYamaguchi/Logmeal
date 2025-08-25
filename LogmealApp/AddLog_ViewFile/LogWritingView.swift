import SwiftUI
import PhotosUI
import SwiftData

struct NewWritingView: View {
    @StateObject var debugContentsManager = DebugContentsManager.shared
    @EnvironmentObject var user: UserData
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var allData: [AjiwaiCardData]
    @Query private var allMenu:[MenuData]
    @Query private var characters: [Character]
    @State private var timeStanp:TimeStamp? = nil
    @State private var currentDate: Date = Date()
    @Binding var showWritingView: Bool
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var uiImage: UIImage? = nil
    @State private var editedText: String = ""
    @State private var editedSenseText: [String] = ["","","","",""]
    @State private var editedMenu: [String] = ["","","",""]
    @State private var showCameraPicker = false
    @State private var showingSaveAlert = false
    @State private var showDatePicker:Bool = false
    @State private var saveResultMessage: String? = nil
    @State private var showSaveResultAlert: Bool = false
    private let senseIcons = ["mt_Eye_icon", "mt_Ear_icon", "mt_Nose_icon", "mt_Tongue_icon", "mt_Hand_Icon"]
    private let senseTitles = ["みため", "おと", "におい", "あじ", "さわりごこち"]
    private let sensePlaceholders = [
        "どんな色やかたちだったかな？",
        "どんな音がしたかな？",
        "どんなにおいがしたかな？",
        "どんな味がしたかな？",
        "さわってみてどうだった？"
    ]
    private let senseColors: [Color] = [
        Color(red: 240 / 255, green: 145 / 255, blue: 144 / 255),
        Color(red: 243 / 255, green: 179 / 255, blue: 67 / 255),
        Color(red: 105 / 255, green: 192 / 255, blue: 160 / 255),
        Color(red: 139 / 255, green: 194 / 255, blue: 222 / 255),
        Color(red: 196 / 255, green: 160 / 255, blue: 193 / 255)
    ]
    private func dateFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    func saveCurrentData(
        saveDay: Date,
        times: TimeStamp,
        sight: String,
        taste: String,
        smell: String,
        tactile: String,
        hearing: String,
        uiImage: UIImage,
        menu: [String]
    ) {
        // 最初にユニークなファイル名を生成
        let fileName = generateUniqueImageFileName(saveDay: saveDay, timeStamp: times)

        // 新しい関数を使って画像を保存し、ファイル名を取得
        guard let savedFileName = saveImageToDocumentDirectory(image: uiImage, fileName: fileName) else {
            saveResultMessage = "画像の保存に失敗しました"
            showSaveResultAlert = true
            return
        }

        let newData = AjiwaiCardData(
            saveDay: saveDay,
            times: times,
            sight: sight,
            taste: taste,
            smell: smell,
            tactile: tactile,
            hearing: hearing,
            imagePath: URL(string: "file://dummy")!, // 仮のURLを保存
            menu: menu,
            imageFileName: savedFileName // ファイル名を保存
        )
        context.insert(newData)
        do {
            try context.save()
            saveResultMessage = "保存に成功しました！"
            print("メニュー = \(newData.menu)")
            print("五感(聴覚) = \(newData.hearing)")
            
            var totalCharacterCount = 0
            // 一言コメントの文字数を加算
            totalCharacterCount += editedText.count
            // 五感コメントの文字数を加算
            for text in editedSenseText {
                totalCharacterCount += text.count
            }
            
            // 合計文字数に基づいて基本経験値を計算 (例: 3文字で1EXP)
            let baseExp = totalCharacterCount / 10 // 調整可能
            
            // 最も近い5の倍数に丸める
            // (baseExp + 2) / 5 * 5 は、整数演算で最も近い5の倍数に丸める一般的な方法
            // 例: 4 -> 5, 7 -> 5, 8 -> 10, 12 -> 10, 13 -> 15
            let expToAward = (baseExp + 2) / 5 * 5
            
            // 文字数が0の場合は経験値0、それ以外は最低5経験値を保証
            let finalExp = totalCharacterCount > 0 ? max(5, expToAward) : 0
            
            user.gainExp(finalExp, current: characters.first(where: {$0.isSelected})!) // 計算された経験値を付与
            if characters.first(where: {$0.isSelected})!.level >= 12{
                characters.first(where: {$0.isSelected})!.growthStage = 3
                user.showGrowthAnimation = true
                user.isGrowthed = true
            }else if characters.first(where: {$0.isSelected})!.level >= 5{
                characters.first(where: {$0.isSelected})!.growthStage = 2
                user.showGrowthAnimation = true
                user.isGrowthed = true
            }
        } catch {
            print("保存に失敗しました: \(error)")
            saveResultMessage = "保存に失敗しました…"
        }
        
        
        showSaveResultAlert = true
    }
    // ユーザー経験値の更新処理
    private func updateUserExperience(by gainedExp: Int) {
        characters.first(where: {$0.isSelected})!.exp += gainedExp / 10 //　10文字につき1exp
        
        
        var newLevel = 0
        // しきい値配列の各値と経験値を比較し、条件を満たす場合にレベルを更新
        for threshold in user.levelThresholds {
            if characters.first(where: {$0.isSelected})!.exp >= threshold {
                newLevel += 1
            } else {
                break
            }
        }
        if newLevel > characters.first(where: {$0.isSelected})!.level {
            user.showLevelUPAnimation = true
        }
        characters.first(where: {$0.isSelected})!.level = newLevel
        user.isIncreasedLevel = true
    }
    // ポイントの更新処理（例：全体の文字数の10分の1を獲得する）
    private func updateUserPoints(by gainedExp: Int) {
        // 獲得ポイントは経験値の計算結果を基にスケールする
        let gainedPoints = gainedExp  / 10 // 10文字につき1ポイント
        user.point += gainedPoints
        print("獲得ポイント: \(gainedPoints), 新しいポイント: \(user.point)")
    }
    private func generateUniqueImageFileName(saveDay: Date, timeStamp: TimeStamp) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString = dateFormatter.string(from: saveDay)
        let timeString = timeStamp.rawValue
        let uuidString = UUID().uuidString
        print("generateUniqueImageFileName:\(dateString)_\(timeString)_\(uuidString)")
        // .jpeg拡張子をつけない
        return "\(dateString)_\(timeString)_\(uuidString)"
    }
    private func getDocumentPath(saveData: UIImage, fileName: String) -> URL {
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentURL.appendingPathComponent(fileName + ".jpeg")
        do {
            try saveData.jpegData(compressionQuality: 1.0)?.write(to: fileURL)
            print("画像の保存に成功しました")
        } catch {
            print("画像の保存に失敗しました: \(error)")
        }
        return fileURL
    }
    func getImageByUrl(url: URL) -> UIImage{
        do {
            let data = try Data(contentsOf: url)
            return UIImage(data: data)!
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
        return UIImage()
    }
    
    //動的ドキュメントパスで画像をsave laodする
    // 画像を保存し、そのファイル名を返す関数
    private func saveImageToDocumentDirectory(image: UIImage, fileName: String) -> String? {
        guard let data = image.jpegData(compressionQuality: 1.0) else {
            print("画像のデータ変換に失敗しました")
            return nil
        }
        
        do {
            let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentURL.appendingPathComponent(fileName + ".jpeg")
            try data.write(to: fileURL)
            print("画像の保存に成功しました: \(fileURL)")
            return fileName
        } catch {
            print("画像の保存に失敗しました: \(error)")
            return nil
        }
    }

    // ドキュメントディレクトリから画像ファイルを読み込む関数
    private func loadImageSafely(from ajiwaiCardData: AjiwaiCardData) -> UIImage? {
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var fileName: String? = nil

        // 新しいimageFileNameプロパティを優先して使用
        if let newFileName = ajiwaiCardData.imageFileName {
            fileName = newFileName
        }
        // imageFileNameがnilの場合、旧imagePathからファイル名を抽出
        else if let oldImagePathURL = URL(string: ajiwaiCardData.imagePath.absoluteString) {
            fileName = oldImagePathURL.lastPathComponent
        }

        // ファイル名が取得できなければ、nilを返す
        guard let finalFileName = fileName else {
            print("ファイル名が取得できませんでした。")
            return nil
        }

        // ドキュメントディレクトリとファイル名を組み合わせて画像のURLを生成
        let fileURL = documentURL.appendingPathComponent(finalFileName)

        do {
            let data = try Data(contentsOf: fileURL)
            return UIImage(data: data)
        } catch {
            print("画像の読み込みに失敗しました: \(error)")
            return nil
        }
    }
    /// 画像の比率から表示すべきフレームサイズを返す
    private func frameSize(for image: UIImage) -> CGSize {
        // ① 画像の縦横比は CGFloat ÷ CGFloat → CGFloat
        let aspectRatio = image.size.width / image.size.height
        
        // ② 比較用定数も CGFloat に揃える
        let targetRatio: CGFloat = 3.0 / 4.0
        let tolerance: CGFloat = 0.01
        
        // ③ 三項演算子の結果を CGFloat にする
        //    ※リテラルを 300.0／400.0 とするか、CGFloat(300)／CGFloat(400) とすれば幅が CGFloat 型になります
        let width: CGFloat = abs(aspectRatio - targetRatio) < tolerance ? 300.0 : 400.0
        
        // ④ 高さは CGFloat ÷ CGFloat
        let height = width / aspectRatio
        
        return CGSize(width: width, height: height)
    }
    
    @State private var showValidationOverlay = false           // ←追加
    @State private var validationMessage: String = ""        // ←追加
    
    /// 足りない入力項目を列挙する
    private var missingFields: [String] {
        var fields: [String] = []
        if timeStanp == nil {
            fields.append("「あさ」か「ひる」か「よる」を選んでね")
        }
        if uiImage == nil {
            fields.append("写真をとるかライブラリから選んでね")
        }
        // ほかに必須のテキストなどがあれば同様に append
        return fields
    }
    
    //デバッグ用サンプル記録生成
    func createSampleData(textLength: Int) {
        // タイムスタンプに値を設定
        timeStanp = .lunch

        // uiImageは代入しない

        // 5つの五感のテキスト合計の長さを引数で指定
        let totalLength = textLength
        let individualLength = totalLength / 5

        // 各要素の文字数を均等に割り振ってテキストを生成
        let sampleText = "サンプルテキスト"
        editedSenseText = (0..<5).map { _ in
            String(repeating: sampleText, count: individualLength / sampleText.count)
        }

        // メニューのテキストに値を設定
        editedMenu = [
            "チーズハンバーグ",
            "フライドポテト",
            "ミニトマトとレタスのサラダ",
            "コーンスープ"
        ]

        // その他、必要に応じて変数を設定
        currentDate = Date()
    }
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                Image("bg_AjiwaiCardView")
                    .resizable()
                    .scaledToFill()
                    .blur(radius: 3)
                    .position(x:geometry.size.width*0.5,y:geometry.size.height*0.5)
                VStack{
                    HStack{
                        Button{
                            dismiss()
                        }label:{
                            Image("bt_close")
                                .resizable()
                                .scaledToFit()
                                .frame(width:geometry.size.width*0.05)
                        }
                        .padding(.horizontal)
                        if debugContentsManager.isShowingDebugContents{
                            Button{
                                createSampleData(textLength: 300) // 例として100文字のサンプルを生成
                            }label: {
                                Text("サンプル記録を生成")
                            }
                            .buttonStyle(.borderedProminent)
                            .padding()
                        }
                        Spacer()
                        dateBar(geometry: geometry)
                    }
                    HStack{
                        Spacer()
                        HStack{
                            Text("いつのごはん？")
                                .font(.custom("GenJyuuGothicX-Bold", size: 25))
                                .padding(.leading)
                            
                            HStack(spacing: 20) {
                                ForEach([TimeStamp.morning, .lunch, .dinner], id: \.self) { time in
                                    Button {
                                        timeStanp = time
                                    } label: {
                                        HStack {
                                            
                                            Text(labelFor(time: time))
                                                .font(.title2)
                                                .bold()
                                        }
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 16)
                                        .foregroundColor(.white)
                                        .background(
                                            Capsule()
                                                .foregroundStyle(timeStanp == time ? Color.cyan : Color.gray.opacity(0.4))
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    ScrollView{
                        HStack(alignment:.top){
                            VStack{
                                VStack{
                                    Text("今日のごはん")
                                        .font(.custom("GenJyuuGothicX-Bold", size: 25))
                                    Text("ごはんの写真を撮ろう！")
                                        .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                        .foregroundStyle(.secondary)
                                    if let image = uiImage {
                                        let size = frameSize(for: image)
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: size.width, height: size.height)
                                            .cornerRadius(15)
                                            .shadow(radius: 5)
                                            .padding()
                                        
                                    } else {
                                        Image("mt_No_Image")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 400,height: 300)
                                            .padding()
                                    }
                                    
                                    HStack(spacing:30){
                                        Button{
                                            showCameraPicker = true
                                        }label:{
                                            Label {
                                                Text("カメラで撮る")
                                            } icon: {
                                                Image(systemName: "camera")
                                            }
                                        }
                                        PhotosPicker(selection: $selectedPhotoItem) {
                                            Label("写真を選ぶ", systemImage: "photo")
                                        }
                                        
                                    }
                                }
                                .padding()
                                .background{
                                    backgroundCard(geometry: geometry)
                                }
                                VStack{
                                    Text("今日のメニュー")
                                        .font(.custom("GenJyuuGothicX-Bold", size: 25))
                                    Text("ごはんのメニューを書き込もう！")
                                        .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                        .foregroundStyle(.secondary)
                                    List{
                                        ForEach(0..<editedMenu.count,id:\.self){ index in
                                            TextField("", text: $editedMenu[index])
                                                .textFieldStyle(.roundedBorder)
                                                .frame(width: geometry.size.width*0.4)
                                        }
                                        .onDelete { (offsets) in
                                            self.editedMenu.remove(atOffsets: offsets)
                                        }
                                    }
                                    .scrollContentBackground(.hidden)
                                    Button{
                                        editedMenu.append("")
                                    }label:{
                                        Label {
                                            Text("メニューを追加する")
                                        } icon: {
                                            Image(systemName: "plus.circle")
                                        }
                                    }
                                }
                                .padding()
                                .background{
                                    backgroundCard(geometry: geometry)
                                }
                                
                            }
                            VStack{
                                VStack{
                                    VStack{
                                        Text("五感で味わってみよう！")
                                            .font(.custom("GenJyuuGothicX-Bold", size: 25))
                                        Text("見た目や匂いについて詳しく書いてみよう！")
                                            .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                    }
                                    VStack(spacing:10){
                                        ForEach(0..<editedSenseText.count,id:\.self){ index in
                                            HStack(alignment:.bottom){
                                                Image("\(senseIcons[index])")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width:geometry.size.width*0.04)
                                                VStack(alignment:.leading){
                                                    TextField(sensePlaceholders[index],text:$editedSenseText[index],axis:.vertical)
                                                        .frame(width:geometry.size.width*0.4)
                                                    Rectangle()
                                                        .frame(width:geometry.size.width*0.4,height:1)
                                                        .foregroundStyle(senseColors[index])
                                                }
                                                
                                            }
                                            .padding()
                                            
                                        }
                                    }
                                }
                                .padding()
                                .background{
                                    backgroundCard(geometry: geometry)
                                }
                                
                            }
                            
                        }
                        .padding()
                    }
                }
                VStack{
                    Spacer()
                    HStack{
                        Spacer()
                        
                        Button {
                            let missing = missingFields
                            if missing.isEmpty {
                                // 必須項目がそろっていれば、もともとの保存処理を実行
                                saveCurrentData(
                                    saveDay: currentDate,
                                    times: timeStanp!,
                                    sight: editedSenseText[0],
                                    taste: editedSenseText[3],
                                    smell: editedSenseText[2],
                                    tactile: editedSenseText[4],
                                    hearing: editedSenseText[1],
                                    uiImage: uiImage!,
                                    menu: editedMenu
                                )
                                user.showAnimation = true
                            } else {
                                // 足りない項目があれば、改行区切りでメッセージを作ってアラート表示
                                validationMessage = missing.joined(separator: "\n")
                                showValidationOverlay = true
                            }
                        } label:{
                            Text("ほぞんする")
                                .font(.custom("GenJyuuGothicX-Bold",size:15))
                                .frame(width: 180, height: 50)
                                .background(Color.white)
                                .foregroundStyle(Color.buttonColor)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .overlay{
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.buttonColor ,lineWidth: 4)
                                }
                        }
                        .alert(isPresented: $showSaveResultAlert) {
                            Alert(
                                title: Text(saveResultMessage ?? ""),
                                dismissButton: .default(Text("OK")) {
                                    if saveResultMessage == "保存に成功しました！"{
                                        dismiss()
                                    }
                                }
                            )
                        }
                        
                    }
                }
                .padding()
            }
            .onAppear(){
                
                print("allMenu",allMenu.first{$0.day == dateFormatter(date: currentDate)}?.menu
                )
                print("emptyMenu",editedMenu)
                editedMenu = allMenu.first{ $0.day == dateFormatter(date: currentDate)}?.menu ?? []
                print("addedMenu",editedMenu)
                
            }
            .fullScreenCover(isPresented: $showCameraPicker) {
                ImagePicker(image: $uiImage, sourceType: .camera)
                    .ignoresSafeArea()
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        self.uiImage = uiImage
                    }
                }
            }
            .overlay(validationOverlay)
            .animation(.easeInOut, value: showValidationOverlay)
        }
    }
    @ViewBuilder private func backgroundCard(geometry:GeometryProxy) -> some View{
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .frame(width: geometry.size.width*0.47)
                .foregroundStyle(.white)
                .shadow(radius: 10)
                .overlay {
                    VStack{
                        
                        HStack{
                            ZStack{
                                Circle()
                                    .frame(width: 13)
                                    .foregroundStyle(.gray)
                                Circle()
                                    .frame(width: 10)
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                            ZStack{
                                Circle()
                                    .frame(width: 13)
                                    .foregroundStyle(.gray)
                                Circle()
                                    .frame(width: 10)
                                    .foregroundStyle(.white)
                            }
                        }
                        Spacer()
                        HStack{
                            ZStack{
                                Circle()
                                    .frame(width: 13)
                                    .foregroundStyle(.gray)
                                Circle()
                                    .frame(width: 10)
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                            ZStack{
                                Circle()
                                    .frame(width: 13)
                                    .foregroundStyle(.gray)
                                Circle()
                                    .frame(width: 10)
                                    .foregroundStyle(.white)
                            }
                        }
                        
                    }
                    .padding()
                }
        }
    }
    
    private func dateBar(geometry: GeometryProxy) -> some View {
        VStack(alignment:.trailing){
            Button {
                withAnimation {
                    showDatePicker = true
                }
            } label: {
                Image("mt_DateBar")
                    .resizable()
                    .scaledToFit()
                    .frame(width:geometry.size.width*0.32)
                    .shadow(radius: 3,y:10)
                    .overlay {
                        HStack {
                            Text(dateFormatter(date: currentDate))
                            Text("：")
                            Text(changeTimeStamp())
                        }
                        .font(.custom("GenJyuuGothicX-Bold", size: 28))
                        .foregroundColor(.white)
                    }
            }
            .buttonStyle(PlainButtonStyle())
            .popover(isPresented: $showDatePicker) {
                calendarPopoverContent()
            }
        }
    }
    private func changeTimeStamp() -> String{
        switch timeStanp{
        case .morning:
            return "あさ"
        case .lunch:
            return "ひる"
        case .dinner:
            return "よる"
        default:
            return "ー"
        }
    }
    
    private func labelFor(time: TimeStamp) -> String {
        switch time {
        case .morning:
            return "あさ"
        case .lunch:
            return "ひる"
        case .dinner:
            return "よる"
        }
    }
    
    @ViewBuilder
    private func calendarPopoverContent() -> some View {
        VStack {
            Rectangle()
                .foregroundStyle(.white)
                .frame(width: 450, height: 40)
                .overlay {
                    Text("日にちをえらぼう！")
                        .font(.custom("GenJyuuGothicX-Bold", size: 20))
                }
            DatePicker("日付を選んでね", selection: $currentDate, displayedComponents: [.date])
                .datePickerStyle(.graphical)
                .labelsHidden()
                .padding()
        }
        .frame(width: 450)
    }
    /// バリデーションエラー用の自作オーバーレイ
    @ViewBuilder
    private var validationOverlay: some View {
        if showValidationOverlay {
            // 1) 背景を半透明で覆う
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            // 2) メッセージ本体
            VStack(spacing: 20) {
                Text(validationMessage)
                    .font(.system(size: 28, weight: .bold))   // ← 修正済み
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                Button("閉じる") {
                    withAnimation {
                        showValidationOverlay = false
                    }
                }
                .font(.system(size: 20))
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
            .padding(20)
            .background(Color.white.opacity(0.8))
            .cornerRadius(12)
            .padding(40)
            .transition(.opacity)
        }
    }
}


