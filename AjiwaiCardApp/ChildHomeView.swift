
import SwiftUI

struct ChildHomeView: View {
    @EnvironmentObject var user:UserData
    @ObservedObject var counterManager = CounterManager()
    @State var isShowShareSheet:Bool = false
    @State var progressValue:CGFloat = 0.1
    @State var width:CGFloat = 300
    @State var showColumn = false
    @State var gifData = NSDataAsset(name: "Rabbit_animation_breath")?.data
    @State var gifArray = ["Rabbit_animation_breath","Rabbit_animation_bow","Rabbit_animation_question","Rabbit_animation_sleep","Rabbit_animation_surprised","Rabbit_animation_yell"]
    @State var playGif = true
    private func changeGifData(){
        switch user.growthStage{
        case 1:
            switch user.selectedCharactar{
            case "Dog":
                gifData = NSDataAsset(name: "Dog_animation_breath")?.data
                gifArray = ["Dog_animation_breath",
                            "Dog_animation_bow",
                            "Dog_animation_question",
                            "Dog_animation_sleep",
                            "Dog_animation_surprised",
                            "Dog_animation_yell",
                            "Dog_animation_byebye",
                            "Dog_animation_crap",
                            "Dog_animation_eat",
                            "Dog_animation_yawn"]
            case "Cat":
                gifData = NSDataAsset(name: "Cat_animation_breath")?.data
                gifArray = ["Cat_animation_breath",
                            "Cat_animation_bow",
                            "Cat_animation_question",
                            "Cat_animation_sleep",
                            "Cat_animation_surprised",
                            "Cat_animation_yell"]
            case "Rabbit":
                gifData = NSDataAsset(name: "Rabbit1_animation_breath")?.data
                gifArray = ["Rabbit1_animation_breath",
                            "Rabbit1_animation_sleep"]
            default:
                gifArray = []
            }
        case 2:
            switch user.selectedCharactar{
            case "Dog":
                gifData = NSDataAsset(name: "Dog_animation_breath")?.data
                gifArray = ["Dog_animation_breath",
                            "Dog_animation_bow",
                            "Dog_animation_question",
                            "Dog_animation_sleep",
                            "Dog_animation_surprised",
                            "Dog_animation_yell",
                            "Dog_animation_byebye",
                            "Dog_animation_crap",
                            "Dog_animation_eat",
                            "Dog_animation_yawn"]
            case "Cat":
                gifData = NSDataAsset(name: "Cat_animation_breath")?.data
                gifArray = ["Cat_animation_breath",
                            "Cat_animation_bow",
                            "Cat_animation_question",
                            "Cat_animation_sleep",
                            "Cat_animation_surprised",
                            "Cat_animation_yell"]
            case "Rabbit":
                gifData = NSDataAsset(name: "Rabbit2_animation_breath")?.data
                gifArray = ["Rabbit2_animation_breath",
                            "Rabbit2_animation_sleep"]
            default:
                gifArray = []
            }
        case 3:
            switch user.selectedCharactar{
            case "Dog":
                gifData = NSDataAsset(name: "Dog_animation_breath")?.data
                gifArray = ["Dog_animation_breath",
                            "Dog_animation_bow",
                            "Dog_animation_question",
                            "Dog_animation_sleep",
                            "Dog_animation_surprised",
                            "Dog_animation_yell",
                            "Dog_animation_byebye",
                            "Dog_animation_crap",
                            "Dog_animation_eat",
                            "Dog_animation_yawn"]
            case "Cat":
                gifData = NSDataAsset(name: "Cat_animation_breath")?.data
                gifArray = ["Cat_animation_breath",
                            "Cat_animation_bow",
                            "Cat_animation_question",
                            "Cat_animation_sleep",
                            "Cat_animation_surprised",
                            "Cat_animation_yell"]
            case "Rabbit":
                gifData = NSDataAsset(name: "Rabbit_animation_breath")?.data
                gifArray = ["Rabbit_animation_breath",
                            "Rabbit_animation_bow",
                            "Rabbit_animation_question",
                            "Rabbit_animation_sleep",
                            "Rabbit_animation_surprised",
                            "Rabbit_animation_yell",
                            "Rabbit_animation_applause",
                            "Rabbit_animation_breath",
                            "Rabbit_animation_eat",
                            "Rabbit_animation_sit",
                            "Rabbit_animation_yawn"]
            default:
                gifArray = []
            }
        default:
            gifData = nil
            gifArray = []
        }
    }
    var body: some View {
        GeometryReader { geometry in
            if user.isLogined {
                ZStack {
                    childHome(size: geometry.size)
                        .navigationBarHidden(true)
                    if showColumn{
                        Color.gray
                            .opacity(0.7)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation {
                                    showColumn = false
                                    counterManager.incrementCount()
                                }
                            }
                    }
                    ColumnView()
                        .frame(width:700,height: 500)
                        .position(showColumn ? CGPoint(x:geometry.size.width*0.5,y:geometry.size.height*0.5) : CGPoint(x:geometry.size.width*0.5,y:geometry.size.height*2))
                }
            } else {
                FirstLoginView()
            }
        }
        .onChange(of: user.exp) { _, _ in
            user.checkLevel()
            user.growth()
        }
        
