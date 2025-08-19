//
//  SettingRowDesign.swift
//  LogmealApp
//
//  Created by Kota Yamaguchi on 2025/08/19.
//

import SwiftUI
struct SettingRowDesign:View {
    let withImage:Bool
    var imageName:String = ""
    var rowTitle:String = ""
    var iconName:String = ""
    var textColor:Color = .black
    var icnoColor:Color = .black
     var body: some View {
        if withImage{
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width:550)
        }else{
            Rectangle()
                .foregroundStyle(.white)
                .frame(width:550,height: 50)
                .overlay{
                    HStack(spacing:30){
                        Image(systemName: iconName)
                            .font(.system(size: 30))
                            .foregroundStyle(icnoColor)
                        Text(rowTitle)
                            .font(.custom("GenJyuuGothicX-Bold", size: 28))
                            .foregroundStyle(textColor)
                        Spacer()
                        
                    }
                    .padding(.horizontal)
                }
        }
    }
}
