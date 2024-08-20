import SwiftUI

struct FirstLoginView: View {
    @EnvironmentObject var user: UserData
    @State private var isSelectedCharacter: Bool = false
    @State private var showFillName: Bool = false
    @State private var selectedGrade: String = ""
    @State private var selectedClass: String = ""
    @State private var showClassPicker: Bool = false
    @State private var showButtonCount: Int = 0
    @State private var isStart: Bool = false
    @State private var conversationCount: Int = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if !isSelectedCharacter {
                    CharacterSelectView(isSelectedCharacter: $isSelectedCharacter)
                        .onDisappear() {
                            showFillName = true
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
                    
                    if showFillName {
                        fillUserName(size: geometry.size)
                    } else if showClassPicker {
                        selectGradeAndClass(size: geometry.size)
                    } else if isStart {
                        gameStart(size: geometry.size)
                    }
                }
            }
        }
    }
    
    @ViewBuilder func fillUserName(size: CGSize) -> some View {
        ZStack {
            TypeWriterTextView("あなたの名前を教えてね", speed: 0.1, font: .custom("GenJyuuGothicX-Bold", size: 25), onAnimationCompleted: {
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
                if user.name.isEmpty{
                    user.name = "ななし"
                }
                showFillName = false
                withAnimation {
                    showClassPicker = true
                }
            }) {
                Image("bt_base")
                    .resizable()
                    .scaledToFit()
                    .frame(width:200,height: 100)
                    .overlay {
                        Text("決定!")
                            .font(.custom("GenJyuuGothicX-Bold", size: 20))
                            .foregroundStyle(Color.buttonColor)
                    }
            }
//            .disabled(user.name.isEmpty)
            .position(x: size.width * 0.5, y: size.height * 0.8)
            .buttonStyle(PlainButtonStyle())
        }
    }

    @ViewBuilder func selectGradeAndClass(size: CGSize) -> some View {
        ZStack {
            TypeWriterTextView("学年とクラスを入力してね！", speed: 0.1, font: .custom("GenJyuuGothicX-Bold", size: 25), onAnimationCompleted: {
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
                
                TextField("クラス：1組なら 1 と入力してね", text: $selectedClass)
                    .font(.custom("GenJyuuGothicX-Bold", size: 17))
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .frame(width: size.width * 0.4)
            }
            .position(x: size.width * 0.5, y: size.height * 0.3)
            
            Button(action: {
                if let grade = Int(selectedGrade), let classNumber = Int(selectedClass) {
                    user.grade = grade
                    user.yourClass = classNumber
                    showClassPicker = false
                    withAnimation {
                        isStart = true
                    }
                }
            }) {
                Image("bt_base")
                    .resizable()
                    .scaledToFit()
                    .frame(width:200,height: 100)
                    .overlay {
                        Text("決定！")
                            .font(.custom("GenJyuuGothicX-Bold", size: 20))
                            .foregroundStyle(Color.buttonColor)
                    }
                    .opacity(selectedGrade.isEmpty || selectedClass.isEmpty ? 0.5 : 1.0)
            }
            .disabled(selectedGrade.isEmpty || selectedClass.isEmpty)
            .position(x: size.width * 0.5, y: size.height * 0.8)
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    @ViewBuilder func gameStart(size: CGSize) -> some View {
        ZStack {
            VStack(alignment: .leading) {
                if conversationCount == 0 {
                    TypeWriterTextView("それじゃあゲームを始めるよ\n準備はいい？", speed: 0.1, font: .custom("GenJyuuGothicX-Bold", size: 17), onAnimationCompleted: {
                        print("アニメーションが終了しました")
                        showButtonCount = 1
                    })
                    
                } else if conversationCount == 1 {
                    TypeWriterTextView("よし！これからよろしくね！", speed: 0.1, font: .custom("GenJyuuGothicX-Bold", size: 17), onAnimationCompleted: {
                        print("アニメーションが終了しました")
                        showButtonCount = 2
                    })
                }
                
            }
            .position(x: size.width * 0.5, y: size.height * 0.35)
            if showButtonCount == 1 {
                Button {
                    conversationCount = 1
                    showButtonCount = 0
                } label: {
                    Image("bt_base")
                        .resizable()
                        .scaledToFit()
                        .frame(width:200,height: 100)
                        .overlay {
                            Text("もちろん!")
                                .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                .foregroundStyle(Color.buttonColor)
                        }
                }
                .padding(.top, 30)
                .position(x: size.width * 0.5, y: size.height * 0.8)
            } else if showButtonCount == 2 {
                Text("画面をタップしてゲームを始めよう")
                    .font(.custom("GenJyuuGothicX-Bold", size: 17))
                    .foregroundStyle(.gray)
                    .padding(.top, 30)
                    .position(x: size.width * 0.5, y: size.height * 0.8)
                    .scaleEffect(conversationCount == 1 ? 1.1 : 0)
            }
        }
        .onAppear() {
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
