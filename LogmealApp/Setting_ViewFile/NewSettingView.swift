import SwiftUI
import SwiftData

struct NewSettingView: View {
    private let tutorialImage: [String] = ["HowToUseHome", "HowToUseCalendar", "HowToUseShop", "HowToUseCharacter", "HowToUseColumnList", "HowToUseAjiwaiCard", "HowToUseQr", "HowToUseCardEdit", "HowToUseSetting", "HowToUseShare1", "HowToUseShare2"]
    @EnvironmentObject var userData: UserData
    var body: some View {
        NavigationStack{
            GeometryReader{ geomtry in
                ZStack{
                    Image("bg_newSettingView.png")
                        .resizable()
                        .ignoresSafeArea()
                    VStack{
                        Image("mt_newSettingView_setting")
                            .resizable()
                            .scaledToFit()
                            .frame(width:550)
                        NavigationLink{
                            ProfileSettingView()
                        }label: {
                            SettingRowDesign(withImage: true, imageName: "mt_newSettingView_profile")
                        }
                        NavigationLink{
                            SoundSettingView()
                        }label: {
                            SettingRowDesign(withImage: true, imageName: "mt_newSettingView_sound")
                        }
                        NavigationLink{
                            ShareExportView()
                        }label: {
                            SettingRowDesign(withImage: true, imageName: "mt_newSettingView_share")
                        }
                        NavigationLink{
                            OtherSettingView()
                        }label: {
                            SettingRowDesign(withImage: true, imageName: "mt_newSettingView_others")
                        }
                        Button{
                            withAnimation {
                                userData.isTitle = true
                            }
                        }label:{
                            SettingRowDesign(withImage: false,rowTitle: "タイトルに戻る", iconName: "arrowshape.turn.up.backward")
                        }
                        .padding(.bottom)
                        Image("mt_newSettingView_aboutTheApp")
                            .resizable()
                            .scaledToFit()
                            .frame(width:550)
                        NavigationLink{
                            YoutubeView(withBaclButton: false)
                        }label: {
                            SettingRowDesign(withImage: true, imageName: "mt_newSettingView_prologue")
                        }
                        NavigationLink{
                            TutorialView(imageArray: tutorialImage,withBackButton: false)
                        }label: {
                            SettingRowDesign(withImage: true, imageName: "mt_newSettingView_houUseApp")
                        }
                        
                    }
                    .padding(.vertical)
                    .frame(width: 600, height: 600)
                    .background(){
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(Color(red: 220/255, green: 221/255, blue: 221/255))
                    }
                }
            }
            
        }
    }
}

struct SettingRowDesign:View {
    let withImage:Bool
    var imageName:String = ""
    var rowTitle:String = ""
    var iconName:String = ""
    var textColor:Color = .black
    var icnoColor:Color = .black
     var body: some View {
        if withImage{
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width:550)
        }else{
            Rectangle()
                .foregroundStyle(.white)
                .frame(width:550,height: 50)
                .overlay{
                    HStack(spacing:30){
                        Image(systemName: iconName)
                            .font(.system(size: 30))
                            .foregroundStyle(icnoColor)
                        Text(rowTitle)
                            .font(.custom("GenJyuuGothicX-Bold", size: 28))
                            .foregroundStyle(textColor)
                        Spacer()
                        
                    }
                    .padding(.horizontal)
                }
        }
    }
}

