import SwiftUI
import Network
import WebKit

struct FirstLoginView: View {
    @EnvironmentObject var user: UserData
    @State private var isSelectedCharacter: Bool = true
    @State private var showFillName: Bool = false
    @State private var selectedName: String = ""
    @State private var selectedGrade:String = ""
    @State private var selectedClass: String = ""
    @State private var selectedAge: Int?
    @State private var showClassPicker: Bool = false
    @State private var showAgePicker: Bool = false
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
    @FocusState  var isActive:Bool
    @State private var rotationAngle: Double = 0 // 左右の傾き角度
//https://youtu.be/6SwhhYdYSm4?feature=shared
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if isSelectedCharacter {
                    CharacterSelectView(isSelectedCharacter: $isSelectedCharacter, showFillUserName: $showFillName)
                        .fullScreenCover(isPresented: $showYouTube) {
                            if isConnected {
                                    YoutubeView()
                                        .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.9)
                                        .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
                                        .onDisappear {
                                            isSelectedCharacter = true
                                            resetCountdown()
                                            bgmManager.playBGM()
                                        }
                                        .onAppear {
                                            startCountdown()
                                            bgmManager.pauseBGM()
                                        }
                            } else {
                                VStack {
                                    Text("インターネットに接続するとプロローグが再生されます。\nプロローグを再生せずに始める場合はボタンを押してください。")
                                        .font(.custom("GenJyuuGothicX-Bold", size: 17))
                                        .padding()
                                    
                                    Button {
                                        withAnimation {
                                            showYouTube = false
                                        }
                                        soundManager.playSound(named: "se_positive")
                                    } label: {
                                        Image("bt_base")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 50)
                                            .overlay {
                                                Text("画面を閉じて次へ！")
                                                    .font(.custom("GenJyuuGothicX-Bold", size: 13))
                                                    .foregroundStyle(Color.buttonColor)
                                            }
                                    }
                                }
                                .onAppear {
                                    monitorNetworkConnection()
                                }
                            }
                        }
                } else {
                    ZStack{
                        Image("bg_AjiwaiCardView")
                            .resizable()
                            .ignoresSafeArea()
                            .onTapGesture {
                                isActive = false
                            }
                        if showFillName {
                            fillUserName()
                        } else if showClassPicker {
                            selectGradeAndClass()
                        } else if showAgePicker {
                            selectAge()
                        } else if isStart {
                            gameStart(size: geometry.size)
                        }
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

    @ViewBuilder func fillUserName() -> some View {
        GeometryReader{ let size = $0.size
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
                TypeWriterTextView("あなたの名前を教えてね", speed: 0.1, font: .custom("GenJyuuGothicX-Bold", size: 25), textColor: .textColor, onAnimationCompleted: {
                    print("アニメーションが終了しました")
                })
                .position(x: size.width * 0.5, y: size.height * 0.2)
                
                TextField("あなたの名前を入力しよう", text: $selectedName)
                    .font(.custom("GenJyuuGothicX-Bold", size: 17))
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .frame(width: size.width * 0.4)
                    .position(x: size.width * 0.5, y: size.height * 0.3)
                    .focused($isActive)
                
                Button {
                    if selectedName.isEmpty {
                        showAlert = true
                    } else {
                        user.name = selectedName
                        showFillName = false
                        withAnimation {
                            showClassPicker = true
                        }
                        soundManager.playSound(named: "se_positive")
                    }
                } label: {
                    Image("bt_base")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 100)
                        .overlay {
                            Text("決定!")
                                .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                .foregroundStyle(Color.buttonColor)
                        }
                }
                .opacity(selectedName.isEmpty ? 0.6 : 1)
                .position(x: size.width * 0.5, y: size.height * 0.8)
                .buttonStyle(PlainButtonStyle())
                .alert("注意！",isPresented: $showAlert) {
                    Button("OK"){
                        
                    }
                }message: {
                    Text("名前を入力してください")
                }
                
                Button {
                    withAnimation {
                        isSelectedCharacter = true
                        showFillName = false
                    }
                } label: {
                    Image("bt_back")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                .padding()
            }
        }
    }
    
    @ViewBuilder func selectGradeAndClass() -> some View {
        GeometryReader{ let size = $0.size
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
                TypeWriterTextView("学年とクラスを入力してね！", speed: 0.1, font: .custom("GenJyuuGothicX-Bold", size: 25), textColor: .textColor, onAnimationCompleted: {
                    print("アニメーションが終了しました")
                })
                .position(x: size.width * 0.5, y: size.height * 0.2)
                
                
                VStack(spacing: 20) {
                    TextField("学年：3年生なら 3 と入力してね", text: $selectedGrade)
                        .font(.custom("GenJyuuGothicX-Bold", size: 17))
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .frame(width: size.width * 0.4)
                        .keyboardType(.numberPad)
                        .focused($isActive)
                    
                    TextField("クラス：1組なら 1 と入力してね", text: $selectedClass)
                        .font(.custom("GenJyuuGothicX-Bold", size: 17))
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .frame(width: size.width * 0.4)
                        .keyboardType(.numberPad)
                        .focused($isActive)
                }
                .position(x: size.width * 0.5, y: size.height * 0.3)
                .ignoresSafeArea(.keyboard)
                Button {
                    if selectedGrade.isEmpty || selectedClass.isEmpty {
                        showAlert = true
                    } else {
                        user.grade = selectedGrade
                        user.yourClass = selectedClass
                        showClassPicker = false
                        soundManager.playSound(named: "se_positive")
                        withAnimation {
                            showAgePicker = true
                        }
                    }
                } label: {
                    Image("bt_base")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 100)
                        .overlay {
                            Text("決定！")
                                .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                .foregroundStyle(Color.buttonColor)
                        }
                }
                .opacity((selectedGrade.isEmpty || selectedClass.isEmpty) ? 0.6 : 1)
                .position(x: size.width * 0.5, y: size.height * 0.8)
                .buttonStyle(PlainButtonStyle())
                .alert("注意！",isPresented: $showAlert) {
                    Button("OK"){
                        
                    }
                }message: {
                    Text("学年とクラスを入力してください")
                }
                
                Button {
                    withAnimation {
                        showFillName = true
                        showClassPicker = false
                    }
                } label: {
                    Image("bt_back")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                .padding()
            }
        }
    }
    
    @ViewBuilder func selectAge() -> some View {
        GeometryReader{ let size = $0.size
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
                TypeWriterTextView("あなたの年齢を教えてね！", speed: 0.1, font: .custom("GenJyuuGothicX-Bold", size: 25), textColor: .textColor, onAnimationCompleted: {
                    print("アニメーションが終了しました")
                })
                .position(x: size.width * 0.5, y: size.height * 0.2)
                
                TextField("年齢を入力してね", value: $selectedAge, format: .number)
                    .font(.custom("GenJyuuGothicX-Bold", size: 17))
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .frame(width: size.width * 0.4)
                    .keyboardType(.numberPad)
                    .position(x: size.width * 0.5, y: size.height * 0.3)
                    .focused($isActive)
                Button {
                    if selectedAge == nil {
                        showAlert = true
                    } else {
                        user.age = selectedAge!
                        showAgePicker = false
                        soundManager.playSound(named: "se_positive")
                        withAnimation {
                            isStart = true
                        }
                    }
                } label: {
                    Image("bt_base")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 100)
                        .overlay {
                            Text("決定！")
                                .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                .foregroundStyle(Color.buttonColor)
                        }
                }
                .opacity(selectedAge == nil ? 0.6 : 1)
                .position(x: size.width * 0.5, y: size.height * 0.8)
                .buttonStyle(PlainButtonStyle())
                .alert("注意！",isPresented: $showAlert) {
                    Button("OK"){
                        
                    }
                }message: {
                    Text("年齢を入力してください")
                }
                
                Button {
                    withAnimation {
                        showClassPicker = true
                        showAgePicker = false
                    }
                } label: {
                    Image("bt_back")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                .padding()
            }
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
                        }
                    })
                }
            }
            .position(x: size.width * 0.5, y: size.height * 0.35)
            
            Button {
                withAnimation {
                    showAgePicker = true
                    isStart = false
                }
            } label: {
                Image("bt_back")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            }
            .padding()
            
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

