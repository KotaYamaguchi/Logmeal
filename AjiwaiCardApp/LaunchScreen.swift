import SwiftUI

struct LaunchScreen: View {
    @State private var isLoading = true
    var body: some View {
        GeometryReader{ geometry in
            if isLoading{
                ZStack{
                    Image("logmeal_icon_view")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 50))
                        .frame(width:geometry.size.width*0.5,height: geometry.size.height*0.5)
                        .position(x:geometry.size.width*0.5,y: geometry.size.height*0.5)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation {
                            isLoading = false
                        }
                    }
                }
            }else{
                ContentView()
            }
        }
    }
}

#Preview {
    LaunchScreen()
        .environmentObject(UserData())
}
