import SwiftUI
import SwiftData
import PhotosUI

struct WritingAjiwaiCardView: View {
    // SwiftData
    @Environment(\.modelContext) private var context
    @Query private var allData: [AjiwaiCardData]
    @Query private var allColumn:[ColumnData]
    @Query private var allmenu:[MenuData]
    // Environment
    @EnvironmentObject var user: UserData
    @Environment(\.dismiss) private var dismiss
    
    // 味わいカード
    @State private var lunchComent: String = ""
    @State var uiimage: UIImage?
    let placeholderImage = Image("mt_No_Image")
    @State private var menu: [String] = []
    @State private var saveDay: Date = Date()
    @State private var fillMenuYourself = false
    
    // テキストフィールド
    @State private var feelingTexts = ["", "", "", "", ""]
    
    // テキストフィールドスタイル
    @State private var feelings = ["視覚", "聴覚", "嗅覚", "味覚", "触覚"]
    private let iconArray = ["mt_Eye_icon", "mt_Ear_icon", "mt_Nose_icon", "mt_Tongue_icon", "mt_Hand_Icon"]
    private let colors: [Color] = [
        Color(red: 240/255, green: 145/255, blue: 144/255),
        Color(red: 243/255, green: 179/255, blue: 67/255),
        Color(red: 105/255, green: 192/255, blue: 160/255),
        Color(red: 139/255, green: 194/255, blue: 222/255),
        Color(red: 196/255, green: 160/255, blue: 193/255)
    ]
    
    // デートピッカー
    @State private var showDatePicker: Bool = false
    
    // QRコードを使用
    @State var showQRscanner: Bool = false
    @State var monthlyMenu: [String:[String]] = [:]
    @State var monthlyColumnTitle: [String:String] = [:]
    @State var monthlyColumnCaption: [String:String] = [:]
    
    // ImagePicker
    @State var showImagePicker: Bool = false
    @State var selectedItem: PhotosPickerItem?
    
    // キーボド表示時にビューをオフセットする
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var focusedField: Int?
    
    // 保存確認アラート
    @State private var showingSaveAlert = false
    
    // 次に行けるようになるフラグ
    @State private var toNext: Bool = true
    
    private let lunchCommentMaxLength = 500
    private let feelingTextMaxLength = 250
    private let menuTextMaxLength = 30
    
    private func isSave() -> Bool {
        return menu.isEmpty || lunchComent.isEmpty || feelingTexts.contains(where: { $0.isEmpty })
    }
    
