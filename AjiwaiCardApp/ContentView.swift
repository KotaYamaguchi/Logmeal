import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var user: UserData
    @Environment(\.modelContext) private var context
    @Query private var allData: [AjiwaiCardData]
    private let soundManager: SoundManager = SoundManager()
    
    @State var itemName = ""
    @State var showMenu = false
    @State private var showResetAlert: Bool = false
    
    @State private var showDeletionResultAlert: Bool = false
    @State private var deletionResultMessage: String = ""
    
    private var gridItem = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack(path: $user.path) {
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                ZStack(alignment: .topTrailing) {
                    Image("bg_TitleView")
                        .resizable()
                        .ignoresSafeArea()
                        .scaledToFill()
                        .frame(width: geometry.size.width * 1.05, height: geometry.size.height)
                        .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
                        .onTapGesture {
                            user.path.append(.home)
                            soundManager.playSound(named: "se_positive")
                        }
                    Button {
                        showMenu = true
                    } label: {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.cyan)
                    }
                    .padding(.all)
                    .buttonStyle(PlainButtonStyle())
                    Text("画面をタップしてゲームを始めよう")
                        .font(.custom("GenJyuuGothicX-Bold", size: 20))
                        .foregroundStyle(.gray)
                        .padding(.top, 30)
                        .position(x: width * 0.5, y: height * 0.8)
                }
                .sheet(isPresented: $showMenu) {
                    appSettingView(geometry: geometry)
                }
            }
            .navigationDestination(for: Homepath.self) { value in
                switch value {
                case .home:
                    ChildHomeView()
                        .navigationBarBackButtonHidden(true)
                case .ajiwaiCard:
                    WritingAjiwaiCardView(saveDay: Date.now)
                        .navigationBarBackButtonHidden(true)
                case .reward:
                    RewardView()
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
    
    @ViewBuilder private func appSettingView(geometry:GeometryProxy) -> some View {
        NavigationStack {
            
            Form{
                Section("情報") {
                    NavigationLink {
                        termsOfUse(geometry: geometry)
                    } label: {
                        Text("利用規約")
                    }
                    
                    NavigationLink {
                        creditView(geometry:geometry)
                    } label: {
                        Text("クレジット")
                    }
                }
                Section {
                    Button {
                        showResetAlert = true
                    } label: {
                        Text("データを全て消す")
                            .foregroundStyle(Color.blue)
                    }
                } header: {
                    Text("ゲームの初期化")
                        .font(.custom("GenJyuuGothicX-Bold", size: 10))
                } footer: {
                    Text("アプリ内のすべてのデータを初期化して初めからプレイします.この操作は取り消すことができません")
                        .font(.custom("GenJyuuGothicX-Bold", size: 10))
                }
            }
            .foregroundStyle(Color.textColor)
            .navigationTitle("情報")
            .alert("本当にデータを消しますか？", isPresented: $showResetAlert) {
                Button("キャンセル", role: .cancel) {}
                Button("消す", role: .destructive) {
                    deleteAllAppData()
                }
            } message: {
                Text("データはもとに戻すことができません")
            }
            .alert(isPresented: $showDeletionResultAlert) {
                Alert(title: Text("削除結果"),
                      message: Text(deletionResultMessage),
                      dismissButton: .default(Text("OK")))
            }
        }
    }
    @ViewBuilder private func termsOfUse(geometry:GeometryProxy) -> some View{
        VStack{
            Text("利用規約")
                .font(.custom("GenJyuuGothicX-Bold", size: 28))
            Divider()
                .frame(width:geometry.size.width*0.5)
                .padding(.vertical)
            ScrollView{
                VStack(alignment:.leading){
                    Text("""
        【利用規約】
        本規約は、熊本県立大学総合管理学部飯村研究室（以下「本研究室」という。）が提供するiPad専用アプリケーション「ろぐみいる」（以下「本アプリ」という。）の利用に関する諸規定を定めるものです。本アプリをインストールする前に本規約をご確認いただき、内容をご確認の上本アプリをご利用ください。
        
        第1条 ご利用にあたって
        利用者は、本規約の定めに従って、本アプリを利用しなければなりません。同意した方に限り、本アプリを利用できるものとします。
        本アプリを利用された場合には、本規約の内容全てに同意したものとみなされます。
        
        第2条 登録について
        利用者は、本アプリ所定の手続きに従い利用手続きを行うことで、本アプリの利用が可能になります。
        
        第3条 著作権について
        本アプリに係る著作権その他一切の権利は、本研究室に帰属します。
        本利用規約に基づく本アプリの提供は、利用者に対する本アプリの著作権その他いかなる権利の移転または実施権の許諾を伴うものではありません。
        
        第4条 免責事項について
        本アプリを利用するにあたり、以下の項目について承諾のうえご利用ください。
        
        （1）本研究室は、利用者に対し、本アプリの一切の動作保証を行わず、いかなる瑕疵担保責任も負いません。
        
        （2）通信環境の状況、システムの障害、メンテナンス、その他やむを得ない事由により、情報の不達、遅延が発生する場合があります。また、ご利用の端未機種等の設定等により、本アプリ内の情報が正しく表示されない場合があります。それらにより利用者が何らかの損害を被ったとしても、本研究室は利用の如何を問わず一切の責任を負いません。
        
        （3）利用者に事前に通知することなく、本アプリを変更、中断、終了することがあります。これによって利用者が何らかの損害を彼ったとしても、本研究室は理由の如何を問わず一切の責任を負いません。
        
        （4）本アプリの利用により、利用者が事故に遭う等、何らかの損害を彼ったとしても、本研究室は理由の如何を問わず一切の責任を負いません。
        
        （5）本アプリの利用料金は無料とします。ただし、本アプリの利用及び更新に要する通信費用は、利用者の負担となります。
        
        第5条 禁止事項について
        
        利用者は、本アプリの利用に際して、以下の行為を行ってはならないものとします。行った場合は事前の通知なく、当該利用者の本アプリの利用を停止される場合があることを予め承諾するものとします。
        （1）本アプリの複製、改変、転用、頒布、又は本アプリの全部又は一部のリバースエンジニアリング、逆コンパイル、逆アセンブル等の行為
        
        （2）本アプリの運営、維持を妨げる行為
        
        （3）その他、本研究室が不適切であると判断した行為
        
        第6条本規約の変更について
        
        本規約は、必要に応じて改定する場合があり、利用者はこれを承諾するものとします。本アプリをご利用の際は、アプリ内に掲載されている最新の利用規約をご確認下さい。
        
        【附則】
        2024年8月31日 施行
        
        """)
                    .padding()
                }
            }
        }
        .ignoresSafeArea()
        .font(.custom("GenJyuuGothicX-Bold", size: 15))
        .foregroundStyle(Color.textColor)
        .padding()
    }
    @ViewBuilder private func creditView(geometry:GeometryProxy) -> some View{
        VStack{
            Text("クレジット")
                .font(.custom("GenJyuuGothicX-Bold", size: 28))
            Divider()
                .frame(width:geometry.size.width*0.5)
                .padding(.vertical)
            ScrollView{
                VStack{
                    Text("アプリケーションデベロッパー")
                        .padding()
                        .font(.custom("GenJyuuGothicX-Bold", size: 27))
                    Text("山口 昂大")
                    
                    Text("クリエイティブプランナー")
                        .padding()
                        .font(.custom("GenJyuuGothicX-Bold", size: 27))
                    HStack(spacing:20){
                        Text("丸田 妃菜美")
                        Text("山下 緩菜")
                    }
                    HStack(spacing:20){
                        Text("山下 徳真")
                        Text("山田 鈴音")
                    }
                    HStack(spacing:20){
                        Text("吉山 千愛")
                        Text("米山 詩歩")
                    }
                    
                    
                    Text("スーパーバイザー")
                        .padding()
                        .font(.custom("GenJyuuGothicX-Bold", size: 27))
                    Text("飯村 伊智郎")
                    
                    Text("SpecialThanks")
                        .padding()
                        .font(.custom("GenJyuuGothicX-Bold", size: 27))
                    Text("----")
                    Text("参考文献")
                        .padding()
                        .font(.custom("GenJyuuGothicX-Bold", size: 27))
                    Text("----")
                    Text("音源提供")
                        .padding()
                        .font(.custom("GenJyuuGothicX-Bold", size: 27))
                    Text("----")
                    Text("フォント提供")
                        .padding()
                        .font(.custom("GenJyuuGothicX-Bold", size: 27))
                    Text("""
    本ソフトでは表示フォントに「源柔ゴシックX」(http://jikasei.me/font/genshin/) を使用しています。
    Licensed under SIL Open Font License 1.1 (http://scripts.sil.org/OFL)
    © 2014-2022 自家製フォント工房,
    © 2014, 2015 Adobe Systems Incorporated,
    © 2015 M+FONTS PROJECT
    """)
                    
                    Image("Iimulab_logo")
                        .resizable()
                        .frame(width:100,height: 100)
                        .padding(.top,50)
                    Text("© 2024 Iimura Laboratory , Prefectural University of Kumamoto")
                    
                }
            }
        }
        .font(.custom("GenJyuuGothicX-Bold", size: 18))
        .foregroundStyle(Color.textColor)
        .padding()
    }
    
    private func deleteAllAppData() {
        var deletionMessages: [String] = []
        
        deleteAllStatus()
        deleteAllImage(deletionMessages: &deletionMessages)
        
        do {
            try deleteAllSwiftData(modelContext: context)
        } catch {
            deletionMessages.append("SwiftDataの削除に失敗しました: \(error.localizedDescription)")
        }
        
        if deletionMessages.isEmpty {
            deletionResultMessage = "すべてのデータが正常に削除されました。"
        } else {
            deletionResultMessage = deletionMessages.joined(separator: "\n")
        }
        
        // Show the deletion result alert
        showDeletionResultAlert = true
    }

    
    private func deleteAllImage(deletionMessages: inout [String]) {
        for content in allData {
            if !removeDocumentFile(itemName: user.dateFormatter(date: content.saveDay)) {
                deletionMessages.append("画像データ: \(user.dateFormatter(date: content.saveDay)) の削除に失敗しました。")
            }
        }
    }
    
    private func deleteAllStatus() {
        let appDomain = Bundle.main.bundleIdentifier
        UserDefaults.standard.removePersistentDomain(forName: appDomain!)
    }
    
    private func deleteAllSwiftData(modelContext: ModelContext) throws {
        do {
            try modelContext.delete(model: AjiwaiCardData.self)
            try modelContext.delete(model: MenuData.self)
            try modelContext.delete(model: ColumnData.self)
        } catch {
            throw error
        }
    }
    
    private func removeDocumentFile(itemName: String) -> Bool {
        let fileManager = FileManager.default
        var pathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        if !fileManager.fileExists(atPath: pathString + "/" + itemName) {
            print("そのファイルは存在しません")
            return false
        }
        pathString = "file://" + pathString + "/" + itemName + ".jpeg"
        guard let path = URL(string: pathString) else { return false }
        do {
            try fileManager.removeItem(at: path)
            print("ファイルの削除に成功しました")
            return true
        } catch {
            print("ファイルの削除に失敗しました")
            return false
        }
    }
}



#Preview{
    ContentView()
        .environmentObject(UserData())
}
