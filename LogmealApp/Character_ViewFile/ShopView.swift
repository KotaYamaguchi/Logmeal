//
//  ShopView.swift
//  LogmealApp
//
//  Created by 山口昂大 on 2025/04/11.
//

import SwiftUI

struct NewShopView:View {
    @State private var isFrontItemsBord:Bool = true
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
                                    RoundedRectangle(cornerRadius: 20)
                                        .frame(width:180,height: 90)
                                        .foregroundStyle(.red)
                                }
                                .disabled(isFrontItemsBord)
                                Button{
                                    isFrontItemsBord = false
                                }label: {
                                    RoundedRectangle(cornerRadius: 20)
                                        .frame(width:180,height: 90)
                                        .foregroundStyle(.blue)
                                }
                                .disabled(!isFrontItemsBord)
                            }
                            .offset(y:20)
                            RoundedRectangle(cornerRadius: 40)
                                .frame(width:450,height: 500)
                                .foregroundStyle(isFrontItemsBord ? .red : .blue)
                        }
    
                                                   
                        Button{
                            
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
        }
    }
}


#Preview{
    NewShopView()
}
