
import SwiftUI
import SwiftData
// MARK: - Tab Selector
 struct CharacterTabSelector: View {
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
