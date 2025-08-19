import SwiftUI
import SwiftData

// MARK: - Main Detail View
struct NewCharacterDetailView: View {
    @Query private var characters: [Character]
    @Environment(\.modelContext) private var context
    @State private var selectedTab: CharacterType = .dog
    @EnvironmentObject var userData: UserData

    @State private var showConfirm = false
    @State private var confirmTarget: Character? = nil
    @State private var confirmType: CharacterType? = nil

    var body: some View {
        ZStack {
            // 動的背景画像
            CharacterDetailBackground(selected: selectedTab)
                .environmentObject(userData)
                .ignoresSafeArea()

            VStack {
                CharacterTabSelector(selectedTab: $selectedTab)
                    .padding(.top, 20)

                Spacer()

                CharacterDetailContent(selected: selectedTab, onRequestSwitch: { type, character in
                    confirmType = type
                    confirmTarget = character
                    showConfirm = true
                })
                .environmentObject(userData)
                .padding(.bottom, 20)
            }

            if showConfirm, let target = confirmTarget, let _ = confirmType {
                CharacterSwitchConfirmView(
                    current: characters.first(where: {$0.isSelected})!,
                    target: target,
                    onConfirm: {
                        let status = userData.canSwitchCharacter(currentharacter: characters.first(where: {$0.isSelected})!)
                        if status == .success{
                            userData.switchCharacter(current: characters.first(where: {$0.isSelected})!, to: target.name, array: characters, context: context)
                            showConfirm = false
                        }else{
                            print("キャラクターの切り替えに失敗しました。成長段階が3ではありません。")
                        }
                    },
                    onCancel: {
                        showConfirm = false
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.4).ignoresSafeArea())
            }
        }
    }
}

// MARK: - Character Types
enum CharacterType: Int, CaseIterable, Identifiable {
    case dog, rabbit, cat
    var id: Int { rawValue }
    var rawValueString: String {
        switch self {
        case .dog: return "Dog"
        case .rabbit: return "Rabbit"
        case .cat: return "Cat"
        }
    }
    var iconName: String {
        switch self {
        case .dog: return "Dog_normal_1"
        case .rabbit: return "Rabbit_normal_1"
        case .cat: return "Cat_normal_1"
        }
    }
    var displayName: String {
        switch self {
        case .dog: return "犬"
        case .rabbit: return "うさぎ"
        case .cat: return "ねこ"
        }
    }
}

// MARK: - Dynamic Background
private struct CharacterDetailBackground: View {
    @Query private var characters: [Character]
    @EnvironmentObject var userData: UserData
    let selected: CharacterType

    var body: some View {
        Image(backgroundImageName)
            .resizable()
    }

    private var backgroundImageName: String {
        switch selected {
        case .dog:
            return "characterDetail_Dog\(characters.first(where: {$0.name == "Dog"})!.growthStage)"
        case .rabbit:
            return "characterDetail_Rabbit\(characters.first(where: {$0.name == "Rabbit"})!.growthStage)"
        case .cat:
            return "characterDetail_Cat\(characters.first(where: {$0.name == "Cat"})!.growthStage)"
        }
    }
}

// MARK: - Tab Selector
private struct CharacterTabSelector: View {
    @Binding var selectedTab: CharacterType

    var body: some View {
        RoundedRectangle(cornerRadius: 50)
            .foregroundStyle(.white)
            .frame(width: 280, height: 90)
            .overlay(
                RoundedRectangle(cornerRadius: 50)
                    .stroke(Color.gray, lineWidth: 3)
            )
            .overlay(
                HStack(spacing: 16) {
                    ForEach(CharacterType.allCases) { type in
                        Button(action: {
                            withAnimation {
                                selectedTab = type
                            }
                        }) {
                            Image(type.iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: selectedTab == type ? 70 : 60)
                                .colorMultiply(selectedTab == type ? .white : .gray)
                        }
                    }
                }
            )
    }
}