struct SoundSettingView:View {
    @ObservedObject private var soundManager = SoundManager.shared
    @ObservedObject private var bgmManager = BGMManager.shared
    @State private var bgmVolume: Float = BGMManager.shared.bgmVolume
    @State private var soundVolume: Float = SoundManager.shared.soundVolume
    var body: some View {
        ZStack{
            Image("bg_newSettingView.png")
                .resizable()
                .ignoresSafeArea()
            
                ZStack{
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 600, height: 330)
                        .foregroundStyle(Color(red: 220/255, green: 221/255, blue: 221/255))
                    VStack(spacing:10){
                        UnevenRoundedRectangle(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20, style: .continuous)
                            .frame(width: 550, height: 40)
                            .foregroundStyle(.white)
                            .overlay{
                                HStack{
                                    Text("サウンド")
                                        .padding()
                                        .font(.custom("GenJyuuGothicX-Bold", size: 23))
                                    Spacer()
                                }
                            }
                        VStack(spacing:6){
                            //BGM変更スライダー
                            VStack(alignment:.leading,spacing: 3){
                                Rectangle()
                                    .foregroundStyle(.white)
                                    .frame(width:550,height: 60)
                                .overlay{
                                    HStack{
                                        Text("BGMの音量")
                                            .font(.custom("GenJyuuGothicX-Bold", size: 15))
                                            .foregroundStyle(bgmManager.isBGMOn ? .black : .gray)
                                        Spacer()
                                        Button {
                                            bgmManager.toggleBGM()
                                        } label: {
                                            ZStack{
                                                Capsule()
                                                    .frame(width: 65, height: 35)
                                                    .foregroundStyle(.gray.opacity(0.3))
                                                Circle()
                                                    .frame(height: 35)
                                                    .foregroundStyle(bgmManager.isBGMOn ? .orange : .gray)
                                                    .offset(x:bgmManager.isBGMOn ? 15 :-15)
                                                    
                                            }
    //                                        ZStack {
    //                                            RoundedRectangle(cornerRadius: 10)
    //                                                .frame(width: 65, height: 35)
    //                                                .foregroundStyle(Color(red: 0.42, green: 0.4, blue: 0.4))
    //                                                .offset(y: 5)
    //                                            RoundedRectangle(cornerRadius: 10)
    //                                                .frame(width: 65, height: 35)
    //                                                .foregroundStyle(bgmManager.isBGMOn ? .orange : .gray)
    //                                                .overlay {
    //                                                    Text(bgmManager.isBGMOn ? "ON" : "OFF")
    //                                                        .font(.title)
    //                                                        .foregroundStyle(.white)
    //                                                }
    //                                        }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                    .padding()
                                }
                                Rectangle()
                                    .foregroundStyle(.white)
                                    .frame(width:550,height: 45)
                                    .overlay{
                                        HStack{
                                            Button{
                                                if bgmVolume >= 0{
                                                    bgmVolume -= 0.1
                                                    print("-1")
                                                }else{
                                                    print("MIN")
                                                }
                                            }label: {
                                                Image(systemName: "minus.circle")
                                                    .font(.system(size: 25))
                                                    .foregroundStyle(bgmVolume <= 0 || !bgmManager.isBGMOn ? .gray : .orange)
                                            }
                                            .disabled(bgmVolume <= 0 || !bgmManager.isBGMOn)
                                            Slider(value: $bgmVolume, in: 0...1, step: 0.1,onEditingChanged: { editing in
                                                if !editing {
                                                    bgmManager.setBGMVolume(bgmVolume)
                                                }
                                            })
                                            .tint(bgmManager.isBGMOn ? .orange : .gray)
                                            .disabled(!bgmManager.isBGMOn)
                                            Button{
                                                if bgmVolume <= 1{
                                                    bgmVolume += 0.1
                                                    print("+1")
                                                }else{
                                                    print("MAX")
                                                }
                                                
                                            }label: {
                                                Image(systemName: "plus.circle")
                                                    .font(.system(size: 25))
                                                    .foregroundStyle(bgmVolume >= 1 || !bgmManager.isBGMOn ? .gray : .orange)
                                            }
                                            .disabled(bgmVolume >= 1 || !bgmManager.isBGMOn)
                                        }
                                        .padding(.horizontal)
                                    }
                                
                            }
                           
                            // SE音量調整スライダー
                            VStack(alignment:.leading,spacing: 3){
                                Rectangle()
                                    .foregroundStyle(.white)
                                    .frame(width:550,height: 60)
                                    .overlay{
                                        HStack{
                                            Text("効果音の音量")
                                                .font(.custom("GenJyuuGothicX-Bold", size: 15))
                                                .foregroundStyle(soundManager.isSoundOn ? .black : .gray)
                                            Spacer()
                                            Button{
                                                soundManager.toggleSound()
                                            }label:{
                                                ZStack{
                                                    Capsule()
                                                        .frame(width: 65, height: 35)
                                                        .foregroundStyle(.gray.opacity(0.3))
                                                    Circle()
                                                        .frame(height: 35)
                                                        .foregroundStyle(soundManager.isSoundOn ? .orange : .gray)
                                                        .offset(x:soundManager.isSoundOn ? 15 :-15)
                                                        
                                                }
                                                
    //                                            ZStack{
    //                                                RoundedRectangle(cornerRadius: 10)
    //                                                    .frame(width: 65, height: 35)
    //                                                    .foregroundStyle(Color(red: 0.42, green: 0.4, blue: 0.4))
    //                                                    .offset(y:5)
    //                                                RoundedRectangle(cornerRadius: 10)
    //                                                    .frame(width: 65, height: 35)
    //                                                    .foregroundStyle( soundManager.isSoundOn ? .orange : .gray)
    //                                                    .overlay{
    //                                                        Text( soundManager.isSoundOn ? "ON" : "OFF")
    //                                                            .font(.title)
    //                                                            .foregroundStyle(.white)
    //                                                    }
    //                                            }
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                        .padding(.horizontal)
                                    }
                                UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 20, bottomTrailingRadius: 20, topTrailingRadius: 0, style: .continuous)
                                    .foregroundStyle(.white)
                                    .frame(width:550,height: 45)
                                    .overlay{
                                        HStack{
                                            Button{
                                                if soundVolume > 0{
                                                    soundVolume -= 0.1
                                                    print("-1")
                                                }else{
                                                    print("MIN")
                                                }
                                                
                                            }label: {
                                                Image(systemName: "minus.circle")
                                                    .font(.system(size: 25))
                                                    .foregroundStyle(soundVolume <= 0 || !soundManager.isSoundOn ? .gray : .orange)
                                            }
                                            .disabled(soundVolume <= 0 || !soundManager.isSoundOn)
                                            Slider(value: $soundVolume, in: 0...1, step: 0.1, onEditingChanged: { editing in
                                                if !editing{
                                                    soundManager.setSoundVolume(soundVolume)
                                                }
                                            })
                                            .tint(soundManager.isSoundOn ? .orange : .gray)
                                            .disabled(!soundManager.isSoundOn)
                                            Button{
                                                if soundVolume < 1{
                                                    soundVolume += 0.1
                                                    print("+1")
                                                }else{
                                                    print("MAX")
                                                }
                                                
                                            }label: {
                                                Image(systemName: "plus.circle")
                                                    .font(.system(size: 25))
                                                    .foregroundStyle(soundVolume >= 1 || !soundManager.isSoundOn ? .gray : .orange)
                                            }
                                            .disabled(soundVolume >= 1 || !soundManager.isSoundOn)
                                        }
                                        .padding(.horizontal)
                                    }
                                
                            }
                        }
                 
                        
                    }
                }
        }
    }
}

struct OtherSettingView:View {
    @Environment(\.modelContext) private var context
    @Query private var allColumns: [ColumnData]
    @Query private var allMenus: [MenuData]
    @EnvironmentObject var user: UserData
    
    let rowTitles = ["メニューとコラムを入力する","メニューを削除する","コラムを削除する"]
    let rowIcons = ["qrcode","trash","trash"]
    
    @State private var showQRreader:Bool = false
    @State private var showDeleteView:Bool = false
    @State private var selectedDates: Set<DateComponents> = []
    @State private var isColumn = false
    
    @State private var showConfirmAlert = false

    var body: some View {
        ZStack{
            Image("bg_newSettingView.png")
                .resizable()
                .ignoresSafeArea()
            VStack(spacing:10){
                UnevenRoundedRectangle(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20, style: .continuous)
                    .frame(width: 550, height: 40)
                    .foregroundStyle(.white)
                    .overlay{
                        HStack{
                            Text("その他")
                                .padding()
                                .font(.custom("GenJyuuGothicX-Bold", size: 23))
                            Spacer()
                        }
                    }
                VStack(spacing:5){
                    Button{
                        showQRreader = true
                    }label: {
                        SettingRowDesign(withImage: false, rowTitle: rowTitles[0], iconName: rowIcons[0])
                    }
                    Button{
                        isColumn = false
                        showDeleteView = true
                    }label: {
                        SettingRowDesign(withImage: false, rowTitle: rowTitles[1], iconName: rowIcons[1],textColor: .red,icnoColor: .red)
                    }
                    Button{
                        isColumn = true
                        showDeleteView = true
                    }label: {
                        UnevenRoundedRectangle(topLeadingRadius: 0,bottomLeadingRadius: 20,bottomTrailingRadius: 20,topTrailingRadius: 0)
                            .foregroundStyle(.white)
                            .frame(width:550,height: 50)
                            .overlay{
                                HStack(spacing:30){
                                    Image(systemName: "trash")
                                        .font(.system(size: 30))
                                        .foregroundStyle(.red)
                                    Text("コラムを削除する")
                                        .font(.custom("GenJyuuGothicX-Bold", size: 28))
                                        .foregroundStyle(.red)
                                    Spacer()
                                    
                                }
                                .padding(.horizontal)
                            }
                    }
                }
                
            }
            .frame(width: 600, height: 250)
            .background(){
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(Color(red: 220/255, green: 221/255, blue: 221/255))
            }
        }
        .sheet(isPresented: $showQRreader) {
            ScannerView(isPresentingScanner: $showQRreader)
        }
        .sheet(isPresented: $showDeleteView) {
            DeleteColumnAndMenuView(isColumn: isColumn)
        }
    }
    
    private func DeleteColumnAndMenuView(isColumn: Bool) -> some View {
        VStack {
            Text(isColumn ? "削除するコラムの日付を選ぶ" : "削除するメニューの日付を選ぶ")
                .font(.custom("GenJyuuGothicX-Bold", size: 20))

            MultiDatePicker("選択", selection: $selectedDates)
                .environment(\.locale, Locale(identifier: "ja_JP"))
                .frame(maxHeight: 400)

            Button("選択した日付のデータを削除") {
                showConfirmAlert = true
            }
            .font(.custom("GenJyuuGothicX-Bold", size: 20))
            .padding()
            .background(Color.red)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .alert(isPresented: $showConfirmAlert) {
                Alert(
                    title: Text("本当に削除しますか？"),
                    message: Text("一度削除すると元に戻せません。"),
                    primaryButton: .destructive(Text("削除")) {
                        deleteSelectedData(isColumn: isColumn)
                        showDeleteView = false // モーダルを閉じる
                    },
                    secondaryButton: .cancel(Text("キャンセル"))
                )
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }

    private func deleteSelectedData(isColumn:Bool) {
          let dateStrings = selectedDates.compactMap { comp -> String? in
              guard let date = Calendar.current.date(from: comp) else { return nil }
              return user.dateFormatter(date: date)
          }
        if isColumn{
            // ColumnData 削除
            for column in allColumns {
                if dateStrings.contains(column.columnDay) {
                    context.delete(column)
                }
            }
            print("\(selectedDates)のコラムを削除完了")
        }else{
            // MenuData 削除
            for menu in allMenus {
                if dateStrings.contains(menu.day) {
                    context.delete(menu)
                }
            }
            print("\(selectedDates)のメニューを削除完了")
        }
        try? context.save()
      }
}

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
    @State private var isSelctedPDF = false
    @State private var isSelctedCSV = false
    enum FileType {
        case pdf, csv
    }
    
    var body: some View {
        ZStack{
            Image("bg_newSettingView.png")
                .resizable()
                .ignoresSafeArea()
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 600, height: 250)
                .foregroundStyle(Color(red: 220/255, green: 221/255, blue: 221/255))
            VStack(spacing:10){
                UnevenRoundedRectangle(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20, style: .continuous)
                    .frame(width: 550, height: 40)
                    .foregroundStyle(.white)
                    .overlay{
                        HStack{
                            Text("共有")
                                .padding()
                                .font(.custom("GenJyuuGothicX-Bold", size: 23))
                            Spacer()
                        }
                    }
                VStack(spacing:5){
                    Button{
                        selectedFileType = .pdf
                        isSelctedCSV = false
                        isSelctedPDF.toggle()
                    }label:{
                        ZStack{
                            SettingRowDesign(withImage: false, rowTitle: "PDFで共有", iconName: isSelctedPDF ? "checkmark.circle.fill" : "circle", textColor: allData.isEmpty ? .gray :  .black, icnoColor:isSelctedPDF ? .orange : .gray)

                        }
                    }
                    .disabled(allData.isEmpty)
                    Button{
                        selectedFileType = .csv
                        isSelctedPDF = false
                        isSelctedCSV .toggle()
                    }label:{
                        ZStack{
                            UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 20, bottomTrailingRadius: 20, topTrailingRadius: 0, style: .continuous)
                                .foregroundStyle(.white)
                                .frame(width:550,height: 50)
                                .overlay{
                                    HStack(spacing:30){
                                        Image(systemName: isSelctedCSV ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 30))
                                            .foregroundStyle(isSelctedCSV ? .orange : .gray)
                                        Text("CSVで共有")
                                            .font(.custom("GenJyuuGothicX-Bold", size: 28))
                                            .foregroundStyle(allData.isEmpty ? .gray : .black)
                                        Spacer()
                                        
                                    }
                                    .padding(.horizontal)
                                }
                        }
                    }
                    .disabled(allData.isEmpty)
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
            VStack{
                Spacer()
                Button{
                    showDatePicker = true
                }label: {
                    Capsule()
                        .frame(width:400,height: 70)
                        .foregroundStyle(isSelctedPDF || isSelctedCSV ? Color(red: 215/255, green: 97/255, blue: 68/255) : .gray)
                        .overlay{
                            Text("完了")
                                .font(.custom("GenJyuuGothicX-Bold", size: 40))
                                .foregroundStyle(.white)
                                .kerning(5)
                        }
                }
                .disabled(!isSelctedPDF && !isSelctedCSV)
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
    ShareExportView()
}
