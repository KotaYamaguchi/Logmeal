import SwiftUI
import SwiftData

/// RabbitDetailView: currentCharacter.growthStage == 3 のときのみ切り替え可能
struct RabbitDetailView: View {
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
