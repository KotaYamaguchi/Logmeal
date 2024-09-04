import SwiftUI

struct StatusBarVIew: View {
    @EnvironmentObject var user: UserData
    @State var fontColor = Color.white
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            ZStack{
                Image("mt_statusBar_\(user.selectedCharacter)")
                    .resizable()
                    .frame(width:geometry.size.width*0.7,height: geometry.size.height*0.2)
                HStack(alignment:.center,spacing: 50){
                    HStack(alignment:.bottom){
                        Text(wrappedName())
                            .font(.custom("GenJyuuGothicX-Bold", size: 30))
                        Text("の")
                            .font(.custom("GenJyuuGothicX-Bold", size: 25))
                        Text("\(user.characterName)")
                            .font(.custom("GenJyuuGothicX-Bold", size: 25))
                        Text("Lv. \(user.level)")
                            .font(.custom("GenJyuuGothicX-Bold", size: 25))
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Image("mt_exp")
                                .resizable()
                                .scaledToFit()
                                .frame(height: size.height * 0.05)
                            HStack{
                                Text("\(user.exp) / \(user.levelTable[user.level+1])")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                Text("Exp")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 20))
                            }
                            ProgressBarView()
                                .frame(width: size.width * 0.2)
                            
                        }
                        HStack {
                            Image("mt_point")
                                .resizable()
                                .scaledToFit()
                                .frame(height: size.height * 0.05)
                            Text("\(user.point)")
                                .font(.custom("GenJyuuGothicX-Bold", size: 20))
                            Text("Point")
                                .font(.custom("GenJyuuGothicX-Bold", size: 20))
                        }
                    }
                }
                .frame(width:geometry.size.width*0.8,height: geometry.size.height*0.2)
                .onAppear {
                    print(geometry.size)
                    switch user.selectedCharacter {
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
    
    /// Function to wrap user.name after 7 Japanese characters
    private func wrappedName() -> String {
        if user.name.count > 7 {
            // Insert newline after 7 characters
            let index = user.name.index(user.name.startIndex, offsetBy: 7)
            let wrappedName = user.name[..<index] + "\n" + user.name[index...]
            return String(wrappedName)
        } else {
            return user.name
        }
    }
}

#Preview {
    StatusBarVIew()
        .environmentObject(UserData())
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
    
                // プログレスバー
                ProgressView(value: progress)
                    .tint(.green)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding()
                    .scaleEffect(x: 1, y: 2)
            }

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

