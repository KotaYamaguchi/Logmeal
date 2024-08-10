import SwiftUI
import SwiftyGif


struct CharacterView: View {
    @EnvironmentObject var user:UserData
    
    var body: some View {
        let imageName: String
        switch user.growthStage {
        case 1:
            imageName = "character1"
        case 2:
            imageName = "character2"
        case 3:
            imageName = "character3"
        default:
            imageName = "character1"
        }
        return Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding()
    }
}

#Preview {
    CharacterView()
        .environmentObject(UserData())
}
