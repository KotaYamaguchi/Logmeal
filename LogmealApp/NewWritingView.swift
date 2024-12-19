import SwiftUI
import PhotosUI

struct NewWritingView: View {
    @Binding var showWritingView: Bool
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var uiImage: UIImage? = nil
    @State private var editedSight: String = ""
    @State private var editedTaste: String = ""
    @State private var editedTactile: String = ""
    @State private var editedSmell: String = ""
    @State private var editedHearing: String = ""
    @State private var editedMenu: [String] = ["", "", "", ""]
    @State private var showingCameraSheet = false
    @State private var activeTab = 0
    
    let senseEmojis = ["👀", "👂", "👃", "👅", "✋"]
    let sensePlaceholders = [
        "どんな色やかたちだったかな？",
        "どんな音がしたかな？",
        "どんなにおいがしたかな？",
        "どんな味がしたかな？",
        "さわってみてどうだった？"
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("bg_AjiwaiCardView")
                    .resizable()
                    .colorMultiply(Color(red:235/255, green:235/255, blue:235/255))
//                    .ignoresSafeArea(.keyboard)
                    
                ScrollView {
                    VStack(spacing: 25) {
                        // Photo Section
                        VStack {
                            Text("きょうのきゅうしょく 📸")
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
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.white)
                                        .frame(height: 300)
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.white)
                                        .frame(width:400,height: 300)
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
                                .overlay{
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(.gray, lineWidth: 1)
                                }
                        )
                        
                        // Menu Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("きょうのメニュー 🍱")
                                .font(.custom("GenJyuuGothicX-Bold", size: 24))
                                .padding(.bottom, 5)
                            
                            ForEach(editedMenu.indices, id: \.self) { index in
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
                                .overlay{
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(.gray, lineWidth: 1)
                                }
                        )
                        
                        // Senses Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("たべたときのかんそう ⭐️")
                                .font(.custom("GenJyuuGothicX-Bold", size: 24))
                                .padding(.bottom, 5)
                            
                            ForEach(0..<5) { index in
                                senseRow(
                                    emoji: senseEmojis[index],
                                    title: ["みため", "おと", "におい", "あじ", "さわりごこち"][index],
                                    binding: [
                                        $editedSight, $editedHearing, $editedSmell,
                                        $editedTaste, $editedTactile
                                    ][index],
                                    placeholder: sensePlaceholders[index]
                                )
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .overlay{
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(.gray, lineWidth: 1)
                                }
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("きょうのきゅうしょく")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("とじる",role:.cancel) {
                        showWritingView = false
                    }
                    .font(.headline)
                    .foregroundColor(.red)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("かんせい！") {
                        showWritingView = false
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
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
    
    private func senseRow(emoji: String, title: String, binding: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(emoji)
                    .font(.title)
                Text(title)
                    .font(.custom("GenJyuuGothicX-Bold", size: 18))
                    .foregroundColor(.primary)
            }
            
            TextField(placeholder, text: binding)
                .font(.system(size: 16))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.leading, 35)
        }
    }
}

#Preview {
    NewWritingView(showWritingView: .constant(true))
}
