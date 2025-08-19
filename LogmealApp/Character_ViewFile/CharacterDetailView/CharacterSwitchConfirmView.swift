import SwiftUI

// MARK: - 仮・キャラクター切り替え確認View
struct CharacterSwitchConfirmView: View {
    let current: Character
    let target: Character
    let onConfirm: () -> Void
    let onCancel: () -> Void
    let screenSize:CGSize = UIScreen.main.bounds.size
    var currentImageName: String {
        switch current.name {
        case "Dog":
            return "img_dog_question"
        case "Rabbit":
            return "img_rabbit_question"
        case "Cat":
            return "img_cat_question"
        default:
            return "img_default_question"
        }
    }
    var targetImageName: String {
        switch target.name {
        case "Dog":
            switch target.growthStage {
            case 1:
                return "Dog1_characterDetail_black"
            case 2:
                return "Dog2_characterDetail_black"
            case 3:
                return "Dog3_characterDetail_black"
            default:
                return "Dog1_characterDetail_black"
            }
        case "Cat":
            switch target.growthStage {
            case 1:
                return "Cat1_characterDetail_black"
            case 2:
                return "Cat2_characterDetail_black"
            case 3:
                return "Cat3_characterDetail_1"
            default:
                return "Cat1_characterDetail_black"
            }
        case "Rabbit":
            switch target.growthStage {
            case 1:
                return "Rabbit1_characterDetail_black"
            case 2:
                return "Rabbit2_characterDetail_black"
            case 3:
                return "Rabbit3_characterDetail_1"
            default:
                return "Rabbit1_characterDetail_black"
            }
        default:
            return "Rabbit1_characterDetail_black"
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text("キャラクターを変える？\n変えると次のキャラクターを育て終わるまで変えられないよ!")
                .font(.custom("GenJyuuGothicX-Bold", size: 30))
            HStack(spacing: 32) {
                VStack {
                    Image(currentImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                    Text("違う子を育てる？")
                        .font(.custom("GenJyuuGothicX-Bold", size: 20))
                        .foregroundColor(.gray)
                }
                Image(systemName: "arrow.right")
                    .font(.largeTitle)
                VStack {
                    Image(targetImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                    Text("これからよろしくね！")
                        .font(.custom("GenJyuuGothicX-Bold", size: 20))
                        .foregroundColor(.gray)
                }
            }
            HStack(spacing: 32) {
                Button("キャンセル", action: onCancel)
                    .font(.custom("GenJyuuGothicX-Bold", size: 20))
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                Button("切り替える", action: onConfirm)
                    .font(.custom("GenJyuuGothicX-Bold", size: 20))
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .frame(width: screenSize.width * 0.8, height: screenSize.height * 0.6)
        .padding()
        .background(Color.white)
        .cornerRadius(24)
        .shadow(radius: 10)
    }
}
