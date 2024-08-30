import SwiftUI
import SwiftData

struct LookBackView: View {
    // SwiftData
    @Environment(\.modelContext) private var context
    @Query private var allData: [AjiwaiCardData]
    var filteredData: AjiwaiCardData? {
        allData.first { Calendar.current.isDate($0.saveDay, inSameDayAs: selectDate) }
    }
    
    // Environment
    @EnvironmentObject var user: UserData
    @Environment(\.dismiss) private var dismiss
    
    // カレンダー関連
    @State private var selectDate: Date = Date()
    
    // 味わいカード関連
    @State private var showDetail: Bool = false
    @State private var navigateToWritingView: Bool = false
    
    // アニメーション関連
    @State private var showBaseLevelUpView = false
    @State private var showBaseAnimationView = false
    @State private var showNormalCharacterView = false
    @State private var showTextCompleted = false
    @State var fromAjiwaiCard: Bool = true
    
    // チュートリアル関連
    @AppStorage("hasSeenLookBackTutorial") private var hasSeenTutorial = false
    @State private var showHowToUseView = false
    
    private let soundManager: SoundManager = SoundManager()
    
    // MARK: - body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundView(geometry: geometry)
                actionButton(geometry: geometry)
                calenderView(geometry: geometry)
                ajiwaiCardPreview(geometry: geometry)
                
                if user.isDataSaved {
                    animationView(geometry: geometry)
                        .onTapGesture {
                            user.isDataSaved = false // フラグをリセット
                        }
                }
            }
            .fullScreenCover(isPresented: $showDetail) {
                if let data = filteredData {
                    AjiwaiCardDetailView(selectedDate: selectDate, data: data)
                }
            }
            .fullScreenCover(isPresented: $navigateToWritingView) {
                WritingAjiwaiCardView(saveDay: selectDate, isFullScreen: true)
                    .onDisappear() {
                        handleOnDisAppear()
                    }
            }
            .sheet(isPresented: $showHowToUseView) {
                TutorialView(imageArray: ["HowToUseCalendar"])
                    .interactiveDismissDisabled()
                    .onDisappear(){
                        hasSeenTutorial = true
                    }

            }
            .onAppear {
                if !hasSeenTutorial {
                    showHowToUseView = true
                }
            }
        }
    }
    
    // MARK: - View Components
    private func backgroundView(geometry: GeometryProxy) -> some View {
        Image("bg_calenderView_\(user.selectedCharacter)")
            .resizable()
            .ignoresSafeArea()
            .frame(width: geometry.size.width, height: geometry.size.height)
            .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
    }
    
    private func actionButton(geometry: GeometryProxy) -> some View {
        Button {
            dismiss()
            soundManager.playSound(named: "se_negative")
        } label: {
            Image("bt_back")
                .resizable()
                .frame(width: 50, height: 50)
        }
        .position(x: geometry.size.width * 0.05, y: geometry.size.height * 0.05)
        .buttonStyle(PlainButtonStyle())
    }
    
    private func calenderView(geometry: GeometryProxy) -> some View {
        CalendarDisplayView(selectedDate: $selectDate, allData: allData)
            .frame(width: geometry.size.width * 0.85, height: geometry.size.height)
            .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
    }
    
    private func ajiwaiCardPreview(geometry: GeometryProxy) -> some View {
        AjiwaiCardDataPreview(selectedDate: selectDate, allData: allData, showDetail: $showDetail, navigateToWritingView: $navigateToWritingView)
            .position(x: geometry.size.width * 0.75, y: geometry.size.height * 0.5)
    }
    
    private func animationView(geometry: GeometryProxy) -> some View {
        ZStack {
            if showBaseAnimationView {
                BaseAnimationView(
                    firstGifName: getFirstGifName(),
                    secondGifName: getSecondGifName(),
                    text1: "おや、\(user.characterName)のようすが…",
                    text2: "おめでとう！\(user.characterName)が進化したよ！",
                    useBackGroundColor: true
                )
            } else if showBaseLevelUpView {
                BaseLevelUpView(
                    characterGifName: "\(user.selectedCharacter)\(user.growthStage)_animation_breath",
                    text: "\(user.characterName)がレベルアップしたよ！",
                    backgroundImage: "mt_RewardView_callout_\(user.selectedCharacter)",
                    useBackGroundColor: true
                )
            } else if showNormalCharacterView {
                NormalCharacterView(
                    characterGifName: "\(user.selectedCharacter)\(user.growthStage)_animation_breath",
                    text: "今日も記録してくれてありがとう！",
                    backgroundImage: "mt_RewardView_callout_\(user.selectedCharacter)",
                    useBackGroundColor: true
                )
            }
        }
    }
    
    // MARK: - functions
    private func handleOnDisAppear() {
        let levelUp = user.checkLevel()
        let growth = user.growth()
        
        if growth {
            showBaseAnimationView = true
        } else if levelUp {
            showBaseLevelUpView = true
        } else {
            showNormalCharacterView = true
        }
        
        // TypeWriterTextView の表示が終わった後の処理
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            showTextCompleted = true
        }
    }
    
    private func getFirstGifName() -> String {
        switch user.growthStage {
        case 2:
            return "\(user.selectedCharacter)1_animation_breath"
        case 3:
            return "\(user.selectedCharacter)2_animation_breath"
        default:
            return "\(user.selectedCharacter)\(user.growthStage)_animation_breath"
        }
    }
    
    private func getSecondGifName() -> String {
        switch user.growthStage {
        case 2:
            return "\(user.selectedCharacter)2_animation_breath"
        case 3:
            return "\(user.selectedCharacter)3_animation_breath"
        default:
            return "\(user.selectedCharacter)\(user.growthStage)_animation_breath"
        }
    }
}
// MARK: - AjiwaiCardDataPreview

