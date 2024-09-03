import SwiftUI

struct CharacterSelectView: View {
    @EnvironmentObject var user: UserData
    @State private var selectedCharacter: Profile? = nil
    @State private var isDetailViewPresented = false
    @Binding var isSelectedCharacter: Bool
    @Binding var showFillUserName: Bool
    @State private var focusedIndex: Int? = nil
    @State private var hasBeenTapped = false
    private let soundManager = SoundManager.shared
    @State private var rotationAngle: Double = 0 // 左右の傾き角度
    @State private var scaleEffectValue: CGFloat = 1.0 // 拡大縮小のためのスケール変数

    var profiles = [
        Profile(charaName: "レーク", charaImage: "Dog", mainStatus: "犬とトマトのハーフ", subStatus: "朝ごはんがだいすき！"),
        Profile(charaName: "ラン", charaImage: "Rabbit", mainStatus: "ウサギとニンジンのハーフ", subStatus: "お昼ごはんがだいすき！"),
        Profile(charaName: "ティナ", charaImage: "Cat", mainStatus: "猫とナスビのハーフ", subStatus: "夜ごはんがだいすき！")
    ]
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            if !isDetailViewPresented {
                selectView(size: size)
            } else {
                detailView(size: size)
            }
        }
        .onAppear {
            startWobbleAnimation()
        }
    }
    
    @ViewBuilder func selectView(size: CGSize) -> some View {
        ZStack {
            Image("bg_AjiwaiCardView")
                .resizable()
                .ignoresSafeArea()
                .frame(width: size.width, height: size.height)
            
            VStack {
                Text("キャラクターを選んでね")
                    .foregroundStyle(Color.textColor)
                    .font(.custom("GenJyuuGothicX-Bold", size: 50))
                    .bold()
                Text("選んだキャラクターがあなたのがんばりによって成長するよ！")
                    .foregroundStyle(Color.textColor)
                    .font(.custom("GenJyuuGothicX-Bold", size: 20))
                    .bold()
                HStack(spacing: size.width * 0.04) {
                    ForEach(profiles.indices, id: \.self) { index in
                        CharacterView(profile: profiles[index], isFocused: focusedIndex == index, hasBeenTapped: hasBeenTapped, size: size, rotationAngle: rotationAngle)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    focusedIndex = index
                                    hasBeenTapped = true
                                }
                            }
                    }
                }
                Button {
                    if let focusedIndex = focusedIndex {
                        selectedCharacter = profiles[focusedIndex]
                        withAnimation {
                            isDetailViewPresented.toggle()
                        }
                        soundManager.playSound(named: "se_positive")
                    }
                } label: {
                    Image("bt_base")
                        .resizable()
                        .scaledToFit()
                        .frame(width:200,height: 100)
                        .overlay {
                            Text("これにする!")
                                .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                .foregroundStyle(Color.buttonColor)
                        }
                }
                .frame(width: size.width * 0.2)
                .padding()
                .padding(.top, 20)
                .buttonStyle(PlainButtonStyle())
                .disabled(focusedIndex == nil)  // フォーカスがない場合はボタンを無効化
            }
        }
    }
    
    // CharacterView は個々のキャラクター表示を担当
    struct CharacterView: View {
        let profile: Profile
        let isFocused: Bool
        let hasBeenTapped: Bool
        let size: CGSize
        let rotationAngle: Double
        
        var body: some View {
            Image("\(profile.charaImage)_normal_1")
                .resizable()
                .scaledToFit()
                .frame(height: isFocused ? size.height * 0.3 : size.height * 0.2)
                .colorMultiply(isFocused || !hasBeenTapped ? .white : .gray)
                .rotationEffect(.degrees(rotationAngle)) // 回転を追加
                .offset(y: isFocused ? 0 : 20)
                .animation(.easeInOut(duration: 0.3), value: isFocused)
        }
    }
    
    @ViewBuilder func detailView(size: CGSize) -> some View {
        if let character = selectedCharacter {
            ZStack(alignment:.topLeading){
                Button {
                    withAnimation {
                        isDetailViewPresented.toggle()
                    }
                    soundManager.playSound(named: "se_negative")
                } label: {
                    Image("bt_back")
                        .resizable()
                        .scaledToFit()
                        .frame(width:size.width*0.05)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.all)
                .offset(x:30,y:15)
                HStack{
                    Spacer()
                    
                    ZStack{
                        Image("\(character.charaImage)_normal_1")
                            .resizable()
                            .scaledToFit()
                            .frame(height: size.height * 0.3)
                            .scaleEffect(scaleEffectValue) // スケールエフェクトを追加
                            .rotationEffect(.degrees(rotationAngle)) // 回転を追加
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: scaleEffectValue) // アニメーションの設定
                            .onAppear {
                                startScaleAnimation() // スケールアニメーションを開始
                            }
                    }
                    
                    Spacer()
                    VStack {
                        Image("bg_DetailScreen_text")
                            .resizable()
                            .frame(width: size.width * 0.4, height: size.width * 0.4)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .animation(.spring(), value: isDetailViewPresented)
                            .foregroundStyle(.bar)
                            .overlay {
                                if let character = selectedCharacter {
                                    VStack {
                                        Text(character.charaName)
                                            .font(.custom("GenJyuuGothicX-Bold", size: 40))
                                            .foregroundStyle(Color.textColor)
                                        Divider()
                                        Text(character.mainStatus)
                                            .font(.custom("GenJyuuGothicX-Bold", size: 25))
                                            .foregroundStyle(Color.textColor)
                                        Text(character.subStatus)
                                            .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                            .foregroundStyle(Color.textColor)
                                    }
                                    .frame(width: size.width*0.3)
                                }
                            }
                        Button {
                            if let character = selectedCharacter {
                                user.selectedCharacter = character.charaImage
                                user.characterName = character.charaName
                                soundManager.playSound(named: "se_positive")
                                withAnimation {
                                    isSelectedCharacter = false
                                    showFillUserName = true
                                }
                                print(user.characterName)
                            }
                        } label: {
                            Image("bt_base")
                                .resizable()
                                .scaledToFit()
                                .frame(width:size.width*0.2)
                                .overlay{
                                    Text("このキャラクターにする!")
                                        .font(.custom("GenJyuuGothicX-Bold", size: 15))
                                        .foregroundStyle(Color.buttonColor)
                                }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal,60)
                }
                .position(x:size.width*0.5,y:size.height*0.5)
            }
            .background(){
                ZStack{
                    Image("bg_AjiwaiCardView")
                        .resizable()
                        .ignoresSafeArea()
                        .frame(width:size.width,height:size.height)
                    Image("mt_border_selectView")
                        .resizable()
                        .ignoresSafeArea()
                        .frame(width:size.width*0.96,height:size.height*0.99)
                }
            }
        }
    }

    private func startWobbleAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 1.0)) {
                self.rotationAngle = 5 * sin(Date().timeIntervalSinceReferenceDate * 2) // 回転角度の計算
            }
        }
    }
    
    private func startScaleAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                self.scaleEffectValue = 1.2 // 拡大率を変更
            }
        }
    }
}
