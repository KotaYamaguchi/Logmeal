import SwiftUI
import PhotosUI
import SwiftData

struct LogEditView: View {
    @EnvironmentObject var user: UserData
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var allData: [AjiwaiCardData]
    @Query private var allMenu:[MenuData]
    @Query private var characters: [Character]
    @State private var timeStanp:TimeStamp? = nil
    @State private var currentDate: Date = Date()
    @Binding var isEditing: Bool
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var uiImage: UIImage? = nil
    @State private var editedText: String = ""
    @State private var editedSenseText: [String] = ["","","","",""]
    @State private var editedMenu: [String] = ["","","",""]
    @State private var showCameraPicker = false
    @State private var showDatePicker:Bool = false
    @State private var showSaveConfirmOverlay = false
    @State private var showSaveResultOverlay = false
    @State private var saveResultMessage: String = ""
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
    
    var selectedData: AjiwaiCardData // 編集対象のデータのインデックスを受け取る
    
//    // 編集対象のAjiwaiCardData
//    private var selectedData: AjiwaiCardData {
//        allData[dataIndex]
//    }
    
    private func dateFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    // MARK: - 画像保存・読み込みヘルパー関数 (LogEditView内で使用)
    
    // 画像を保存し、そのファイル名を返す関数
    private func saveImageToDocumentDirectory(image: UIImage, fileName: String) -> String? {
        guard let data = image.jpegData(compressionQuality: 1.0) else {
            print("画像のデータ変換に失敗しました")
            return nil
        }
        
        do {
            let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            // ここでファイル名に.jpeg拡張子を付与
            let fileURL = documentURL.appendingPathComponent(fileName + ".jpeg")
            try data.write(to: fileURL)
            print("画像の保存に成功しました: \(fileURL)")
            // 拡張子を含んだファイル名を保存用として返す
            return fileName + ".jpeg"
        } catch {
            print("画像の保存に失敗しました: \(error)")
            return nil
        }
    }
    
    // ドキュメントディレクトリから画像ファイルを読み込む関数
    private func loadImageFromDocumentDirectory(fileName: String) -> UIImage? {
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // ファイル名に.jpeg拡張子が含まれていない場合、追加する
        let fileNameWithExtension: String
        if !fileName.hasSuffix(".jpeg") {
            fileNameWithExtension = fileName + ".jpeg"
        } else {
            fileNameWithExtension = fileName
        }
        
        let fileURL = documentURL.appendingPathComponent(fileNameWithExtension)
        
        do {
            let data = try Data(contentsOf: fileURL)
            return UIImage(data: data)
        } catch {
            print("画像の読み込みに失敗しました: \(error)")
            return nil
        }
    }
    
    // AjiwaiCardDataから画像を安全に読み込む関数
    private func loadImageSafely(from ajiwaiCardData: AjiwaiCardData) -> UIImage? {
        var fileName: String? = nil
        
        // 1. 新しい imageFileName プロパティを優先して使用
        if let newFileName = ajiwaiCardData.imageFileName {
            fileName = newFileName
        }
        // 2. imageFileName が nil の場合、旧 imagePath からファイル名を抽出
        else if let oldImagePathURL = URL(string: ajiwaiCardData.imagePath.absoluteString) {
            fileName = oldImagePathURL.lastPathComponent
        }
        
        // ファイル名が取得できなければ、nilを返す
        guard let finalFileName = fileName else {
            print("ファイル名が取得できませんでした。")
            return nil
        }
        
        // loadImageFromDocumentDirectory を使って画像を読み込む
        return loadImageFromDocumentDirectory(fileName: finalFileName)
    }
    
    // 一意なファイル名を生成する関数（拡張子なし）
    private func generateUniqueImageFileName(saveDay: Date, timeStamp: TimeStamp) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString = dateFormatter.string(from: saveDay)
        let timeString = timeStamp.rawValue
        let uuidString = UUID().uuidString
        print("generateUniqueImageFileName:\(dateString)_\(timeString)_\(uuidString)")
        // ここでは拡張子を含めずにファイル名を返す
        return "\(dateString)_\(timeString)_\(uuidString)"
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
        // 既存のデータを更新
        selectedData.saveDay = saveDay
        selectedData.time = times
        selectedData.sight = sight
        selectedData.taste = taste
        selectedData.smell = smell
        selectedData.tactile = tactile
        selectedData.hearing = hearing
        selectedData.menu = menu
        
        // 画像が変更された場合のみ再保存
            // 画像が変更されたか、または新規設定された場合
            let fileName = generateUniqueImageFileName(saveDay: saveDay, timeStamp: times)
            if let savedFileNameWithExtension = saveImageToDocumentDirectory(image: uiImage, fileName: fileName) {
                selectedData.imagePath = URL(string: "file://dummy_old_path")! // 旧バージョン互換性のためダミーURLを更新
                selectedData.imageFileName = savedFileNameWithExtension // 新しいファイル名を更新
            } else {
                saveResultMessage = "画像の保存に失敗しました"
                showSaveResultOverlay = true
                return
            }
//        }
        