        .onAppear(){
            changeGifData()
        }
        .onChange(of: user.selectedCharactar) { oldValue, newValue in
            changeGifData()
        }
    }
    
    @ViewBuilder func childHome(size: CGSize) -> some View {
        NavigationStack(path:$user.path){
            ZStack {
                Image("bg_\(user.selectedCharactar)")
                    .resizable()
                    .frame(width: size.width)
                    .ignoresSafeArea(.all)
                
                    if let gifData = gifData {
                        GIFImage(data: gifData, playGif: $playGif){
                            print("GIF animation finished!")
                        }
                        .frame(width: size.width * 0.5)
                        .onTapGesture {
                            self.gifData = NSDataAsset(name: gifArray.randomElement()!)?.data
                        }
                        .position(x:size.width*0.45,y:size.height*0.65)
                    }
                
                NavigationLink
                {
                    ShopView()
                        .navigationBarBackButtonHidden(true)
                }label: {
                    Image("bt_HomeVIew_\(user.selectedCharactar)_2")
                        .resizable()
                        .scaledToFit()
                        .shadow(radius: 5, y: 20)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: size.width * 0.0884, height: size.height * 0.2333)
                .position(x: size.width * 0.67, y: size.height * 0.72)
                .disabled(user.growthStage < 3)
                NavigationLink
                {
                    CharacterView()
                        .navigationBarBackButtonHidden(true)
                }label: {
                    Image("bt_HomeVIew_\(user.selectedCharactar)_3")
                        .resizable()
                        .scaledToFit()
                    
                        .shadow(radius: 5, y: 20)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: size.width * 0.0884, height: size.height * 0.2333)
                .position(x: size.width * 0.735, y: size.height * 0.60)
                NavigationLink
                {
                    LookBackView()
                        .navigationBarBackButtonHidden(true)
                }label: {
                    Image("bt_HomeVIew_\(user.selectedCharactar)_4")
                        .resizable()
                        .scaledToFit()
                    
                        .shadow(radius: 5, y: 20)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: size.width * 0.0884, height: size.height * 0.2333)
                .position(x: size.width * 0.84, y: size.height * 0.575)
                NavigationLink
                {
                    ColumnListView()
                }label: {
                    Image("bt_HomeVIew_\(user.selectedCharactar)_5")
                        .resizable()
                        .scaledToFit()
                        .shadow(radius: 5, y: 20)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: size.width * 0.0884, height: size.height * 0.2333)
                .position(x: size.width * 0.91, y: size.height * 0.69)
                Button
                {
                    user.path.append(.ajiwaiCard)
                }label: {
                    Image("bt_HomeVIew_\(user.selectedCharactar)_1")
                        .resizable()
                        .scaledToFit()
                        .shadow(radius: 5, y: 20)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: size.width * 0.1764, height: size.height * 0.3672)
                .position(x: size.width * 0.798, y: size.height * 0.752)
                StatusBarVIew()
                    .position(x:size.width*0.54,y:size.height*0.52)
                VStack {
                    NavigationLink{
                        SettingView()
                    }label: {
                        Image("bt_gear")
                            .resizable()
                            .scaledToFit()
                        .shadow(radius: 5,x:5,y:10)
                    }
                    .padding(.bottom)
                    Button{
                        withAnimation {
                            showColumn = true
                        }
                        
                    }label: {
                
                        if counterManager.count >= 1 || user.monthlyColumnTitle != [:]{
                            Image("mt_columnIcon_circle_1")
                                .resizable()
                                .frame(width: 90,height: 90)
                                .shadow(radius: 5,x:5,y:10)
                        }else{
                            Image("mt_columnIcon_circle_2")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 90)
                                .shadow(radius: 5,x:5,y:10)
                        }
                    }
                }
                .frame(width: size.width * 0.08)
                .position(x: size.width * 0.9, y: size.height * 0.15)
                .buttonStyle(PlainButtonStyle())
            }
            .navigationDestination(for: Homepath.self) { value in
                switch value {
                case .home:
                    ChildHomeView()
                        .navigationBarBackButtonHidden(true)
                case .ajiwaiCard:
                    WritingAjiwaiCardView()
                        .navigationBarBackButtonHidden(true)
                case .reward:
                    AjiwaiThirdView()
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}
struct ChildHomeView_Previews: PreviewProvider {
    static var previews: some View {
        let user = UserData()
        ChildHomeView()
            .environmentObject(user)
    }
}
