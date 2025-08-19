import SwiftUI
import SwiftData

struct NewSettingView: View {
    private let tutorialImage: [String] = ["HowToUseHome", "HowToUseCalendar", "HowToUseShop", "HowToUseCharacter", "HowToUseColumnList", "HowToUseAjiwaiCard", "HowToUseQr", "HowToUseCardEdit", "HowToUseSetting", "HowToUseShare1", "HowToUseShare2"]
    @EnvironmentObject var userData: UserData
    var body: some View {
        NavigationStack{
            GeometryReader{ geomtry in
                ZStack{
                    Image("bg_newSettingView.png")
                        .resizable()
                        .ignoresSafeArea()
                    VStack{
                        Image("mt_newSettingView_setting")
                            .resizable()
                            .scaledToFit()
                            .frame(width:550)
                        NavigationLink{
                            ProfileSettingView()
                        }label: {
                            SettingRowDesign(withImage: true, imageName: "mt_newSettingView_profile")
                        }
                        NavigationLink{
                            SoundSettingView()
                        }label: {
                            SettingRowDesign(withImage: true, imageName: "mt_newSettingView_sound")
                        }
                        NavigationLink{
                            ShareExportView()
                        }label: {
                            SettingRowDesign(withImage: true, imageName: "mt_newSettingView_share")
                        }
                        NavigationLink{
                            OtherSettingView()
                        }label: {
                            SettingRowDesign(withImage: true, imageName: "mt_newSettingView_others")
                        }
                        Button{
                            withAnimation {
                                userData.isTitle = true
                            }
                        }label:{
                            SettingRowDesign(withImage: false,rowTitle: "タイトルに戻る", iconName: "arrowshape.turn.up.backward")
                        }
                        .padding(.bottom)
                        Image("mt_newSettingView_aboutTheApp")
                            .resizable()
                            .scaledToFit()
                            .frame(width:550)
                        NavigationLink{
                            YoutubeView(withBaclButton: false)
                        }label: {
                            SettingRowDesign(withImage: true, imageName: "mt_newSettingView_prologue")
                        }
                        NavigationLink{
                            TutorialView(imageArray: tutorialImage,withBackButton: false)
                        }label: {
                            SettingRowDesign(withImage: true, imageName: "mt_newSettingView_houUseApp")
                        }
                        
                    }
                    .padding(.vertical)
                    .frame(width: 600, height: 600)
                    .background(){
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(Color(red: 220/255, green: 221/255, blue: 221/255))
                    }
                }
            }
            
        }
    }
}
