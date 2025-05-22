import SwiftUI
struct NewCharacterView: View {
    @Binding var showCharacterView:Bool
    @EnvironmentObject var userData :UserData
    @State private var houseSize:CGFloat = 0
    @State private var houseOffsetX:CGFloat = 0
    @State private var houseOffsetY:CGFloat = 0
    private func setHouseSize() -> CGFloat{
        switch userData.selectedCharacter{
        case "Dog":
            return 590
        case "Cat":
            return 590
        case "Rabbit":
            return 590
        default:
            return 400
        }
    }
    private func setHouseOffsetX() -> CGFloat{
        switch userData.selectedCharacter{
        case "Dog":
            return -40
        case "Cat":
            return -50
        case "Rabbit":
            return -50
        default:
            return 0
        }
    }
    private func setHouseOffsetY() -> CGFloat{
        switch userData.selectedCharacter{
        case "Dog":
            return 130
        case "Cat":
            return 135
        case "Rabbit":
            return 130
        default:
            return 0
        }
    }
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
                        Image("bt_toShop_\(userData.selectedCharacter)")
                            .resizable()
                            .scaledToFit()
                            .frame(width:300)
                    }
                    NavigationLink{
                        NewCharacterDetailView()
                    }label:{
                        Image("bt_toCharaSelect_\(userData.selectedCharacter)")
                            .resizable()
                            .scaledToFit()
                            .frame(width:350)
                    }
                }
                .position(x:1000,y:600)
                ZStack{
                    ZStack{
                        Image("House_\(userData.selectedCharacter)")
                            .resizable()
                            .scaledToFit()
                            .frame(height:setHouseSize())
                            .offset(x:houseOffsetX,y:houseOffsetY)
                    }
                    .onAppear(){
                        self.houseSize = setHouseSize()
                        self.houseOffsetX = setHouseOffsetX()
                        self.houseOffsetY = setHouseOffsetY()
                    }
                    .onChange(of: userData.selectedCharacter, { oldValue, newValue in
                        self.houseSize = setHouseSize()
                    })
                    HStack(spacing:20){
                        Image("mt_PointBadge")
                            .resizable()
                            .scaledToFit()
                            .frame(width:50)
                        Text("\(userData.point)")
                            .foregroundStyle(.green)
                            .font(.custom("GenJyuuGothicX-Bold", size: 40))
                        Text("pt")
                            .foregroundStyle(.green)
                            .font(.custom("GenJyuuGothicX-Bold", size: 35))
                    }
                    .offset(x:-80,y:-80)
                    VStack(spacing:0){
                        Text("\(userData.name)のレーク")
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
                                    .frame(width:CGFloat(userData.exp)/260,height: 15)
                                    .foregroundStyle(.red)
                            }
                            Text("LV.\(userData.level)")
                                .foregroundStyle(.white)
                                .font(.custom("GenJyuuGothicX-Bold", size: 35))
                                .padding(.horizontal)
                        }
                    }
                    .offset(x:-25,y:40)
                }
                .position(x:350,y:300)
                VStack{
                    HStack{
                        Spacer()
                        Button{
                            withAnimation {
                                showCharacterView = false
                            }
                        }label: {
                            Image("bt_toHome_\(userData.selectedCharacter)")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80)
                        
                        }
                        .padding(.horizontal)
                    }
                    Spacer()
                }
            }
        }
    }
}



#Preview(body: {
    NewCharacterView(showCharacterView: .constant(true))
        .environmentObject(UserData())
})

struct NewCharacterDetailView:View {
    @State private var selectedTab:Int = 0
    @State private var isSelected:Bool = false
    @EnvironmentObject var user:UserData
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
                    VStack{
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
                        if user.selectedCharacter != "Dog"{
                            Button{
                                user.selectedCharacter = "Dog"
                            }label:{
                                RoundedRectangle(cornerRadius: 50)
                                    .frame(width:400,height: 80)
                                    .foregroundStyle(.green)
                                    .overlay{
                                        Text("このキャラにする！")
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
                } else if selectedTab == 1 {
                    Text("うさぎ")
                    if user.selectedCharacter != "Rabbit"{
                        Button{
                            user.selectedCharacter = "Rabbit"
                        }label:{
                            RoundedRectangle(cornerRadius: 50)
                                .frame(width:400,height: 80)
                                .foregroundStyle(.green)
                                .overlay{
                                    Text("このキャラにする！")
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
                } else if selectedTab == 2 {
                    Text("ねこ")
                    if user.selectedCharacter != "Cat"{
                        Button{
                            user.selectedCharacter = "Cat"
                        }label:{
                            RoundedRectangle(cornerRadius: 50)
                                .frame(width:400,height: 80)
                                .foregroundStyle(.green)
                                .overlay{
                                    Text("このキャラにする！")
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
}
