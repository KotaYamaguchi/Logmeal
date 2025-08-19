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
