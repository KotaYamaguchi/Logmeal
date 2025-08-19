import SwiftUI
import PhotosUI

struct ProfileSettingView: View {
    @EnvironmentObject var userData:UserData
    @State var showSaveSuccess:Bool = false
    @State private var userName: String = ""
    @State private var userGrade: String = ""
    @State private var userClass: String = ""
    @State private var userAge: Int = 6
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var userImage:UIImage? = nil
    @State private var showNameAlert = false
    @State private var nameTextColor = Color.black
    //AsyncImageをUIImageに変換して取得したサイズ
    @State private var asyncImageSize: CGSize? = nil
    let gradeArray = ["1","2","3","4","5","6"]
    let classArray = ["1","2","3","4","5","6","7","8","9","10"]
    
    private func saveNewProfile(){
            userData.name = self.userName
            userData.age = self.userAge
            userData.yourClass = self.userClass
            userData.grade = self.userGrade
            if let userImage = self.userImage{
                userData.userImage =  saveImageToDocumentDirectory(image: userImage, inputFileName: generateUniqueImageFileName())
            }
            
    }
    private func generateUniqueImageFileName() -> String {
        let uuidString = UUID().uuidString
        let fileName = "UserImage" + uuidString
        // .jpeg拡張子をつけない
        return fileName
    }
    
