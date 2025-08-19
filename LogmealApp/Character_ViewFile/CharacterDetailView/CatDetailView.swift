
import SwiftUI
import SwiftData
// MARK: - Individual Detail Views


/// CatDetailView: currentCharacter.growthStage == 3 のときのみ切り替え可能
struct CatDetailView: View {
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


