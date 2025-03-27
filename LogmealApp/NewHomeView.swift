import SwiftUI
import PhotosUI
import SwiftData

struct NewHomeView: View {
    @State private var showWritingView = false
    @EnvironmentObject var user: UserData
    @Environment(\.modelContext) private var context
    @Query private var allData: [AjiwaiCardData]
    @State var selectedData:AjiwaiCardData? = nil
    @State var showDetailView:Bool = false
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("bg_HomeView_dog")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .position(x:geometry.size.width*0.5,y:geometry.size.height*0.5)
                
                VStack {
                    HStack {
                        Spacer()
                        VStack {
                            Image("no_user_image")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.2)
                                .overlay {
                                    Circle()
                                        .stroke(Color(red: 236/255, green: 178/255, blue: 183/255), lineWidth: 5)
                                }
                            Text("\(user.name)")
                                .font(.custom("GenJyuuGothicX-Bold", size: geometry.size.width * 0.03))
                        }
                        VStack {
                            HStack {
                                VStack {
                                    Text("\(allData.count)")
                                        .font(.custom("GenJyuuGothicX-Bold", size: geometry.size.width * 0.06))
                                    Text("ろぐ")
                                        .font(.custom("GenJyuuGothicX-Bold", size: geometry.size.width * 0.04))
                                }
                                .padding(.horizontal, geometry.size.width * 0.05)
                                
                                VStack {
                                    Text("\(user.point)")
                                        .font(.custom("GenJyuuGothicX-Bold", size: geometry.size.width * 0.06))
                                    Text("ポイント")
                                        .font(.custom("GenJyuuGothicX-Bold", size: geometry.size.width * 0.04))
                                }
                                .padding(.horizontal, geometry.size.width * 0.05)
                                
                                VStack {
                                    Text("\(user.level)")
                                        .font(.custom("GenJyuuGothicX-Bold", size: geometry.size.width * 0.06))
                                    Text("レベル")
                                        .font(.custom("GenJyuuGothicX-Bold", size: geometry.size.width * 0.04))
                                }
                                .padding(.horizontal, geometry.size.width * 0.05)
                            }
                            
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: geometry.size.width * 0.8, height: 3)
                                .foregroundStyle(Color(red: 236/255, green: 178/255, blue: 183/255))
                        }
                        Spacer()
                    }
                    .padding(.top, geometry.size.height * 0.05)
                 
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: geometry.size.width * 0.02) {
                                ForEach(0..<allData.count, id: \.self) { index in
                                    Button {
                                        if allData.indices.contains(index) {
                                            selectedData = allData[index]
                                        }
                                    } label: {
                                        AsyncImage(url: allData[index].imagePath) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: (geometry.size.width * 0.8) / 3)
                                            case .failure(_):
                                                Rectangle()
                                                    .frame(width: (geometry.size.width * 0.8) / 3, height: geometry.size.height * 0.25)
                                                    .foregroundStyle(Color(red: 206/255, green: 206/255, blue: 206/255))
                                            @unknown default:
                                                Rectangle()
                                                    .frame(width: (geometry.size.width * 0.8) / 3, height: geometry.size.height * 0.25)
                                                    .foregroundStyle(Color(red: 206/255, green: 206/255, blue: 206/255))
                                            }
                                        }
                                    }

                                }
                            }
                            .frame(width: geometry.size.width * 0.8)
                            .padding(.horizontal)
                        }
                }
                
                Button {
                    showWritingView = true
                } label: {
                    Image("bt_add_log")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.15)
                }
                .position(x: geometry.size.width * 0.85, y: geometry.size.height * 0.9)
            }
         
            .onChange(of: selectedData, { oldValue, newValue in
                showDetailView = true
            })
            .fullScreenCover(isPresented: $showWritingView) {
                NewWritingView(showWritingView: $showWritingView)
            }
            .fullScreenCover(isPresented: $showDetailView) {
                if let data = selectedData {
                    NewLogDetailView(selectedData: data, showDetailView: $showDetailView)
                        .onAppear {
                            print("NewLogDetailView is opened with selectedData: \(data)")
                        }
                }
            }

            
        }
    }
}

#Preview {
    NewContentView()
        .environmentObject(UserData())
        .modelContainer(for: AjiwaiCardData.self)
}
