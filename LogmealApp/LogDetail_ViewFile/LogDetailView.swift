import SwiftUI
import SwiftData
import PhotosUI



struct LogDetailView:View {
    @Binding var isEditing:Bool
    @EnvironmentObject var user: UserData
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var allData: [AjiwaiCardData]
    private let senseIcons = ["mt_Eye_icon", "mt_Ear_icon", "mt_Nose_icon", "mt_Tongue_icon", "mt_Hand_Icon"]
    private let senseTitles = ["みため", "おと", "におい", "あじ", "さわりごこち"]
    private let senseColors: [Color] = [
        Color(red: 240 / 255, green: 145 / 255, blue: 144 / 255),
        Color(red: 243 / 255, green: 179 / 255, blue: 67 / 255),
        Color(red: 105 / 255, green: 192 / 255, blue: 160 / 255),
        Color(red: 139 / 255, green: 194 / 255, blue: 222 / 255),
        Color(red: 196 / 255, green: 160 / 255, blue: 193 / 255)
    ]
    private func dateFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    var selectedData:AjiwaiCardData
    @State private var detailUIImage: UIImage? = nil   // ←追加
    
    // ① UIImage の URL から読み込むユーティリティ
    private func getImageByUrl(url: URL) -> UIImage? {
        guard let data = try? Data(contentsOf: url),
              let uiImage = UIImage(data: data) else {
            return nil
        }
        return uiImage
    }
    
