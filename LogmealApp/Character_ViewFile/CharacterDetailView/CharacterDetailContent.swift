
import SwiftUI
import SwiftData
// MARK: - Detail Content Switcher
 struct CharacterDetailContent: View {
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
