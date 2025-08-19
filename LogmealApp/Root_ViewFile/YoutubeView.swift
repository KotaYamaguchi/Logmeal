//
//  YoutubeView.swift
//  LogmealApp
//
//  Created by Kota Yamaguchi on 2025/08/19.
//
import SwiftUI
import Network
import WebKit
import AVKit

struct YoutubeView: View {
    @Environment(\.dismiss) private var dismiss
    let withBaclButton:Bool
    var body: some View {
        NavigationStack{
            YouTubeViewRepresentable(videoID: "6SwhhYdYSm4")
                .padding(.horizontal)
                .toolbar{
                    if withBaclButton{
                        ToolbarItem{
                            Button{
                                dismiss()
                            }label: {
                                Image("bt_close")
                                    .resizable()
                                    .frame(width: 35,height: 35)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
        }
    }
}
