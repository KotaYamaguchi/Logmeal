import SwiftUI

struct SelectButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
                    Text(title)
                        .foregroundColor(.white)
                        .font(.custom("GenJyuuGothicX-Bold", size: 40))
                        .padding(.horizontal)
                        .background(){
                            RoundedRectangle(cornerRadius: 50)
                                .frame(width:500, height: 80)
                                .foregroundStyle(.green)
                        }
        }
    }
}
