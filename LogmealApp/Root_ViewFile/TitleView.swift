//
//  TitleView.swift
//  LogmealApp
//
//  Created by 山口昂大 on 2025/03/19.
//

import SwiftUI
import SwiftData

struct TitleView: View {
    @State private var textScaleEffectValue: Double = 1.0
    @State private var showMenu: Bool = false
    @EnvironmentObject var user: UserData
    @EnvironmentObject var coordinator: AppCoordinator
    @Query private var allData: [AjiwaiCardData]
    @Environment(\.modelContext) private var context
    
    var body: some View {
        if user.isTitle {
            GeometryReader { geometry in
                ZStack(alignment: .topTrailing) {
                    ZStack {
                        Image("bg_AjiwaiCardView")
                            .resizable()
                            .ignoresSafeArea()
                            .scaledToFill()
                            .frame(width: geometry.size.width * 1.05, height: geometry.size.height)
                            .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
                        Image("bg_TitleView")
                            .resizable()
                            .ignoresSafeArea()
                            .scaledToFill()
                            .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
                    }
                    
                    Button {
                        showMenu = true
                    } label: {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.pink)
                    }
                    .padding(.all)
                    .buttonStyle(PlainButtonStyle())
                    
                    Text("画面をタップしてゲームを始めよう")
                        .font(.custom("GenJyuuGothicX-Bold", size: 20))
                        .foregroundStyle(.gray)
                        .padding(.top, 30)
                        .scaleEffect(textScaleEffectValue)
                        .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.8)
                }
                .onAppear {
                    user.migrateLegacyData()
                    startTextAnimation()
                }
                .onTapGesture {
                    withAnimation {
                        if user.isLogined {
                            // User is already logged in, go to main content
                            coordinator.navigateToHome()
                        } else {
                            // User needs to login/setup profile
                            coordinator.navigateToFirstLogin()
                        }
                        user.isTitle = false
                    }
                }
                .sheet(isPresented: $showMenu) {
                    appSettingView(geometry: geometry)
                }
            }
        } else {
            // Show appropriate view based on login status
            if user.isLogined {
                CompleteContentView(userData: user)
            } else {
                InitialScreenSelectorView()
            }
        }
    }
    
    private func startTextAnimation() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            textScaleEffectValue = 1.1
        }
    }
            
    }
    @ViewBuilder private func appSettingView(geometry:GeometryProxy) -> some View {
        NavigationStack {
            Form{
                Section("情報") {
                    NavigationLink {
                        termsOfUse(geometry: geometry)
                    } label: {
                        Text("利用規約")
                    }
                    
                    NavigationLink {
                        creditView(geometry:geometry)
                    } label: {
                        Text("クレジット")
                    }
                }
                Section {
                    Button {
                        let appDomain = Bundle.main.bundleIdentifier
                         UserDefaults.standard.removePersistentDomain(forName: appDomain!)
                        do{
                            try context.delete(model:AjiwaiCardData.self,includeSubclasses: true)
                        }catch{
                            print("error:\(error.localizedDescription)")
                        }
                    } label: {
                        Text("データを全て消す")
                            .foregroundStyle(Color.blue)
                    }
                } header: {
                    Text("ゲームの初期化")
                        .font(.custom("GenJyuuGothicX-Bold", size: 10))
                } footer: {
                    Text("アプリ内のすべてのデータを初期化して初めからプレイします.この操作は取り消すことができません")
                        .font(.custom("GenJyuuGothicX-Bold", size: 10))
                }
                Section("開発者コンテンツ"){
                    Button{
                        user.isCharacterDataMigrated = false
                        
                    }label:{
                    Text("マイグレーションリセット")
                    }
                }
            }
            .foregroundStyle(Color.textColor)
            .navigationTitle("情報")
        }
    }
    
    @ViewBuilder private func termsOfUse(geometry:GeometryProxy) -> some View {
        VStack{
            Text("利用規約")
                .font(.custom("GenJyuuGothicX-Bold", size: 28))
            Divider()
                .frame(width:geometry.size.width*0.5)
                .padding(.vertical)
            ScrollView{
                VStack(alignment:.leading){
                    Text("""
        【利用規約】
        本規約は、熊本県立大学総合管理学部飯村研究室（以下「本研究室」という。）が提供するiPad専用アプリケーション「ろぐみいる」（以下「本アプリ」という。）の利用に関する諸規定を定めるものです。本アプリをインストールする前に本規約をご確認いただき、内容をご確認の上本アプリをご利用ください。
        
        第1条 ご利用にあたって
        利用者は、本規約の定めに従って、本アプリを利用しなければなりません。同意した方に限り、本アプリを利用できるものとします。
        本アプリを利用された場合には、本規約の内容全てに同意したものとみなされます。
        
        第2条 登録について
        利用者は、本アプリ所定の手続きに従い利用手続きを行うことで、本アプリの利用が可能になります。
        
        第3条 著作権について
        本アプリに係る著作権その他一切の権利は、本研究室に帰属します。
        本利用規約に基づく本アプリの提供は、利用者に対する本アプリの著作権その他いかなる権利の移転または実施権の許諾を伴うものではありません。
        
        第4条 免責事項について
        本アプリを利用するにあたり、以下の項目について承諾のうえご利用ください。
        
        （1）本研究室は、利用者に対し、本アプリの一切の動作保証を行わず、いかなる瑕疵担保責任も負いません。
        
        （2）通信環境の状況、システムの障害、メンテナンス、その他やむを得ない事由により、情報の不達、遅延が発生する場合があります。また、ご利用の端未機種等の設定等により、本アプリ内の情報が正しく表示されない場合があります。それらにより利用者が何らかの損害を被ったとしても、本研究室は利用の如何を問わず一切の責任を負いません。
        
        （3）利用者に事前に通知することなく、本アプリを変更、中断、終了することがあります。これによって利用者が何らかの損害を彼ったとしても、本研究室は理由の如何を問わず一切の責任を負いません。
        
        （4）本アプリの利用により、利用者が事故に遭う等、何らかの損害を彼ったとしても、本研究室は理由の如何を問わず一切の責任を負いません。
        
        （5）本アプリの利用料金は無料とします。ただし、本アプリの利用及び更新に要する通信費用は、利用者の負担となります。
        
        第5条 禁止事項について
        
        利用者は、本アプリの利用に際して、以下の行為を行ってはならないものとします。行った場合は事前の通知なく、当該利用者の本アプリの利用を停止される場合があることを予め承諾するものとします。
        （1）本アプリの複製、改変、転用、頒布、又は本アプリの全部又は一部のリバースエンジニアリング、逆コンパイル、逆アセンブル等の行為
        
        （2）本アプリの運営、維持を妨げる行為
        
        （3）その他、本研究室が不適切であると判断した行為
        
        第6条本規約の変更について
        
        本規約は、必要に応じて改定する場合があり、利用者はこれを承諾するものとします。本アプリをご利用の際は、アプリ内に掲載されている最新の利用規約をご確認下さい。
        
        【附則】
        2024年8月31日 施行
        
        """)
                    .padding()
                }
            }
        }
        .ignoresSafeArea()
        .font(.custom("GenJyuuGothicX-Bold", size: 15))
        .foregroundStyle(Color.textColor)
        .padding()
    }
    
    @ViewBuilder private func creditView(geometry:GeometryProxy) -> some View {
        VStack{
            Text("クレジット")
                .font(.custom("GenJyuuGothicX-Bold", size: 28))
            Divider()
                .frame(width:geometry.size.width*0.3)
                .padding(.vertical)
            ScrollView{
                VStack{
                    Text("アプリケーションデベロッパー")
                        .padding()
                        .font(.custom("GenJyuuGothicX-Bold", size: 27))
                    Text("山口 昂大")
                    
                    Text("クリエイティブプランナー")
                        .padding()
                        .font(.custom("GenJyuuGothicX-Bold", size: 27))
                    HStack(spacing:20){
                        Text("丸田 妃菜美")
                        Text("山下 緩菜")
                    }
                    HStack(spacing:20){
                        Text("山下 徳真")
                        Text("山田 鈴音")
                    }
                    HStack(spacing:20){
                        Text("吉山 千愛")
                        Text("米山 詩歩")
                    }
                    
                    Text("スーパーバイザー")
                        .padding()
                        .font(.custom("GenJyuuGothicX-Bold", size: 27))
                    Text("飯村 伊智郎")
                    Text("Special Thanks")
                        .padding()
                        .font(.custom("GenJyuuGothicX-Bold", size: 27))
                    Text("熊本市教育センター")
                    Text("千葉県君津市立周西小学校教諭　佐藤孝子")
                    
                    Text("音源提供")
                        .padding()
                        .font(.custom("GenJyuuGothicX-Bold", size: 27))
                    Text("HALTO(ハルト)")
                    Text("フォント提供")
                        .padding()
                        .font(.custom("GenJyuuGothicX-Bold", size: 27))
                    let url1 = "http://jikasei.me/font/genshin/"
                    let url2 = "http://scripts.sil.org/OFL"
                    Text("""
    本ソフトでは表示フォントに「源柔ゴシックX」(\(url1) を使用しています。
    Licensed under SIL Open Font License 1.1 (\(url2)
    © 2014-2022 自家製フォント工房,
    © 2014, 2015 Adobe Systems Incorporated,
    © 2015 M+FONTS PROJECT
    """)
                    .frame(width:geometry.size.width*0.4)
                    HStack{
                        Image("Iimulab_logo")
                            .resizable()
                            .frame(width:100,height: 100)
                            .padding(.top,50)
                        Image("EducationCenter_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200)
                            .padding(.top,50)
                    }
                    Text("© 2024 Iimura Laboratory , Prefectural University of Kumamoto")
                }
            }
        }
        .font(.custom("GenJyuuGothicX-Bold", size: 18))
        .foregroundStyle(Color.textColor)
        .padding()
    }
}

#Preview {
    TitleView()
        .environmentObject(UserData())
        .environmentObject(AppCoordinator())
        .modelContainer(for: AjiwaiCardData.self)
}
