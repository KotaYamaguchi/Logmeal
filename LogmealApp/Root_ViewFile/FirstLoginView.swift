import SwiftUI
import Network
import WebKit
import AVKit

struct FirstLoginView: View {
    @EnvironmentObject var user: UserData
    @State private var isSelectedCharacter: Bool = true
    @State private var showButtonCount: Int = 0
    @State private var isStart: Bool = false
    @State private var conversationCount: Int = 0
    @State private var isConnected: Bool = false
    @State private var showYouTube: Bool = true
    @State private var showAlert: Bool = false
    @State private var countdownTimer: Timer?
    @State private var countdownDuration: TimeInterval = 120.0
    private let soundManager = SoundManager.shared
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "Monitor")
    @StateObject private var bgmManager = BGMManager.shared
    @State private var rotationAngle: Double = 0 // 左右の傾き角度
    @State private var player = AVPlayer(url: Bundle.main.url(forResource: "prologue 2", withExtension: "mp4")!)
    //https://youtu.be/6SwhhYdYSm4?feature=shared
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                if isSelectedCharacter {
                    CharacterSelectView(isSelectedCharacter: $isSelectedCharacter)
                        .fullScreenCover(isPresented: $showYouTube) {
                            prologueView(geometry: geometry)
                        }
                } else if isStart{
                    ZStack{
                        Image("bg_AjiwaiCardView")
                            .resizable()
                            .ignoresSafeArea()
                        gameStart(size: geometry.size)
                    }
                    
                }else{
                    ZStack{
                        Image("bg_AjiwaiCardView")
                            .resizable()
                            .ignoresSafeArea()
                        ProfileSettingView(isFirst: true)
                        VStack{
                            TypeWriterTextView("あなたのことを教えてね", speed: 0.1, font: .custom("GenJyuuGothicX-Bold", size: 30), textColor: .textColor, onAnimationCompleted: {
                                print("アニメーションが終了しました")
                            })
                            .padding()
                            .background(){
                                RoundedRectangle(cornerRadius: 30)
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                        }
                        .padding()
                        VStack(spacing:50){
                            Image("\(user.selectedCharacter)_normal_1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 180)
                                .rotationEffect(.degrees(rotationAngle))
                                .animation(.easeInOut(duration: 0.3), value: rotationAngle)
                            Button{
                                isStart = true
                            }label:{
                                Text("決定")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 30))
                                    .background(){
                                        Image("bt_base")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100,height: 60)
                                    }
                            }
                        }
                        .position(x:geometry.size.width * 0.88, y:geometry.size.height * 0.85)
                    }
                    .ignoresSafeArea()
                }
            }
        }
        .onAppear {
            startWobbleAnimation()
        }
    }
    
    private func startWobbleAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 1.0)) {
                self.rotationAngle = 5 * sin(Date().timeIntervalSinceReferenceDate * 2) // 回転角度の計算
            }
        }
    }
    
    private func monitorNetworkConnection() {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    isConnected = true
                }
            } else {
                DispatchQueue.main.async {
                    isConnected = false
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    private func startCountdown() {
        resetCountdown()  // Ensure any existing timer is reset
        countdownTimer = Timer.scheduledTimer(withTimeInterval: countdownDuration, repeats: false) { _ in
            showYouTube = false
            isSelectedCharacter = true
        }
    }
    
    private func resetCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
    
    @ViewBuilder private func prologueView(geometry:GeometryProxy) -> some View{
        //        if isConnected {
        //                YoutubeView()
        //                    .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.9)
        //                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
        //                    .onDisappear {
        //                        isSelectedCharacter = true
        //                        resetCountdown()
        //                        bgmManager.playBGM()
        //                    }
        //                    .onAppear {
        //                        startCountdown()
        //                        bgmManager.pauseBGM()
        //                    }
        //        } else {
        //            VStack {
        //                Text("インターネットに接続するとプロローグが再生されます。\nプロローグを再生せずに始める場合はボタンを押してください。")
        //                    .font(.custom("GenJyuuGothicX-Bold", size: 17))
        //                    .padding()
        //
        //                Button {
        //                    withAnimation {
        //                        showYouTube = false
        //                    }
        //                    soundManager.playSound(named: "se_positive")
        //                } label: {
        //                    Image("bt_base")
        //                        .resizable()
        //                        .scaledToFit()
        //                        .frame(height: 50)
        //                        .overlay {
        //                            Text("画面を閉じて次へ！")
        //                                .font(.custom("GenJyuuGothicX-Bold", size: 13))
        //                                .foregroundStyle(Color.buttonColor)
        //                        }
        //                }
        //                .buttonStyle(PlainButtonStyle())
        //            }
        //            .onAppear {
        //                monitorNetworkConnection()
        //            }
        //        }
        ZStack(alignment:.topLeading){
            VideoPlayer(player: player)
                .frame(width: geometry.size.width * 0.95, height: geometry.size.height * 0.95)
                .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
                .onDisappear {
                    player.pause()
                    isSelectedCharacter = true
                    resetCountdown()
                    bgmManager.playBGM()
                }
                .onAppear {
                    player.play()
                    player.volume = 0.5
                    startCountdown()
                    bgmManager.pauseBGM()
                }
                .onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: player.currentItem), perform: { _ in
                    showYouTube = false
                })
            Button {
                showYouTube = false
                resetCountdown()
            } label: {
                Image("bt_close")
                    .resizable()
                    .frame(width:50,height: 50)
            }
            .padding()
        }
        
    }
    @ViewBuilder func gameStart(size: CGSize) -> some View {
        ZStack(alignment: .topLeading) {
            Image("\(user.selectedCharacter)_normal_1")
                .resizable()
                .scaledToFit()
                .frame(width: 180)
                .rotationEffect(.degrees(rotationAngle))
                .position(x:size.width * 0.75, y:size.height * 0.75)
                .animation(.easeInOut(duration: 0.3), value: rotationAngle)
            Image("mt_callout")
                .resizable()
                .scaledToFit()
                .frame(width: 650)
                .position(x:size.width * 0.5, y:size.height * 0.38)
            
            VStack(alignment: .leading) {
                if conversationCount == 0 {
                    TypeWriterTextView("それじゃあゲームを始めるよ\n準備はいい？", speed: 0.1, font: .custom("GenJyuuGothicX-Bold", size: 17), textColor: .textColor, onAnimationCompleted: {
                        print("アニメーションが終了しました")
                        showButtonCount = 1
                    })
                } else if conversationCount == 1 {
                    TypeWriterTextView("よし！これからよろしくね！", speed: 0.1, font: .custom("GenJyuuGothicX-Bold", size: 17), textColor: .textColor, onAnimationCompleted: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            user.isLogined = true
                            user.isTitle = false
                        }
                    })
                }
            }
            .position(x: size.width * 0.5, y: size.height * 0.35)
            if showButtonCount == 1 {
                Button {
                    conversationCount = 1
                    showButtonCount = 0
                    soundManager.playSound(named: "se_positive")
                } label: {
                    Image("bt_base")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 100)
                        .overlay {
                            Text("もちろん!")
                                .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                .foregroundStyle(Color.buttonColor)
                        }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 30)
                .position(x: size.width * 0.5, y: size.height * 0.8)
            }
        }
        .onAppear {
            showButtonCount = 0
        }
    }
}

#Preview {
    FirstLoginView()
        .environmentObject(UserData())
}



struct YouTubeViewRepresentable: UIViewRepresentable {
    let videoID: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false  // Disable scrolling
        webView.contentMode = .scaleAspectFit  // Adjust content scaling
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let htmlString = """
        <html>
        <body style="margin:0;padding:0;">
        <iframe width="100%" height="100%" src="https://www.youtube.com/embed/\(videoID)?playsinline=1" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
        </body>
        </html>
        """
        uiView.loadHTMLString(htmlString, baseURL: nil)
    }
}
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

