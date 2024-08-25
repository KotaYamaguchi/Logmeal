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
            ZStack{
                HStack{
                    HStack{
                        Text("\(user.name)")
                        Text("の")
                        Text("\(user.characterName)")
                        Text("Lv. \(user.level)")
                    }
                    .padding(.horizontal)
                    VStack(alignment:.leading,spacing: 0){
                        HStack{
                            Image("mt_exp")
                                .resizable()
                                .scaledToFit()
                                .frame(height: size.height*0.035)
                                .padding(.horizontal)
                            Text("\(user.exp) / \(user.levelTable[user.level+1])  EXP")
                            ProgressBarView()
                                .frame(width: size.width*0.2)
                        }
                        HStack{
                            Image("mt_point")
                                .resizable()
                                .scaledToFit()
                                .frame(height: size.height*0.035)
                                .padding(.horizontal)
                            Text("\(user.point)  POINT")
                        }
                    }
                }
                .background(){
                    Image("mt_statusBar_\(user.selectedCharacter)")
                        .resizable()
                        .frame(width: size.width*0.6,height: size.height*0.16)
                }
                .padding(.horizontal,size.width*0.04)
                .font(.custom("GenJyuuGothicX-Bold", size: 17))
                .foregroundStyle(fontColor)
                .onAppear(){
                    switch user.selectedCharacter{
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
            }
        }
    }
}

#Preview {
    ChildHomeView()
        .environmentObject(UserData())
}

import SwiftUI

struct ProgressBarView: View {
    @EnvironmentObject var user:UserData
   @State var nextLevelExp :Int = 0
    @State var progress:Double = 0.0
    var body: some View {
        VStack(alignment:.trailing,spacing: 0){
            VStack(alignment:.leading,spacing: 0){
//                Text("Level \(user.level)")
//                    .font(.headline)
//                
                // プログレスバー
                ProgressView(value: progress)
                    .tint(.green)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding()
                    .scaleEffect(x: 1, y: 2)
            }
//            Text("\(user.exp) / \(nextLevelExp) EXP")
//                .font(.subheadline)
        }
        .padding()
        .onAppear(){
            // 次のレベルに到達するための必要な経験値
             nextLevelExp = user.levelTable[user.level + 1]
            // 現在の経験値を元にプログレスバーの進行度を計算
             progress = Double(user.exp) / Double(nextLevelExp)
        }
    }
}

struct ProgressBarView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBarView()
            .environmentObject(UserData())
    }
}
