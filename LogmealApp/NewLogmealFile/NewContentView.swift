import SwiftUI
struct NewContentView: View {
    let headLineTitles: [String] = ["ホーム", "コラム", "せってい"]
    @State private var isShowSelectedView: [Bool] = [true, false, false] // 初期状態で1つ目を選択
    @State private var showCharactarView:Bool = false
    var body: some View {
        ZStack{
            NavigationSplitView {
                leftSideSection()
//                    .navigationSplitViewColumnWidth(min: 200, ideal: 300)
//                    .toolbar(removing: .sidebarToggle)
            } detail: {
                rightSideSection()
            }
            // Remove the default sidebar toggle button
//            NewCharacterView(showCharacterView: $showCharactarView)
//                .scaleEffect(showCharactarView ? 1.0 : 0.0)
//                .ignoresSafeArea()
        }
    }
    
    private func leftSideSection() -> some View {
        VStack(alignment: .leading) {
            ForEach(0..<headLineTitles.count, id: \.self) { index in
                Button {
                    // 他のすべての状態をリセットし、現在のものだけを true に
                    isShowSelectedView = Array(repeating: false, count: headLineTitles.count)
                    isShowSelectedView[index] = true
                } label: {
                    headlineItem(
                        text: headLineTitles[index],
                        icon: "bt_HomeVIew_Cat_2",
                        isSelected: isShowSelectedView[index]
                    )
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(isShowSelectedView[index] ? Color(red: 255/255, green: 235/255, blue: 200/255) : Color.clear)
                    }
                }
                Divider()
            }
            Spacer()
            Image("img_dog_yell")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .onTapGesture {
                    withAnimation {
                        showCharactarView = true
                    }
                    
                }
        }
        .padding(.top)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 255/255, green: 254/255, blue: 245/255))
    }
    
    private func headlineItem(text: String, icon: String, isSelected: Bool) -> some View {
        HStack {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
            Text(text)
                .font(.system(size: 30))
            Spacer()
        }
        .padding()
    }
    
    private func rightSideSection() -> some View {
        ZStack {
            if isShowSelectedView[0] {
                NewHomeView()
            } else if isShowSelectedView[1] {
                NewColumnView()
            } else if isShowSelectedView[2] {
                NewSettingView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        //        .background(Color.blue.opacity(0.1))
    }
}

#Preview {
    NewContentView()
}