    private func filereMenu() {
        let currentDate = dateFormatter(date: saveDay)
        if let matchingMenu = allmenu.first(where: { $0.day == currentDate }) {
            self.menu = matchingMenu.menu
        } else {
            menu = []
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("bg_AjiwaiCardView")
                    .resizable()
                    .ignoresSafeArea()
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
                
                Button {
                    dismiss()
                } label: {
                    Image("bt_back")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
                .zIndex(5)
                .position(x: geometry.size.width * 0.05, y: geometry.size.height * 0.05)
                
                ScrollView {
                    HStack {
                        Spacer()
                        VStack {
                            Group {
                                if let uiimage = self.uiimage {
                                    Image(uiImage: uiimage)
                                        .resizable()
                                        .frame(width: 400, height: 300)
                                } else {
                                    placeholderImage
                                        .resizable()
                                        .frame(width: 400, height: 300)
                                }
                                PhotosPicker(selection: $selectedItem) {
                                    Text("写真を選ぶ")
                                }
                                Text("今日の献立")
                                    .padding()
                                
                                if fillMenuYourself {
                                    ScrollView {
                                        ForEach($menu.indices, id: \.self) { index in
                                            TextFieldWithCounterWithBorder(text: Binding(
                                                get: { menu[index] },
                                                set: { newValue in
                                                    if newValue.count <= menuTextMaxLength {
                                                        menu[index] = newValue
                                                    }
                                                }
                                            ), maxLength: menuTextMaxLength)
                                            .padding(.vertical, 2)
                                            .focused($focusedField, equals: index + 100) // 100以降の値をメニュー用に予約
                                        }
                                        Button(action: {
                                            menu.append("")
                                        }) {
                                            Text("メニュー項目を追加")
                                        }
                                        Button {
                                            fillMenuYourself = false
                                        } label: {
                                            Text("閉じる")
                                        }
                                    }
                                } else {
                                    if !menu.isEmpty {
                                        ForEach(menu, id: \.self) { content in
                                            Text(content)
                                        }
                                    } else {
                                        VStack {
                                            Button {
                                                showQRscanner = true
                                            } label: {
                                                Text("QRコードから入力する")
                                            }
                                            Button {
                                                fillMenuYourself = true
                                            } label: {
                                                Text("自分で入力する")
                                            }
                                        }
                                    }
                                }
                                Spacer()
                            }
                            .offset(y: 10)
                        }
                        .frame(width: 400, height: 600)
                        .background {
                            Image("bg_MenuList")
                        }
                        Spacer()
                        VStack {
                            Image("mt_AjiwaiCard")
                                .overlay {
                                    VStack(alignment: .trailing) {
                                        TextField("給食の感想を書こう！", text: Binding(
                                            get: { lunchComent },
                                            set: { newValue in
                                                if newValue.count <= lunchCommentMaxLength {
                                                    lunchComent = newValue
                                                }
                                            }
                                        ), axis: .vertical)
                                        .frame(width: 400, height: 200)
                                        .focused($focusedField, equals: -1)
                                        Text("\(lunchComent.count)/\(lunchCommentMaxLength)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 5)
                                            .offset(y:-10)
                                    }
                                }
                            VStack{
                                ForEach(0..<feelings.count, id: \.self) { index in
                                    TextFieldWithCounter(text: Binding(
                                        get: { feelingTexts[index] },
                                        set: { newValue in
                                            if newValue.count <= feelingTextMaxLength {
                                                feelingTexts[index] = newValue
                                            }
                                        }
                                    ), maxLength: feelingTextMaxLength)
                                    .feelingsTextFieldStyle(image: iconArray[index], underlineColor: colors[index])
                                    .padding(.bottom)
                                    .focused($focusedField, equals: index)
                                }
                            }
                        }
                        .frame(width: 400, height: geometry.size.height)
                        
                        Spacer()
                    }
                }
                .offset(y: focusedField != nil && focusedField! >= 0 ? -keyboardHeight : 0)
                .frame(width: geometry.size.width, height: geometry.size.height)
                
                Button {
                    withAnimation {
                        showDatePicker = true
                    }
                } label: {
                    Image("mt_DateBar")
                        .overlay {
                            Text(dateFormatter(date: saveDay))
                                .font(.custom("GenJyuuGothicX-Bold", size: 28))
                                .foregroundStyle(.white)
                        }
                }
                .position(x: geometry.size.width * 0.9, y: geometry.size.height * 0.05)
                
                if showDatePicker {
                    Color.gray
                        .opacity(0.5)
                        .ignoresSafeArea()
                    VStack {
                        ZStack(alignment: .bottom) {
                            DatePicker("", selection: $saveDay, displayedComponents: [.date])
                                .datePickerStyle(.graphical)
                                .environment(\.locale, Locale(identifier: "ja_JP"))
                                .frame(width: 400, height: 500)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            Button {
                                withAnimation {
                                    showDatePicker = false
                                }
                            } label: {
                                Text("閉じる")
                            }
                            .padding(.bottom, 25)
                        }
                    }
                    .frame(width: 400, height: 500)
                }
                HStack {
                    Button {
                        showingSaveAlert = true
                    } label: {
                        Image("bt_base")
                            .resizable()
                            .frame(width: geometry.size.width * 0.1, height: geometry.size.height * 0.05)
                            .opacity(isSave() ? 0.5 : 1.0)
                            .overlay {
                                Text("保存する")
                            }
                    }
                    .disabled(isSave())
                    .padding()
                    
                    Button {
                        user.exp += 10
                        user.appearExp += 10
                        user.point += 100
                        user.path.append(.reward)
                    } label: {
                        Image("bt_base")
                            .resizable()
                            .frame(width: geometry.size.width * 0.1, height: geometry.size.height * 0.05)
                            .opacity(toNext ? 0.5 : 1.0)
                            .overlay {
                                Text("次へ")
                                
                            }
                    }
                    .disabled(toNext)
                    .padding()
                }
                .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.95)
            }
            .font(.custom("GenJyuuGothicX-Bold", size: 17))
            .sheet(isPresented: $showQRscanner) {
                ScannerView(isPresentingScanner: $showQRscanner)
            }
            .onChange(of: selectedItem, { oldValue, newValue in
                Task {
                    // 選択アイテムをDataに変換(nilで処理終了)
                    guard let data = try? await newValue?.loadTransferable(type: Data.self) else { return }
                    // DataをUIImageに変換(nilで処理終了)
                    guard let uiImage = UIImage(data: data) else { return }
                    // UIImage型プロパティに保存
                    self.uiimage = uiImage
                }
            })
            .onChange(of: monthlyMenu) { oldValue, newValue in
                filereMenu()
            }
            .onChange(of: saveDay) { oldValue, newValue in
                filereMenu()
            }
            .onAppear {
                filereMenu()
            }
        }
        .ignoresSafeArea(.keyboard)
        .alert("保存の確認", isPresented: $showingSaveAlert) {
            Button("キャンセル", role: .cancel) { }
            Button("保存") {
                if let uiimage = self.uiimage {
                    let filePath = getDocumentPath(saveData: uiimage, fileName: dateFormatter(date: saveDay))
                    add(lunchComments: self.lunchComent, sight: self.feelingTexts[0], hearing: self.feelingTexts[1], smell: self.feelingTexts[2], taste: self.feelingTexts[3], tacticle: self.feelingTexts[4], menu: self.menu, imagePath: filePath)
                    toNext = false
                } else {
                    // 画像保存が失敗した場合のエラーハンドリング
                    print("画像の保存に失敗しました")
                }
            }
        } message: {
            Text("味わいカードを保存しますか？")
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                    let keyboardRectangle = keyboardFrame.cgRectValue
                    withAnimation {
                        keyboardHeight = keyboardRectangle.height - 100.0
                    }
                }
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                withAnimation {
                    keyboardHeight = 0
                }
            }
        }
    }
    
    func getDocumentPath(saveData: UIImage, fileName: String) -> URL {
        // ドキュメントファイルのパスを取得
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        // ファイルネームを付け加えてURLを作成
        let fileURL = documentURL.appendingPathComponent(fileName + ".jpeg")
        // JPEGデータに変換してドキュメントファイルに保存
        do {
            try saveData.jpegData(compressionQuality: 0.25)?.write(to: fileURL)
        } catch {
            print("画像の保存に失敗しました: \(error)")
        }
        // ファイルURLを返す
        return fileURL
    }
    
    private func add(lunchComments: String, sight: String, hearing: String, smell: String, taste: String, tacticle: String, menu: [String], imagePath: URL) {
        let newData = AjiwaiCardData(saveDay: saveDay, lunchComments: lunchComments, sight: sight, taste: taste, smell: smell, tactile: tacticle, hearing: hearing, imagePath: imagePath, menu: menu)
        context.insert(newData)
        do {
            try context.save()
        } catch {
            print("コンテキストの保存エラー: \(error)")
        }
    }
    
    private func delete(item: AjiwaiCardData) {
        context.delete(item)
    }
    
    // 日付をStringに変換する
    private func dateFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