    //動的ドキュメントパスで画像をsave laodする
    // 画像を保存し、そのファイル名を返す関数
    private func saveImageToDocumentDirectory(image: UIImage, inputFileName: String) -> String? {
        guard let data = image.jpegData(compressionQuality: 1.0) else {
            print("画像のデータ変換に失敗しました")
            return nil
        }
        
        do {
            let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentURL.appendingPathComponent(inputFileName + ".jpeg")
            try data.write(to: fileURL)
            print("画像の保存に成功しました: \(fileURL)")
            return inputFileName
        } catch {
            print("画像の保存に失敗しました: \(error)")
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
    var body: some View {
        GeometryReader{ geometry in
            ZStack {
                
                Image("bg_newSettingView.png")
                    .resizable()
                    .ignoresSafeArea()
                
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: geometry.size.width*0.8, height: geometry.size.height*0.9)
                    .foregroundStyle(Color(red: 220/255, green: 221/255, blue: 221/255))
                    .shadow(radius: 5)
                ScrollView{
                    if let userImage = self.userImage{
                        if userImage.size.width < userImage.size.height{
                            Image(uiImage: userImage)
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                                .frame(width: geometry.size.width * 0.2)
                                

                        }else{
                            Image(uiImage: userImage)
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                                .frame(width: geometry.size.width * 0.28)
                                .padding(.vertical,35)
                        }
                    }else{
                        if let currentUserImage = loadUserImage(from: userData.userImage) {
                            Image(uiImage: currentUserImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width:asyncImageSize?.width ?? 1 < asyncImageSize?.height ?? 0 ? geometry.size.width * 0.2 : geometry.size.width * 0.28)
                                .clipShape(Circle())
                                .padding(.vertical, asyncImageSize?.width ?? 1 < asyncImageSize?.height ?? 0 ? 0 :35)
                                .background(
                                    GeometryReader { geo in
                                        Color.clear
                                            .onAppear {
                                                if asyncImageSize == nil {
                                                    // UIImageを取得してサイズ判定
                                                    if let currentUserImage = loadUserImage(from: userData.userImage){
                                                  
                                                            asyncImageSize = currentUserImage.size
                                                        
                                                    }
                                                }
                                            }
                                    }
                                )
                        }
                    }
                    
                    HStack{
                        PhotosPicker(selection: $selectedPhotoItem) {
                            Label("写真を選ぶ", systemImage: "photo")
                                .font(.custom("GenJyuuGothicX-Bold", size: 20))
                        }
                        if userImage != nil{
                            Button{
                                withAnimation {
                                    userImage = nil
                                }
                            }label:{
                                Text("写真をリセット")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                    
                            }
                            .padding(.horizontal)
                        }
                    }
                    Image("mt_newSettingView_profileHeadline")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width*0.63)
                    
                    // 名前入力
                    Rectangle()
                        .foregroundStyle(.white)
                        .frame(width: geometry.size.width*0.63,height: geometry.size.height*0.07)
                        .overlay {
                            HStack {
                                Text("名前")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 28))
                                    .padding(.leading)
                                Spacer()
                                TextField("ここに名前を入力してください", text: $userName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .font(.custom("GenJyuuGothicX-Bold", size: 18))
                                    .frame(width: geometry.size.width*0.43)
                                    .foregroundStyle(nameTextColor)
                                    .padding(.horizontal)
                                    .multilineTextAlignment(TextAlignment.trailing)
                                    .onChange(of: userName) { oldValue, newValue in
                                        let containsBannedWord = bannedWords.contains { word in
                                            newValue.localizedCaseInsensitiveContains(word)
                                        }
                                        
                                        if containsBannedWord {
                                            showNameAlert = true
                                            nameTextColor = .red
                                        } else {
                                            showNameAlert = false
                                            nameTextColor = .black
                                        }
                                    }
                            }
                        }
                    
                    // 学年選択
                    Rectangle()
                        .foregroundStyle(.white)
                        .frame(width: geometry.size.width*0.63,height: geometry.size.height*0.07)
                        .overlay {
                            HStack {
                                Text("学年")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 28))
                                    .padding(.leading)
                                Spacer()
                                
                                Picker("選択してください", selection: $userGrade) {
                                    ForEach(gradeArray, id: \.self) { grade in
                                        Text("\(grade)年").tag(grade)
                                            .font(.custom("GenJyuuGothicX-Bold", size: 18))
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .font(.custom("GenJyuuGothicX-Bold", size: 18))
                                .frame(width: 150)
                            }
                            
                        }
                    
                    // クラス選択
                    Rectangle()
                        .foregroundStyle(.white)
                        .frame(width: geometry.size.width*0.63,height: geometry.size.height*0.07)
                        .overlay {
                            HStack {
                                Text("クラス")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 28))
                                    .padding(.leading)
                                Spacer()
                                
                                Picker("選択してください", selection: $userClass) {
                                    ForEach(classArray, id: \.self) { classNum in
                                        Text("\(classNum)組").tag(classNum)
                                            .font(.custom("GenJyuuGothicX-Bold", size: 18))
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .font(.custom("GenJyuuGothicX-Bold", size: 18))
                                .frame(width: 150)
                            }
                            
                        }
                    
                    // 年齢選択
                    Rectangle()
                        .foregroundStyle(.white)
                        .frame(width: geometry.size.width*0.63,height: geometry.size.height*0.07)
                        .overlay {
                            HStack {
                                Text("年齢")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 28))
                                    .padding(.leading)
                                Spacer()
                                
                                Picker("選択してください", selection: $userAge) {
                                    ForEach(6...18, id: \.self) { age in
                                        Text("\(age)歳").tag(age)
                                            .font(.custom("GenJyuuGothicX-Bold", size: 18))
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .font(.custom("GenJyuuGothicX-Bold", size: 18))
                                .frame(width: 150)
                            }
                            
                        }
                }
                .frame(width: geometry.size.width*0.8, height: geometry.size.height*0.85)
                .padding()
                VStack{
                    HStack{
                        Spacer()
                        Button{
                            saveNewProfile()
                            showSaveSuccess = true
                            print("押された")
                        }label: {
                            Text("ほぞんする")
                                .font(.custom("GenJyuuGothicX-Bold",size:15))
                                .frame(width: 160, height: 50)
                                .background(Color.white)
                                .foregroundStyle(Color.cyan)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .overlay{
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.cyan ,lineWidth: 4)
                                }
                        }
                    }
                    Spacer()
                }
                .padding()
            }
            .onAppear(){
                print(geometry.size)
                userName = userData.name
                userGrade = userData.grade
                userAge = userData.age
                userClass = userData.yourClass
                
                print(userData.name)
                print(userData.age)
                print(userData.grade)
                print(userData.yourClass)
            }
            .onChange(of: selectedPhotoItem) { oldValue, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let userImage = UIImage(data: data) {
                        self.userImage = userImage
                    }
                }
            }
            .alert(isPresented: $showSaveSuccess) {
                Alert(
                    title: Text("プロフィールを更新しました").font(.custom("GenJyuuGothicX-Bold", size: 18)),
                    dismissButton: .default(Text("OK")) {
                        
                    }
                )
            }
        }
    }
}

#Preview{
    NewSettingView()
        .environmentObject(UserData())
}
#Preview{
    NewContentView()
        .environmentObject(UserData())
}
