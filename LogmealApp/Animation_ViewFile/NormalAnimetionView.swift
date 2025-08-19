//
//  NormalAnimetionView.swift
//  LogmealApp
//
//  Created by Kota Yamaguchi on 2025/08/19.
//

import SwiftUI

struct NormalAnimetionView: View {
    var characterGifName: String
    var text: String
    var backgroundImage: String = ""
    let useBackGroundColor:Bool
    @State private var playGif: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if useBackGroundColor{
                    Color.black.opacity(0.5) // 背景色を黒に設定
                        .ignoresSafeArea()
                }
                // キャラクターのGIF
                GIFImage(data: NSDataAsset(name: characterGifName)!.data, loopCount: -1, playGif: $playGif)
                    .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.7)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.65)
                
                // テキスト表示 (TypeWriterTextView)
                ZStack {
                    if !useBackGroundColor {
                        Image(backgroundImage)
                            .resizable()
                            .scaledToFit()
                    }
                    
                    TypeWriterTextView(text,
                                       speed: 0.1,
                                       font: .custom("GenJyuuGothicX-Bold", size: 17),
                                       textColor: useBackGroundColor ? .white : .textColor) {
                        // 完了アクション (必要に応じて)
                    }
                                       .padding()
                }
                .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.2)
                .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.3)
            }
        }
    }
}
