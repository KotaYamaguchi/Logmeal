import SwiftUI

struct CharacterSelectView: View {
    @EnvironmentObject var user: UserData
    @State private var selectedCharacter: Profile? = nil
    @State private var isDetailViewPresented = false
    @Binding var isSelectedCharacter: Bool
    @State private var focusedIndex: Int? = nil
    @State private var hasBeenTapped = false
    
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
    }
    
    @ViewBuilder func selectView(size: CGSize) -> some View {
        ZStack {
            Image("bg_AjiwaiCardView")
                .resizable()
                .ignoresSafeArea()
                .frame(width: size.width, height: size.height)
            
            VStack {
                Text("キャラクターを選んでね")
                    .font(.custom("GenJyuuGothicX-Bold", size: 50))
                    .bold()
                    .foregroundStyle(.gray)
                
                HStack(spacing: size.width * 0.04) {
                    ForEach(profiles.indices, id: \.self) { index in
                        CharacterView(profile: profiles[index], isFocused: focusedIndex == index, hasBeenTapped: hasBeenTapped, size: size)
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
        
        var body: some View {
            Image("\(profile.charaImage)_normal_1")
                .resizable()
                .scaledToFit()
                .frame(height: isFocused ? size.height * 0.3 : size.height * 0.2)
                .colorMultiply(isFocused || !hasBeenTapped ? .white : .gray)
                .offset(y: isFocused ? 0 : 20)
                .animation(.easeInOut(duration: 0.3), value: isFocused)
        }
    }
    
    @ViewBuilder func detailView(size:CGSize) -> some View{
        if let character = selectedCharacter {
            ZStack(alignment:.topLeading){
                Button {
                    withAnimation {
                        isDetailViewPresented.toggle()
                    }
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
                            Image("mt_groundCircle")
                                .offset(y:100)
                            Image("\(character.charaImage)_normal_1")
                                .resizable()
                                .scaledToFit()
                                .frame(height: size.height * 0.3)
                               
                        }
                    
                    Spacer()
                    VStack {
                        Image("bg_DetailScreen_text")
                            .resizable()
                            .frame(width: size.width * 0.4, height: size.width * 0.4)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .animation(.spring, value: isDetailViewPresented)
                            .foregroundStyle(.bar)
                            .overlay {
                                if let character = selectedCharacter {
                                    VStack {
                                        Text(character.mainStatus)
                                            .font(.custom("GenJyuuGothicX-Bold", size: 30))
                                        Text(character.subStatus)
                                            .font(.custom("GenJyuuGothicX-Bold", size: 25))
                                    }
                                }
                            }
                        Button {
                            if let character = selectedCharacter {
                                user.selectedCharacter = character.charaImage
                                user.characterName = character.charaName
                            }
                            isSelectedCharacter = true
                            print(user.characterName)
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
    
}

#Preview{
    ContentView()
        .environmentObject(UserData())
}

