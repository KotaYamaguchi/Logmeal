import SwiftUI
import PhotosUI
import SwiftData

struct NewWritingView: View {
    @Environment(\.modelContext) private var context
    @Query private var allData: [AjiwaiCardData]
    @State private var timeStanp:TimeStamp? = nil
    @State private var currentDate: Date = Date()
    @Binding var showWritingView: Bool
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var uiImage: UIImage? = nil
    @State private var editedMenu: [String] = ["ご飯", "味噌汁", "鯖の味噌煮", "コールスロー"]
    @State private var editedSenses: [String] = Array(repeating: "", count: 5)
    @State private var showingCameraSheet = false
    @State private var showingSaveAlert = false

    private let senseIcons = ["eye", "ear", "nose", "mouth", "hand.raised"]
    private let senseTitles = ["みため", "おと", "におい", "あじ", "さわりごこち"]
    private let sensePlaceholders = [
        "どんな色やかたちだったかな？",
        "どんな音がしたかな？",
        "どんなにおいがしたかな？",
        "どんな味がしたかな？",
        "さわってみてどうだった？"
    ]
    private func dateFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    func saveCurrentData(saveDay: Date, times: TimeStamp, sight: String, taste: String, smell: String, tactile: String, hearing: String, uiImage: UIImage, menu: [String]){
        let imagePath: URL = getDocumentPath(saveData: uiImage, fileName: dateFormatter(date: saveDay))
        let newData = AjiwaiCardData(saveDay: saveDay, times: times, sight: sight, taste: taste, smell: smell, tactile: tactile, hearing: hearing, imagePath: imagePath, menu: menu)
        
        context.insert(newData)
        
        do {
            try context.save()
        } catch {
            print("コンテキストの保存エラー: \(error)")
        }
    }
    
    private func getDocumentPath(saveData: UIImage, fileName: String) -> URL {
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentURL.appendingPathComponent(fileName + ".jpeg")
        do {
            try saveData.jpegData(compressionQuality: 1.0)?.write(to: fileURL)
        } catch {
            print("画像の保存に失敗しました: \(error)")
        }
        return fileURL
    }
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                Image("bg_AjiwaiCardView")
                    
                    .resizable()
                    .scaledToFill()
                    .blur(radius: 3)
                    .position(x:geometry.size.width*0.5,y:geometry.size.height*0.5)
                
                ScrollView{
                    HStack{
                        VStack{
                            VStack{
                                Text("今日の給食")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 25))
                                Text("給食の写真を撮ろう！")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                    .foregroundStyle(.secondary)
                                Image("mt_No_Image")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width*0.38)
                                    .padding()
                                HStack(spacing:30){
                                    Button{
                                        
                                    }label:{
                                        Label {
                                            Text("カメラで撮る")
                                        } icon: {
                                            Image(systemName: "camera")
                                        }
                                        
                                    }
                                    Button{
                                        
                                    }label:{
                                        Label {
                                            Text("写真を選ぶ")
                                        } icon: {
                                            Image(systemName: "photo")
                                        }
                                        
                                    }
                                }
                            }
                            .padding()
                            .background{
                                backgroundCard(geometry: geometry)
                            }
                            VStack{
                                Text("今日のメニュー")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 25))
                                Text("給食のメニューを書き込もう！")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                    .foregroundStyle(.secondary)
                                ForEach(0..<editedMenu.count,id:\.self){ index in
                                    TextField("", text: $editedMenu[index])
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: geometry.size.width*0.4)
                                }
                                Button{
                                    editedMenu.append("")
                                }label:{
                                    Label {
                                        Text("メニューを追加する")
                                    } icon: {
                                        Image(systemName: "plus.circle")
                                    }
                                }
                            }
                            .padding()
                            .background{
                                backgroundCard(geometry: geometry)
                            }
                        }
                    }
                }
            }
        }
    }
    @ViewBuilder private func backgroundCard(geometry:GeometryProxy) -> some View{
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                
                .frame(width: .infinity,height: .infinity)
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    NewWritingView(showWritingView: .constant(true))
}
