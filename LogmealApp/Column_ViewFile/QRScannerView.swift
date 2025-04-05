import SwiftUI
import SwiftData
import CodeScanner

struct ScannerView: View {
    @Environment(\.modelContext) private var context
    @Query private var allColumn: [ColumnData]
    @Query private var allMenu: [MenuData]
    @Binding var isPresentingScanner: Bool
    @State private var scannedCode: String = ""
    @State private var isScanning: Bool = false
    @State private var sheetURL: String = ""
    @State private var sheetID: String = ""
    @StateObject private var spreadSheetManager = SpreadSheetManager()
    @State private var selectedYear: String = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年"
        dateFormatter.locale = Locale(identifier: "ja_JP")
        return dateFormatter.string(from: Date())
    }()
    @State private var selectedMonth: String = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M月"
        dateFormatter.locale = Locale(identifier: "ja_JP")
        return dateFormatter.string(from: Date())
    }()
    @State private var keyOfDate: [String] = []
    @State private var valueOfDate: [[String]] = []
    @State private var titleOfColumn: [String] = []
    @State private var captionOfColumn: [String] = []
    @State private var showQRscanResults: Bool = false
    @State private var QRscanResults: Bool = false
    @State private var isReady:Bool = true
    private let soundManager = SoundManager.shared
    @State private var escapeData:[[String]] = []

    // QRコードを読み取った後のデータ保存関数
    func saveToDatabase(dataArray: [[String]]) {
        for data in dataArray {
            guard data.count >= 3 else {
                continue // 要素数が3未満の場合は無視
            }
            
            // データを分割
            let columnDay = data[0] // 最初の要素をcolumnDayに設定
            let title = data[data.count - 2] // 後ろから2番目の要素をtitleに設定
            let caption = data[data.count - 1] // 最後の要素をcaptionに設定
            let menuItems = Array(data[1..<(data.count - 2)]) // 残りの要素をmenuに設定
            
            // ColumnDataを作成
            let columnData = ColumnData(columnDay: columnDay, title: title, caption: caption)
            // MenuDataを作成
            let menuData = MenuData(day: columnDay, menu: menuItems)
            
            // データベースに保存
            context.insert(columnData)
            context.insert(menuData)
        }

        // データベース保存処理
        do {
            try context.save()
            print("データベースに保存されました")
        } catch {
            print("データ保存エラー: \(error)")
        }
    }

    func fetchData() {
        sheetID = extractSheetID(from: sheetURL)
        Task {
            do{
                let sheetName = "\(selectedYear)\(selectedMonth)"
                try await spreadSheetManager.fetchGoogleSheetData(spreadsheetId: sheetID, sheetName: sheetName, cellRange: "A2:I32")
                escapeData = spreadSheetManager.spreadSheetResponse.values
                escapeData.removeAll{ $0.count == 1 } // 空のセルを削除
                print(escapeData)
                print("Success")
                QRscanResults = true
                showQRscanResults = true
                
                // データ保存を呼び出す
                saveToDatabase(dataArray: escapeData)
                
            }catch{
                QRscanResults = false
                showQRscanResults = true
                print("Error: \(error)")
            }
        }
    }
    
    func extractSheetID(from url: String) -> String {
        // URLからシートIDを抽出する正規表現
        let pattern = "spreadsheets/d/([a-zA-Z0-9-_]+)"
        if let range = url.range(of: pattern, options: .regularExpression) {
            let sheetID = url[range]
            let components = sheetID.split(separator: "/")
            if components.count > 2 {
                return String(components[2])
            }
        }
        return "Invalid URL"
    }

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            ZStack{
                VStack {
                    HStack {
                        Picker("", selection: $selectedYear) {
                            ForEach(-1...1, id: \.self) { offset in
                                let year = Calendar.current.component(.year, from: Date()) + offset
                                let yearString = "\(year)年".replacingOccurrences(of: ",", with: "")
                                Text(yearString).tag(yearString)
                            }
                        }
                        .pickerStyle(.menu)
                        .font(.title)
                        .tint(Color.black)

                        Picker("", selection: $selectedMonth) {
                            ForEach(1...12, id: \.self) { month in
                                Text("\(month)月").tag("\(month)月")
                            }
                        }
                        .pickerStyle(.menu)
                        .font(.title)
                        .tint(Color.black)

                        Text("のメニューとコラムを取得します")
                            .font(.custom("GenJyuuGothicX-Bold", size: 17))
                            .foregroundStyle(Color.black)
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(style: StrokeStyle())
                    }
                    ZStack {
                        CodeScannerView(codeTypes: [.qr], showViewfinder: true) { result in
                            if case let .success(scannedResult) = result {
                                isScanning = false
                                scannedCode = scannedResult.string
                            }
                        }
                        .frame(width: size.width * 0.5, height: size.height * 0.5)
                        .overlay {
                            if isReady{
                                Color.black
                                    .ignoresSafeArea()
                            }else{
                                if isScanning {
                                    Text("スキャン中...")
                                        .font(.custom("GenJyuuGothicX-Bold", size: 17))
                                        .padding()
                                        .background(Color.black.opacity(0.7))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                }
                .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
                .alert(QRscanResults ? "読み取りに成功しました" : "読み取りに失敗しました", isPresented: $showQRscanResults) {
                    Button {
                        showQRscanResults = false
                        isPresentingScanner = false
                        soundManager.playSound(named: "se_negative")
                    } label: {
                        Text("閉じる")
                    }
                } message: {
                    if QRscanResults {
                        Text("\(selectedYear)\(selectedMonth)のメニューとコラムが入力されました。")
                    } else {
                        Text("入力したい年と月が正しく選択されているか確認してください\nもしくはQRコードが正しいか確認してください")
                    }
                }
            }
        }
        .onChange(of: scannedCode) { oldValue, newValue in
            sheetURL = scannedCode
            fetchData()
        }
        .onAppear {
            isScanning = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isReady = false
            }
        }
        .onDisappear {
            isScanning = false
        }
    }
}

#Preview {
    ScannerView(isPresentingScanner: .constant(true))
        .modelContainer(for: [ColumnData.self, MenuData.self], inMemory: true)
}
