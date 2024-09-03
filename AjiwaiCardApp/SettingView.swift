import SwiftUI
import SwiftData

struct SettingView: View {
    @Environment(\.modelContext) private var context
    @Query private var allData: [AjiwaiCardData]
    @EnvironmentObject var user: UserData
    @State var showQRscaner = false
    @State private var pdfURL: URL?
    @State private var showShareSheet = false
    @State private var isGenerating = false
    @State private var showActionSheet = false
    @State private var showDatePicker = false
    @State private var selectedFileType: FileType = .pdf
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasSeenSettingViewTutorial") private var hasSeenTutorial = false
    @State private var showHowToUseView = false
    @State private var showTutorialView = false
    @State private var showProfileEditlView = false
    private let tutorialImage: [String] = ["HowToUseHome", "HowToUseCalendar", "HowToUseShop", "HowToUseCharacter", "HowToUseColumnList", "HowToUseAjiwaiCard", "HowToUseQr", "HowToUseCardEdit", "HowToUseSetting", "HowToUseShare1", "HowToUseShare2"]
    
    private let soundManager = SoundManager.shared
    private let bgmManager = BGMManager.shared
    
    @State private var cacheSize: String = "Calculating..."
    
    enum FileType {
        case pdf, csv
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack(alignment: .top) {
                    Image("bg_AjiwaiCardView")
                        .resizable()
                        .ignoresSafeArea()
                        .saturation(0.0)
                    HStack {
                        Button {
                            dismiss()
                            soundManager.playSound(named: "se_nagative")
                        } label: {
                            Image("bt_close")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 50)
                        }
                        .padding()
                        .buttonStyle(PlainButtonStyle())
                        Spacer()
                        Button {
                            showHowToUseView = true
                            soundManager.playSound(named: "se_positive")
                        } label: {
                            Image("bt_description")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding()
                    }
                    VStack(spacing: 20) {
                        Text("設定画面")
                            .font(.custom("GenJyuuGothicX-Bold", size: 35))
                        Divider()
                            .frame(width: geometry.size.width * 0.5)
                        
                        ScrollView{
                            // BGM音量調整スライダー
                            VStack {
                                Text("BGMの音量")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 15))
                                HStack {
                                    Button {
                                        bgmManager.bgmVolume -= 0.1
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.title)
                                            .foregroundStyle(.orange)
                                    }
                                    Slider(value: Binding(
                                        get: { bgmManager.bgmVolume },
                                        set: { newVolume in
                                            bgmManager.setBGMVolume(newVolume)
                                        }
                                    ), in: 0...1, onEditingChanged: { editing in
                                        if !editing {
                                            // スライダー操作終了時に音量変更を反映
                                            bgmManager.setBGMVolume(bgmManager.bgmVolume)
                                        }
                                    })
                                    .tint(.orange)
                                    .padding(.horizontal)
                                    Button {
                                        bgmManager.bgmVolume += 0.1
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title)
                                            .foregroundStyle(.orange)
                                    }
                                }
                            }
                            .padding()
                            .frame(width: geometry.size.width * 0.3)
                            
