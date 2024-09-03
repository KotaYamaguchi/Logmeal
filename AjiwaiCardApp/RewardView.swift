import SwiftUI
import ConfettiSwiftUI

struct RewardView: View {
    @EnvironmentObject var user: UserData
    @State private var showBaseLevelUpView = false
    @State private var showBaseAnimationView = false
    @State private var showNormalCharacterView = false
    @State private var showTextCompleted = false
    @State private var scaleFlag = false
    @State private var counter = 0
    private let soundManager = SoundManager.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundView(geometry: geometry)
                animationView(geometry: geometry)
                confettiView(geometry: geometry)
                navigationButton(geometry: geometry)
            }
            .onAppear(){
                handleOnAppear()
            }
        }
    }
    private func getFirstGifName() -> String {
        switch user.growthStage {
        case 2:
            return "\(user.selectedCharacter)1_animation_breath"
        case 3:
            return "\(user.selectedCharacter)2_animation_breath"
        default:
            return "\(user.selectedCharacter)\(user.growthStage)_animation_breath"
        }
    }
    
    private func getSecondGifName() -> String {
        switch user.growthStage {
        case 2:
            return "\(user.selectedCharacter)2_animation_breath"
        case 3:
            return "\(user.selectedCharacter)3_animation_breath"
        default:
            return "\(user.selectedCharacter)\(user.growthStage)_animation_breath"
        }
    }
    
    private func handleOnAppear() {
        counter += 1
        let levelUp = user.checkLevel()
        let growth = user.growth()
        
        if growth {
            showBaseAnimationView = true
        } else if levelUp {
            showBaseLevelUpView = true
        } else {
            showNormalCharacterView = true
        }
        
        // TypeWriterTextView の表示が終わった後の処理
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            showTextCompleted = true
        }
    }
    private func animationView(geometry: GeometryProxy) -> some View{
        ZStack{
            if showBaseAnimationView {
                BaseAnimationView(
                    firstGifName: getFirstGifName(),
                    secondGifName: getSecondGifName(),
                    text1: "おや、\(user.characterName)のようすが…",
                    text2: "おめでとう！\(user.characterName)が進化したよ！",
                    useBackGroundColor: true
                )
            } else if showBaseLevelUpView {
                BaseLevelUpView(
                    characterGifName: "\(user.selectedCharacter)\(user.growthStage)_animation_breath",
                    text: "\(user.characterName)がレベルアップしたよ！",
                    backgroundImage: "mt_RewardView_callout_\(user.selectedCharacter)",
                    useBackGroundColor: false
                )
            } else if showNormalCharacterView {
                NormalCharacterView(
                    characterGifName: "\(user.selectedCharacter)\(user.growthStage)_animation_breath",
                    text: "今日も記録してくれてありがとう！",
                    backgroundImage: "mt_RewardView_callout_\(user.selectedCharacter)",
                    useBackGroundColor: false
                )
            }
        }
    }
    private func backgroundView(geometry: GeometryProxy) -> some View {
        ZStack {
            Image("bg_RewardView")
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
        }
    }
    private func navigationButton(geometry: GeometryProxy) -> some View {
        Button {
            user.isDataSaved = false // フラグをリセット
            user.path.removeAll()
            user.path.append(.home)
            soundManager.playSound(named: "se_negative")
            
        } label: {
            Image("bt_backHome")
                .resizable()
                .scaledToFit()
                .frame(width: geometry.size.width * 0.15)
                .shadow(radius: 10)
        }
        .position(x: geometry.size.width * 0.93, y: geometry.size.height * 0.98)
        .buttonStyle(PlainButtonStyle())
    }
    
    private func confettiView(geometry: GeometryProxy) -> some View {
        HStack {
            confettiCannonView(imageName: "mt_cracker", scaleFlag: $scaleFlag, counter: $counter, rotation: .degrees(60), openingAngle: .degrees(0), closingAngle: .degrees(90))
            Spacer().frame(width: geometry.size.width * 0.75)
            confettiCannonView(imageName: "mt_cracker", scaleFlag: $scaleFlag, counter: $counter, rotation: .zero, openingAngle: .degrees(90), closingAngle: .degrees(180))
        }
        .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.9)
    }

    private func confettiCannonView(imageName: String, scaleFlag: Binding<Bool>, counter: Binding<Int>, rotation: Angle, openingAngle: Angle, closingAngle: Angle) -> some View {
        Image(imageName)
            .scaleEffect(scaleFlag.wrappedValue ? 0.2 : 1)
            .rotationEffect(rotation)
            .confettiCannon(counter: counter, num: 50, confettiSize: 10, rainHeight: 100, fadesOut: true, openingAngle: openingAngle, closingAngle: closingAngle, radius: 800)
    }

}

#Preview {
    RewardView()
        .environmentObject(UserData())
}





