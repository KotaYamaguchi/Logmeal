import SwiftUI
import PhotosUI
import SwiftData

struct NewWritingView: View {
    @EnvironmentObject var user: UserData
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var allData: [AjiwaiCardData]
    @Query private var allMenu:[MenuData]
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
    
    
    
    @Binding var isEditing:Bool
    let dataIndex:Int
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
        let imagePath: URL = getDocumentPath(saveData: uiImage, fileName: dateFormatter(date: saveDay))
        if isEditing {
            // 各プロパティを更新
            allData[dataIndex].saveDay = saveDay
            allData[dataIndex].time = times
            allData[dataIndex].sight = sight
            allData[dataIndex].taste = taste
            allData[dataIndex].smell = smell
            allData[dataIndex].tactile = tactile
            allData[dataIndex].hearing = hearing
            allData[dataIndex].imagePath = getDocumentPath(saveData: uiImage, fileName: dateFormatter(date: saveDay))
            allData[dataIndex].menu = menu

            do {
                try context.save()
                saveResultMessage = "保存に成功しました！"
            } catch {
                print("保存に失敗しました: \(error)")
                saveResultMessage = "保存に失敗しました…"
            }
        }else{
            let newData = AjiwaiCardData(
                saveDay: saveDay,
                times: times,
                sight: sight,
                taste: taste,
                smell: smell,
                tactile: tactile,
                hearing: hearing,
                imagePath: imagePath,
                menu: menu
            )
            context.insert(newData)
            do {
                try context.save()
                saveResultMessage = "保存に成功しました！"
                print("メニュー = \(newData.menu)")
                print("五感(聴覚) = \(newData.hearing)")
           
                    // ① 各文字列の文字数を計算して配列に変換
                    let characterCounts = editedSenseText.map { $0.count }
                    // ② その総和を求める
                    let totalCharacterCount = characterCounts.reduce(0, +)
                    print("合計文字数\(totalCharacterCount)")
                    // 経験値更新：10文字につき1exp（バランス調整可能）
                    updateUserExperience(by: totalCharacterCount)
                    // ポイント更新：1文字につき1ポイント（バランス調整可能）
                    updateUserPoints(by: totalCharacterCount)
                    if user.level >= 12{
                        user.growthStage = 3
                        user.isGrowthed = true
                    }else if user.level >= 5{
                        user.growthStage = 2
                        user.isGrowthed = true
                    }
            } catch {
                print("保存に失敗しました: \(error)")
                saveResultMessage = "保存に失敗しました…"
            }
        }
        showSaveResultAlert = true
    }
    // ユーザー経験値の更新処理
        private func updateUserExperience(by gainedExp: Int) {
            user.exp += gainedExp / 10 //　10文字につき1exp
            
            let levelThresholds: [Int] = [0, 10, 20, 30, 50, 70, 90, 110, 130, 150, 170, 200, 220, 250, 290, 350]
            var newLevel = 0
            // しきい値配列の各値と経験値を比較し、条件を満たす場合にレベルを更新
            for threshold in levelThresholds {
                if user.exp >= threshold {
                    newLevel += 1
                } else {
                    break
                }
            }
            user.level = newLevel
            user.isIncreasedLevel = true
            print("獲得経験値: \(gainedExp), 総経験値: \(user.exp), 新しいレベル: \(user.level)")
        }
    // ポイントの更新処理（例：全体の文字数の10分の1を獲得する）
      private func updateUserPoints(by gainedExp: Int) {
          // 獲得ポイントは経験値の計算結果を基にスケールする
          let gainedPoints = gainedExp  / 10 // 10文字につき1ポイント
          user.point += gainedPoints
          print("獲得ポイント: \(gainedPoints), 新しいポイント: \(user.point)")
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
    func getImageByUrl(url: URL) -> UIImage{
        do {
            let data = try Data(contentsOf: url)
            return UIImage(data: data)!
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
        return UIImage()
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
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: geometry.size.width*0.38)
                                            .cornerRadius(15)
                                            .shadow(radius: 5)
                                            .padding()
                                    } else {
                                        Image("mt_No_Image")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: geometry.size.width*0.38)
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
//                                VStack{
//                                    Text("ごはんはどうだった？")
//                                        .font(.custom("GenJyuuGothicX-Bold", size: 25))
//                                    Text("食べた感想を教えてね！")
//                                        .font(.custom("GenJyuuGothicX-Bold", size: 20))
//                                    Image("mt_AjiwaiCard")
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(height: geometry.size.height*0.4)
//                                        .overlay{
//
//                                            TextField("カレーの色が家のものと違って明るくて、甘い味でした。フルーツヨーグルトが...",text: $editedText,axis:.vertical)
//                                                .frame(width: geometry.size.width*0.34,height:geometry.size.height*0.15)
//                                        }
//                                }
//                                .padding()
//                                .background{
//                                    backgroundCard(geometry: geometry)
//                                }
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
                        if isEditing{
                            Button{
                                isEditing = false
                            }label: {
                                Text("キャンセル")
                                    .font(.custom("GenJyuuGothicX-Bold",size:15))
                                    .frame(width: 180, height: 50)
                                    .background(Color.white)
                                    .foregroundStyle(Color.red)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .overlay{
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.red ,lineWidth: 4)
                                    }
                            }
                        }
                        Button{
                            if let timeStanp = timeStanp, let uiImage = uiImage {
                                saveCurrentData(
                                    saveDay: currentDate,
                                    times: timeStanp,
                                    sight: editedSenseText[0],
                                    taste: editedSenseText[3],
                                    smell: editedSenseText[2],
                                    tactile: editedSenseText[4],
                                    hearing: editedSenseText[1],
                                    uiImage: uiImage,
                                    menu: editedMenu
                                )
                                    user.showAnimation = true
                                
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
                                    if isEditing{
                                        isEditing = false
                                    }else if saveResultMessage == "保存に成功しました！"{
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
                if self.isEditing{
                    self.uiImage = getImageByUrl(url: allData[dataIndex].imagePath)
                    self.currentDate = allData[dataIndex].saveDay
                    self.timeStanp = allData[dataIndex].time
                    self.editedSenseText[0] = allData[dataIndex].sight
                    self.editedSenseText[1] = allData[dataIndex].hearing
                    self.editedSenseText[2] = allData[dataIndex].smell
                    self.editedSenseText[3] = allData[dataIndex].taste
                    self.editedSenseText[4] = allData[dataIndex].tactile
                    self.editedMenu = allData[dataIndex].menu
                }else{
                    print("allMenu",allMenu.first{$0.day == dateFormatter(date: currentDate)}?.menu
                    )
                    print("emptyMenu",editedMenu)
                    editedMenu = allMenu.first{ $0.day == dateFormatter(date: currentDate)}?.menu ?? []
                    print("addedMenu",editedMenu)
                }
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
}

//#Preview {
//    NewWritingView(showWritingView: .constant(true), isEditing: true)
//        .environmentObject(UserData())
//        .modelContainer(for: AjiwaiCardData.self)
//}
//#Preview {
//    NewContentView()
//        .environmentObject(UserData())
//        .modelContainer(for: AjiwaiCardData.self)
//}