                            // SE音量調整スライダー
                            VStack {
                                Text("効果音の音量")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 15))
                                HStack {
                                    Button {
                                        soundManager.soundVolume = max(soundManager.soundVolume - 0.1, 0) // 最小値を0に制限
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.title)
                                            .foregroundStyle(.orange)
                                    }
                                    Slider(value: Binding(
                                        get: { soundManager.soundVolume },
                                        set: { newVolume in
                                            soundManager.setSoundVolume(newVolume)
                                        }
                                    ), in: 0...1, onEditingChanged: { editing in
                                        if !editing {
                                            soundManager.setSoundVolume(soundManager.soundVolume)
                                        }
                                    })
                                    .tint(.orange)
                                    .padding(.horizontal)
                                    Button {
                                        soundManager.soundVolume = min(soundManager.soundVolume + 0.1, 1) // 最大値を1に制限
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title)
                                            .foregroundStyle(.orange)
                                    }
                                }
                            }
                            .padding()
                            .frame(width: geometry.size.width * 0.3)
                            
                            Button {
                                showProfileEditlView = true
                            } label: {
                                Text("プロフィールを編集する")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 15))
                                    .frame(width: 300, height: 50)
                                    .background(Color.cyan)
                                    .foregroundStyle(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                            .buttonStyle(PlainButtonStyle())
                            .simultaneousGesture(TapGesture().onEnded {
                                soundManager.playSound(named: "se_positive")
                            })
                            Button {
                                showTutorialView = true
                            } label: {
                                Text("アプリの使い方を見る")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 15))
                                    .frame(width: 300, height: 50)
                                    .background(Color.cyan)
                                    .foregroundStyle(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                            .buttonStyle(PlainButtonStyle())
                            .simultaneousGesture(TapGesture().onEnded {
                                soundManager.playSound(named: "se_positive")
                            })
                            Button {
                                showQRscaner = true
                                soundManager.playSound(named: "se_positive")
                            } label: {
                                Text("1ヶ月分のメニューを入力する")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 15))
                                    .frame(width: 300, height: 50)
                                    .background(Color.cyan)
                                    .foregroundStyle(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                            .buttonStyle(PlainButtonStyle())
                            Button {
                                showActionSheet = true
                                soundManager.playSound(named: "se_positive")
                            } label: {
                                Text("共有する")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 15))
                                    .frame(width: 300, height: 50)
                                    .background(Color.cyan)
                                    .foregroundStyle(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(allData.isEmpty)
                            .actionSheet(isPresented: $showActionSheet) {
                                ActionSheet(title: Text("共有方法を選択してください"), buttons: [
                                    .default(Text("PDFで共有")) {
                                        selectedFileType = .pdf
                                        showDatePicker = true
                                    },
                                    .default(Text("CSVで共有")) {
                                        selectedFileType = .csv
                                        showDatePicker = true
                                    },
                                    .cancel()
                                ])
                            }
                            Button {
                                print(user.path)
                                user.path.removeLast()
                                soundManager.playSound(named: "se_negative")
                            } label: {
                                Text("タイトルに戻る")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 15))
                                    .frame(width: 220, height: 50)
                                    .background(Color.red)
                                    .foregroundStyle(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height*0.8)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
                    if isGenerating {
                        ProgressView("共有の準備中...")
                            .font(.custom("GenJyuuGothicX-Bold", size: 17))
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .tint(.white)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        Color.gray.opacity(0.5)
                            .ignoresSafeArea()
                    }
                }
                .onAppear() {
                    if !hasSeenTutorial {
                        showHowToUseView = true
                    }
                }
                .sheet(isPresented: $showTutorialView) {
                    TutorialView(imageArray: tutorialImage)
                }
                .sheet(isPresented: $showProfileEditlView) {
                    ProfileEditView()
                }
                .sheet(isPresented: $showQRscaner) {
                    ScannerView(isPresentingScanner: $showQRscaner)
                }
                .sheet(isPresented: $showShareSheet) {
                    if let url = pdfURL {
                        ShareSheet(activityItems: [url])
                            .onAppear() {
                                isGenerating = false
                            }
                    }
                }
                .sheet(isPresented: $showDatePicker) {
                    VStack {
                        HStack {
                            VStack {
                                Text("この日から")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 17))
                                DatePicker("開始日", selection: $startDate, displayedComponents: .date)
                                    .datePickerStyle(GraphicalDatePickerStyle())
                                    .padding()
                            }
                            Divider()
                                .frame(height: 400)
                            VStack {
                                Text("この日まで")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 17))
                                DatePicker("終了日", selection: $endDate, displayedComponents: .date)
                                    .datePickerStyle(GraphicalDatePickerStyle())
                                    .padding()
                            }
                        }
                        Button("データを共有する") {
                            soundManager.playSound(named: "se_positive")
                            showDatePicker = false
                            isGenerating = true
                            Task {
                                await generateAndShareFile()
                            }
                        }
                        .font(.custom("GenJyuuGothicX-Bold", size: 15))
                        .frame(width: 220, height: 50)
                        .background(Color.cyan)
                        .foregroundStyle(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .buttonStyle(PlainButtonStyle())
                        Button("キャンセル") {
                            showDatePicker = false
                            soundManager.playSound(named: "se_negative")
                        }
                        .font(.custom("GenJyuuGothicX-Bold", size: 15))
                        .frame(width: 220, height: 50)
                        .background(Color.gray)
                        .foregroundStyle(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                }
                .sheet(isPresented: $showHowToUseView) {
                    TutorialView(imageArray: ["HowToUseSetting", "HowToUseQr", "HowToUseShare1", "HowToUseShare2"])
                        .interactiveDismissDisabled()
                        .onDisappear() {
                            hasSeenTutorial = true
                        }
                }
            }
        }
    }
    
    @MainActor
    func generateAndShareFile() async {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: startDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate))!
        
        let filteredData = allData
            .filter { $0.saveDay >= startOfDay && $0.saveDay < endOfDay }
            .sorted(by: { $0.saveDay < $1.saveDay })
        
        switch selectedFileType {
        case .pdf:
            let pdfGenerator = MultiPagePDFGenerator(allData: filteredData, userName: user.name, userGrade: user.grade, userClass: user.yourClass)
            let pdfPath = await pdfGenerator.generatePDF()
            
            await MainActor.run {
                self.pdfURL = pdfPath
                self.isGenerating = false
                self.showShareSheet = true
            }
            
        case .csv:
            let exportData = ExportData()
            let filename = "\(user.grade)年 \(user.yourClass)組\(user.name)の味わいカード"
            exportData.createCSV(filename: filename, datas: filteredData)
            
            let documentsPath = exportData.getDocumentsDirectory()
            let csvPath = documentsPath.appendingPathComponent("\(filename).csv")
            
            await MainActor.run {
                self.pdfURL = csvPath
                self.isGenerating = false
                self.showShareSheet = true
            }
        }
    }
}

