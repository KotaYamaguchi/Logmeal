
import SwiftUI
struct DisabledButton: View {
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