    // ② アスペクト比に応じたサイズを返す関数（NewWritingView と同じ）
    private func frameSize(for image: UIImage) -> CGSize {
        let aspectRatio = image.size.width / image.size.height
        let tolerance: CGFloat = 0.01
        // 3:4 に「ほぼ一致」→幅300、その他→幅400
        let width: CGFloat = abs(aspectRatio - (3.0/4.0)) < tolerance
        ? 300.0
        : 400.0
        let height = width / aspectRatio
        return CGSize(width: width, height: height)
    }
    // ドキュメントディレクトリから画像ファイルを読み込む関数
    private func loadImageFromDocumentDirectory(fileName: String) -> UIImage? {
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // ファイル名に.jpeg拡張子が含まれていない場合、追加する
        let fileNameWithExtension: String
        if !fileName.hasSuffix(".jpeg") {
            fileNameWithExtension = fileName + ".jpeg"
        } else {
            fileNameWithExtension = fileName
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
    
    // AjiwaiCardDataから画像を安全に読み込む関数
    private func loadImageSafely(from ajiwaiCardData: AjiwaiCardData) -> UIImage? {
        var fileName: String? = nil
        
        // 1. 新しい imageFileName プロパティを優先して使用
        if let newFileName = ajiwaiCardData.imageFileName {
            fileName = newFileName
        }
        // 2. imageFileName が nil の場合、旧 imagePath からファイル名を抽出
        else if let oldImagePathURL = URL(string: ajiwaiCardData.imagePath.absoluteString) {
            fileName = oldImagePathURL.lastPathComponent
        }
        
        // ファイル名が取得できなければ、nilを返す
        guard let finalFileName = fileName else {
            print("ファイル名が取得できませんでした。")
            return nil
        }
        
        // loadImageFromDocumentDirectory を使って画像を読み込む
        return loadImageFromDocumentDirectory(fileName: finalFileName)
    }
    
    @State private var showDeleteAlert = false   // 削除確認アラート表示用
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                Image("bg_AjiwaiCardView")
                    .resizable()
                    .scaledToFill()
                    .blur(radius: 3)
                    .position(x:geometry.size.width*0.5,y:geometry.size.height*0.5)
                
                VStack{
                    HStack{
                        Button{
                            dismiss()
                        }label:{
                            Image("bt_close")
                                .resizable()
                                .scaledToFit()
                                .frame(width:geometry.size.width*0.05)
                        }
                        .padding(.horizontal)
                        Spacer()
                        dateBar(geometry: geometry)
                    }
                    
                    ScrollView{
                        HStack(alignment:.top){
                            VStack{
                                VStack{
                                    Text("今日のごはん")
                                        .font(.custom("GenJyuuGothicX-Bold", size: 25))
                                    Text("ごはんの写真を撮ろう！")
                                        .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                        .foregroundStyle(.secondary)
                                    if let image = loadImageSafely(from: selectedData) { // ここで修正したloadImageSafelyを使用
                                        let size = frameSize(for: image)
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: size.width, height: size.height)
                                            .clipped()
                                            .cornerRadius(15)
                                            .shadow(radius: 5)
                                    } else {
                                        Rectangle()
                                            .frame(width: geometry.size.width * 0.4, height: geometry.size.height * 0.4)
                                            .foregroundStyle(Color(red: 206/255, green: 206/255, blue: 206/255))
                                            .cornerRadius(15)
                                    }
                                }
                                .padding()
                                .background{
                                    backgroundCard(geometry: geometry)
                                }
                                VStack{
                                    Text("今日のメニュー")
                                        .font(.custom("GenJyuuGothicX-Bold", size: 25))
                                    List{
                                        ForEach(0..<selectedData.menu.count,id:\.self){ index in
                                            Text(selectedData.menu[index])
                                                .frame(width: geometry.size.width*0.4)
                                        }
                                    }
                                    .scrollContentBackground(.hidden)
                                }
                                .padding()
                                .background{
                                    backgroundCard(geometry: geometry)
                                }
                                
                            }
                            VStack{
                                VStack{
                                    VStack{
                                        Text("五感で味わってみよう！")
                                            .font(.custom("GenJyuuGothicX-Bold", size: 25))
                                    }
                                    VStack(spacing:10){
                                        HStack(alignment:.bottom){
                                            Image("\(senseIcons[0])")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width:geometry.size.width*0.04)
                                            VStack(alignment:.leading){
                                                Text(selectedData.sight)
                                                    .frame(width:geometry.size.width*0.4)
                                                Rectangle()
                                                    .frame(width:geometry.size.width*0.4,height:1)
                                                    .foregroundStyle(senseColors[0])
                                            }
                                        }
                                        .padding()
                                    }
                                    VStack(spacing:10){
                                        HStack(alignment:.bottom){
                                            Image("\(senseIcons[1])")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width:geometry.size.width*0.04)
                                            VStack(alignment:.leading){
                                                Text(selectedData.hearing)
                                                    .frame(width:geometry.size.width*0.4)
                                                Rectangle()
                                                    .frame(width:geometry.size.width*0.4,height:1)
                                                    .foregroundStyle(senseColors[1])
                                            }
                                        }
                                        .padding()
                                    }
                                    VStack(spacing:10){
                                        HStack(alignment:.bottom){
                                            Image("\(senseIcons[2])")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width:geometry.size.width*0.04)
                                            VStack(alignment:.leading){
                                                Text(selectedData.smell)
                                                    .frame(width:geometry.size.width*0.4)
                                                Rectangle()
                                                    .frame(width:geometry.size.width*0.4,height:1)
                                                    .foregroundStyle(senseColors[2])
                                            }
                                        }
                                        .padding()
                                    }
                                    VStack(spacing:10){
                                        HStack(alignment:.bottom){
                                            Image("\(senseIcons[3])")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width:geometry.size.width*0.04)
                                            VStack(alignment:.leading){
                                                Text(selectedData.taste)
                                                    .frame(width:geometry.size.width*0.4)
                                                Rectangle()
                                                    .frame(width:geometry.size.width*0.4,height:1)
                                                    .foregroundStyle(senseColors[3])
                                            }
                                        }
                                        .padding()
                                    }
                                    VStack(spacing:10){
                                        HStack(alignment:.bottom){
                                            Image("\(senseIcons[4])")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width:geometry.size.width*0.04)
                                            VStack(alignment:.leading){
                                                Text(selectedData.tactile)
                                                    .frame(width:geometry.size.width*0.4)
                                                Rectangle()
                                                    .frame(width:geometry.size.width*0.4,height:1)
                                                    .foregroundStyle(senseColors[4])
                                            }
                                        }
                                        .padding()
                                    }
                                }
                                .padding()
                                .background{
                                    backgroundCard(geometry: geometry)
                                }
                                
                            }
                            
                        }
                        .padding()
                    }
                }
                VStack{
                    Spacer()
                    HStack{
                        Spacer()
                        if !isEditing{
                            Button{
                                showDeleteAlert = true   // アラート表示
                               
                            }label: {
                                Text("消す")
                                    .font(.custom("GenJyuuGothicX-Bold",size:15))
                                    .frame(width: 180, height: 50)
                                    .background(Color.white)
                                    .foregroundStyle(Color.red)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .overlay{
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.red ,lineWidth: 4)
                                    }
                            }
                            Button{
                                isEditing.toggle()
                            }label: {
                                Text("書き直す")
                                    .font(.custom("GenJyuuGothicX-Bold",size:15))
                                    .frame(width: 180, height: 50)
                                    .background(Color.white)
                                    .foregroundStyle(Color.cyan)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .overlay{
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.cyan ,lineWidth: 4)
                                    }
                            }
                            .padding()
                        }
                    }
                }
                
                // 自作アラートオーバーレイ
                if showDeleteAlert {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    VStack(spacing: 24){
                        Text("本当に消してもいいですか？")
                            .font(.custom("GenJyuuGothicX-Bold", size: 22))
                            .foregroundColor(.red)
                        Text("一度消すと、元に戻すことはできません。")
                            .font(.custom("GenJyuuGothicX-Regular", size: 17))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                        HStack(spacing: 32){
                            Button{
                                showDeleteAlert = false
                            }label: {
                                Text("やっぱりやめる")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 16))
                                    .frame(width: 120, height: 44)
                                    .background(Color.white)
                                    .foregroundStyle(Color.gray)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay{
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray, lineWidth: 3)
                                    }
                            }
                            Button{
                                context.delete(selectedData)
                                showDeleteAlert = false
                                dismiss()
                            }label: {
                                Text("消す")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 16))
                                    .frame(width: 120, height: 44)
                                    .background(Color.red.opacity(0.9))
                                    .foregroundStyle(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay{
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.red, lineWidth: 3)
                                    }
                            }
                        }
                    }
                    .padding(.vertical, 40)
                    .padding(.horizontal, 36)
                    .background(Color.white)
                    .cornerRadius(24)
                    .shadow(radius: 16)
                    // アラートを中央表示
                    .frame(maxWidth: 340)
                }
            }
            .onAppear {
                // 非同期化せず同期的にロードしていますが、
                // サイズ計算だけなら問題ありません
                detailUIImage = getImageByUrl(
                    url: selectedData.imagePath
                )
            }
        }
    }
    @ViewBuilder private func backgroundCard(geometry:GeometryProxy) -> some View{
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .frame(width: geometry.size.width*0.47)
                .foregroundStyle(.white)
                .shadow(radius: 10)
                .overlay {
                    VStack{
                        
                        HStack{
                            ZStack{
                                Circle()
                                    .frame(width: 13)
                                    .foregroundStyle(.gray)
                                Circle()
                                    .frame(width: 10)
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                            ZStack{
                                Circle()
                                    .frame(width: 13)
                                    .foregroundStyle(.gray)
                                Circle()
                                    .frame(width: 10)
                                    .foregroundStyle(.white)
                            }
                        }
                        Spacer()
                        HStack{
                            ZStack{
                                Circle()
                                    .frame(width: 13)
                                    .foregroundStyle(.gray)
                                Circle()
                                    .frame(width: 10)
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                            ZStack{
                                Circle()
                                    .frame(width: 13)
                                    .foregroundStyle(.gray)
                                Circle()
                                    .frame(width: 10)
                                    .foregroundStyle(.white)
                            }
                        }
                        
                    }
                    .padding()
                }
        }
    }
    
    private func dateBar(geometry: GeometryProxy) -> some View {
        VStack(alignment:.trailing){
            
            Image("mt_DateBar")
                .resizable()
                .scaledToFit()
                .frame(width:geometry.size.width*0.32)
                .shadow(radius: 3,y:10)
                .overlay {
                    HStack {
                        Text(dateFormatter(date: selectedData.saveDay))
                        Text("：")
                        if let time = selectedData.time{
                            Text(changeTimeStamp(timeStamp: time))
                        }else{
                            Text("-")
                        }
                    }
                    .font(.custom("GenJyuuGothicX-Bold", size: 28))
                    .foregroundColor(.white)
                }
            
        }
    }
    private func changeTimeStamp(timeStamp:TimeStamp) -> String{
        switch timeStamp{
        case .morning:
            return "あさ"
        case .lunch:
            return "ひる"
        case .dinner:
            return "よる"
        default:
            return "ー"
        }
    }
    
    private func labelFor(time: TimeStamp) -> String {
        switch time {
        case .morning:
            return "あさ"
        case .lunch:
            return "ひる"
        case .dinner:
            return "よる"
        }
    }
}
