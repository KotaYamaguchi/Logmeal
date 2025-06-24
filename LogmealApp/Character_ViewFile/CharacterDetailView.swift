import SwiftUI

// MARK: - Main Detail View
struct NewCharacterDetailView: View {
    @State private var selectedTab: CharacterType = .dog
    @EnvironmentObject var userData: UserData

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

                CharacterDetailContent(selected: selectedTab)
                    .environmentObject(userData)

                Spacer()
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
    @EnvironmentObject var userData: UserData
    let selected: CharacterType

    var body: some View {
        Image(backgroundImageName)
            .resizable()
    }

    private var backgroundImageName: String {
        switch selected {
        case .dog:
            return "characterDetail_Dog\(userData.DogData.growthStage)"
        case .rabbit:
            return "characterDetail_Rabbit\(userData.RabbitData.growthStage)"
        case .cat:
            return "characterDetail_Cat\(userData.CatData.growthStage)"
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

    var body: some View {
        switch selected {
        case .dog:
            DogDetailView()
        case .rabbit:
            RabbitDetailView()
        case .cat:
            CatDetailView()
        }
    }
}

// MARK: - Individual Detail Views

/// DogDetailView: currentCharacter.growthStage == 3 のときのみ切り替え可能
private struct DogDetailView: View {
    @EnvironmentObject var userData: UserData

    var body: some View {
        if userData.selectedCharacter == "Dog" {
            // すでにDogが選択中
            DisabledButton(title: "選択中")
        } else {
            // 現在のキャラが成長段階3なら切り替え可能
            if userData.currentCharacter.growthStage == 3 {
                SelectButton(title: "このキャラにする！") {
                    let status = userData.canSwitchCharacter(
                        currentharacter: userData.currentCharacter
                    )
                    userData.switchCharacter(switchStatus: status, targetCharacter: userData.DogData)
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

    var body: some View {
        VStack(spacing: 24) {
            Text("うさぎ")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)

            if userData.selectedCharacter == "Rabbit" {
                DisabledButton(title: "選択中")
            } else {
                if userData.currentCharacter.growthStage == 3 {
                    SelectButton(title: "このキャラにする！") {
                        let status = userData.canSwitchCharacter(
                            currentharacter: userData.currentCharacter
                        )
                        userData.switchCharacter(switchStatus: status, targetCharacter: userData.RabbitData)
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

    var body: some View {
        VStack(spacing: 24) {
            Text("ねこ")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)

            if userData.selectedCharacter == "Cat" {
                DisabledButton(title: "選択中")
            } else {
                if userData.currentCharacter.growthStage == 3 {
                    SelectButton(title: "このキャラにする！") {
                        let status = userData.canSwitchCharacter(
                            currentharacter: userData.currentCharacter
                        )
                        userData.switchCharacter(switchStatus: status, targetCharacter: userData.CatData)
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
            RoundedRectangle(cornerRadius: 50)
                .frame(width: 400, height: 80)
                .foregroundStyle(.green)
                .overlay(
                    Text(title)
                        .foregroundColor(.white)
                        .font(.custom("GenJyuuGothicX-Bold", size: 40))
                )
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
