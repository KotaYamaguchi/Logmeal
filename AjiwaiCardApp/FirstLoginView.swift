import SwiftUI

struct FirstLoginView: View {
    @EnvironmentObject var user: UserData
    @State private var isSelectedCharacter: Bool = false
    @State private var showSelectGrade: Bool = false
    @State private var showFiiName: Bool = false
    @State private var grade: Int = 1
    @State private var selectedGrade: Int? = nil
    @State private var conversationCount:Int = 0
    @State private var showButtonCount:Int = 0
    @State private var isStart:Bool = false
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                if !isSelectedCharacter {
                    CharacterSelectView(isSelectedCharacter: $isSelectedCharacter)
                        .onDisappear(){
                            showFiiName = true
                        }
                } else {
                    Image("bg_AjiwaiCardView")
                        .resizable()
                        .onTapGesture {
                            if showButtonCount == 2 {
                                withAnimation {
                                    user.isLogined = true
                                }
                            }
                        }
                    Image("\(user.selectedCharactar)_normal_1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180)
                        .position(x: geometry.size.width * 0.75, y: geometry.size.height * 0.75)
                    Image("mt_callout")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 650)
                        .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.38)
                    
                    if showFiiName{
                        fillUserName(size: geometry.size)
                    }else if showSelectGrade{
                        selectGrade(size: geometry.size)
                    }else if isStart{
                        gameStart(size: geometry.size)
                    }
                }
            }
        }
    }
    
    @ViewBuilder func fillUserName(size: CGSize) -> some View {
        ZStack {
            TypeWriterTextView("あなたの名前を教えてね", speed: 0.1,font:.custom("GenJyuuGothicX-Bold", size: 25),onAnimationCompleted: {
                print("アニメーションが終了しました")
            })
            .position(x: size.width * 0.5, y: size.height * 0.2)
            
            TextField("", text: $user.name)
                .font(.custom("GenJyuuGothicX-Bold", size: 17))
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .frame(width: size.width * 0.4)
                .position(x: size.width * 0.5, y: size.height * 0.3)
            
            Button(action: {
                showFiiName = false
                isStart = false
                withAnimation {
                    showSelectGrade = true
                }
            }) {
                Image("bt_done")
                    .font(.largeTitle)
                    .foregroundColor(.black)
                    .frame(width: 170, height: 80)
                    .opacity(user.name.isEmpty ? 0.5 : 1.0) // 使用不可時に薄く表示
            }
            .disabled(user.name.isEmpty)
            .position(x: size.width * 0.5, y: size.height * 0.8)
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    @ViewBuilder func selectGrade(size: CGSize) -> some View {
        ZStack {
            TypeWriterTextView("学年を選んでね！", speed: 0.1,font:.custom("GenJyuuGothicX-Bold", size: 25),onAnimationCompleted: {
                print("アニメーションが終了しました")
                showButtonCount = 1
            })
            .padding()
            .position(x: size.width * 0.5, y: size.height * 0.2)
            Grid{
                GridRow{
                    ForEach(1...3, id: \.self) { gradeNumber in
                        Button(action: {
                            selectedGrade = gradeNumber
                            grade = gradeNumber
                        }) {
                            Text("\(gradeNumber)年生")
                                .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                .foregroundColor(.white)
                                .frame(width: 150, height: 60)
                                .background(selectedGrade == gradeNumber ? Color.red : Color.gray.opacity(0.7))
                                .cornerRadius(20)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                GridRow{
                    ForEach(4...6, id: \.self) { gradeNumber in
                        Button(action: {
                            selectedGrade = gradeNumber
                            grade = gradeNumber
                        }) {
                            Text("\(gradeNumber)年生")
                                .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                .foregroundColor(.white)
                                .frame(width: 150, height: 60)
                                .background(selectedGrade == gradeNumber ? Color.red : Color.gray.opacity(0.7))
                                .cornerRadius(20)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .position(x: size.width * 0.5, y: size.height * 0.4)
            Button(action: {
                user.grade = selectedGrade!
                showFiiName = false
                showSelectGrade = false
                withAnimation {
                    isStart = true
                }
                
            }) {
                Image("bt_done")
                    .font(.largeTitle)
                    .foregroundColor(.black)
                    .frame(width: 170, height: 80)
                    .opacity(selectedGrade == nil ? 0.5 : 1.0) // 使用不可時に薄く表示
            }
            .disabled(selectedGrade == nil)
            .padding(.top, 30)
            .position(x: size.width * 0.5, y: size.height * 0.8)
            .buttonStyle(PlainButtonStyle())
        }
        .onChange(of: grade) { oldValue, newValue in
            print(grade)
        }
    }
    @ViewBuilder func gameStart(size: CGSize) -> some View{
        ZStack{
            VStack(alignment:.leading){
                if conversationCount == 0 {
                    TypeWriterTextView("それじゃあゲームを始めるよ\n準備はいい？", speed: 0.1,font:.custom("GenJyuuGothicX-Bold", size: 17),onAnimationCompleted: {
                        print("アニメーションが終了しました")
                        showButtonCount = 1
                    })
                    
                }else if conversationCount == 1 {
                    TypeWriterTextView("よし！これからよろしくね！", speed: 0.1,font:.custom("GenJyuuGothicX-Bold", size: 17),onAnimationCompleted: {
                        print("アニメーションが終了しました")
                        showButtonCount = 2
                    })
                }
                
            }
            .position(x: size.width * 0.5, y: size.height * 0.35)
            if showButtonCount == 1 {
                Button{
                    conversationCount = 1
                    showButtonCount = 0
                }label: {
                    Text("もちろん！")
                        .font(.custom("GenJyuuGothicX-Bold", size: 17))
                        .background(){
                            ZStack{
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 210, height: 110)
                                    .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                                    .cornerRadius(20)
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 200, height: 100)
                                    .background(Color(red: 0.99, green: 0.99, blue: 0.99))
                                    .cornerRadius(20)
                            }
                        }
                }
                .padding(.top, 30)
                .position(x: size.width * 0.5, y: size.height * 0.8)
            }else if showButtonCount == 2 {
                Text("画面をタップしてゲームを始めよう")
                    .font(.custom("GenJyuuGothicX-Bold", size: 17))
                    .foregroundStyle(.gray)
                    .padding(.top, 30)
                    .position(x: size.width * 0.5, y: size.height * 0.8)
                    .scaleEffect(conversationCount == 1 ? 1.1 : 0)
            }
        }
        .onAppear(){
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
