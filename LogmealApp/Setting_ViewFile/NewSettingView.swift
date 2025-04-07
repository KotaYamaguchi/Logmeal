import SwiftUI


struct NewSettingView: View {
    private let tutorialImage: [String] = ["HowToUseHome", "HowToUseCalendar", "HowToUseShop", "HowToUseCharacter", "HowToUseColumnList", "HowToUseAjiwaiCard", "HowToUseQr", "HowToUseCardEdit", "HowToUseSetting", "HowToUseShare1", "HowToUseShare2"]
    @ObservedObject private var soundManager = SoundManager.shared
    @ObservedObject private var bgmManager = BGMManager.shared
    @State private var bgmVolume: Float = BGMManager.shared.bgmVolume
    @EnvironmentObject var userData: UserData
    var body: some View {
        NavigationStack{
            ZStack{
                Image("bg_newSettingView.png")
                    .resizable()
                    .ignoresSafeArea()
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 650, height: 650)
                    .foregroundStyle(Color(red: 220/255, green: 221/255, blue: 221/255))
                VStack{
                    Spacer()
                    Image("mt_newSettingView_setting")
                        .resizable()
                        .scaledToFit()
                        .frame(width:550)
                    settingRow(destination: NewProfileEditView(userData: userData), imageName: "mt_newSettingView_profile")
                    settingRow(destination: soundSettingView(), imageName: "mt_newSettingView_sound")
                    settingRow(destination: ShareExportView(), imageName: "mt_newSettingView_share")
                    settingRow(destination: otherSettingView(), imageName: "mt_newSettingView_others")
                    Button{
                        withAnimation {
                            userData.isTitle = true
                        }
                    }label:{
                        rowDesignWithoutImage()
                    }
                    Spacer()
                    Image("mt_newSettingView_aboutTheApp")
                        .resizable()
                        .scaledToFit()
                        .frame(width:550)
                    settingRow(destination: YoutubeView(), imageName: "mt_newSettingView_prologue")
                    settingRow(destination:TutorialView(imageArray: tutorialImage), imageName: "mt_newSettingView_houUseApp")
                    Spacer()
                }
            }
        }
    }
    private func rowDesignWithoutImage() -> some View{
            Rectangle()
                .foregroundStyle(.white)
                .frame(width:550,height: 50)
                .overlay{
                    HStack(spacing:30){
                        Image(systemName: "arrowshape.turn.up.backward")
                            .font(.system(size: 30))
                        Text("タイトルに戻る")
                            .font(.custom("GenJyuuGothicX-Bold", size: 28))
                        Spacer()
                        
                    }
                    .padding(.horizontal)
                }
    }
    private func settingRow(destination:some View,imageName: String) -> some View {
        NavigationLink{
            destination
        }label: {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width:550)
        }
    }
    private func soundSettingView() -> some View{
        ZStack{
            Image("bg_newSettingView.png")
                .resizable()
                .ignoresSafeArea()
            
            VStack(alignment:.leading){
                Text("サウンド")
                    .font(.custom("GenJyuuGothicX-Bold", size: 30))
                ZStack{
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 600, height: 350)
                        .foregroundStyle(Color(red: 220/255, green: 221/255, blue: 221/255))
                    
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 550, height: 300)
                        .foregroundStyle(.white)
                    VStack(alignment:.leading){
                        //BGM変更スライダー
                        VStack(alignment:.leading){
                            HStack{
                                Text("BGMの音量")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 15))
                                    .foregroundStyle(bgmManager.isBGMOn ? .black : .gray)
                                Spacer()
                                
                                Image(systemName: "speaker.wave.2")
                                    .font(.largeTitle)
                                    .foregroundStyle(bgmManager.isBGMOn ? .black : .gray)
                                Button {
                                    bgmManager.toggleBGM()
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .frame(width: 65, height: 35)
                                            .foregroundStyle(Color(red: 0.42, green: 0.4, blue: 0.4))
                                            .offset(y: 5)
                                        RoundedRectangle(cornerRadius: 10)
                                            .frame(width: 65, height: 35)
                                            .foregroundStyle(bgmManager.isBGMOn ? .orange : .gray)
                                            .overlay {
                                                Text(bgmManager.isBGMOn ? "ON" : "OFF")
                                                    .font(.title)
                                                    .foregroundStyle(.white)
                                            }
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            Slider(value: $bgmVolume, in: 0...1, step: 0.1,onEditingChanged: { editing in
                                if !editing {
                                    bgmManager.setBGMVolume(bgmVolume)
                                }
                            })
                            .tint(bgmManager.isBGMOn ? .orange : .gray)
                            .disabled(!bgmManager.isBGMOn)
                            .padding(.horizontal)
                        }
                        .padding()
                        // SE音量調整スライダー
                        VStack(alignment:.leading){
                            HStack{
                                Text("効果音の音量")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 15))
                                    .foregroundStyle(soundManager.isSoundOn ? .black : .gray)
                                Spacer()
                                Image(systemName: "speaker.wave.2")
                                    .font(.largeTitle)
                                    .foregroundStyle(soundManager.isSoundOn ? .black : .gray)
                                Button{
                                    soundManager.toggleSound()
                                }label:{
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 10)
                                            .frame(width: 65, height: 35)
                                            .foregroundStyle(Color(red: 0.42, green: 0.4, blue: 0.4))
                                            .offset(y:5)
                                        RoundedRectangle(cornerRadius: 10)
                                            .frame(width: 65, height: 35)
                                            .foregroundStyle( soundManager.isSoundOn ? .orange : .gray)
                                            .overlay{
                                                Text( soundManager.isSoundOn ? "ON" : "OFF")
                                                    .font(.title)
                                                    .foregroundStyle(.white)
                                            }
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            Slider(value: Binding(
                                get: { soundManager.soundVolume },
                                set: { newVolume in
                                    soundManager.setSoundVolume(newVolume)
                                }
                            ), in: 0...1, step:0.1, onEditingChanged: { editing in
                                if !editing {
                                    soundManager.setSoundVolume(soundManager.soundVolume)
                                }
                            })
                            .tint(soundManager.isSoundOn ? .orange : .gray)
                            .disabled(!soundManager.isSoundOn)
                        }
                        .padding()
                    }
                    .frame(width: 500, height: 300)
                }
            }
        }
    }
    private func otherSettingView() -> some View{
        VStack{
            
        }
    }
}