// MARK: - Detail Content Switcher
private struct CharacterDetailContent: View {
    @EnvironmentObject var userData: UserData
    let selected: CharacterType
    let onRequestSwitch: (CharacterType, Character) -> Void

    var body: some View {
        switch selected {
        case .dog:
            DogDetailView(onRequestSwitch: onRequestSwitch)
        case .rabbit:
            RabbitDetailView(onRequestSwitch: onRequestSwitch)
        case .cat:
            CatDetailView(onRequestSwitch: onRequestSwitch)
        }
    }
}

// MARK: - Individual Detail Views

/// DogDetailView: currentCharacter.growthStage == 3 のときのみ切り替え可能
private struct DogDetailView: View {
    @Query private var characters: [Character]
    @EnvironmentObject var userData: UserData
    let onRequestSwitch: (CharacterType, Character) -> Void

    var body: some View {
        if characters.first(where: {$0.isSelected})!.name == "Dog" {
            // すでにDogが選択中
            DisabledButton(title: "選択中")
        } else {
            // 現在のキャラが成長段階3なら切り替え可能
            if characters.first(where: {$0.isSelected})!.growthStage == 3 {
                SelectButton(title: "このキャラにする！") {
                    onRequestSwitch(.dog, characters.first(where: {$0.name == "Dog"})!)
                }
            } else {
                DisabledButton(title: "選択不可")
            }
        }
    }
}

/// RabbitDetailView: currentCharacter.growthStage == 3 のときのみ切り替え可能
private struct RabbitDetailView: View {
    @EnvironmentObject var userData: UserData
    let onRequestSwitch: (CharacterType, Character) -> Void
    @Query private var characters: [Character]
    var body: some View {
        VStack(spacing: 24) {
           
            if characters.first(where: {$0.isSelected})!.name == "Rabbit"  {
                DisabledButton(title: "選択中")
            } else {
                if characters.first(where: {$0.isSelected})!.growthStage == 3 {
                    SelectButton(title: "このキャラにする！") {
                        onRequestSwitch(.rabbit, characters.first(where: {$0.name == "Rabbit"})!)
                    }
                } else {
                    DisabledButton(title: "選択不可")
                }
            }
        }
    }
}

/// CatDetailView: currentCharacter.growthStage == 3 のときのみ切り替え可能
private struct CatDetailView: View {
    @EnvironmentObject var userData: UserData
    let onRequestSwitch: (CharacterType, Character) -> Void
    @Query private var characters: [Character]
    var body: some View {
        VStack(spacing: 24) {
    

            if characters.first(where: {$0.isSelected})!.name == "Cat"  {
                DisabledButton(title: "選択中")
            } else {
                if characters.first(where: {$0.isSelected})!.growthStage == 3 {
                    SelectButton(title: "このキャラにする！") {
                        onRequestSwitch(.cat, characters.first(where: {$0.name == "Cat"})!)
                    }
                } else {
                    DisabledButton(title: "選択不可")
                }
            }
        }
    }
}

// MARK: - Shared Buttons
private struct SelectButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
                    Text(title)
                        .foregroundColor(.white)
                        .font(.custom("GenJyuuGothicX-Bold", size: 40))
                        .padding(.horizontal)
                        .background(){
                            RoundedRectangle(cornerRadius: 50)
                                .frame(width:500, height: 80)
                                .foregroundStyle(.green)
                        }
        }
    }
}

private struct DisabledButton: View {
    let title: String

    var body: some View {
        RoundedRectangle(cornerRadius: 50)
            .frame(width: 300, height: 80)
            .foregroundStyle(.gray)
            .overlay(
                Text(title)
                    .foregroundColor(.white)
                    .font(.custom("GenJyuuGothicX-Bold", size: 40))
            )
    }
}

// MARK: - 仮・キャラクター切り替え確認View
private struct CharacterSwitchConfirmView: View {
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