struct AjiwaiCardDataPreview: View {
    //Environment
    @EnvironmentObject var user:UserData
    private let soundManager:SoundManager = SoundManager()
    //カレンダー用
    let selectedDate: Date
    //選択したデータ
    let allData: [AjiwaiCardData]
    var filteredData: AjiwaiCardData? {
        allData.first { Calendar.current.isDate($0.saveDay, inSameDayAs: selectedDate) }
    }
    //View遷移管理
    @Binding var showDetail: Bool
    @Binding var navigateToWritingView: Bool
//MARK: - Body
    var body: some View {
        VStack{
            Spacer()
            if let data = filteredData {
                imageView(data: data)
                .offset(y:50)
              menuListPreview(data: data)
                showDetailButton()
            } else {
             isEnptyView()
            }
            Spacer()
        }
    }
    //MARK: - View Componets
    private func imageView(data:AjiwaiCardData) -> some View{
        AsyncImage(url: data.imagePath) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                succeedImageView(image: image)
            case .failure(_):
               defaultImageView()
                
            @unknown default:
                defaultImageView()
            }
        }
    }
    private func succeedImageView(image:Image) -> some View{
        ZStack{
            image
                .resizable()
                .frame(width: 400,height:300)
                .offset(y:-40)
            imageFrameView()
        }
    }
    private func defaultImageView() -> some View{
        ZStack{
            placeholdarImageView()
            imageFrameView()
        }
    }
    private func placeholdarImageView() -> some View{
        Image("mt_No_Image")
            .resizable()
            .frame(width: 400,height:300)
            .offset(y:-40)
    }
    private func imageFrameView() -> some View{
        Image("mt_calenderView_imageFrame_\(user.selectedCharacter)")
            .resizable()
            .frame(width: 650,height:400)
    }
    private func menuListPreview(data:AjiwaiCardData) -> some View{
        Image("mt_calenderView_menuList")
            .resizable()
            .scaledToFit()
            .frame(width: 400)
            .overlay{
                VStack(alignment:.leading){
                    ForEach(data.menu, id: \.self) { content in
                        VStack(alignment: .leading, spacing: 0){
                            Text("・" + content)
                                .font(.custom("GenJyuuGothicX-Bold", size: 15))
                                .foregroundStyle(Color.black)
                            Rectangle()
                                .frame(width: 300, height: 1)
                                .foregroundStyle(Color.gray)
                        }
                        .padding(.vertical,2)
                    }
                }
            }
    }
    private func showDetailButton() -> some View{
        Button {
            showDetail = true
            soundManager.playSound(named: "se_positive")
        } label: {
            Image("bt_base")
                .resizable()
                .scaledToFit()
                .frame(height: 50)
                .overlay{
                    Text("詳しく見る")
                        .font(.custom("GenJyuuGothicX-Bold", size: 17))
                        .foregroundStyle(Color.buttonColor)
                }
        }
        .buttonStyle(PlainButtonStyle())
    }
    private func isEnptyView() -> some View{
        Group{
            Text("データがありません")
                .font(.custom("GenJyuuGothicX-Bold", size: 17))
            Button{
                navigateToWritingView = true
                soundManager.playSound(named: "se_positive")
            }label:{
                Image("bt_base")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 70)
                    .overlay{
                        Text("この日のデータを\n記録する！")
                            .font(.custom("GenJyuuGothicX-Bold", size: 17))
                            .foregroundStyle(Color.buttonColor)
                    }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

import SwiftUI
import SwiftData
import PhotosUI

struct AjiwaiCardDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    let selectedDate: Date
    @Bindable var data: AjiwaiCardData
    @State private var editedLunchComments: String
    @State private var editedSight: String
    @State private var editedTaste: String
    @State private var editedTactile: String
    @State private var editedSmell: String
    @State private var editedHearing: String
    @State private var editedMenu: [String]
    @State private var editedImagePath: URL
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var uiimage: UIImage? = nil
    @State private var showingSaveAlert = false
    @State private var showingDeleteAlert = false
    @State private var showCameraPicker = false
    @State private var showingCameraView = false
    @AppStorage("hasSeenCardEditViewTutorial") private var hasSeenTutorial = false
    @State private var showHowToUseView = false
    private let soundManager:SoundManager = SoundManager()
    init(selectedDate: Date, data: AjiwaiCardData) {
        self.selectedDate = selectedDate
        self.data = data
        _editedLunchComments = State(initialValue: data.lunchComments)
        _editedSight = State(initialValue: data.sight)
        _editedTaste = State(initialValue: data.taste)
        _editedTactile = State(initialValue: data.tactile)
        _editedSmell = State(initialValue: data.smell)
        _editedHearing = State(initialValue: data.hearing)
        _editedMenu = State(initialValue: data.menu)
        _editedImagePath = State(initialValue: data.imagePath)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    imageSection
                    menuSection
                    commentSection
                    sensesSection
                }
                .padding()
            }
            .background(Color(UIColor.systemGray6))
            .onAppear(){
                if !hasSeenTutorial {
                    showHowToUseView = true
                }
            }
            .navigationTitle("味わいカード編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button("削除") {
                            showingDeleteAlert = true
                        }
                        .foregroundColor(.red)
                        
                        Button("保存") {
                            showingSaveAlert = true
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .alert("このカードを削除しますか？", isPresented: $showingDeleteAlert) {
                Button("キャンセル", role: .cancel) { }
                Button("削除", role: .destructive) {
                    deleteCard()
                    dismiss()
                }
            } message: {
                Text("このカードは削除されます。元に戻すことはできません。")
            }
            .alert("変更を保存", isPresented: $showingSaveAlert) {
                Button("キャンセル", role: .cancel) { }
                Button("保存") {
                    saveChanges()
                    dismiss()
                }
            } message: {
                Text("変更を保存しますか？")
            }
            .fullScreenCover(isPresented: $showCameraPicker) {
                ImagePicker(image: $uiimage, sourceType: .camera)
                    .ignoresSafeArea()
                    .onAppear() {
                        showingCameraView = false
                        if let uiimage = uiimage {
                            saveNewImage(image: uiimage)
                        }
                    }
            }
            .sheet(isPresented:$showHowToUseView){
                TutorialView(imageArray: ["HowToUseCardEdit"])
                    .interactiveDismissDisabled()
                    .onDisappear(){
                        hasSeenTutorial = true
                    }
            }

        }
    }
    
    private var imageSection: some View {
        VStack {
            Text("今日の一枚")
                .font(.custom("GenJyuuGothicX-Bold", size: 15))
                .padding(.bottom, 5)
            AsyncImage(url: editedImagePath) { image in
                image.resizable().aspectRatio(contentMode: .fit)
            } placeholder: {
                Image("mt_No_Image")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 400)
            }
            .frame(height: 400)
            .cornerRadius(5)
            .shadow(radius: 5)
            
            HStack {
                PhotosPicker(selection: $selectedPhotoItem) {
                    Label("写真を選ぶ", systemImage: "photo")
                }
                Button {
                    showCameraPicker = true
                    showingCameraView = true
                } label: {
                    Label("カメラで撮る", systemImage: "camera")
                }
            }
            .onChange(of: selectedPhotoItem) {_ , newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        saveNewImage(image: uiImage)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
    }
    
    private var menuSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("メニュー")
                .font(.custom("GenJyuuGothicX-Bold", size: 15))
            ForEach($editedMenu.indices, id: \.self) { index in
                HStack {
                    Image(systemName: "fork.knife")
                        .foregroundColor(.orange)
                    TextField("メニュー項目", text: $editedMenu[index])
                        .font(.custom("GenJyuuGothicX-Bold", size: 17))
                }
            }
            .onDelete(perform: deleteMenuItem)
            Button(action: {
                editedMenu.append("")
                soundManager.playSound(named: "se_negative")
            }) {
                Label("メニュー項目を追加", systemImage: "plus.circle.fill")
            }
            .foregroundColor(.green)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
    }
    
    private var commentSection: some View {
        VStack(alignment: .leading) {
            Text("感想")
                .font(.custom("GenJyuuGothicX-Bold", size: 15))
            TextEditor(text: $editedLunchComments)
                .font(.custom("GenJyuuGothicX-Bold", size: 17))
                .frame(height: 100)
                .padding(5)
                .background(Color(UIColor.systemGray5))
                .cornerRadius(8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
    }
    
    private var sensesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("五感")
                .font(.custom("GenJyuuGothicX-Bold", size: 15))
            senseRow(icon: "eye.fill", title: "視覚", binding: $editedSight)
            senseRow(icon: "ear.fill", title: "聴覚", binding: $editedHearing)
            senseRow(icon: "nose.fill", title: "嗅覚", binding: $editedSmell)
            senseRow(icon: "mouth.fill", title: "味覚", binding: $editedTaste)
            senseRow(icon: "hand.point.up.fill", title: "触覚", binding: $editedTactile)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
    }
    
    private func senseRow(icon: String, title: String, binding: Binding<String>) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30, height: 30)
            Text(title)
                .font(.custom("GenJyuuGothicX-Bold", size: 16))
                .foregroundColor(.gray)
            TextField(title, text: binding)
                .font(.custom("GenJyuuGothicX-Bold", size: 17))
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    private func deleteMenuItem(at offsets: IndexSet) {
        editedMenu.remove(atOffsets: offsets)
    }
    
    private func saveChanges() {
        data.lunchComments = editedLunchComments
        data.sight = editedSight
        data.taste = editedTaste
        data.tactile = editedTactile
        data.smell = editedSmell
        data.hearing = editedHearing
        data.menu = editedMenu
        data.imagePath = editedImagePath
        try? context.save()
    }
    
    private func deleteCard() {
        context.delete(data)
        try? context.save()
    }
    
    private func saveNewImage(image: UIImage) {
        let fileURL = saveImageToDocumentsDirectory(image: image)
        editedImagePath = fileURL
    }
    
    private func saveImageToDocumentsDirectory(image: UIImage) -> URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: fileURL)
        }
        
        return fileURL
    }
}

#Preview{
    LookBackView()
        .environmentObject(UserData())
        .modelContainer(for: [AjiwaiCardData.self,MenuData.self,ColumnData.self])
}
#Preview{
    ChildHomeView()
        .environmentObject(UserData())
        .modelContainer(for: [AjiwaiCardData.self,MenuData.self,ColumnData.self])
}


