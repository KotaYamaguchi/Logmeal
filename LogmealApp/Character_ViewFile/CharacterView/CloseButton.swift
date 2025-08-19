
import SwiftUI
import SwiftData
// MARK: - Close Button
 struct CloseButton: View {
    let size: CGSize
    let character: String
    private let baseSize = CGSize(width: 1210, height: 785)
    @Binding var showCharacterView:Bool
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    showCharacterView = false
                } label: {
                    Image("bt_toHome_\(character)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: size.width * (80 / baseSize.width))
                }
                .padding(.horizontal)
            }
            Spacer()
        }
    }
}
