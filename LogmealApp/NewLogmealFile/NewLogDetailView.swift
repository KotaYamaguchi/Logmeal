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
    let selectedData: AjiwaiCardData
    @State private var timeStanp:TimeStamp? = nil
    @State private var currentDate: Date = Date()
    @Binding var showDetailView: Bool
    @State var editedText: String
    @State var editedSenseText: [String]
    @State var editedMenu: [String]
    @State var uiImage: UIImage?
    @State private var showDatePicker: Bool = false
    private let senseIcons = ["mt_Eye_icon", "mt_Ear_icon", "mt_Nose_icon", "mt_Tongue_icon", "mt_Hand_Icon"]
    
    init(selectedData: AjiwaiCardData, showDetailView: Binding<Bool>) {
        self.selectedData = selectedData
        self._showDetailView = showDetailView
        self._editedText = State(initialValue: selectedData.taste)
        self._editedSenseText = State(initialValue: [selectedData.sight, selectedData.hearing, selectedData.smell, selectedData.taste, selectedData.tactile])
        self._editedMenu = State(initialValue: selectedData.menu)
        if let imageData = try? Data(contentsOf: selectedData.imagePath),
           let image = UIImage(data: imageData) {
            self.uiImage = image
        } else {
            self.uiImage = nil
        }
    }
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

                        Button {
                            if isEditing {
                                saveEdits()
                            }
                            isEditing.toggle()
                        } label: {
                            Text(isEditing ? "保存" : "編集")
                                .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                                .background(Color.blue.opacity(0.7))
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(.horizontal)
                    HStack{
                        Spacer()
                        dateBar(geometry: geometry)
                    }
                    ScrollView {
                        HStack(alignment: .top) {
                            VStack {
                                VStack {
                                    Text("今日のごはん")
                                        .font(.custom("GenJyuuGothicX-Bold", size: 25))

                                    if let image = uiImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: geometry.size.width * 0.38)
                                            .cornerRadius(15)
                                            .shadow(radius: 5)
                                            .padding()
                                    } else {
                                        Image("mt_No_Image")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: geometry.size.width * 0.38)
                                            .padding()
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
                                .background {
                                    backgroundCard(geometry: geometry)
                                }

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
                                .background {
                                    backgroundCard(geometry: geometry)
                                }
                            }

                            VStack {
                                VStack {
                                    Text("ごはんはどうだった？")
                                        .font(.custom("GenJyuuGothicX-Bold", size: 25))

                                    if isEditing {
                                        TextField("", text: $editedText, axis: .vertical)
                                            .frame(width: geometry.size.width * 0.34, height: geometry.size.height * 0.15)
                                            .textFieldStyle(.roundedBorder)
                                            .padding()
                                    } else {
                                        Text(editedText)
                                            .frame(width: geometry.size.width * 0.34, height: geometry.size.height * 0.15)
                                            .padding()
                                    }
                                }
                                .padding()
                                .background {
                                    backgroundCard(geometry: geometry)
                                }

                                VStack {
                                    VStack {
                                        Text("五感で味わってみよう！")
                                            .font(.custom("GenJyuuGothicX-Bold", size: 25))
                                    }

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
    private func saveEdits() {
        selectedData.taste = editedText
        selectedData.sight = editedSenseText[0]
        selectedData.hearing = editedSenseText[1]
        selectedData.smell = editedSenseText[2]
        selectedData.taste = editedSenseText[3]
        selectedData.tactile = editedSenseText[4]
        selectedData.menu = editedMenu

        do {
            try context.save()
        } catch {
            print("データの保存に失敗しました: \(error)")
        }
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
            return "あさ"
        }
    }
}


#Preview{
    NewContentView()
        .environmentObject(UserData())
        .modelContainer(for: AjiwaiCardData.self)
}
