import SwiftUI
import SwiftData

/// MVVM対応のHomeView実装
struct MVVMHomeViewImplementation: View {
    @StateObject private var characterViewModel = CharacterViewModel()
    @StateObject private var ajiwaiCardViewModel = AjiwaiCardViewModel()
    @StateObject private var userProfileViewModel = UserProfileViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundImage(geometry: geometry)
                ScrollView {
                    userInfoPanel(geometry: geometry)
                    logGrid(geometry: geometry)
                }
                addLogButton(geometry: geometry)
            }
            .onAppear {
                print("ーーーーーーーーーーーーMVVM Home画面を表示しました！ーーーーーーーーーーーー")
                characterViewModel.initCharacterData()
                ajiwaiCardViewModel.fetchCards()
            }
            .onChange(of: ajiwaiCardViewModel.selectedIndex) { _, newValue in
                ajiwaiCardViewModel.showDetailView = (newValue != nil)
            }
            .fullScreenCover(isPresented: $ajiwaiCardViewModel.showWritingView) {
                MVVMLogWritingView(showWritingView: $ajiwaiCardViewModel.showWritingView)
            }
            .fullScreenCover(isPresented: $ajiwaiCardViewModel.showDetailView) {
                if let index = ajiwaiCardViewModel.selectedIndex {
                    MVVMLogDetailView(dataIndex: index)
                        .onDisappear {
                            ajiwaiCardViewModel.selectedIndex = nil
                        }
                }
            }
        }
    }
    
    private func backgroundImage(geometry: GeometryProxy) -> some View {
        Image(characterViewModel.backgroundImageName)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
            .scaleEffect(1.1)
            .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
    }
    
    private func userInfoPanel(geometry: GeometryProxy) -> some View {
        HStack {
            Spacer()
            VStack(spacing: 0) {
                if let userImage = userProfileViewModel.userProfile.userImage,
                   let uiImage = loadUserImage(from: userImage) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width * 0.2)
                        .clipShape(Circle())
                } else {
                    Image("no_user_image")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.2)
                        .overlay {
                            Circle()
                                .stroke(characterViewModel.displayContentColor, lineWidth: 5)
                        }
                }
                
                Text(userProfileViewModel.userProfile.name)
                    .font(.custom("GenJyuuGothicX-Bold", size: geometry.size.width * 0.03))
            }
            
            VStack {
                HStack {
                    ForEach([
                        ("\(ajiwaiCardViewModel.logCount)", "ろぐ"),
                        ("\(userProfileViewModel.userProfile.point)", "ポイント"),
                        ("\(characterViewModel.currentCharacter.level)", "レベル")
                    ], id: \.1) { value, label in
                        VStack {
                            Text(value)
                                .font(.custom("GenJyuuGothicX-Bold", size: geometry.size.width * 0.06))
                            Text(label)
                                .font(.custom("GenJyuuGothicX-Bold", size: geometry.size.width * 0.04))
                        }
                        .padding(.horizontal, geometry.size.width * 0.05)
                    }
                }
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: geometry.size.width * 0.8, height: 3)
                    .foregroundStyle(characterViewModel.displayContentColor)
                    .padding()
            }
            Spacer()
        }
        .padding(.top, geometry.size.height * 0.05)
    }
    
    private func logGrid(geometry: GeometryProxy) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: geometry.size.width * 0.005) {
            ForEach(0..<ajiwaiCardViewModel.cards.count, id: \.self) { index in
                Button {
                    ajiwaiCardViewModel.selectedIndex = nil
                    DispatchQueue.main.async {
                        ajiwaiCardViewModel.selectedIndex = index
                    }
                } label: {
                    if let image = ajiwaiCardViewModel.loadImage(from: ajiwaiCardViewModel.cards[index]) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: (geometry.size.width * 0.8) / 3, height: (geometry.size.width * 0.8) / 3)
                            .clipped()
                    } else {
                        Rectangle()
                            .frame(width: (geometry.size.width * 0.8) / 3, height: (geometry.size.width * 0.8) / 3)
                            .foregroundStyle(Color(red: 206/255, green: 206/255, blue: 206/255))
                    }
                }
            }
        }
        .frame(width: geometry.size.width * 0.8)
        .padding(.horizontal)
    }
    
    private func addLogButton(geometry: GeometryProxy) -> some View {
        Button {
            ajiwaiCardViewModel.showWritingView = true
        } label: {
            Image(characterViewModel.addButtonImageName)
                .resizable()
                .scaledToFit()
                .frame(width: geometry.size.width * 0.15)
        }
        .position(x: geometry.size.width * 0.85, y: geometry.size.height * 0.9)
    }
    
    private func loadUserImage(from fileName: String) -> UIImage? {
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL: URL
        
        if fileName.hasSuffix(".jpeg") {
            fileURL = documentURL.appendingPathComponent(fileName)
        } else {
            fileURL = documentURL.appendingPathComponent(fileName + ".jpeg")
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            return UIImage(data: data)
        } catch {
            print("画像の読み込みに失敗しました: \(error)")
            return nil
        }
    }
}

/// プレースホルダー: MVVM対応のLogWritingView
struct MVVMLogWritingView: View {
    @Binding var showWritingView: Bool
    
    var body: some View {
        VStack {
            Text("MVVM Log Writing View")
            Button("閉じる") {
                showWritingView = false
            }
        }
    }
}

/// プレースホルダー: MVVM対応のLogDetailView
struct MVVMLogDetailView: View {
    let dataIndex: Int
    
    var body: some View {
        VStack {
            Text("MVVM Log Detail View")
            Text("Index: \(dataIndex)")
        }
    }
}

#Preview {
    MVVMHomeViewImplementation()
        .modelContainer(for: AjiwaiCardData.self)
}