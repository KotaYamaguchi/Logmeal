import SwiftUI
struct NewCharacterView: View {
    @Binding var show: Bool
    var body: some View {
        TabView {
            Text("トマト")
                .tabItem {
                    Text("とまと")
                }
            Text("ナスビ")
                .tabItem {
                    Text("なすび")
                }
            Text("ニンジン")
                .tabItem {
                    Text("にんじん")
                }
        }
        .onTapGesture {
            withAnimation {
                show = false
            }
        }
    }
}

