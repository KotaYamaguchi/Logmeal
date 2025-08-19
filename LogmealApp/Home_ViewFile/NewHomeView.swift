import SwiftUI
import PhotosUI
import SwiftData

struct NewHomeView: View {
    @State private var showWritingView = false
    @EnvironmentObject var user: UserData
    @Environment(\.modelContext) private var context
    @Query private var allData: [AjiwaiCardData]
    @Query private var characters: [Character]
    @State var selectedIndex: Int? = nil
    @State var showDetailView:Bool = false
    private var displayContentColor:Color{
        switch characters.first(where: {$0.isSelected})!.name {
        case "Dog": Color(red: 248/255, green: 201/255, blue: 201/255)
        case "Cat": Color(red: 198/255, green: 166/255, blue: 208/255)
        case "Rabbit": Color(red: 251/255, green: 233/255, blue: 184/255)
        default:
            Color.white
        }
    }
    private var backgoundImage:String{
        switch characters.first(where: {$0.isSelected})!.name{
        case "Dog":"bg_home_Dog"
        case "Cat":"bg_home_Cat"
        case "Rabbit":"bg_home_Rabbit"
        default:
            "bg_home_Dog"
        }
    }
    private var addButtonImage:String{
        switch characters.first(where: {$0.isSelected})!.name{
        case "Dog":"bt_add_Dog"
        case "Cat":"bt_add_Cat"
        case "Rabbit":"bt_add_Rabbit"
        default:
            "bt_add_Dog"
        }
    }
    @State private var showDebugPanel = false
    // 削除処理
    private func resetAllAjiwaiCardDataAndImages() {
        // 1. SwiftDataのAjiwaiCardDataを全削除
        for item in allData {
            context.delete(item)
        }
        try? context.save()
        // 2. Documentディレクトリの画像ファイルを全削除
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        if let fileURLs = try? fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil) {
            for url in fileURLs where url.pathExtension.lowercased() == "jpeg" {
                try? fileManager.removeItem(at: url)
            }
        }
    }
    private func loadImageSafely(from ajiwaiCardData: AjiwaiCardData) -> UIImage? {
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var fileName: String? = nil

        // 新しいimageFileNameプロパティを優先して使用
        if let newFileName = ajiwaiCardData.imageFileName {
            fileName = newFileName
        }
        // imageFileNameがnilの場合、旧imagePathからファイル名を抽出
        else if let oldImagePathURL = URL(string: ajiwaiCardData.imagePath.absoluteString) {
            fileName = oldImagePathURL.lastPathComponent
        }

        // ファイル名が取得できなければ、nilを返す
        guard let finalFileName = fileName else {
            print("ファイル名が取得できませんでした。")
            return nil
        }

        // ドキュメントディレクトリとファイル名を組み合わせて画像のURLを生成
        let fileURL: URL
        // ここで拡張子を付与する
        if finalFileName.hasSuffix(".jpeg") {
            fileURL = documentURL.appendingPathComponent(finalFileName)
        } else {
            fileURL = documentURL.appendingPathComponent(finalFileName + ".jpeg")
        }

        do {
            let data = try Data(contentsOf: fileURL)
            return UIImage(data: data)
        } catch {
            print("画像の読み込みに失敗しました: \(error)")
            return nil
        }
    }
    private func loadUserImage(from inputFileName: String?) -> UIImage? { // パラメータ名を変更
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // 引数の inputFileName を直接使う
        guard let finalFileName = inputFileName else {
            print("ファイル名が取得できませんでした。")
            return nil
        }

        // ファイル名に.jpeg拡張子が含まれていない場合、追加する
        let fileNameWithExtension: String
        if !finalFileName.hasSuffix(".jpeg") {
            fileNameWithExtension = finalFileName + ".jpeg"
        } else {
            fileNameWithExtension = finalFileName
        }
        
        let fileURL = documentURL.appendingPathComponent(fileNameWithExtension)
        
        do {
            let data = try Data(contentsOf: fileURL)
            return UIImage(data: data)
        } catch {
            print("画像の読み込みに失敗しました: \(error)")
            return nil
        }
    }
    private func debugPanel() -> some View {
        // デバッグ用オーバーレイパネル
        ZStack{
            VStack{
                HStack{
                    VStack(spacing: 20) {
                        Text("デバッグパネル")
                            .font(.title)
                            .foregroundColor(.black)
                        Button(role: .destructive) {
                            resetAllAjiwaiCardDataAndImages()
                        } label: {
                            Text("AjiwaiCardDataと画像を全て削除")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)).opacity(0.95))
                    .frame(maxWidth: 350)
                    Spacer()
                }
                Spacer()
            }
            .padding()
        }
    }
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundImage(geometry: geometry)
                ScrollView {
                    userInfoPanel(geometry: geometry)
                    logGrid(geometry: geometry)
                }
                addLogButton(geometry: geometry)
