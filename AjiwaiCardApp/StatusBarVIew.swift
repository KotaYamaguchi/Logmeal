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
    var body: some View {
        GeometryReader{
            let size = $0.size
            HStack{
                Spacer()
                    HStack{
                        Text("Name:")
                    
                        Text(user.name)
                        
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
    }
}

#Preview {
    ChildHomeView()
        .environmentObject(UserData())
}
