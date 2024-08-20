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
    @State private var selection: String = {
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
    func fetchData() {
        sheetID = extractSheetID(from: sheetURL)
        Task {
            do {
                // Fetch keyOfDate
                try await spreadSheetManager.fetchGoogleSheetData(spreadsheetId: sheetID, sheetName: selection, cellRange: "A2:A32")
                keyOfDate = spreadSheetManager.spreadSheetResponse.values.flatMap { $0 }
                
                // Fetch valueOfDate
                try await spreadSheetManager.fetchGoogleSheetData(spreadsheetId: sheetID, sheetName: selection, cellRange: "B2:G32")
                valueOfDate = spreadSheetManager.spreadSheetResponse.values
                
                // Fetch titleOfColumn
                try await spreadSheetManager.fetchGoogleSheetData(spreadsheetId: sheetID, sheetName: selection, cellRange: "H2:H32")
                titleOfColumn = spreadSheetManager.spreadSheetResponse.values.flatMap { $0 }
                
                // Fetch captionOfColumn
                try await spreadSheetManager.fetchGoogleSheetData(spreadsheetId: sheetID, sheetName: selection, cellRange: "I2:I32")
                captionOfColumn = spreadSheetManager.spreadSheetResponse.values.flatMap { $0 }
                
                // Save MenuData
                for (index, key) in keyOfDate.enumerated() {
                    if index < valueOfDate.count {
                        let menuData = MenuData(day: key, menu: valueOfDate[index])
                        context.insert(menuData)
                    }
                }
                
                // Save ColumnData
                for index in 0..<min(keyOfDate.count, titleOfColumn.count, captionOfColumn.count) {
                    let columnData = ColumnData(columnDay: keyOfDate[index], title: titleOfColumn[index], caption: captionOfColumn[index])
                    context.insert(columnData)
                }
                
                try context.save()
                
                print("Success")
                QRscanResults = true
                showQRscanResults = true
            } catch {
                QRscanResults = false
                showQRscanResults = true
                print("Error: \(error)")
            }
        }
    }
    
    func extractSheetID(from url: String) -> String {
        // Regex to extract sheet ID from URL
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
                        Picker("", selection: $selection) {
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
                        CodeScannerView(codeTypes: [.qr],showViewfinder:true) { result in
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
                    } label: {
                        Text("閉じる")
                    }
                } message: {
                    if QRscanResults {
                        Text("\(selection)のメニューとコラムが入力されました。")
                    } else {
                        Text("入力したい月が正しく選択されているか確認してください\nもしくはQRコードが正しいか確認してください")
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
