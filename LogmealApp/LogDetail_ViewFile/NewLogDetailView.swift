import SwiftUI
import SwiftData
import PhotosUI

struct NewLogDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @EnvironmentObject var user: UserData
    @State private var isEditing: Bool = false
    @State private var showCameraPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    let dataIndex: Int
    @Query private var allData: [AjiwaiCardData]
    @State private var timeStanp:TimeStamp? = nil
    @State private var currentDate: Date = Date()
    @Binding var showDetailView: Bool
    @State var editedText: String = ""
    @State var editedSenseText: [String] = ["","","","",""]
    @State var editedMenu: [String] = []
    @State var uiImage: UIImage?
    @State private var showDatePicker: Bool = false
    private let senseIcons = ["mt_Eye_icon", "mt_Ear_icon", "mt_Nose_icon", "mt_Tongue_icon", "mt_Hand_Icon"]

    private func dateFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("bg_AjiwaiCardView")
                    .resizable()
                    .scaledToFill()
                    .blur(radius: 3)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
                
                VStack {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image("bt_close")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.05)
                        }
                        Spacer()
                        dateBar(geometry: geometry)
                    }
                    .padding(.horizontal)
                    ScrollView {
                        HStack(alignment: .top) {
                            VStack {
                                VStack {
                                    Text("今日のごはん")
                                        .font(.custom("GenJyuuGothicX-Bold", size: 25))
                                    if let image = uiImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .frame(width: geometry.size.width*0.4,height:geometry.size.height*0.4)
                                            .scaledToFit()
                                            .clipped()
                                    } else {
                                        Image("mt_No_Image")
                                            .resizable()
                                            .frame(width: geometry.size.width*0.4,height:geometry.size.height*0.4)
                                            .scaledToFit()
                                            .clipped()
                                    }
                                    if isEditing{
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
                                }
                                .padding()
                                VStack {
                                    Text("今日のメニュー")
                                        .font(.custom("GenJyuuGothicX-Bold", size: 25))
                                    
                                    List {
                                        ForEach(0..<editedMenu.count, id: \.self) { index in
                                            if isEditing {
                                                TextField("", text: $editedMenu[index])
                                                    .textFieldStyle(.roundedBorder)
                                            } else {
                                                Text(editedMenu[index])
                                            }
                                        }
                                    }
                                    .scrollContentBackground(.hidden)
                                }
                                .padding()
                            }
                            .background {
                                backgroundCard(geometry: geometry)
                            }
                            VStack {
//                                VStack {
//                                    Text("ごはんはどうだった？")
//                                        .font(.custom("GenJyuuGothicX-Bold", size: 25))
//                                    
//                                    if isEditing {
//                                        TextField("", text: $editedText, axis: .vertical)
//                                            .frame(width: geometry.size.width * 0.34, height: geometry.size.height * 0.15)
//                                            .textFieldStyle(.roundedBorder)
//                                            .padding()
//                                    } else {
//                                        Text(editedText)
//                                            .frame(width: geometry.size.width * 0.34, height: geometry.size.height * 0.15)
//                                            .padding()
//                                    }
//                                }
//                                .padding()
//                                .background {
//                                    backgroundCard(geometry: geometry)
//                                }
                                
                                VStack {
                                        Text("五感で味わってみよう！")
                                            .font(.custom("GenJyuuGothicX-Bold", size: 25))
                                    VStack(spacing: 10) {
                                        ForEach(0..<editedSenseText.count, id: \.self) { index in
                                            HStack(alignment: .bottom) {
                                                Image(senseIcons[index])
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: geometry.size.width * 0.04)
                                                
                                                VStack(alignment: .leading) {
                                                    if isEditing {
                                                        TextField("", text: $editedSenseText[index])
                                                            .textFieldStyle(.roundedBorder)
                                                            .frame(width: geometry.size.width * 0.4)
                                                    } else {
                                                        Text(editedSenseText[index])
                                                            .frame(width: geometry.size.width * 0.4)
                                                    }
                                                    Rectangle()
                                                        .frame(width: geometry.size.width * 0.4, height: 1)
                                                        .foregroundStyle(Color.gray)
                                                }
                                            }
                                            .padding()
                                        }
                                    }
                                }
                                .padding()
                                .background {
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
                        if isEditing{
                            Button{
                                if let uiimage = self.uiImage,let time = self.timeStanp{
                                    saveEdits()
                                }
                            }label:{
                                Text("保存する")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                    .padding(.horizontal)
                                    .padding(.vertical, 5)
                                    .background(Color.blue.opacity(0.7))
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        Button {
                            withAnimation {
                                isEditing.toggle()
                            }
                        } label: {
                            Text(isEditing ? "キャンセル" : "編集")
                                .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                                .background(Color.blue.opacity(0.7))
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(.horizontal)
                }
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
                            timeStanp = .dinner
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
            .onAppear {
                currentDate = allData[dataIndex].saveDay
                timeStanp = allData[dataIndex].time
                editedText = allData[dataIndex].taste
                editedSenseText = [
                    allData[dataIndex].sight,
                    allData[dataIndex].hearing,
                    allData[dataIndex].smell,
                    allData[dataIndex].taste,
                    allData[dataIndex].tactile
                ]
                editedMenu = allData[dataIndex].menu

                if let imageData = try? Data(contentsOf: allData[dataIndex].imagePath),
                   let loadedImage = UIImage(data: imageData) {
                    uiImage = loadedImage
                }
            }
        }
    }
    private func saveEdits() {
        if let image = self.uiImage{
            let oldImagePath = allData[dataIndex].imagePath
            let NewImagePath = saveImageToDocumentsDirectory(image: image)
            
            allData[dataIndex].saveDay = currentDate
            allData[dataIndex].time = timeStanp
            allData[dataIndex].sight = editedSenseText[0]
            allData[dataIndex].hearing = editedSenseText[1]
            allData[dataIndex].smell = editedSenseText[2]
            allData[dataIndex].taste = editedSenseText[3]
            allData[dataIndex].tactile = editedSenseText[4]
            allData[dataIndex].menu = editedMenu
            allData[dataIndex].imagePath = NewImagePath
            deleteOldImage(imagePath: oldImagePath)
            
            do {
                try context.save()
                print("保存成功")
            } catch {
                print("保存失敗: \(error)")
            }
        }
    }
    private func deleteOldImage(imagePath: URL){
        do{
            try FileManager.default.removeItem(at:imagePath)
        }catch{
            print(error.localizedDescription)
        }
    }
    private func saveImageToDocumentsDirectory(image: UIImage) -> URL {
           let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
           let fileName = UUID().uuidString + ".jpg"
           let fileURL = documentDirectory.appendingPathComponent(fileName)
           
        if let data = image.jpegData(compressionQuality: 1.0) {
               try? data.write(to: fileURL)
           }
           
           return fileURL
       }
    @ViewBuilder private func backgroundCard(geometry: GeometryProxy) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: geometry.size.width * 0.47, height: .infinity)
                .foregroundStyle(.white)
                .shadow(radius: 10)
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
            return "ー"
        }
    }
}


#Preview{
    NewContentView()
        .environmentObject(UserData())
        .modelContainer(for: AjiwaiCardData.self)
}
