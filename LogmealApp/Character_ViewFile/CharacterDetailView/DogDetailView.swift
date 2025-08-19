import SwiftUI
import SwiftData


/// DogDetailView: currentCharacter.growthStage == 3 のときのみ切り替え可能
struct DogDetailView: View {
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

