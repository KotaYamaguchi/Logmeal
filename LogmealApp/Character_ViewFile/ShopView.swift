//
//  ShopView.swift
//  LogmealApp
//
//  Created by 山口昂大 on 2025/04/11.
//

import SwiftUI

struct NewShopView:View {
    @EnvironmentObject var user:UserData
    @State private var isFrontItemsBord:Bool = true
    @State private var showPurchaseAlert:Bool = false
    @State private var products:[Product] = []
    @State private var boughtProducts:[Product] = [
        Product(name: "Dog3_animation_applause", price: 200, img: "img_dog_applause", isBought: false),
        Product(name: "Dog3_animation_bow", price: 400, img: "img_dog_bow", isBought: false),
        Product(name: "Dog3_animation_byebye", price: 600, img: "img_dog_byebye", isBought: false),
        Product(name: "Dog3_animation_eat", price: 800, img: "img_dog_eat", isBought: false),
        Product(name: "Dog3_animation_question", price: 1000, img: "img_dog_question", isBought: false),
        Product(name: "Dog3_animation_sit", price: 300, img: "img_dog_sit", isBought: false),
        Product(name: "Dog3_animation_sleep", price: 500, img: "img_dog_sleep", isBought: false),
        Product(name: "Dog3_animation_surprised", price: 700, img: "img_dog_surprised", isBought: false),
        Product(name: "Dog3_animation_yawn", price: 900, img: "img_dog_yawn", isBought: false),
        Product(name: "Dog3_animation_yell", price: 150, img: "img_dog_yell", isBought: false)
    ]
    @State private var selectedItemIndex:Int? = nil
    @State private var displayImage = ""
    var body: some View {
        ZStack{
            Image("bg_shop_Dog")
                .resizable()
                .ignoresSafeArea()
                .scaleEffect(1.1)
            HStack{
                Spacer()
                //選択したものによって表示を変える
                if displayImage.isEmpty{
                    Text("右側の一覧から\n買いたい商品を選んでね")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }else{
                    Image(displayImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width:400)
                }
                
                Spacer()
                VStack(alignment:.trailing){
                    Image("shop_point_display")
                        .overlay{
                            Text("1,000")
                                .foregroundStyle(.white)
                                .font(.custom("GenJyuuGothicX-Bold", size: 30))
                                .offset(x:20)
                        }
                    VStack{
                        VStack(spacing: 0){
                            HStack(spacing:0){
                                Button{
                                    isFrontItemsBord = true
                                }label: {
                                    Image("shop_top_label")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:195)
                                        .overlay{
                                            Label("ショップ", systemImage: "cart.fill")
                                                .font(.custom("GenJyuuGothicX-Bold", size: 23))
                                                .foregroundStyle(.black)
                                        }
                                }
                                .disabled(isFrontItemsBord)
                                Button{
                                    isFrontItemsBord = false
                                }label: {
                                    Image("shop_top_label_dog")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:195)
                                        .overlay{
                                            Text("買ったもの")
                                                .font(.custom("GenJyuuGothicX-Bold", size: 23))
                                                .foregroundStyle(.black)
                                        }
                                }
                                .disabled(!isFrontItemsBord)
                            }
                            .offset(y:5)
                            Image(isFrontItemsBord ?"shop_main_bord" : "shop_main_bord_dog")
                                .resizable()
                                .scaledToFit()
                                .frame(width:460)
                                .overlay{
                                    if isFrontItemsBord{
                                        itemArray()
                                    }else{
                                        isBoughtItemArray()
                                    }
                                }
                            
                        }
                        
                        if isFrontItemsBord{
                            Button{
                                showPurchaseAlert = true
                            }label:{
                                RoundedRectangle(cornerRadius: 50)
                                    .frame(width:400,height:70)
                                    .foregroundStyle(Color(red: 225/255, green: 108/255, blue: 68/255))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 50)
                                            .stroke(.white,lineWidth: 5)
                                        Text("買う")
                                            .foregroundStyle(.white)
                                            .font(.custom("GenJyuuGothicX-Bold", size: 45))
                                    }
                                
                            }
                            .disabled(selectedItemIndex == nil)
                        }
                    }
                }
                Spacer()
            }
            if showPurchaseAlert{
                Color.gray.opacity(0.6)
                    .ignoresSafeArea()
                VStack(spacing:0){
                    ZStack{
                        UnevenRoundedRectangle(topLeadingRadius: 40, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 40, style: .continuous)
                            .frame(width:400,height: 80)
                            .foregroundStyle(.white)
                        UnevenRoundedRectangle(topLeadingRadius: 40, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 40, style: .continuous)
                            .stroke(lineWidth: 2)
                            .frame(width:400,height: 80)
                            .foregroundStyle(.gray)
                    }
                    .overlay{
                        Text("購入しますか？")
                            .font(.custom("GenJyuuGothicX-Bold", size: 30))
                    }
                    HStack(spacing:0){
                        Button{
                            //購入時の処理を行う
                            if let index =  selectedItemIndex{
                                products[index].isBought = true
                                showPurchaseAlert = false
                                selectedItemIndex = nil
                            }
                        }label:{
                            ZStack{
                                UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 40, bottomTrailingRadius: 0, topTrailingRadius: 0, style: .continuous)
                                    .frame(width:200,height: 80)
                                    .foregroundStyle(.white)
                                UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 40, bottomTrailingRadius: 0, topTrailingRadius: 0, style: .continuous)
                                    .stroke(lineWidth: 2)
                                    .frame(width:200,height: 80)
                                    .foregroundStyle(.gray)
                            }
                            .overlay{
                                Text("する")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 30))
                            }
                        }
                        Button{
                            showPurchaseAlert = false
                        }label:{
                            ZStack{
                                UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 40, topTrailingRadius: 0, style: .continuous)
                                    .frame(width:200,height: 80)
                                    .foregroundStyle(.white)
                                UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 40, topTrailingRadius: 0, style: .continuous)
                                    .stroke(lineWidth: 2)
                                    .frame(width:200,height: 80)
                                    .foregroundStyle(.gray)
                            }
                            .overlay{
                                Text("しない")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 30))
                            }
                        }
                    }
                }
                
            }
        }
    }
    @ViewBuilder private func itemArray() -> some View{
            ZStack{
                List{
                    ForEach(Array(zip(products.indices, products)), id: \.1.id) { index, product in
                        Button{
                            selectedItemIndex = index
                            displayImage = product.img
                        }label:{
                            HStack{
                                Image(product.img)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width:50)
                                Spacer()
                                VStack(alignment:.trailing){
                                    VStack(alignment:.leading){
                                        Text("つままれる")
                                        Text("ポチッとつまんで、キャラクターと遊ぼう！")
                                    }
                                    HStack{
                                        Text("120")
                                        Text("pt")
                                    }
                                }
                            }
                            .padding()
                            .background{
                                if selectedItemIndex == index{
                                    Color(red: 248/255, green: 201/255, blue: 201/255)
                                        .ignoresSafeArea()
                                }
                            }
                        }
                        .overlay{
                            if products[index].isBought{
                                Color.gray.opacity(0.6)
                                    .overlay{
                                        Text("SOLD OUT")
                                            .font(.largeTitle)
                                            .fontWeight(.heavy)
                                            .foregroundStyle(.red)
                                    }
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
            }
            .frame(width:.infinity,height: .infinity)
            .onAppear(){
                switch user.selectedCharacter {
                case "Dog":
                    products = [
                        Product(name: "Dog3_animation_applause", price: 200, img: "img_dog_applause", isBought: false),
                        Product(name: "Dog3_animation_bow", price: 400, img: "img_dog_bow", isBought: false),
                        Product(name: "Dog3_animation_byebye", price: 600, img: "img_dog_byebye", isBought: false),
                        Product(name: "Dog3_animation_eat", price: 800, img: "img_dog_eat", isBought: false),
                        Product(name: "Dog3_animation_question", price: 1000, img: "img_dog_question", isBought: false),
                        Product(name: "Dog3_animation_sit", price: 300, img: "img_dog_sit", isBought: false),
                        Product(name: "Dog3_animation_sleep", price: 500, img: "img_dog_sleep", isBought: false),
                        Product(name: "Dog3_animation_surprised", price: 700, img: "img_dog_surprised", isBought: false),
                        Product(name: "Dog3_animation_yawn", price: 900, img: "img_dog_yawn", isBought: false),
                        Product(name: "Dog3_animation_yell", price: 150, img: "img_dog_yell", isBought: false)
                    ]
                case "Cat":
                    products = [
                        Product(name: "Cat3_animation_applause", price: 250, img: "img_cat_applause", isBought: false),
                        Product(name: "Cat3_animation_bow", price: 500, img: "img_cat_bow", isBought: false),
                        Product(name: "Cat3_animation_byebye", price: 750, img: "img_cat_byebye", isBought: false),
                        Product(name: "Cat3_animation_eat", price: 1000, img: "img_cat_eat", isBought: false),
                        Product(name: "Cat3_animation_question", price: 350, img: "img_cat_question", isBought: false),
                        Product(name: "Cat3_animation_sit", price: 600, img: "img_cat_sit", isBought: false),
                        Product(name: "Cat3_animation_sleep", price: 850, img: "img_cat_sleep", isBought: false),
                        Product(name: "Cat3_animation_surprised", price: 150, img: "img_cat_surprised", isBought: false),
                        Product(name: "Cat3_animation_yawn", price: 400, img: "img_cat_yawn", isBought: false),
                        Product(name: "Cat3_animation_yell", price: 650, img: "img_cat_yell", isBought: false)
                    ]
                case "Rabbit":
                    products = [
                        Product(name: "Rabbit3_animation_applause", price: 150, img: "img_rabbit_applause", isBought: false),
                        Product(name: "Rabbit3_animation_bow", price: 300, img: "img_rabbit_bow", isBought: false),
                        Product(name: "Rabbit3_animation_byebye", price: 450, img: "img_rabbit_byebye", isBought: false),
                        Product(name: "Rabbit3_animation_eat", price: 600, img: "img_rabbit_eat", isBought: false),
                        Product(name: "Rabbit3_animation_question", price: 750, img: "img_rabbit_question", isBought: false),
                        Product(name: "Rabbit3_animation_sit", price: 900, img: "img_rabbit_sit", isBought: false),
                        Product(name: "Rabbit3_animation_sleep", price: 1000, img: "img_rabbit_sleep", isBought: false),
                        Product(name: "Rabbit3_animation_surprised", price: 200, img: "img_rabbit_surprised", isBought: false),
                        Product(name: "Rabbit3_animation_yawn", price: 350, img: "img_rabbit_yawn", isBought: false),
                        Product(name: "Rabbit3_animation_yell", price: 500, img: "img_rabbit_yell", isBought: false)
                    ]
                default:
                    products = []
                }
            }
    }
    @ViewBuilder private func isBoughtItemArray() -> some View{
        ZStack{
            List{
                ForEach(Array(zip(boughtProducts.indices, boughtProducts)), id: \.1.id) { index, product in
                    Button{
                        selectedItemIndex = index
                        displayImage = product.img
                    }label:{
                        HStack{
                            Image(product.img)
                                .resizable()
                                .scaledToFit()
                                .frame(width:50)
                            Spacer()
                            VStack(alignment:.trailing){
                                VStack(alignment:.leading){
                                    Text("つままれる")
                                    Text("ポチッとつまんで、キャラクターと遊ぼう！")
                                }
                                HStack{
                                    Text("120")
                                    Text("pt")
                                }
                            }
                        }
                        .padding()
                        .background{
                            if selectedItemIndex == index{
                                Color.white
                                    .ignoresSafeArea()
                            }
                        }
                    }
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
        }
        .frame(width:.infinity,height: .infinity)
        .onAppear(){
            boughtProducts = products.filter{
                $0.isBought == true
            }
        }
    }
}


#Preview{
    NewShopView()
        .environmentObject(UserData())
}
