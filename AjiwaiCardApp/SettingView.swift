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
    
    var body: some View {
        NavigationStack{
            ZStack {
                if isGenerating {
                    ProgressView("共有の準備中...")
                        .font(.custom("GenJyuuGothicX-Bold", size: 17))
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .tint(.white)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .zIndex(10.0)
                    Color.gray.opacity(0.5)
                        .ignoresSafeArea()
                        .zIndex(9.0)
                }
                VStack(spacing: 20) {
                    Text("設定画面")
                        .font(.custom("GenJyuuGothicX-Bold", size: 25))
                        .padding(.top, 20)
                    Picker("キャラクターを選択", selection: $user.selectedCharactar) {
                                       Text("いぬ").tag("Dog")
                                       Text("ねこ").tag("Cat")
                                       Text("うさぎ").tag("Rabbit")
                                   }
                                   .frame(width: 300, height: 50)
                    NavigationLink{
                        ProfileEditView()
                    } label: {
                        Text("プロフィールを編集する")
                            .font(.custom("GenJyuuGothicX-Bold", size: 15))
                            .frame(width: 300, height: 50)
                            .background(Color.cyan)
                            .foregroundStyle(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    Button {
                        showQRscaner = true
                    } label: {
                        Text("1ヶ月分のメニューを入力する")
                            .font(.custom("GenJyuuGothicX-Bold", size: 15))
                            .frame(width: 300, height: 50)
                            .background(Color.cyan)
                            .foregroundStyle(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    Button {
                        showActionSheet = true
                    } label: {
                        Text("共有する")
                            .font(.custom("GenJyuuGothicX-Bold", size: 15))
                            .frame(width: 300, height: 50)
                            .background(Color.cyan)
                            .foregroundStyle(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .disabled(allData.isEmpty)
                    .actionSheet(isPresented: $showActionSheet) {
                        ActionSheet(title: Text("共有方法を選択してください"), buttons: [
                            .default(Text("PDFで共有")) {
                                isGenerating = true
                                Task {
                                    await generateAndSharePDF()
                                }
                            },
                            .default(Text("CSVで共有")) {
                                isGenerating = true
                                Task {
                                    await generateAndShareCSV()
                                }
                            },
                            .cancel()
                        ])
                    }
                    Button {
                        print(user.path)
                        user.path.removeLast()
                    } label: {
                        Text("タイトルに戻る")
                            .font(.custom("GenJyuuGothicX-Bold", size: 15))
                            .frame(width: 220, height: 50)
                            .background(Color.white)
                            .foregroundStyle(Color.cyan)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
            }
            .sheet(isPresented: $showQRscaner) {
                ScannerView(isPresentingScanner: $showQRscaner)
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = pdfURL {
                    ShareSheet(activityItems: [url])
                }
            }
        }
    }
    
    @MainActor
    func generateAndSharePDF() async {
        let pdfGenerator = MultiPagePDFGenerator(allData: allData, userName: user.name,userGrade: user.grade,userClass: user.yourClass)
        let pdfPath = await pdfGenerator.generatePDF()
        
        await MainActor.run {
            self.pdfURL = pdfPath
            self.isGenerating = false
            self.showShareSheet = true
        }
    }
    
    @MainActor
    func generateAndShareCSV() async {
        defer { isGenerating = false }
        
        let exportData = ExportData()
        let filename = "\(user.name)の味わいカード"
        let datas: [AjiwaiCardData] = allData
        
        exportData.createCSV(filename: filename, datas: datas)
        
        let documentsPath = exportData.getDocumentsDirectory()
        let csvPath = documentsPath.appendingPathComponent("\(filename).csv")
        
        self.pdfURL = csvPath
        self.showShareSheet = true
    }
}



#Preview {
    SettingView()
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
    
    private var profileInfoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("プロフィール情報")
                .font(.custom("GenJyuuGothicX-Bold", size: 15))
            
            infoRow(icon: "person.fill", title: "名前") {
                TextField("名前", text: $editedName)
                    .font(.custom("GenJyuuGothicX-Bold", size: 17))
            }
            
            infoRow(icon: "graduationcap.fill", title: "学年") {
                Picker("学年", selection: $editedGrade) {
                    ForEach(1..<7) { grade in
                        Text("\(grade)年生").tag(grade)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            infoRow(icon: "book.fill", title: "クラス") {
                Picker("クラス", selection: $editedClass) {
                    ForEach(1..<25) { Class in
                        Text("\(Class)年生").tag(Class)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            infoRow(icon: "birthday.cake.fill", title: "年齢") {
                Picker("年齢", selection: $editedAge) {
                    ForEach(6..<13) { age in
                        Text("\(age)歳").tag(age)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
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
        user.name = editedName
        user.grade = editedGrade
        user.age = editedAge
    }
}
