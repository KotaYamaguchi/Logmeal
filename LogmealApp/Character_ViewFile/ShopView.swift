//
//  ShopView.swift
//  LogmealApp
//
//  Created by 山口昂大 on 2025/04/11.
//

import SwiftUI

struct NewShopView:View {
    @State private var isFrontItemsBord:Bool = true
    @State private var showPurchaseAlert:Bool = true
    var body: some View {
        ZStack{
            Image("bg_shop_Dog")
                .resizable()
                .ignoresSafeArea()
                .scaleEffect(1.1)
            HStack{
                Spacer()
                Image("img_dog_applause")
                    .resizable()
                    .scaledToFit()
                    .frame(width:400)
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
                                }
                                .disabled(isFrontItemsBord)
                                Button{
                                    isFrontItemsBord = false
                                }label: {
                                    Image("shop_top_label_dog")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:195)
                                }
                                .disabled(!isFrontItemsBord)
                            }
                            .offset(y:5)
                            Image(isFrontItemsBord ?"shop_main_bord" : "shop_main_bord_dog")
                                .resizable()
                                .scaledToFit()
                                .frame(width:460)
                            
                        }
                        
                        
                        Button{
                            showPurchaseAlert = true
                        }label:{
                            RoundedRectangle(cornerRadius: 50)
                                .frame(width:400,height:70)
                                .foregroundStyle(.red)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 50)
                                        .stroke(.white,lineWidth: 5)
                                    Text("買う")
                                        .foregroundStyle(.white)
                                        .font(.custom("GenJyuuGothicX-Bold", size: 45))
                                }
                            
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
                            showPurchaseAlert = false
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
}


#Preview{
    NewShopView()
}


