import SwiftUI
import SwiftData
import PhotosUI

struct WritingAjiwaiCardView: View {
    // SwiftData
    @Environment(\.modelContext) private var context
    @Query private var allData: [AjiwaiCardData]
    @Query private var allColumn: [ColumnData]
    @Query private var allmenu: [MenuData]
    
    // Environment
    @EnvironmentObject var user: UserData
    @Environment(\.dismiss) private var dismiss
    
    // Image
    let placeholderImage = UIImage(named: "mt_No_Image")
    @State private var menu: [String] = []
    
    // 味わいカード
    @State private var lunchComent: String = ""
    @State var uiimage: UIImage?
    @State var saveDay: Date
    @State private var fillMenuYourself = false
    
    // 五感テキストフィールド
    @State private var feelingTexts = ["", "", "", "", ""]
    
    // テキストフィールドスタイル
    @State private var feelings = ["視覚", "聴覚", "嗅覚", "味覚", "触覚"]
    private let iconArray = ["mt_Eye_icon", "mt_Ear_icon", "mt_Nose_icon", "mt_Tongue_icon", "mt_Hand_Icon"]
    private let colors: [Color] = [
        Color(red: 240 / 255, green: 145 / 255, blue: 144 / 255),
        Color(red: 243 / 255, green: 179 / 255, blue: 67 / 255),
        Color(red: 105 / 255, green: 192 / 255, blue: 160 / 255),
        Color(red: 139 / 255, green: 194 / 255, blue: 222 / 255),
        Color(red: 196 / 255, green: 160 / 255, blue: 193 / 255)
    ]
    
    // その他の状態管理
    @State private var showDatePicker: Bool = false
    @State var showQRscanner: Bool = false
    @State var monthlyMenu: [String: [String]] = [:]
    @State var monthlyColumnTitle: [String: String] = [:]
    @State var monthlyColumnCaption: [String: String] = [:]
    @State var showImagePicker: Bool = false
    @State var selectedItem: PhotosPickerItem?
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var focusedField: Int?
    @State private var showingSaveAlert = false
    @State private var toNext: Bool = true
    @State private var showCameraPicker = false
    @State private var showingCameraView = false
    @State var isFullScreen: Bool = false
    @State private var gotEXP = 0
    @State private var isSaving = false
    @State private var showSaveSuccess = false
    
    private let lunchCommentMaxLength = 500
    private let feelingTextMaxLength = 250
    private let menuTextMaxLength = 30
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundView(geometry: geometry)
                    .onTapGesture {
                        focusedField = nil
                    }
                
                contentView(geometry: geometry)
                    .onTapGesture {
                        focusedField = nil
                    }
                dateBar(geometry: geometry)
                
                customDatePicker(geometry: geometry)
                
                dismissView(geometry: geometry)
                
