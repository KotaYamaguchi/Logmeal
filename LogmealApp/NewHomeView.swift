import SwiftUI
import PhotosUI



struct NewHomeView: View {
    @State private var showWritingView = false
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                HStack(alignment: .top) {
                    Spacer()
                    Image(systemName: "person.circle")
                        .font(.system(size: 80))
                    Spacer()
                    Text("熊本 太郎")
                        .font(.system(size: 80))
                    Spacer()
                    VStack(spacing: 0) {
                        Text("30")
                            .font(.system(size: 80))
                        Text("ろぐ")
                            .font(.system(size: 30))
                    }
                    Spacer()
                }
                .frame(height: 200)
                .padding()
                ScrollView {
                    LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                        ForEach(0..<20) { i in
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 100, height: 100)
                        }
                    }
                }
            }
            Button {
                showWritingView = true
            } label: {
                Image(systemName: "plus.circle")
                    .font(.system(size: 50))
            }
            .padding()
        }
        .fullScreenCover(isPresented: $showWritingView) {
            NewWriteingView(showWritingView: $showWritingView)
        }
    }
}

