
import SwiftUI
import SwiftData
// MARK: - Dynamic Background
 struct CharacterDetailBackground: View {
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