                if isSaving {
                    savingOverlayView()
                }
                if showingCameraView {
                    showingCameraOverlayview()
                }
            }
            .font(.custom("GenJyuuGothicX-Bold", size: 15))
            .fullScreenCover(isPresented: $showCameraPicker) {
                ImagePicker(image: $uiimage, sourceType: .camera)
                    .ignoresSafeArea()
                    .onAppear() {
                        showingCameraView = false
                    }
            }
            .sheet(isPresented: $showQRscanner) {
                ScannerView(isPresentingScanner: $showQRscanner)
                    .onDisappear() {
                        filereMenu()
                    }
            }
            .alert(isPresented: $showingSaveAlert) {
                saveConfirmationAlert()
            }
            .onChange(of: selectedItem) { oldValue, newValue in
                handleSelectedItemChange(newValue: newValue)
            }
            .onChange(of: monthlyMenu) { oldValue, newValue in
                filereMenu()
            }
            .onChange(of: saveDay) { oldValue, newValue in
                filereMenu()
            }
            .onAppear(perform: onAppear)
        }
        .ignoresSafeArea(.keyboard)
        .alert("保存が完了しました", isPresented: $showSaveSuccess) {
            Button("OK", role: .cancel) {
                gotEXP = Int.random(in: 10...20)
                user.exp += gotEXP
                user.gotEXP = gotEXP
                user.appearExp += 10
                user.point += 100
                if isFullScreen {
                    dismiss()
                } else {
                    user.path.append(.reward)
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private func backgroundView(geometry: GeometryProxy) -> some View {
        Image("bg_AjiwaiCardView")
            .resizable()
            .ignoresSafeArea()
            .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
    }

    private func dismissView(geometry: GeometryProxy) -> some View {
        Button {
            dismiss()
        } label: {
            if isFullScreen {
                Image("bt_close")
                    .resizable()
                    .frame(width: 50, height: 50)
            } else {
                Image("bt_back")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
        }
        .position(x: geometry.size.width * 0.05, y: geometry.size.height * 0.05)
    }

    private func showingCameraOverlayview() -> some View {
        ZStack {
            Color.gray.opacity(0.5)
                .ignoresSafeArea()
            
            ProgressView("カメラを起動中...")
                .font(.custom("GenJyuuGothicX-Bold", size: 17))
                .padding()
                .background(Color.black.opacity(0.7))
                .tint(.white)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }

    private func savingOverlayView() -> some View {
        ZStack {
            Color.gray.opacity(0.5)
                .ignoresSafeArea()
            
            ProgressView("保存中...")
                .font(.custom("GenJyuuGothicX-Bold", size: 17))
                .padding()
                .background(Color.black.opacity(0.7))
                .tint(.white)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
    
    private func contentView(geometry: GeometryProxy) -> some View {
            HStack {
                Spacer()
                ScrollView{
                    VStack {
                        imageSelectionView()
                        menuInputView()
                        Spacer()
                    }
                }
                .frame(width: 400, height: 600)
                .background {
                    Image("bg_MenuList")
                }
                Spacer()
                commentsAndFeelingsView(geometry: geometry)
                    .onTapGesture {
                        // タップ時にテキストフィールドのフォーカスを外す
                        focusedField = nil
                    }
                Spacer()
            }
        
        .offset(y: focusedField != nil && focusedField! >= 0 ? -keyboardHeight : 0)
        .frame(width: geometry.size.width, height: geometry.size.height)
    }
    
    private func imageSelectionView() -> some View {
        VStack {
            Group {
                if let uiimage = self.uiimage {
                    Image(uiImage: uiimage)
                        .resizable()
                        .frame(width: 340, height: 255)
                } else {
                    Image(uiImage: placeholderImage!)
                        .resizable()
                        .frame(width: 340, height: 255)
                }
                HStack {
                    PhotosPicker(selection: $selectedItem) {
                        Label("写真を選ぶ", systemImage: "photo")
                    }
                    Button {
                        showCameraPicker = true
                        showingCameraView = true
                    } label: {
                        Label("カメラで撮る", systemImage: "camera")
                    }
                }
            }
            .padding()
        }
    }

    private func menuInputView() -> some View {
        VStack {
            Text("今日の献立")
                .padding()
            
            if fillMenuYourself {
                menuTextFieldsView()
            } else {
                menuSelectionButtons()
            }
        }
    }
    
    private func menuTextFieldsView() -> some View {
        ScrollView {
            VStack(alignment: .leading) {
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
                    .focused($focusedField, equals: index + 100)
                }
            }
            Button(action: {
                menu.append("")
                focusedField = (menu.count - 1) + 100 // 新しいフィールドにフォーカスを設定
            }) {
                Label("メニュー項目を追加", systemImage: "plus.circle.fill")
            }
            Button {
                // 空のフィールドを削除
                menu.removeAll(where: { $0.isEmpty })
                fillMenuYourself = false
            } label: {
                Text("閉じる")
            }
        }
    }
    
    private func menuSelectionButtons() -> some View {
        VStack {
            if !menu.isEmpty {
                ForEach(menu, id: \.self) { content in
                    Text(content)
                }
            }
            HStack{
                Button {
                    showQRscanner = true
                } label: {
                    Label("QRコードから入力", systemImage: "qrcode")
                }
                Button {
                    fillMenuYourself = true
                } label: {
                    Label("自分で入力する", systemImage: "pencil.line")
                }
            }
        }
    }
    
    private func commentsAndFeelingsView(geometry: GeometryProxy) -> some View {
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
                            .offset(y: -10)
                    }
                }
            feelingsTextFields()
        }
        .frame(width: 400, height: geometry.size.height)
    }
    
    private func feelingsTextFields() -> some View {
        VStack {
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
            actionButtons()
        }
    }

    private func dateBar(geometry: GeometryProxy) -> some View {
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
        .position(x: geometry.size.width * 0.9, y: geometry.size.height * 0.04)
    }

    private func customDatePicker(geometry: GeometryProxy) -> some View {
        ZStack {
            if showDatePicker {
                Color.gray
                    .opacity(0.5)
                    .ignoresSafeArea()
                VStack {
                    Spacer()
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
                    Spacer()
                }
                .frame(width: 400, height: 500)
            }
        }
    }

    private func actionButtons() -> some View {
        HStack {
            saveButton()
        }
    }
    
    private func saveButton() -> some View {
        Button {
            showingSaveAlert = true
        } label: {
            Image("bt_base")
                .resizable()
                .scaledToFit()
                .frame(height: 50)
                .opacity(isSave() ? 0.5 : 1.0)
                .overlay {
                    HStack {
                        Image(systemName: "")
                        Text("保存する")
                            .foregroundStyle(Color.buttonColor)
                            .font(.custom("GenJyuuGothicX-Bold", size: 15))
                    }
                }
        }
        .disabled(isSave())
        .padding()
    }
    
    private func saveConfirmationAlert() -> Alert {
        Alert(
            title: Text("保存の確認"),
            message: Text("味わいカードを保存しますか？"),
            primaryButton: .cancel(Text("キャンセル")),
            secondaryButton: .default(Text("保存"), action: saveData)
        )
    }
    
    // MARK: - Functions
    
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
    
    private func saveData() {
        isSaving = true

        DispatchQueue.global(qos: .userInitiated).async {
            let imageToSave: UIImage
            
            if let uiimage = self.uiimage {
                imageToSave = uiimage
            } else if let placeholderUIImage = placeholderImage {
                imageToSave = placeholderUIImage
            } else {
                print("画像の保存に失敗しました")
                DispatchQueue.main.async {
                    isSaving = false
                    showSaveSuccess = false
                }
                return
            }

            let filePath = getDocumentPath(saveData: imageToSave, fileName: dateFormatter(date: saveDay))
            add(lunchComments: self.lunchComent, sight: self.feelingTexts[0], hearing: self.feelingTexts[1], smell: self.feelingTexts[2], taste: self.feelingTexts[3], tacticle: self.feelingTexts[4], menu: self.menu, imagePath: filePath)
            toNext = false

            DispatchQueue.main.async {
                isSaving = false
                showSaveSuccess = true
                
                // データ保存フラグをtrueに設定
                user.isDataSaved = true

                // LookBackViewへ戻る
                if isFullScreen {
                    dismiss()
                } else {
                    user.path.append(.reward)
                }
            }
        }
    }

    private func getDocumentPath(saveData: UIImage, fileName: String) -> URL {
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentURL.appendingPathComponent(fileName + ".jpeg")
        do {
            try saveData.jpegData(compressionQuality: 0.25)?.write(to: fileURL)
        } catch {
            print("画像の保存に失敗しました: \(error)")
        }
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
    
    private func dateFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    private func handleSelectedItemChange(newValue: PhotosPickerItem?) {
        Task {
            guard let data = try? await newValue?.loadTransferable(type: Data.self) else { return }
            guard let uiImage = UIImage(data: data) else { return }
            self.uiimage = uiImage
        }
    }
    
    private func onAppear() {
        filereMenu()
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

// MARK: - Helper Views

struct TextFieldWithCounterWithBorder: View {
    @Binding var text: String
    let maxLength: Int
    
    var body: some View {
        ZStack(alignment: .trailing) {
            TextField("メニューを入力...", text: $text)
                .padding(.trailing, 40)
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
            TextField("", text: $text, axis: .vertical)
                .padding(.trailing, 40)
            Text("\(text.count)/\(maxLength)")
                .font(.custom("GenJyuuGothicX-Bold", size: 12))
                .foregroundColor(.gray)
                .padding(.trailing, 5)
        }
    }
}

// MARK: - Preview

#Preview {
    WritingAjiwaiCardView(saveDay: Date())
        .modelContainer(for: [AjiwaiCardData.self, MenuData.self, ColumnData.self])
        .environmentObject(UserData())
}

#Preview {
    ChildHomeView()
        .modelContainer(for: [AjiwaiCardData.self, MenuData.self, ColumnData.self])
        .environmentObject(UserData())
}

// MARK: - Custom Modifiers

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
    } catch {
        fatalError(error.localizedDescription)
    }
}


import UIKit
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
