import SwiftUI
import PhotosUI

struct NewWriteingView: View {
    @Binding var showWritingView:Bool
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var uiImage: UIImage? = nil
    @State private var editedSight: String = ""
    @State private var editedTaste: String = ""
    @State private var editedTactile: String = ""
    @State private var editedSmell: String = ""
    @State private var editedHearing: String = ""
    @State private var editedMenu: [String] = ["", "", "", "", "", ""]
    
    var body: some View {
        NavigationStack{
            ZStack{
                Image("bg_AjiwaiCardView")
                    .resizable()
                    .blur(radius: 5)
                //                Color.gray.opacity(0.2)
                
                ScrollView{
                    VStack(spacing:20){
                        VStack{
                            Text("きゅうしょくのしゃしん")
                            if let image = uiImage{
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 400, height: 300)
                                    .padding(.bottom)
                            }else{
                                RoundedRectangle(cornerRadius: 20)
                                    .frame(width: 400, height: 300)
                                    .padding(.bottom)
                            }
                            HStack{
                                PhotosPicker(selection: $selectedPhotoItem) {
                                    Label("写真を選ぶ", systemImage: "photo")
                                }
                                Button {
                                    // 描画用のアクション
                                } label: {
                                    Text("きゅうしょくの絵をかく")
                                }
                                
                            }
                        }
                        .padding(30)
                        .background{
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundStyle(.white)
                            
                        }
                        .onChange(of: selectedPhotoItem) {_ , newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    self.uiImage = uiImage
                                }
                            }
                        }
                        
                        
                        VStack(alignment:.leading){
                            Text("メニュー")
                            ForEach(editedMenu.indices, id: \.self) { index in
                                HStack {
                                    Image(systemName: "fork.knife")
                                        .foregroundColor(.orange)
                                    TextField("メニュー項目", text: $editedMenu[index])
                                        .font(.custom("GenJyuuGothicX-Bold", size: 17))
                                        .textFieldStyle(.roundedBorder)
                                }
                                .contextMenu {
                                    Button(role: .destructive){
                                        editedMenu.remove(at: index)
                                        
                                    } label: {
                                        Label("メニューを削除", systemImage: "trash")
                                            .tint(.red)
                                    }
                                }
                            }
                            Button{
                                editedMenu.append("")
                            } label: {
                                Label("メニュー項目を追加", systemImage: "plus.circle.fill")
                            }
                            .foregroundColor(.green)
                            .padding(.top)
                        }
                        .padding(30)
                        .background{
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundStyle(.white)
                            
                        }
                        .frame(width:1000)
                        VStack(alignment:.leading){
                            senseRow(icon: "eye.fill", title: "視覚", binding: $editedSight)
                            senseRow(icon: "ear.fill", title: "聴覚", binding: $editedHearing)
                            senseRow(icon: "nose.fill", title: "嗅覚", binding: $editedSmell)
                            senseRow(icon: "mouth.fill", title: "味覚", binding: $editedTaste)
                            senseRow(icon: "hand.point.up.fill", title: "触覚", binding: $editedTactile)
                        }
                        .frame(width:940)
                        .padding(30)
                        .background{
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundStyle(.white)
                            
                        }
                        
                    }
                }
                .padding()
                
            }
            .navigationTitle("ごはんのきろく")
            .toolbar{
                ToolbarItem{
                    Button(role:.destructive){
                        showWritingView = false
                    }label:{
                        Text("とじる")
                            .foregroundStyle(.red)
                    }
                }
            }
        }
    }
    private func senseRow(icon: String, title: String, binding: Binding<String>) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30, height: 30)
            Text(title)
                .font(.custom("GenJyuuGothicX-Bold", size: 16))
                .foregroundColor(.gray)
            TextField(title, text: binding)
                .font(.custom("GenJyuuGothicX-Bold", size: 17))
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}