//                debugPanel()
            }
            .onAppear(){
                print("ーーーーーーーーーーーーアプリを起動しました！ーーーーーーーーーーーー")
            }
            .onChange(of: selectedIndex) { _, newValue in
                showDetailView = (newValue != nil)
            }
            .fullScreenCover(isPresented: $showWritingView) {
                NewWritingView(showWritingView: $showWritingView)
            }
            .fullScreenCover(isPresented: $showDetailView) {
                if let index = selectedIndex {
                    LogCardlView(dataIndex: index)
                        .onDisappear(){
                            selectedIndex = nil
                        }
                }
            }
        }
    }
    
    private func backgroundImage(geometry: GeometryProxy) -> some View {
        Image("bg_home_\(characters.first(where: {$0.isSelected})!.name)")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
            .scaleEffect(1.1)
            .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
    }
    
    private func userInfoPanel(geometry: GeometryProxy) -> some View {
        HStack{
            Spacer()
            VStack(spacing: 0){
                if let image = loadUserImage(from: user.userImage) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width * 0.2)
                        .clipShape(Circle())
                }else{
                    Image("no_user_image")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.2)
                        .overlay {
                            Circle()
                                .stroke(displayContentColor, lineWidth: 5)
                        }
                }
            
                Text("\(user.name)")
                    .font(.custom("GenJyuuGothicX-Bold", size: geometry.size.width * 0.03))
                    
            }
            VStack {
                HStack {
                    ForEach([
                        ("\(allData.count)", "ろぐ"),
                        ("\(user.point)", "ポイント"),
                        ("\(characters.first(where: {$0.isSelected})!.level)", "レベル")
                    ], id: \.1) { value, label in
                        VStack {
                            Text(value)
                                .font(.custom("GenJyuuGothicX-Bold", size: geometry.size.width * 0.06))
                            Text(label)
                                .font(.custom("GenJyuuGothicX-Bold", size: geometry.size.width * 0.04))
                        }
                        .padding(.horizontal, geometry.size.width * 0.05)
                    }
                }
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: geometry.size.width * 0.8, height: 3)
                    .foregroundStyle(displayContentColor)
                    .padding()
            }
            Spacer()
        }
        .padding(.top, geometry.size.height * 0.05)
    }
    
    private func logGrid(geometry: GeometryProxy) -> some View {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: geometry.size.width * 0.005) {
                ForEach(0..<allData.count, id: \.self) { index in
                    Button {
                        selectedIndex = nil
                        DispatchQueue.main.async {
                            selectedIndex = index
                        }
                    } label: {
//                        AsyncImage(url: allData[index].imagePath) { phase in
//                            switch phase {
//                            case .empty:
//                                ProgressView()
//                            case .success(let image):
//                                image
//                                    .resizable()
//                                    .scaledToFill()
//                                    .frame(width: (geometry.size.width * 0.8) / 3,height:(geometry.size.width * 0.8) / 3)
//                                    .clipped()
//                            case .failure(_):
//                                Rectangle()
//                                    .frame(width: (geometry.size.width * 0.8) / 3, height: (geometry.size.width * 0.8) / 3)
//                                    .foregroundStyle(Color(red: 206/255, green: 206/255, blue: 206/255))
//                            @unknown default:
//                                Rectangle()
//                                    .frame(width: (geometry.size.width * 0.8) / 3, height:(geometry.size.width * 0.8) / 3)
//                                    .foregroundStyle(Color(red: 206/255, green: 206/255, blue: 206/255))
//                            }
//                        }
                        if let image = loadImageSafely(from: allData[index]) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: (geometry.size.width * 0.8) / 3, height: (geometry.size.width * 0.8) / 3)
                                .clipped()
                        } else {
                            Rectangle()
                                .frame(width: (geometry.size.width * 0.8) / 3, height: (geometry.size.width * 0.8) / 3)
                                .foregroundStyle(Color(red: 206/255, green: 206/255, blue: 206/255))
                        }
                    }
                    .onAppear(){
                        print(allData[index].imagePath)
                    }
                }
            }
            .frame(width: geometry.size.width * 0.8)
            .padding(.horizontal)
    }
    
    private func addLogButton(geometry: GeometryProxy) -> some View {
        Button {
            showWritingView = true
        } label: {
            Image(addButtonImage)
                .resizable()
                .scaledToFit()
                .frame(width: geometry.size.width * 0.15)
        }
        .position(x: geometry.size.width * 0.85, y: geometry.size.height * 0.9)
    }
}

#Preview {
    NewContentView()
        .environmentObject(UserData())
        .modelContainer(for: AjiwaiCardData.self)
}
