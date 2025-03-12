import SwiftUI
import PhotosUI
import SwiftData

struct NewWritingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var allData: [AjiwaiCardData]
    @State private var timeStanp:TimeStamp? = nil
    @State private var currentDate: Date = Date()
    @Binding var showWritingView: Bool
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var uiImage: UIImage? = nil
    @State private var editedText: String = ""
    @State private var editedSenseText: [String] = ["","","","",""]
    @State private var editedMenu: [String] = ["ご飯", "味噌汁", "鯖の味噌煮", "コールスロー"]
    @State private var editedSenses: [String] = Array(repeating: "", count: 5)
    @State private var showCameraPicker = false
    @State private var showingSaveAlert = false
    @State private var showDatePicker:Bool = false
    private let senseIcons = ["mt_Eye_icon", "mt_Ear_icon", "mt_Nose_icon", "mt_Tongue_icon", "mt_Hand_Icon"]
    private let senseTitles = ["みため", "おと", "におい", "あじ", "さわりごこち"]
    private let sensePlaceholders = [
        "どんな色やかたちだったかな？",
        "どんな音がしたかな？",
        "どんなにおいがしたかな？",
        "どんな味がしたかな？",
        "さわってみてどうだった？"
    ]
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
                                    if let image = uiImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: geometry.size.width*0.38)
                                            .cornerRadius(15)
                                            .shadow(radius: 5)
                                            .padding()
                                    } else {
                                        Image("mt_No_Image")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: geometry.size.width*0.38)
                                            .padding()
                                    }
                                    
                                    HStack(spacing:30){
                                        Button{
                                            showCameraPicker = true
                                        }label:{
                                            Label {
                                                Text("カメラで撮る")
                                            } icon: {
                                                Image(systemName: "camera")
                                            }
                                        }
                                        PhotosPicker(selection: $selectedPhotoItem) {
                                            Label("写真を選ぶ", systemImage: "photo")
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
                                    Text("ごはんのメニューを書き込もう！")
                                        .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                        .foregroundStyle(.secondary)
                                    List{
                                        ForEach(0..<editedMenu.count,id:\.self){ index in
                                            TextField("", text: $editedMenu[index])
                                                .textFieldStyle(.roundedBorder)
                                                .frame(width: geometry.size.width*0.4)
                                        }
                                        .onDelete { (offsets) in
                                            self.editedMenu.remove(atOffsets: offsets)
                                        }
                                    }
                                    .scrollContentBackground(.hidden)
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
                            VStack{
                                VStack{
                                    Text("ごはんはどうだった？")
                                        .font(.custom("GenJyuuGothicX-Bold", size: 25))
                                    Text("食べた感想を教えてね！")
                                        .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                    TextField("",text: $editedText,axis:.vertical)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: geometry.size.width*0.4,height:geometry.size.height*0.15)
                                        .padding()
                                }
                                .padding()
                                .background{
                                    backgroundCard(geometry: geometry)
                                }
                                VStack{
                                    Text("五感で味わってみよう！")
                                        .font(.custom("GenJyuuGothicX-Bold", size: 25))
                                    Text("見た目や匂いについて詳しく書いてみよう！")
                                        .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                    ForEach(0..<editedSenseText.count,id:\.self){ index in
                                        HStack(alignment:.bottom){
                                            Image("\(senseIcons[index])")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width:geometry.size.width*0.03)
                                            VStack(alignment:.leading){
                                                TextField(sensePlaceholders[index],text:$editedSenseText[index],axis:.vertical)
                                                    .frame(width:geometry.size.width*0.4,height:1)
                                                Rectangle()
                                                    .frame(width:geometry.size.width*0.4,height:1)
                                                    .foregroundStyle(senseColors[index])
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
                        Button{
                            if let timeStanp = timeStanp, let uiImage = uiImage {
                                saveCurrentData(
                                    saveDay: currentDate,
                                    times: timeStanp,
                                    sight: editedSenses[0],
                                    taste: editedSenses[3],
                                    smell: editedSenses[2],
                                    tactile: editedSenses[4],
                                    hearing: editedSenses[1],
                                    uiImage: uiImage,
                                    menu: editedMenu
                                )
                                showWritingView = false
                            }
                        }label:{
                            Text("ほぞんする")
                                .font(.custom("GenJyuuGothicX-Bold",size:15))
                                .frame(width: 180, height: 50)
                                .background(Color.white)
                                .foregroundStyle( Color.buttonColor)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .overlay{
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.buttonColor ,lineWidth: 4)
                                }
                        }
                    }
                }
                .padding()
            }
            .sheet(isPresented:$showDatePicker){
                VStack{
                    DatePicker("", selection: $currentDate,displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                    Divider()
                    HStack{
                        Spacer()
                        Text("いつのごはん？")
                            .font(.title2)
                        Spacer()
                        Button{
                            timeStanp = .morning
                        }label:{
                            Text("あさ")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .padding()
                                .background{
                                    Circle()
                                        .foregroundStyle(.cyan)
                                }
                        }
                        Button{
                            timeStanp = .lunch
                        }label:{
                            Text("ひる")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .padding()
                                .background{
                                    Circle()
                                        .foregroundStyle(.cyan)
                                }
                        }
                        Button{
                            timeStanp = .morning
                        }label:{
                            Text("よる")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .padding()
                                .background{
                                    Circle()
                                        .foregroundStyle(.cyan)
                                }
                        }
                        Spacer()
                    }
                    Button{
                        showDatePicker = false
                    }label:{
                        Text("とじる")
                    }
                }
                .padding()
            }
            .fullScreenCover(isPresented: $showCameraPicker) {
                ImagePicker(image: $uiImage, sourceType: .camera)
                    .ignoresSafeArea()
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        self.uiImage = uiImage
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
            Button {
                withAnimation {
                    showDatePicker = true
                }
            } label: {
                Image("mt_DateBar")
                    .resizable()
                    .scaledToFit()
                    .frame(width:geometry.size.width*0.32)
                    .overlay {
                        HStack{
                            Text(dateFormatter(date: currentDate))
                                .font(.custom("GenJyuuGothicX-Bold", size: 28))
                                .foregroundStyle(.white)
                            Text("：")
                                .foregroundStyle(.white)
                                .font(.custom("GenJyuuGothicX-Bold", size: 28))
                            Text(changeTimeStamp())
                                .foregroundStyle(.white)
                                .font(.custom("GenJyuuGothicX-Bold", size: 28))
                        }
                    }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    private func changeTimeStamp() -> String{
        switch timeStanp{
        case .morning:
            return "あさ"
        case .lunch:
            return "ひる"
        case .dinner:
            return "よる"
        default:
            return "あさ"
        }
    }
}

#Preview {
    NewWritingView(showWritingView: .constant(true))
}