struct NewProfileEditView: View {
    @ObservedObject var userData:UserData
    
    @State private var userName: String = ""
    @State private var userGrade: Int = 1
    @State private var userClass: Int = 1
    @State private var userAge: Int = 6
    var body: some View {
        ZStack {
            Image("bg_newSettingView.png")
                .resizable()
                .ignoresSafeArea()
            
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 650, height: 750)
                .foregroundStyle(Color(red: 220/255, green: 221/255, blue: 221/255))
                .shadow(radius: 5)
            
            VStack{
                Image("mt_newSettingView_userImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                    .padding(.bottom)
                Image("mt_newSettingView_profileHeadline")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 550)
                
                // 名前入力
                Image("mt_newSettingView_name")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 550)
                    .overlay {
                        HStack {
                            Spacer()
                            TextField("ここに名前を入力してください", text: $userName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 400)
                                .padding(.horizontal)
                                .multilineTextAlignment(TextAlignment.trailing)
                        }
                    }
                
                // 学年選択
                Image("mt_newSettingView_grade")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 550)
                    .overlay {
                        HStack {
                            Spacer()
                            
                            Picker("選択してください", selection: $userGrade) {
                                ForEach(1...6, id: \.self) { grade in
                                    Text("\(grade)年").tag(grade)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 150)
                        }
                        .padding(.horizontal)
                    }
                
                // クラス選択
                Image("mt_newSettingView_class")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 550)
                    .overlay {
                        HStack {
                            Spacer()
                            
                            Picker("選択してください", selection: $userClass) {
                                ForEach(1...10, id: \.self) { classNum in
                                    Text("\(classNum)組").tag(classNum)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 150)
                        }
                        .padding(.horizontal)
                    }
                
                // 年齢選択
                Image("mt_newSettingView_age")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 550)
                    .overlay {
                        HStack {
                            Spacer()
                            
                            Picker("選択してください", selection: $userAge) {
                                ForEach(6...18, id: \.self) { age in
                                    Text("\(age)歳").tag(age)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 150)
                        }
                        .padding(.horizontal)
                    }
            }
            .padding()
        }
    }
}

