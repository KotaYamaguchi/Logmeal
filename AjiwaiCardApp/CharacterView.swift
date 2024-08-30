import SwiftUI
import SwiftyGif


struct CharacterView: View {
    @EnvironmentObject var user:UserData
    @Environment(\.dismiss) private var dismiss
    @State private var showModal:Bool = false
    private let soundManager:SoundManager = SoundManager()
    @AppStorage("hasSeenCharacterViewTutorial") private var hasSeenTutorial = false
    @State private var showHowToUseView = false
    func setBackGround() -> String{
        switch user.selectedCharacter{
        case "Dog":
            switch user.growthStage {
            case 1:
                return "characterView_Dog1"
            case 2:
                return "characterView_Dog2"
            case 3:
                return "characterView_Dog3"
            default:
                return "characterView_Dog1"
            }
        case "Cat":
            switch user.growthStage {
            case 1:
                return "characterView_Cat1"
            case 2:
                return "characterView_Cat2"
            case 3:
                return "characterView_Cat3"
            default:
                return "characterView_Cat1"
            }
        case "Rabbit":
            switch user.growthStage {
            case 1:
                return "characterView_Rabbit1"
            case 2:
                return "characterView_Rabbit2"
            case 3:
                return "characterView_Rabbit3"
            default:
                return "characterView_Rabbit"
            }
        default:
            return "characterView_Dog1"
        }
    }
    var body: some View {
        GeometryReader{ geometry in
            ZStack(alignment:.top){
                imageView(geometry:geometry)
                buttonView(geometry: geometry)
            }
            .sheet(isPresented:$showModal){
                
            }
            .sheet(isPresented:$showHowToUseView){
                TutorialView(imageArray: ["HowToUseCharacter"])
                    .interactiveDismissDisabled()
                    .onDisappear(){
                        hasSeenTutorial = true
                    }
            }
            .onAppear {
                if !hasSeenTutorial {
                    showHowToUseView = true
                }
            }

        }
    }
    private func imageView(geometry:GeometryProxy) -> some View{
        Image(setBackGround())
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
            .frame(width:geometry.size.width,height:geometry.size.height)
            .position(x:geometry.size.width*0.45,y:geometry.size.height*0.5)
    }
    private func buttonView(geometry:GeometryProxy) -> some View{
        HStack{
            Button{
                dismiss()
                soundManager.playSound(named: "se_negative")
            }label: {
                Image("bt_back")
                    .resizable()
                    .frame(width:50,height: 50)
            }
            .buttonStyle(PlainButtonStyle())
            Spacer()
            Button{
                showModal = true
                soundManager.playSound(named: "se_positive")
            }label: {
                Image("bt_description")
                    .resizable()
                    .frame(width:50,height: 50)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal)
    }
}

#Preview {
    CharacterView()
        .environmentObject(UserData())
}
