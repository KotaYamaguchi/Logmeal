import SwiftUI

struct CharacterSelectView: View {
    @EnvironmentObject var user: UserData
    @State private var selectedCharacter: Profile? = nil
    @State private var isDetailViewPresented = false
    @Binding var isSelectedCharacter: Bool
    @State private var focusedIndex: Int? = nil
    @State private var hasBeenTapped = false
    private let soundManager = SoundManager.shared
    @State private var scaleEffectValue: CGFloat = 1.0
    @State private var showAlert = false // State to control the alert
    @Environment(\.dismiss) private var dismiss
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
            startScaleAnimation()
        }
        .alert(isPresented: $showAlert) { // Alert for prompting user to select a character
            Alert(
                title: Text("キャラクターを選択してください"),
                message: Text("キャラクターを選んでからボタンを押してください。"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    @ViewBuilder func selectView(size: CGSize) -> some View {
        ZStack(alignment:.topLeading){
            Image("bg_AjiwaiCardView")
                .resizable()
                .ignoresSafeArea()
                .frame(width: size.width, height: size.height)
            Button {
               dismiss()
            } label: {
                Image("bt_back")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            }
            .buttonStyle(PlainButtonStyle())
            .padding()
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
                        DisplayView(profile: profiles[index], isFocused: focusedIndex == index, hasBeenTapped: hasBeenTapped, size: size)
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
                    } else {
                        showAlert = true // Show alert if no character is selected
                    }
                } label: {
                    Image("bt_base")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 100)
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
                .opacity(focusedIndex == nil ? 0.5 : 1.0) // Dim the button if no character is selected
            }
            .position(x:size.width*0.5,y:size.height*0.5)
        }
    }
    
    struct DisplayView: View {
        let profile: Profile
        let isFocused: Bool
        let hasBeenTapped: Bool
        let size: CGSize
        @State private var rotationAngle: Double = 0
        @State private var wobbleSpeed: Double = Double.random(in: 1.0...3.0)
        @State private var wobbleOffset: Double = Double.random(in: 0...2 * .pi)
        
        var body: some View {
            Image("\(profile.charaImage)_normal_1")
                .resizable()
                .scaledToFit()
                .frame(height: isFocused ? size.height * 0.3 : size.height * 0.2)
                .colorMultiply(isFocused || !hasBeenTapped ? .white : .gray)
                .rotationEffect(.degrees(rotationAngle))
                .offset(y: isFocused ? 0 : 20)
                .animation(.easeInOut(duration: 0.3), value: isFocused)
                .onAppear {
                    startWobbleAnimation()
                }
        }
        
        private func startWobbleAnimation() {
            Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 1.0)) {
                    self.rotationAngle = 5 * sin(Date().timeIntervalSinceReferenceDate * wobbleSpeed + wobbleOffset)
                }
            }
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
                            .scaleEffect(scaleEffectValue)
                            .rotationEffect(.degrees(5 * sin(Date().timeIntervalSinceReferenceDate * 2)))
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: scaleEffectValue)
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
                                user.resetAllCharacterData()
                                if user.DogData.name == character.charaImage{
                                    user.selectedCharacter = character.charaImage
                                    user.inTrainingCharactar = character.charaImage
                                    user.DogData.growthStage = 1
                                } else if user.RabbitData.name == character.charaImage {
                                    user.selectedCharacter = character.charaImage
                                    user.RabbitData.growthStage = 1
                                    user.selectedCharacter = character.charaImage
                                    user.inTrainingCharactar = character.charaImage
                                } else if user.CatData.name == character.charaImage {
                                    user.selectedCharacter = character.charaImage
                                    user.CatData.growthStage = 1
                                    user.selectedCharacter = character.charaImage
                                    user.inTrainingCharactar = character.charaImage
                                }
                                user.characterName = character.charaName
                                
                                user.saveCharacterData(data:user.DogData, key: "DogData")
                                user.saveCharacterData(data:user.RabbitData, key: "RabbitData")
                                user.saveCharacterData(data:user.CatData, key: "CatData")
                                soundManager.playSound(named: "se_positive")
                                withAnimation {
                                    isSelectedCharacter = false
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
//                    Image("mt_border_selectView")
//                        .resizable()
//                        .ignoresSafeArea()
//                        .frame(width:size.width*0.96,height:size.height*0.99)
                }
            }
        }
    }

    private func startScaleAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                self.scaleEffectValue = 1.2
            }
        }
    }
}



#Preview {
    CharacterSelectView(isSelectedCharacter: .constant(false)).detailView(size: CGSize(width: 800, height: 600))
        .environmentObject(UserData())
}
