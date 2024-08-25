
import SwiftUI
import SwiftData
struct ContentView: View {
    //App内全体で共有する変数
    @EnvironmentObject var user:UserData

    var body: some View {
        NavigationStack(path:$user.path){
            GeometryReader{ geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                ZStack(alignment:.topLeading){
                    Image("bg_TitleView")
                        .resizable()
                        .ignoresSafeArea()
                        .scaledToFill()
                        .frame(width:geometry.size.width*1.05,height: geometry.size.height)
                        .position(x:geometry.size.width*0.5,y:geometry.size.height*0.5)
                        .onTapGesture {
                            user.path.append(.home)
                        }
                    Text("画面をタップしてゲームを始めよう")
                        .font(.custom("GenJyuuGothicX-Bold", size: 20))
                        .foregroundStyle(.gray)
                        .padding(.top, 30)
                        .position(x: width * 0.5, y: height * 0.8)
                    Button{
                        UserDefaults.standard.removeObject(forKey: "isLogined")
                    }label: {
                        Text("もう一度、初めてログイン画面にする")
                            .font(.custom("GenJyuuGothicX-Bold", size: 15))
                            .frame(width: 350,height: 50)
                            .background(Color.cyan)
                            .foregroundStyle(Color.white)
                            .cornerRadius(20)
                        
                    }
                    .buttonStyle(PlainButtonStyle())
                }//Zstack
            }//GeometryReader
            .navigationDestination(for: Homepath.self) { value in
                switch value {
                    case .home:
                        ChildHomeView()
                            .navigationBarBackButtonHidden(true)
                    case .ajiwaiCard:
                        WritingAjiwaiCardView(saveDay:Date.now)
                            .navigationBarBackButtonHidden(true)
                    case .reward:
                        RewardView()
                            .navigationBarBackButtonHidden(true)
                    }
                }
        }
        //NavifationStack
    }//body

}//View

#Preview {
    ContentView()
        .environmentObject(UserData())
}

