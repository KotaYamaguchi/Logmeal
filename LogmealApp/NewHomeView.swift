import SwiftUI
import PhotosUI



struct NewHomeView: View {
    @State private var showWritingView = false
    var body: some View {
        ZStack{
            Image("bg_HomeView_dog")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            VStack{
                HStack{
                    VStack{
                    Image("no_user_image").resizable()
                        .scaledToFit()
                        .frame(width: 180)
                        .overlay {
                            Circle()
                                .stroke(Color(red:236/255, green:178/255, blue:183/255), lineWidth: 5)
                        }
                        Text("熊本 太郎")
                            .font(.custom("GenJyuuGothicX-Bold", size: 25))
                }
                    VStack{
                        HStack{
                        VStack{
                            Text("30")
                                .font(.custom("GenJyuuGothicX-Bold", size: 55))
                            Text("ろぐ")
                                .font(.custom("GenJyuuGothicX-Bold", size: 30))
                        }
                        .padding(.horizontal,50)
                        VStack{
                            Text("100")
                                .font(.custom("GenJyuuGothicX-Bold", size: 55))
                            Text("ポイント")
                                .font(.custom("GenJyuuGothicX-Bold", size: 30))
                        }
                        .padding(.horizontal,50)
                        VStack{
                            Text("20")
                                .font(.custom("GenJyuuGothicX-Bold", size: 55))
                            Text("レベル")
                                .font(.custom("GenJyuuGothicX-Bold", size: 30))
                        }
                        .padding(.horizontal,50)
                        }
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width:600,height: 3)
                            .foregroundStyle(Color(red: 236/255, green: 178/255, blue: 183/255))
                    }
                }
                .padding(.top,30)
                ScrollView{
                    LazyVGrid(columns: [GridItem(),GridItem(),GridItem()],spacing: 5){
                        ForEach(0..<30){ i in
                            Rectangle()
                                .frame(width:255,height: 190)
                                .foregroundStyle(Color(red:206/255, green:206/255, blue:206/255))
                        }
                    }
                    .frame(width:780)
                    .padding(.horizontal)
                }
            }
            Button{
                showWritingView = true
            }label: {
                Image("bt_add_log")
                    .resizable()
                    .scaledToFit()
                    .frame(width:150)
            }
            .position(x:820,y:690)
        }
        .fullScreenCover(isPresented: $showWritingView) {
            NewWritingView(showWritingView: $showWritingView)
        }
    }
}

#Preview{
    NewContentView()
}