        do {
            try context.save()
            saveResultMessage = "きろくが保存できました！"
            print("メニュー = \(selectedData.menu)")
            print("五感(聴覚) = \(selectedData.hearing)")
        } catch {
            print("保存に失敗しました: \(error)")
            saveResultMessage = "保存に失敗しました…"
        }
        showSaveResultOverlay = true
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
    
    @State private var showValidationOverlay = false          // ←追加
    @State private var validationMessage: String = ""       // ←追加
    
    /// 足りない入力項目を列挙する
    private var missingFields: [String] {
        var fields: [String] = []
        if timeStanp == nil {
            fields.append("「あさ」か「ひる」か「よる」を選んでね")
        }
        if uiImage == nil {
            fields.append("しゃしんがないよ！")
        }
        // ほかに必須のテキストなどがあれば同様に append
        return fields
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
                            isEditing = false // 編集モードを終了
                        }label:{
                            Image("bt_close")
                                .resizable()
                                .scaledToFit()
                                .frame(width:geometry.size.width*0.05)
                        }
                        .padding(.horizontal)
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
                                // 必須項目がそろっていれば、自作確認アラート表示
                                showSaveConfirmOverlay = true
                            } else {
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
                    }
                }
                .padding()
            }
            .onAppear(){
                // 編集対象のデータから初期値をセット
                currentDate = selectedData.saveDay
                timeStanp = selectedData.time
                editedSenseText[0] = selectedData.sight
                editedSenseText[1] = selectedData.hearing
                editedSenseText[2] = selectedData.smell
                editedSenseText[3] = selectedData.taste
                editedSenseText[4] = selectedData.tactile
                editedMenu = selectedData.menu
                
                self.uiImage = loadImageSafely(from: selectedData) // 初期画像を設定
            }
            .fullScreenCover(isPresented: $showCameraPicker) {
                ImagePicker(image: $uiImage, sourceType: .camera)
                    .ignoresSafeArea()
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        print("新しい画像が選択されました")
                        self.uiImage = uiImage
                    }
                }
            }
            .overlay(validationOverlay)
            .overlay(saveConfirmOverlay)
            .overlay(saveResultOverlay)
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
    /// 保存確認用の自作オーバーレイ
    @ViewBuilder
    private var saveConfirmOverlay: some View {
        if showSaveConfirmOverlay {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            VStack(spacing: 24){
                Text("このきろくを保存しますか？")
                    .font(.custom("GenJyuuGothicX-Bold", size: 24))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                Text("あとから書き直すこともできます")
                    .font(.custom("GenJyuuGothicX-Regular", size: 18))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                HStack(spacing: 32){
                    Button {
                        withAnimation {
                            showSaveConfirmOverlay = false
                        }
                    } label: {
                        Text("やめる")
                            .font(.custom("GenJyuuGothicX-Bold", size: 18))
                            .frame(width: 120, height: 44)
                            .background(Color.white)
                            .foregroundStyle(Color.gray)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay{
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray, lineWidth: 3)
                            }
                    }
                    Button {
                        // 保存処理
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
                        withAnimation {
                            showSaveConfirmOverlay = false
                        }
                    } label: {
                        Text("ほぞんする")
                            .font(.custom("GenJyuuGothicX-Bold", size: 18))
                            .frame(width: 120, height: 44)
                            .background(Color.buttonColor)
                            .foregroundStyle(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay{
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.buttonColor, lineWidth: 3)
                            }
                    }
                }
            }
            .padding(.vertical, 40)
            .padding(.horizontal, 36)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(radius: 16)
            .frame(maxWidth: 340)
            .transition(.opacity)
        }
    }
    /// 保存結果表示用の自作オーバーレイ
    @ViewBuilder
    private var saveResultOverlay: some View {
        if showSaveResultOverlay {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            VStack(spacing: 24){
                Text(saveResultMessage)
                    .font(.custom("GenJyuuGothicX-Bold", size: 26))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                Button("OK") {
                    withAnimation {
                        showSaveResultOverlay = false
                        if saveResultMessage == "きろくが保存できました！" {
                            isEditing = false
                        }
                    }
                }
                .font(.custom("GenJyuuGothicX-Bold", size: 20))
                .frame(width: 120, height: 44)
                .background(Color.buttonColor)
                .foregroundStyle(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay{
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.buttonColor, lineWidth: 3)
                }
            }
            .padding(.vertical, 40)
            .padding(.horizontal, 36)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(radius: 16)
            .frame(minWidth: 340)
            .transition(.opacity)
        }
    }
}
