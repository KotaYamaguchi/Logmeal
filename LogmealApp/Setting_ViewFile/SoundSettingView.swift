//
//  SoundSettingView.swift
//  LogmealApp
//
//  Created by Kota Yamaguchi on 2025/08/19.
//

import SwiftUI
struct SoundSettingView:View {
    @ObservedObject private var soundManager = SoundManager.shared
    @ObservedObject private var bgmManager = BGMManager.shared
    @State private var bgmVolume: Float = BGMManager.shared.bgmVolume
    @State private var soundVolume: Float = SoundManager.shared.soundVolume
    var body: some View {
        ZStack{
            Image("bg_newSettingView.png")
                .resizable()
                .ignoresSafeArea()
            
                ZStack{
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 600, height: 330)
                        .foregroundStyle(Color(red: 220/255, green: 221/255, blue: 221/255))
                    VStack(spacing:10){
                        UnevenRoundedRectangle(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20, style: .continuous)
                            .frame(width: 550, height: 40)
                            .foregroundStyle(.white)
                            .overlay{
                                HStack{
                                    Text("サウンド")
                                        .padding()
                                        .font(.custom("GenJyuuGothicX-Bold", size: 23))
                                    Spacer()
                                }
                            }
                        VStack(spacing:6){
                            //BGM変更スライダー
                            VStack(alignment:.leading,spacing: 3){
                                Rectangle()
                                    .foregroundStyle(.white)
                                    .frame(width:550,height: 60)
                                .overlay{
                                    HStack{
                                        Text("BGMの音量")
                                            .font(.custom("GenJyuuGothicX-Bold", size: 15))
                                            .foregroundStyle(bgmManager.isBGMOn ? .black : .gray)
                                        Spacer()
                                        Button {
                                            bgmManager.toggleBGM()
                                        } label: {
                                            ZStack{
                                                Capsule()
                                                    .frame(width: 65, height: 35)
                                                    .foregroundStyle(.gray.opacity(0.3))
                                                Circle()
                                                    .frame(height: 35)
                                                    .foregroundStyle(bgmManager.isBGMOn ? .orange : .gray)
                                                    .offset(x:bgmManager.isBGMOn ? 15 :-15)
                                                    
                                            }
    //                                        ZStack {
    //                                            RoundedRectangle(cornerRadius: 10)
    //                                                .frame(width: 65, height: 35)
    //                                                .foregroundStyle(Color(red: 0.42, green: 0.4, blue: 0.4))
    //                                                .offset(y: 5)
    //                                            RoundedRectangle(cornerRadius: 10)
    //                                                .frame(width: 65, height: 35)
    //                                                .foregroundStyle(bgmManager.isBGMOn ? .orange : .gray)
    //                                                .overlay {
    //                                                    Text(bgmManager.isBGMOn ? "ON" : "OFF")
    //                                                        .font(.title)
    //                                                        .foregroundStyle(.white)
    //                                                }
    //                                        }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                    .padding()
                                }
                                Rectangle()
                                    .foregroundStyle(.white)
                                    .frame(width:550,height: 45)
                                    .overlay{
                                        HStack{
                                            Button{
                                                if bgmVolume >= 0{
                                                    bgmVolume -= 0.1
                                                    print("-1")
                                                }else{
                                                    print("MIN")
                                                }
                                            }label: {
                                                Image(systemName: "minus.circle")
                                                    .font(.system(size: 25))
                                                    .foregroundStyle(bgmVolume <= 0 || !bgmManager.isBGMOn ? .gray : .orange)
                                            }
                                            .disabled(bgmVolume <= 0 || !bgmManager.isBGMOn)
                                            Slider(value: $bgmVolume, in: 0...1, step: 0.1,onEditingChanged: { editing in
                                                if !editing {
                                                    bgmManager.setBGMVolume(bgmVolume)
                                                }
                                            })
                                            .tint(bgmManager.isBGMOn ? .orange : .gray)
                                            .disabled(!bgmManager.isBGMOn)
                                            Button{
                                                if bgmVolume <= 1{
                                                    bgmVolume += 0.1
                                                    print("+1")
                                                }else{
                                                    print("MAX")
                                                }
                                                
                                            }label: {
                                                Image(systemName: "plus.circle")
                                                    .font(.system(size: 25))
                                                    .foregroundStyle(bgmVolume >= 1 || !bgmManager.isBGMOn ? .gray : .orange)
                                            }
                                            .disabled(bgmVolume >= 1 || !bgmManager.isBGMOn)
                                        }
                                        .padding(.horizontal)
                                    }
                                
                            }
                           
                            // SE音量調整スライダー
                            VStack(alignment:.leading,spacing: 3){
                                Rectangle()
                                    .foregroundStyle(.white)
                                    .frame(width:550,height: 60)
                                    .overlay{
                                        HStack{
                                            Text("効果音の音量")
                                                .font(.custom("GenJyuuGothicX-Bold", size: 15))
                                                .foregroundStyle(soundManager.isSoundOn ? .black : .gray)
                                            Spacer()
                                            Button{
                                                soundManager.toggleSound()
                                            }label:{
                                                ZStack{
                                                    Capsule()
                                                        .frame(width: 65, height: 35)
                                                        .foregroundStyle(.gray.opacity(0.3))
                                                    Circle()
                                                        .frame(height: 35)
                                                        .foregroundStyle(soundManager.isSoundOn ? .orange : .gray)
                                                        .offset(x:soundManager.isSoundOn ? 15 :-15)
                                                        
                                                }
                                                
    //                                            ZStack{
    //                                                RoundedRectangle(cornerRadius: 10)
    //                                                    .frame(width: 65, height: 35)
    //                                                    .foregroundStyle(Color(red: 0.42, green: 0.4, blue: 0.4))
    //                                                    .offset(y:5)
    //                                                RoundedRectangle(cornerRadius: 10)
    //                                                    .frame(width: 65, height: 35)
    //                                                    .foregroundStyle( soundManager.isSoundOn ? .orange : .gray)
    //                                                    .overlay{
    //                                                        Text( soundManager.isSoundOn ? "ON" : "OFF")
    //                                                            .font(.title)
    //                                                            .foregroundStyle(.white)
    //                                                    }
    //                                            }
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                        .padding(.horizontal)
                                    }
                                UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 20, bottomTrailingRadius: 20, topTrailingRadius: 0, style: .continuous)
                                    .foregroundStyle(.white)
                                    .frame(width:550,height: 45)
                                    .overlay{
                                        HStack{
                                            Button{
                                                if soundVolume > 0{
                                                    soundVolume -= 0.1
                                                    print("-1")
                                                }else{
                                                    print("MIN")
                                                }
                                                
                                            }label: {
                                                Image(systemName: "minus.circle")
                                                    .font(.system(size: 25))
                                                    .foregroundStyle(soundVolume <= 0 || !soundManager.isSoundOn ? .gray : .orange)
                                            }
                                            .disabled(soundVolume <= 0 || !soundManager.isSoundOn)
                                            Slider(value: $soundVolume, in: 0...1, step: 0.1, onEditingChanged: { editing in
                                                if !editing{
                                                    soundManager.setSoundVolume(soundVolume)
                                                }
                                            })
                                            .tint(soundManager.isSoundOn ? .orange : .gray)
                                            .disabled(!soundManager.isSoundOn)
                                            Button{
                                                if soundVolume < 1{
                                                    soundVolume += 0.1
                                                    print("+1")
                                                }else{
                                                    print("MAX")
                                                }
                                                
                                            }label: {
                                                Image(systemName: "plus.circle")
                                                    .font(.system(size: 25))
                                                    .foregroundStyle(soundVolume >= 1 || !soundManager.isSoundOn ? .gray : .orange)
                                            }
                                            .disabled(soundVolume >= 1 || !soundManager.isSoundOn)
                                        }
                                        .padding(.horizontal)
                                    }
                                
                            }
                        }
                 
                        
                    }
                }
        }
    }
}
