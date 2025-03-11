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
    @State private var editedMenu: [String] = ["", "", "", ""]
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
        NavigationStack {
            ZStack {
                BackgroundView()
                ScrollView {
                    VStack(spacing: 25) {
                        PhotoSection(uiImage: $uiImage, selectedPhotoItem: $selectedPhotoItem, showingCameraSheet: $showingCameraSheet)
                        TimeStampSection(currentDate: $currentDate, timeStamp: $timeStanp)
                        MenuSection(editedMenu: $editedMenu)
                        SensesSection(editedSenses: $editedSenses, senseIcons: senseIcons, senseTitles: senseTitles, sensePlaceholders: sensePlaceholders)
                    }
                    .padding()
                }
            }
            .navigationTitle("きょうのきゅうしょく")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("とじる", role: .cancel) {
                        showWritingView = false
                    }
                    .font(.headline)
                    .foregroundColor(.red)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("かんせい！") {
                        showingSaveAlert = true
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                }
            }
            .alert("データを保存しますか？", isPresented: $showingSaveAlert) {
                Button("キャンセル", role: .cancel) {}
                Button("保存") {
                    if let timeStanp = timeStanp, let uiImage = uiImage {
                        saveCurrentData(
                            saveDay: currentDate,
                            times: timeStanp,
                            sight: editedSenses[0],
                            taste: editedSenses[1],
                            smell: editedSenses[2],
                            tactile: editedSenses[3],
                            hearing: editedSenses[4],
                            uiImage: uiImage,
                            menu: editedMenu
                        )
                        showWritingView = false
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingCameraSheet) {
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

struct BackgroundView: View {
    var body: some View {
        Image("bg_AjiwaiCardView")
            .resizable()
            .colorMultiply(Color(red: 235/255, green: 235/255, blue: 235/255))
    }
}

struct PhotoSection: View {
    @Binding var uiImage: UIImage?
    @Binding var selectedPhotoItem: PhotosPickerItem?
    @Binding var showingCameraSheet: Bool

    var body: some View {
        VStack {
            Text("きょうのきゅうしょく")
                .font(.custom("GenJyuuGothicX-Bold", size: 24))
                .foregroundColor(.primary)
                .padding(.top)

            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    .padding()
            } else {
                PlaceholderPhotoView()
            }

            HStack(spacing: 20) {
                PhotosPicker(selection: $selectedPhotoItem) {
                    Label("しゃしんをえらぶ", systemImage: "photo.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }

                Button {
                    showingCameraSheet = true
                } label: {
                    Label("カメラをつかう", systemImage: "camera.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.gray, lineWidth: 1)
                )
        )
    }
}

struct PlaceholderPhotoView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .frame(height: 300)
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .frame(width: 400, height: 300)
                .shadow(radius: 5)

            VStack {
                Image(systemName: "camera.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
                Text("しゃしんをとろう！")
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

struct TimeStampSection: View {
    @Binding var currentDate:Date
    @Binding var timeStamp:TimeStamp?
    var body: some View {
        HStack {
            DatePicker("", selection: $currentDate)
            ForEach(["sun.horizon", "sun.max", "moon"], id: \ .self) { symbol in
                Button {} label: {
                    Circle()
                        .frame(width: 80)
                        .foregroundStyle(.cyan)
                        .overlay(
                            Image(systemName: symbol)
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.gray, lineWidth: 1)
                )
        )
    }
}

struct MenuSection: View {
    @Binding var editedMenu: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("きょうのメニュー")
                .font(.custom("GenJyuuGothicX-Bold", size: 24))
                .padding(.bottom, 5)

            ForEach(editedMenu.indices, id: \ .self) { index in
                HStack {
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    TextField("なにをたべたかな？", text: $editedMenu[index])
                        .font(.system(size: 18))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
            }

            Button {
                withAnimation {
                    editedMenu.append("")
                }
            } label: {
                Label("メニューをついか", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            .padding()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.gray, lineWidth: 1)
                )
        )
    }
}

struct SensesSection: View {
    @Binding var editedSenses: [String]
    let senseIcons: [String]
    let senseTitles: [String]
    let sensePlaceholders: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("たべたときのかんそう")
                .font(.custom("GenJyuuGothicX-Bold", size: 24))
                .padding(.bottom, 5)

            ForEach(0..<senseIcons.count, id: \ .self) { index in
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: senseIcons[index])
                            .font(.title)
                        Text(senseTitles[index])
                            .font(.custom("GenJyuuGothicX-Bold", size: 18))
                            .foregroundColor(.primary)
                    }

                    TextField(sensePlaceholders[index], text: $editedSenses[index])
                        .font(.system(size: 16))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading, 35)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.gray, lineWidth: 1)
                )
        )
    }
}

#Preview {
    NewWritingView(showWritingView: .constant(true))
}
