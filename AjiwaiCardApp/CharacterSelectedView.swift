//
//  CharacterSelectedView.swift
//  AjiwaiCardApp
//
//  Created by 山口昂大 on 2024/05/30.
//
import SwiftUI

struct CharacterSelectView: View {
    @EnvironmentObject var user: UserData
    @State private var selectedCharacter: Profile? = nil
    @State private var isDetailViewPresented = false
    @Binding var isSelectedCharacter:Bool
    var animals = ["Dog", "Cat", "Rabbit"]
    var profiles = [
        Profile(charaName: "レーク", charaImage: "Dog", mainStatus: "犬とトマトのハーフ", subStatus: "朝ごはんがだいすき！"),
        Profile(charaName: "ラン", charaImage: "Rabbit", mainStatus: "ウサギとニンジンのハーフ", subStatus: "お昼ごはんがだいすき！"),
        Profile(charaName: "ティナ", charaImage: "Cat", mainStatus: "猫とナスビのハーフ", subStatus: "夜ごはんがだいすき！")
    ]
    var body: some View {
            GeometryReader { geometry in
                let size = geometry.size
                if !isDetailViewPresented{
                    ZStack{
                        VStack{
                            Text("キャラクターを選んでね")
                                .font(.system(size: 60))
                                .bold()
                                .foregroundStyle(.gray)
                            HStack(spacing: size.width * 0.04) {
                                ForEach(profiles) { profile in
                                    Image("\(profile.charaImage)_normal_1")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 250)
                                        .onTapGesture {
                                            withAnimation {
                                                isDetailViewPresented.toggle()
                                            }
                                            selectedCharacter = profile
                                        }
                                        
                                }
                            }
                        }
                        .position(x:geometry.size.width*0.5,y:geometry.size.height*0.5)
                        .background(){
                            Image("bg_AjiwaiCardView")
                                .resizable()
                                .ignoresSafeArea()
                                .frame(width:geometry.size.width,height: geometry.size.height)
                        }
                        
                    }
                } else {
                    if let character = selectedCharacter {
                        ZStack(alignment:.topLeading){
                            Button {
                                isDetailViewPresented.toggle()
                            } label: {
                                Image("bt_back")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width:geometry.size.width*0.05)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.all)
                            HStack{
                                Spacer()
                                if character.charaImage == "Cat" || character.charaImage == "Dog"{
                                    Image("\(character.charaImage)_normal_1")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: size.height * 0.3)
                                }else{
                                    Image("\(character.charaImage)_normal_1")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: size.height * 0.4)
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
                                                        .font(.title)
                                                    Text(character.subStatus)
                                                        .font(.callout)
                                                }
                                            }
                                        }
                                    Button {
                                        if let character = selectedCharacter {
                                            user.selectedCharactar = character.charaImage
                                        }
                                        isSelectedCharacter = true
                                        print(user.selectedCharactar)
                                    } label: {
                                        Image("bt_done")
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                Spacer()
                            }
                            .position(x:geometry.size.width*0.5,y:geometry.size.height*0.5)
                        }
                        .background(){
                            Image("bg_AjiwaiCardView")
                                .resizable()
                                .ignoresSafeArea()
                                .frame(width:geometry.size.width,height: geometry.size.height)
                        }
                    }
                }
            }
        //}
    }
}

#Preview{
    ChildHomeView()
        .environmentObject(UserData())
}
extension Animation {
  static let easeOutExpo: Animation = .timingCurve(0.25, 0.8, 0.1, 1, duration: 0.5) // 秘伝のタレ
}