struct TextFieldWithCounterWithBorder: View {
    @Binding var text: String
    let maxLength: Int
    
    var body: some View {
        ZStack(alignment: .trailing) {
            TextField("メニューを入力...", text: $text)
                .padding(.trailing, 40) // 右端にスペースを確保
                .textFieldStyle(.roundedBorder)
            Text("\(text.count)/\(maxLength)")
                .font(.custom("GenJyuuGothicX-Bold", size: 12))
                .foregroundColor(.gray)
                .padding(.trailing, 5)
        }
    }
}
struct TextFieldWithCounter: View {
    @Binding var text: String
    let maxLength: Int
    
    var body: some View {
        ZStack(alignment: .trailing) {
            TextField("", text: $text)
                .padding(.trailing, 40) // 右端にスペースを確保
            Text("\(text.count)/\(maxLength)")
                .font(.custom("GenJyuuGothicX-Bold", size: 12))
                .foregroundColor(.gray)
                .padding(.trailing, 5)
        }
    }
}

#Preview {
    WritingAjiwaiCardView()
        .modelContainer(for: [AjiwaiCardData.self, MenuData.self, ColumnData.self])
        .environmentObject(UserData())
}

struct FeelingsTextFieldStyle: ViewModifier {
    var image: String
    var underlineColor: Color
    
    func body(content: Content) -> some View {
        HStack {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 35)
            VStack(spacing: 3) {
                content
                    .padding(.horizontal, 2)
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(underlineColor)
            }
        }
    }
}
extension View {
    func feelingsTextFieldStyle(image: String, underlineColor: Color) -> some View {
        self.modifier(FeelingsTextFieldStyle(image: image, underlineColor: underlineColor))
    }
}

func DeleteAll(modelContext: ModelContext) {
    do {
        try modelContext.delete(model: AjiwaiCardData.self)
        print(AjiwaiCardData.self)
    } catch {
        fatalError(error.localizedDescription)
    }
}
