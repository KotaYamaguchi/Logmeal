import SwiftUI


struct NewSettingView: View {
    private let tutorialImage: [String] = ["HowToUseHome", "HowToUseCalendar", "HowToUseShop", "HowToUseCharacter", "HowToUseColumnList", "HowToUseAjiwaiCard", "HowToUseQr", "HowToUseCardEdit", "HowToUseSetting", "HowToUseShare1", "HowToUseShare2"]
    @ObservedObject private var soundManager = SoundManager.shared
    @ObservedObject private var bgmManager = BGMManager.shared
    @State private var bgmVolume: Float = BGMManager.shared.bgmVolume
    @EnvironmentObject var userData: UserData
    var body: some View {
        NavigationStack {
            ZStack{
                Image("bg_newSettingView.png")
                    .resizable()
                    .ignoresSafeArea()
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 650, height: 650)
                    .foregroundStyle(Color(red: 220/255, green: 221/255, blue: 221/255))
                VStack{
                    Spacer()
                    Image("mt_newSettingView_setting")
                        .resizable()
                        .scaledToFit()
                        .frame(width:550)
                    settingRow(destination: NewProfileEditView(userData: userData), imageName: "mt_newSettingView_profile")
                    settingRow(destination: soundSettingView(), imageName: "mt_newSettingView_sound")
                    settingRow(destination: dataShareView(), imageName: "mt_newSettingView_share")
                    settingRow(destination: otherSettingView(), imageName: "mt_newSettingView_others")
                    Spacer()
                    Image("mt_newSettingView_aboutTheApp")
                        .resizable()
                        .scaledToFit()
                        .frame(width:550)
                    settingRow(destination: YoutubeView(), imageName: "mt_newSettingView_prologue")
                    settingRow(destination:TutorialView(imageArray: tutorialImage), imageName: "mt_newSettingView_houUseApp")
                    Spacer()
                }
            }
        }
    }
    private func settingRow(destination:some View,imageName: String) -> some View {
        NavigationLink{
            destination
        }label: {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width:550)
        }
    }
    private func soundSettingView() -> some View{
        VStack{
            VStack {
                Text("BGMの音量")
                    .font(.custom("GenJyuuGothicX-Bold", size: 15))
                HStack {
                    Button {
                        bgmVolume = max(bgmVolume - 0.1, 0)
                        bgmManager.setBGMVolume(bgmVolume)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title)
                            .foregroundStyle(.orange)
                    }
                    .buttonStyle(PlainButtonStyle())
                    Slider(value: $bgmVolume, in: 0...1, onEditingChanged: { editing in
                        if !editing {
                            bgmManager.setBGMVolume(bgmVolume)
                        }
                    })
                    .tint(.orange)
                    .padding(.horizontal)
                    Button {
                        bgmVolume = min(bgmVolume + 0.1, 1)
                        bgmManager.setBGMVolume(bgmVolume)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundStyle(.orange)
                    }
                    .buttonStyle(PlainButtonStyle())
                    Button {
                        bgmManager.toggleBGM()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 65, height: 35)
                                .foregroundStyle(Color(red: 0.42, green: 0.4, blue: 0.4))
                                .offset(y: 5)
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 65, height: 35)
                                .foregroundStyle(bgmManager.isBGMOn ? .orange : .gray)
                                .overlay {
                                    Text(bgmManager.isBGMOn ? "ON" : "OFF")
                                        .font(.title)
                                        .foregroundStyle(.white)
                                }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            // SE音量調整スライダー
            VStack {
                Text("効果音の音量")
                    .font(.custom("GenJyuuGothicX-Bold", size: 15))
                HStack {
                    Button {
                        soundManager.soundVolume = max(soundManager.soundVolume - 0.1, 0)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title)
                            .foregroundStyle(.orange)
                    }
                    .buttonStyle(PlainButtonStyle())
                    Slider(value: Binding(
                        get: { soundManager.soundVolume },
                        set: { newVolume in
                            soundManager.setSoundVolume(newVolume)
                        }
                    ), in: 0...1, onEditingChanged: { editing in
                        if !editing {
                            soundManager.setSoundVolume(soundManager.soundVolume)
                        }
                    })
                    .tint(.orange)
                    .padding(.horizontal)
                    Button {
                        soundManager.soundVolume = min(soundManager.soundVolume + 0.1, 1)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundStyle(.orange)
                    }
                    .buttonStyle(PlainButtonStyle())
                    Button{
                        soundManager.toggleSound()
                        
                    }label:{
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 65, height: 35)
                                .foregroundStyle(Color(red: 0.42, green: 0.4, blue: 0.4))
                                .offset(y:5)
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 65, height: 35)
                                .foregroundStyle( soundManager.isSoundOn ? .orange : .gray)
                                .overlay{
                                    Text( soundManager.isSoundOn ? "ON" : "OFF")
                                        .font(.title)
                                        .foregroundStyle(.white)
                                }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
    private func dataShareView() -> some View{
        VStack{
            
        }
    }
    private func otherSettingView() -> some View{
        VStack{
            
        }
    }
    private func showPrologueVideo() -> some View{
        VStack{
            
        }
    }
    private func howUseAppView() -> some View{
        VStack{
            TutorialView(imageArray: tutorialImage)
        }
    }
}

struct NewProfileEditView: View {
    @ObservedObject var userData:UserData
    
    @State private var userName: String = ""
    @State private var userGrade: Int = 1
    @State private var userClass: Int = 1
    @State private var userAge: Int = 6
    var body: some View {
        ZStack {
            Image("bg_newSettingView.png")
                .resizable()
                .ignoresSafeArea()
            
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 650, height: 750)
                .foregroundStyle(Color(red: 220/255, green: 221/255, blue: 221/255))
                .shadow(radius: 5)
            
            VStack{
                Image("mt_newSettingView_userImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                    .padding(.bottom)
                Image("mt_newSettingView_profileHeadline")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 550)
                
                // 名前入力
                Image("mt_newSettingView_name")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 550)
                    .overlay {
                        HStack {
                            Spacer()
                            TextField("ここに名前を入力してください", text: $userName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 400)
                                .padding(.horizontal)
                                .multilineTextAlignment(TextAlignment.trailing)
                        }
                    }
                
                // 学年選択
                Image("mt_newSettingView_grade")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 550)
                    .overlay {
                        HStack {
                            Spacer()
                            
                            Picker("選択してください", selection: $userGrade) {
                                ForEach(1...6, id: \.self) { grade in
                                    Text("\(grade)年").tag(grade)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 150)
                        }
                        .padding(.horizontal)
                    }
                
                // クラス選択
                Image("mt_newSettingView_class")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 550)
                    .overlay {
                        HStack {
                            Spacer()
                            
                            Picker("選択してください", selection: $userClass) {
                                ForEach(1...10, id: \.self) { classNum in
                                    Text("\(classNum)組").tag(classNum)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 150)
                        }
                        .padding(.horizontal)
                    }
                
                // 年齢選択
                Image("mt_newSettingView_age")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 550)
                    .overlay {
                        HStack {
                            Spacer()
                            
                            Picker("選択してください", selection: $userAge) {
                                ForEach(6...18, id: \.self) { age in
                                    Text("\(age)歳").tag(age)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 150)
                        }
                        .padding(.horizontal)
                    }
            }
            .padding()
        }
    }
}


#Preview{
    NewContentView()
}