import SwiftUI
import SwiftData

struct ShareExportView: View {
    @Environment(\.modelContext) private var context
    @Query private var allData: [AjiwaiCardData]
    @EnvironmentObject var user: UserData
    
    @State private var pdfURL: URL?
    @State private var showShareSheet = false
    @State private var isGenerating = false
    @State private var showActionSheet = false
    @State private var showDatePicker = false
    @State private var selectedFileType: FileType = .pdf
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()

    enum FileType {
        case pdf, csv
    }
    
    var body: some View {
        ZStack{
            Image("bg_newSettingView.png")
                .resizable()
                .ignoresSafeArea()
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 350, height: 200)
                .foregroundStyle(Color(red: 220/255, green: 221/255, blue: 221/255))
        VStack(spacing: 20) {
            Button{
                selectedFileType = .pdf
                showDatePicker = true
            }label:{
                Text("PDFで共有")
                    .font(.custom("GenJyuuGothicX-Bold", size: 15))
                    .frame(width: 300, height: 50)
                    .background(Color.white)
                    .foregroundStyle(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .disabled(allData.isEmpty)
            Button{
                selectedFileType = .csv
                showDatePicker = true
            }label:{
                Text("CSVで共有")
                    .font(.custom("GenJyuuGothicX-Bold", size: 15))
                    .frame(width: 300, height: 50)
                    .background(Color.white)
                    .foregroundStyle(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .disabled(allData.isEmpty)
        }
        .padding()
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
                    
                }
                .font(.custom("GenJyuuGothicX-Bold", size: 15))
                .frame(width: 220, height: 50)
                .background(Color.gray)
                .foregroundStyle(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .buttonStyle(PlainButtonStyle())
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = pdfURL {
                ShareSheet(activityItems: [url])
                    .onAppear() {
                        isGenerating = false
                    }
            }
        }
        .overlay {
            if isGenerating {
                ZStack {
                    Color.gray.opacity(0.5).ignoresSafeArea()
                    ProgressView("共有の準備中...")
                        .font(.custom("GenJyuuGothicX-Bold", size: 17))
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .tint(.white)
                        .foregroundColor(.white)
                        .cornerRadius(10)
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
            let pdfGenerator = MultiPagePDFGenerator(
                allData: filteredData,
                userName: user.name,
                userGrade: user.grade,
                userClass: user.yourClass,
                userAge: String(user.age),
                userSex: user.gender
            )
            let pdfPath = await pdfGenerator.generatePDF()

            await MainActor.run {
                self.pdfURL = pdfPath
                self.isGenerating = false
                self.showShareSheet = true
            }

        case .csv:
            let exportData = ExportData(
                userName: user.name,
                userGrade: user.grade,
                userClass: user.yourClass,
                userAge: String(user.age),
                userSex: user.gender
            )
            let filename = "\(user.grade)年 \(user.yourClass)組\(user.name)の給食の記録"
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


#Preview{
    NewContentView()
        .environmentObject(UserData())
        .modelContainer(for: AjiwaiCardData.self)
}
#Preview{
    NewSettingView()
        .environmentObject(UserData())
        .modelContainer(for: AjiwaiCardData.self)
}
