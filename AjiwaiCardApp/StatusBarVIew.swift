//
//  StatusBarVIew.swift
//  AjiwaiCardApp
//
//  Created by 山口昂大 on 2024/05/09.
//

import SwiftUI

struct StatusBarVIew: View {
    @EnvironmentObject var user:UserData
    @State var fontColor = Color.white
    @State private var characterName:String = ""
    
    var body: some View {
        GeometryReader{
            let size = $0.size
            HStack{
                Spacer()
                    HStack{
                    
                        Text(user.name)
                        Text("の\(characterName)")
                        Text("Lv.\(user.level)")
    
                    }
                    Spacer()
                    VStack{
                        Text("exp")
                        Text("point")
                    }
                    VStack{
                        Text("：")
                        Text("：")
                    }
                    VStack{
                        Text("\(user.exp)")
                        Text("\(user.point)")
                    }
                    .padding(.horizontal)
                    Spacer()
                }
            .font(.custom("GenJyuuGothicX-Bold", size: 17))
                .foregroundStyle(fontColor)
                .frame(width: size.width*0.5)
                .onAppear(){
                    switch user.selectedCharactar{
                    case "Dog":
                        fontColor = .white
                    case "Cat":
                        fontColor = .black
                    case "Rabbit":
                        fontColor = .black
                    default:
                        fontColor = .white
                    }
                }
                .background(){
                    Image("mt_statusBar_\(user.selectedCharactar)")
                        .resizable()
                        .frame(width:size.width*0.5,height: size.height*0.1)
            }
        }
        .onAppear(){
            switch user.selectedCharactar{
            case "Dog" :
                characterName = "レーク"
                
            case "Cat" :
                characterName = "ティナ"

            case "Rabbit" :
                characterName = "ラン"

            default:
                break
            }
        }
    }
}

#Preview {
    ChildHomeView()
        .environmentObject(UserData())
}
