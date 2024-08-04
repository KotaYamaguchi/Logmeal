import SwiftUI
import UIKit
import SwiftData

struct SettingView: View {
    @Environment(\.modelContext) private var context
    @Query private var allData: [AjiwaiCardData]
    @EnvironmentObject var user: UserData
    @State var showQRscaner = false
    @State var savedDataArray: [String: SavedData] = [:]
    @State private var pdfURL: URL?
    @State private var showShareSheet = false
    @State private var isGenerating = false
    @State var monthlyMenu: [String: [String]] = [:]
    @State var monthlyColumnTitle: [String: String] = [:]
    @State var monthlyColumnCaption: [String: String] = [:]
    @State var saveForNow: [String: String] = [:]
    @State var saveForNowMenu: [String: [String]] = [:]
    @State private var previewPDF = false
    @State private var showingShareSheet = false
    @State private var csvURL: URL?
    
    var body: some View {
        ZStack {
            if isGenerating {
                ProgressView("共有の準備中...")
                    .font(.headline)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .tint(.white)
                    .cornerRadius(10)
                    .zIndex(10.0)
                Color.gray.opacity(0.5)
                    .ignoresSafeArea()
                    .zIndex(9.0)
            }
            VStack {
                Text("設定画面")
                Picker("キャラクターを選択", selection: $user.selectedCharactar) {
                    Text("いぬ").tag("Dog")
                    Text("ねこ").tag("Cat")
                    Text("うさぎ").tag("Rabbit")
                }
                .frame(width: 300, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                Button {
                    showQRscaner = true
                } label: {
                    Text("1ヶ月分のメニューを入力する")
                        .frame(width: 300, height: 50)
                        .background(Color.cyan)
                        .foregroundStyle(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(PlainButtonStyle())
                Button {
                    previewPDF = true
                    user.savedDatas = user.readSavedDatas() ?? [:]
                } label: {
                    Text("味わいカードを先生に提出する")
                        .frame(width: 300, height: 50)
                        .background(Color.cyan)
                        .foregroundStyle(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(allData.isEmpty)
                Button {
                    isGenerating = true
                   Task {
                       await generateAndShareCSV()
                   }
                } label: {
                    Text("CSVファイルで提出する")
                        .frame(width: 300, height: 50)
                        .background(Color.cyan)
                        .foregroundStyle(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(allData.isEmpty)
                Button {
                    print(user.path)
                    user.path.removeLast()
                } label: {
                    Text("タイトルに戻る")
                        .frame(width: 300, height: 50)
                        .background(Color.cyan)
                        .foregroundStyle(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .sheet(isPresented: $showQRscaner) {
            ScannerView(isPresentingScanner: $showQRscaner, monthlyMenu: $monthlyMenu, monthlyColumnTitle: $monthlyColumnTitle, monthlyColumnCaption: $monthlyColumnCaption)
        }
        .fullScreenCover(isPresented: $previewPDF) {
            MultiPageAchievementView(previewPDF: $previewPDF)
        }
        .sheet(isPresented: $showingShareSheet, content: {
            if let csvURL = csvURL {
                ActivityViewController(activityItems: [csvURL])
            }
        })
        
        .onChange(of: [monthlyColumnTitle, monthlyColumnCaption]) { oldValue, newValue in
            // QRからのデータを追加、同じ日付のものを追加したときは新しい方が優先される
            saveForNow = user.loadStringDictionary(forKey: "monthlyColumnTitle")
            saveForNow.merge(monthlyColumnTitle) { (current, new) in current }
            user.monthlyColumnTitle = saveForNow
            user.writeStringDictionary(user.monthlyColumnTitle, forKey: "monthlyColumnTitle")

            saveForNow = user.loadStringDictionary(forKey: "monthlyColumnCaption")
            saveForNow.merge(monthlyColumnCaption) { (current, new) in current }
            user.monthlyColumnCaption = saveForNow
            user.writeStringDictionary(user.monthlyColumnCaption, forKey: "monthlyColumnCaption")
        }
        .onChange(of: monthlyMenu) { oldValue, newValue in
            saveForNowMenu = user.loadMonthlyMenu()
            saveForNowMenu.merge(monthlyMenu) { (current, new) in current }
            user.monthlyMenu = saveForNowMenu
            user.saveMonthlyMenu()
        }
        .onAppear {
            print(user.savedDatas)
        }
    }
    
    @MainActor
    func generateAndShareCSV() async {
        
        defer { isGenerating = false }
        
        let exportData = ExportData()
        let filename = "export_\(Date().timeIntervalSince1970)"
        let datas: [AjiwaiCardData] = allData // ここにデータを追加
        
        exportData.createCSV(filename: filename, datas: datas)
        
        let documentsPath = exportData.getDocumentsDirectory()
        let csvPath = documentsPath.appendingPathComponent("\(filename).csv")
        
        self.csvURL = csvPath
        self.showingShareSheet = true
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingView()
        .environmentObject(UserData())
        .modelContainer(for: AjiwaiCardData.self)
}

#Preview {
    ContentView()
        .environmentObject(UserData())
}
