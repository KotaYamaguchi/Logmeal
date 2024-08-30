import SwiftUI

struct TutorialView: View {
    let imageArray:[String]
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        GeometryReader{ geometry in
            ZStack(alignment:.topLeading){
                Image("bg_AjiwaiCardView")
                    .resizable()
                    .saturation(0.0)
                    .ignoresSafeArea()
                TabView{
                    ForEach(imageArray,id: \.self){ content in
                        Image(content)
                            .resizable()
                            .scaledToFit()
                            .frame(width:geometry.size.width*0.95,height:geometry.size.height*0.95)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .position(x:geometry.size.width*0.5,y:geometry.size.height*0.5)
                    }
                }
                .tabViewStyle(.page)
                Button{
                    dismiss()
                }label: {
                    Image("bt_close")
                        .resizable()
                        .frame(width:50,height: 50)
                }
                .buttonStyle(PlainButtonStyle())
                .padding()
            }
        }
    }
}

//#Preview {
//    TutorialView(imageArray: tutorialImage)
//}

