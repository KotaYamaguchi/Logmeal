import SwiftUI
import SwiftData
import PhotosUI

struct NewLogDetailView: View {
    
    @Environment(\.modelContext) private var context
    @EnvironmentObject var user: UserData
    
    @State private var isEditing = false
    @State private var showCameraPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var timeStanp: TimeStamp? = nil
    @State private var currentDate = Date()
    @State private var editedSenseText = ["", "", "", "", ""]
    @State private var editedMenu = ["", "", ""]
    @State private var uiImage: UIImage?
    @State private var showDatePicker = false
    
    let dataIndex: Int
    @Binding var showDetailView: Bool
    @Query private var allData: [AjiwaiCardData]
    
    private let senseIcons = ["mt_Eye_icon", "mt_Ear_icon", "mt_Nose_icon", "mt_Tongue_icon", "mt_Hand_Icon"]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundImage(geometry: geometry)
                contentLayout(geometry: geometry)
            }
            .fullScreenCover(isPresented: $showCameraPicker) {
                ImagePicker(image: $uiImage, sourceType: .camera)
                    .ignoresSafeArea()
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                loadSelectedPhoto(newItem)
            }
            .onAppear{
                print("現在の allData.count = \(allData.count)")
                print("読み込む dataIndex = \(dataIndex)")
                print("メニュー = \(allData[dataIndex].menu)")
                
                print("五感(聴覚のみ) = \(allData[dataIndex].hearing)")
                loadInitialData()
                print("editedMenu = \(editedMenu)")
            }
        }
    }
    
    private func backgroundImage(geometry: GeometryProxy) -> some View {
        Image("bg_AjiwaiCardView")
            .resizable()
            .scaledToFill()
            .blur(radius: 3)
            .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
    }
    
    private func contentLayout(geometry: GeometryProxy) -> some View {
        VStack {
            HeaderBarView(geometry: geometry, currentDate: $currentDate, timeStanp: $timeStanp, showDatePicker: $showDatePicker)
            if isEditing{
                timeStampSection
            }
            ScrollView {
                HStack(alignment: .top) {
                    VStack {
                        MealImageView(geometry: geometry, uiImage: uiImage, isEditing: isEditing, showCameraPicker: $showCameraPicker, selectedPhotoItem: $selectedPhotoItem)
                        MenuListView(geometry: geometry, isEditing: isEditing, editedMenu: $editedMenu)
                    }
                    .background { backgroundCard(geometry: geometry) }
                    
                    SenseInputView(geometry: geometry, senseIcons: senseIcons, isEditing: isEditing, editedSenseText: $editedSenseText)
                        .background { backgroundCard(geometry: geometry) }
                }
                .padding()
            }
            
            FooterButtonsView(isEditing: $isEditing, onSave: saveEdits)
                .padding(.horizontal)
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
    private var timeStampSection: some View {
        VStack {
            HStack{
                Spacer()
                Text("いつのごはん？")
                    .font(.custom("GenJyuuGothicX-Bold", size: 25))
                    .padding(.leading)

                HStack(spacing: 20) {
                    ForEach([TimeStamp.morning, .lunch, .dinner], id: \.self) { time in
                        Button {
                            timeStanp = time
                        } label: {
                            HStack {
                                
                                Text(labelFor(time: time))
                                    .font(.title2)
                                    .bold()
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .foregroundColor(.white)
                            .background(
                                Capsule()
                                    .foregroundStyle(timeStanp == time ? Color.cyan : Color.gray.opacity(0.4))
                            )
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    private func loadSelectedPhoto(_ newItem: PhotosPickerItem?) {
        Task {
            if let data = try? await newItem?.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                self.uiImage = uiImage
            }
        }
    }
    
    private func loadInitialData() {
        let data = allData[dataIndex]
        currentDate = data.saveDay
        timeStanp = data.time
        editedMenu = data.menu
        editedSenseText = [data.sight, data.hearing, data.smell, data.taste, data.tactile]
        
        if let imageData = try? Data(contentsOf: data.imagePath),
           let loadedImage = UIImage(data: imageData) {
            uiImage = loadedImage
        }
    }
    
    private func saveEdits() {
        guard let image = uiImage, let time = timeStanp else { return }
        
        let oldImagePath = allData[dataIndex].imagePath
        let newImagePath = saveImageToDocumentsDirectory(image: image)
        
        allData[dataIndex].saveDay = currentDate
        allData[dataIndex].time = time
        allData[dataIndex].sight = editedSenseText[0]
        allData[dataIndex].hearing = editedSenseText[1]
        allData[dataIndex].smell = editedSenseText[2]
        allData[dataIndex].taste = editedSenseText[3]
        allData[dataIndex].tactile = editedSenseText[4]
        allData[dataIndex].menu = editedMenu
        allData[dataIndex].imagePath = newImagePath
        
        do {
            try context.save()
            print("保存成功")
        } catch {
            print("保存失敗: \(error)")
        }
    }
    
    private func saveImageToDocumentsDirectory(image: UIImage) -> URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = directory.appendingPathComponent(fileName)
        
        if let data = image.jpegData(compressionQuality: 1.0) {
            try? data.write(to: fileURL)
        }
        return fileURL
    }
    
    private func backgroundCard(geometry: GeometryProxy) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(width: geometry.size.width * 0.47)
            .foregroundStyle(.white)
            .shadow(radius: 10)
    }
}

struct HeaderBarView: View {
    let geometry: GeometryProxy
    @Binding var currentDate: Date
    @Binding var timeStanp: TimeStamp?
    @Binding var showDatePicker: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack {
            Button { dismiss() } label: {
                Image("bt_close")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.05)
            }
            Spacer()
            Button {
                withAnimation { showDatePicker = true }
            } label: {
                Image("mt_DateBar")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.32)
                    .overlay(alignment: .center) {
                        HStack {
                            Text(dateFormatter(date: currentDate))
                            Text(":")
                            Text(changeTimeStamp())
                        }
                        .font(.custom("GenJyuuGothicX-Bold", size: 28))
                        .foregroundStyle(.white)
                    }
            }
            .buttonStyle(PlainButtonStyle())
            .popover(isPresented: $showDatePicker) {
                calendarPopoverContent()
            }
        }
        .padding(.horizontal)
    }
    @ViewBuilder
    private func calendarPopoverContent() -> some View {
        VStack {
            Rectangle()
                .foregroundStyle(.white)
                .frame(width: 450, height: 40)
                .overlay {
                    Text("日にちをえらぼう！")
                        .font(.custom("GenJyuuGothicX-Bold", size: 20))
                }
            DatePicker("日付を選んでね", selection: $currentDate, displayedComponents: [.date])
                .datePickerStyle(.graphical)
                .labelsHidden()
                .padding()
        }
        .frame(width: 450)
    }
    private func dateFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    private func changeTimeStamp() -> String {
        switch timeStanp {
        case .morning: return "あさ"
        case .lunch: return "ひる"
        case .dinner: return "よる"
        default: return "ー"
        }
    }
}

struct MealImageView: View {
    let geometry: GeometryProxy
    let uiImage: UIImage?
    let isEditing: Bool
    @Binding var showCameraPicker: Bool
    @Binding var selectedPhotoItem: PhotosPickerItem?
    var body: some View {
        VStack {
            Text("今日のごはん")
                .font(.custom("GenJyuuGothicX-Bold", size: 25))
            
            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: geometry.size.width * 0.4, height: geometry.size.height * 0.4)
                    .scaledToFit()
                    .clipped()
            } else {
                Image("mt_No_Image")
                    .resizable()
                    .frame(width: geometry.size.width * 0.4, height: geometry.size.height * 0.4)
                    .scaledToFit()
                    .clipped()
            }
            
            if isEditing {
                HStack(spacing: 30) {
                    Button { showCameraPicker = true } label: {
                        Label("カメラで撮る", systemImage: "camera")
                    }
                    PhotosPicker(selection: $selectedPhotoItem) {
                        Label("写真を選ぶ", systemImage: "photo")
                    }
                }
            }
        }
        .padding()
    }
}