#Preview {
    SettingView()
        .modelContainer(for: [AjiwaiCardData.self, MenuData.self, ColumnData.self])
        .environmentObject(UserData())
}
#Preview {
    ChildHomeView()
        .modelContainer(for: [AjiwaiCardData.self, MenuData.self, ColumnData.self])
        .environmentObject(UserData())
}

import SwiftUI

struct ProfileEditView: View {
    @EnvironmentObject var user: UserData
    @Environment(\.dismiss) var dismiss
    @State private var editedName: String = ""
    @State private var editedGrade: Int = 0
    @State private var editedClass: Int = 0
    @State private var editedAge: Int = 0
    @State private var showingSaveAlert = false
    
    
    
    var body: some View {
        NavigationStack{
            ScrollView {
                VStack(spacing: 20) {
                    profileInfoSection
                }
                .padding()
            }
            .background(Color(UIColor.systemGray6))
            .navigationTitle("プロフィール編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement:.topBarLeading){
                    Button("キャンセル",role: .cancel){
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        showingSaveAlert = true
                    }
                    .foregroundColor(.blue)
                }
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
        }
    }
    
    private var profileInfoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("プロフィール情報")
                .font(.custom("GenJyuuGothicX-Bold", size: 15))
            
            infoRow(icon: "person.fill", title: "名前") {
                TextField("名前", text: $user.name)
                    .font(.custom("GenJyuuGothicX-Bold", size: 17))
            }
            
            infoRow(icon: "graduationcap.fill", title: "学年") {
                Picker("学年", selection: $user.grade) {
                    ForEach(1..<6) { grade in
                        Text("\(grade)年生").tag(grade)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            infoRow(icon: "book.fill", title: "クラス") {
                Picker("クラス", selection: $user.yourClass) {
                    ForEach(1..<100) { Class in
                        Text("\(Class)").tag(Class)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            infoRow(icon: "birthday.cake.fill", title: "年齢") {
                Picker("年齢", selection: $user.age) {
                    ForEach(0..<100) { age in
                        Text("\(age)歳").tag(age)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
        }
        .onAppear(){
            print(user.name)
            print(user.age)
            print(user.grade)
            print(user.yourClass)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
    }
    
    private func infoRow<Content: View>(icon: String, title: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30, height: 30)
            Text(title)
                .font(.custom("GenJyuuGothicX-Bold", size: 16))
                .foregroundColor(.gray)
            content()
        }
    }
    
    private func saveChanges() {
        if user.name == ""{
            user.name = "ななし"
        }
    }
}