struct TypeWriterTextView: View {
    private let text: String
    private let speed: TimeInterval
    private let font: Font
    private let textColor: Color
    private let onAnimationCompleted: () -> Void
    
    @State private var textArray: String = ""
    
    init(_ text: String, speed: TimeInterval = 0.1, font: Font = .body, textColor: Color = .primary, onAnimationCompleted: @escaping () -> Void) {
        self.text = text
        self.speed = speed
        self.font = font
        self.textColor = textColor
        self.onAnimationCompleted = onAnimationCompleted
    }
    
    var body: some View {
        Text(textArray)
            .font(font)
            .foregroundColor(textColor)
            .onAppear {
                startAnimation()
            }
    }
    
    private func startAnimation() {
        DispatchQueue.global().async {
            for character in text {
                Thread.sleep(forTimeInterval: speed)
                DispatchQueue.main.async {
                    textArray += String(character)
                }
            }
            DispatchQueue.main.async {
                onAnimationCompleted()
            }
        }
    }
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
    var body: some View {
        NavigationStack{
            YouTubeViewRepresentable(videoID: "6SwhhYdYSm4")
                .padding(.horizontal)
                .toolbar{
                    ToolbarItem{
                        Button{
                            dismiss()
                        }label: {
                            Image("bt_close")
                                .resizable()
                                .frame(width: 35,height: 35)
                        }
                    }
                }
        }
    }
}

#Preview {
    YoutubeView()
}