struct MenuListView: View {
    let geometry: GeometryProxy
    let isEditing: Bool
    @Binding var editedMenu: [String]

    var body: some View {
        VStack(alignment: .leading) {
            Text("今日のメニュー")
                .font(.custom("GenJyuuGothicX-Bold", size: 25))

            ForEach(Array(editedMenu.enumerated()), id: \.offset) { index, _ in
                HStack {
                    if isEditing {
                        TextField("メニューを入力", text: $editedMenu[index])
                            .textFieldStyle(.roundedBorder)
                            .frame(width: geometry.size.width * 0.3)

                        Button(action: {
                            withAnimation {
                                removeMenu(at: index)
                            }
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .padding(.leading, 5)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    } else {
                        Text(editedMenu[index])
                    }
                }
                .padding(.vertical, 4)
            }

            if isEditing {
                Button {
                    withAnimation {
                        editedMenu.append("")
                    }
                } label: {
                    Label("メニューを追加", systemImage: "plus.circle")
                        .padding(.top, 8)
                }
            }
        }
        .padding()
    }

    private func removeMenu(at index: Int) {
        if editedMenu.indices.contains(index) {
            editedMenu.remove(at: index)
        }
    }
}


struct SenseInputView: View {
    let geometry: GeometryProxy
    let senseIcons: [String]
    let isEditing: Bool
    @Binding var editedSenseText: [String]
    
    var body: some View {
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
    }
}

struct FooterButtonsView: View {
    @Binding var isEditing: Bool
    var onSave: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            if isEditing {
                Button(action: onSave) {
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
                withAnimation { isEditing.toggle() }
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
    }
}

#Preview {
    NewContentView()
        .environmentObject(UserData())
        .modelContainer(for: AjiwaiCardData.self)
}
