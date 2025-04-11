import SwiftUI
struct NewCharacterView: View {
    @Binding var showCharacterView:Bool
    var body: some View {
        NavigationStack{
            ZStack{
                Image("bg_homeView")
                    .resizable()
                    .ignoresSafeArea()
                VStack(alignment:.trailing,spacing:0){
                    NavigationLink{
                        NewShopView()
                    }label:{
                        Image("bt_toShop")
                            .resizable()
                            .scaledToFit()
                            .frame(width:350)
                    }
                    NavigationLink{
                        
                    }label:{
                        Image("bt_toCharaSelect")
                            .resizable()
                            .scaledToFit()
                            .frame(width:350)
                    }
                }
                .position(x:1000,y:600)
                Image("mt_characterHouse")
                    .resizable()
                    .scaledToFit()
                    .frame(width:1000,height:600)
                    .position(x:300,y:450)
                HStack(spacing:20){
                    Image("mt_PointBadge")
                        .resizable()
                        .scaledToFit()
                        .frame(width:50)
                    Text("3,000")
                        .foregroundStyle(.green)
                        .font(.custom("GenJyuuGothicX-Bold", size: 40))
                    Text("pt")
                        .foregroundStyle(.green)
                        .font(.custom("GenJyuuGothicX-Bold", size: 35))
                }
                .position(x:250,y:230)
                VStack(spacing:0){
                    Text("やましたとくまのレーク")
                        .foregroundStyle(.white)
                        .font(.custom("GenJyuuGothicX-Bold", size: 35))
                    HStack(spacing:0){
                        Image("mt_LvBadge")
                            .resizable()
                            .scaledToFit()
                            .frame(width:50)
                        ZStack(alignment:.leading){
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width:260,height: 15)
                                .foregroundStyle(.white)
                            
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width:160,height: 15)
                                .foregroundStyle(.red)
                        }
                        Text("LV.10")
                            .foregroundStyle(.white)
                            .font(.custom("GenJyuuGothicX-Bold", size: 35))
                            .padding(.horizontal)
                    }
                }
                
                .position(x:310,y:365)
                Button{
                    withAnimation {
                        showCharacterView = false
                    }
                }label: {
                    Image(systemName: "house.circle.fill")
                        .font(.system(size: 100))
                }
                .position(x:1140,y:60)
            }
        }
    }
}



#Preview(body: {
//    NewCharacterView(showCharacterView: .constant(true))
    NewShopView()
})

struct NewCharacterDetailView:View {
    @State private var selectedTab:Int = 0
    @State private var isSelected:Bool = false
    var body: some View {
        ZStack{
            switch selectedTab {
                case 0:
                Image("bg_charactarDetailView_dog")
                    .resizable()
                    .ignoresSafeArea()
            case 1:
                Image("bg_charactarDetailView_rabbit")
                    .resizable()
                    .ignoresSafeArea()
            case 2:
                Image("bg_charactarDetailView_cat")
                    .resizable()
                    .ignoresSafeArea()
            default:
                Image("bg_charactarDetailView_tomato")
                    .resizable()
                    .ignoresSafeArea()
            }
            
            VStack {
                RoundedRectangle(cornerRadius: 50)
                    .frame(width: 280, height: 90)
                    .foregroundStyle(.white)
                    .overlay {
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(Color.gray, lineWidth: 3)
                    }
                    .overlay {
                        HStack {
                            Button {
                                withAnimation{
                                    selectedTab = 0
                                }
                                
                            } label: {
                                Image("Dog_normal_1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: selectedTab == 0 ? 70 : 60)
                                    .colorMultiply(selectedTab == 0 ? .white : .gray) // 選択されていない場合にグレー
                            }
                            Button {
                                withAnimation{
                                    selectedTab = 1
                                }
                            } label: {
                                Image("Rabbit_normal_1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: selectedTab == 1 ? 70 : 60)
                                    .colorMultiply(selectedTab == 1 ? .white : .gray)
                            }
                            Button {
                                withAnimation{
                                    selectedTab = 2
                                }
                            } label: {
                                Image("Cat_normal_1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: selectedTab == 2 ? 70 : 60)
                                    .colorMultiply(selectedTab == 2 ? .white : .gray)
                            }
                        }
                    }
                Spacer()
                if selectedTab == 0 {
                    HStack(alignment: .bottom, spacing: 1) {
                        Spacer()
                        Image("Dog_normal_1")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200)
                        Image("arrow_symbol")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80)
                            .offset(y: -50)
                        Image("img_dog_applause")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300)
                        Image("arrow_symbol")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80)
                            .offset(y: -50)
                        Image("img_dog_applause")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 400)
                        Spacer()
                    }
                } else if selectedTab == 1 {
                    Text("うさぎ")
                } else if selectedTab == 2 {
                    Text("ねこ")
                }
                Spacer()
                if isSelected{
                    Button{
                        
                    }label:{
                        RoundedRectangle(cornerRadius: 50)
                            .frame(width:300,height: 80)
                            .foregroundStyle(.green)
                            .overlay{
                                Text("決定")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 40))
                            }
                    }
                }else{
                    Button{
                        
                    }label:{
                        RoundedRectangle(cornerRadius: 50)
                            .frame(width:300,height: 80)
                            .foregroundStyle(.gray)
                            .overlay{
                                Text("選択中")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 40))
                            }
                    }
                }
                
            }

        }
    }
}
