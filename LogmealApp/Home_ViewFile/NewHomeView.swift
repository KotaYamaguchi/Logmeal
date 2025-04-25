import SwiftUI
import PhotosUI
import SwiftData

struct NewHomeView: View {
    @State private var showWritingView = false
    @EnvironmentObject var user: UserData
    @Environment(\.modelContext) private var context
    @Query private var allData: [AjiwaiCardData]
    @State var selectedIndex: Int? = nil
    @State var showDetailView:Bool = false
    private var displayContentColor:Color{
        switch user.selectedCharacter{
        case "Dog": Color(red: 248/255, green: 201/255, blue: 201/255)
        case "Cat": Color(red: 198/255, green: 166/255, blue: 208/255)
        case "Rabbit": Color(red: 251/255, green: 233/255, blue: 184/255)
        default:
            Color.white
        }
    }
    private var backgoundImage:String{
        switch user.selectedCharacter{
        case "Dog":"bg_home_Dog"
        case "Cat":"bg_home_Cat"
        case "Rabbit":"bg_home_Rabbit"
        default:
            "bg_home_Dog"
        }
    }
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundImage(geometry: geometry)
                VStack {
                    userInfoPanel(geometry: geometry)
                    logGrid(geometry: geometry)
                }
                addLogButton(geometry: geometry)
               
            }
            .onAppear(){
                print("ーーーーーーーーーーーーアプリを起動しました！ーーーーーーーーーーーー")
            }
            .onChange(of: selectedIndex) { _, newValue in
                showDetailView = (newValue != nil)
            }
            .fullScreenCover(isPresented: $showWritingView) {
                NewWritingView(showWritingView: $showWritingView)
            }
            .fullScreenCover(isPresented: $showDetailView) {
                if let index = selectedIndex {
                    NewLogDetailView(dataIndex: index, showDetailView: $showDetailView)
                        .onDisappear(){
                            selectedIndex = nil
                        }
                }
            }
        }
    }

    private func backgroundImage(geometry: GeometryProxy) -> some View {
        Image("bg_HomeView_dog")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
            .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
    }

    private func userInfoPanel(geometry: GeometryProxy) -> some View {
        HStack{
            Spacer()
            VStack(spacing: 0){
                AsyncImage(url: user.userImage) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width * 0.2)
                            .clipShape(Circle())
                    case .failure(_):
                        Image("no_user_image")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.2)
                            .overlay {
                                Circle()
                                    .stroke(Color(red: 236/255, green: 178/255, blue: 183/255), lineWidth: 5)
                            }
                    @unknown default:
                        Image("no_user_image")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.2)
                            .overlay {
                                Circle()
                                    .stroke(Color(red: 236/255, green: 178/255, blue: 183/255), lineWidth: 5)
                            }
                    }
                }
                Text("\(user.name)")
                    .font(.custom("GenJyuuGothicX-Bold", size: geometry.size.width * 0.03))
                    .offset(y:-geometry.size.height*0.07)
            }
            VStack {
                HStack {
                    ForEach([
                        ("\(allData.count)", "ろぐ"),
                        ("\(user.point)", "ポイント"),
                        ("\(user.level)", "レベル")
                    ], id: \.1) { value, label in
                        VStack {
                            Text(value)
                                .font(.custom("GenJyuuGothicX-Bold", size: geometry.size.width * 0.06))
                            Text(label)
                                .font(.custom("GenJyuuGothicX-Bold", size: geometry.size.width * 0.04))
                        }
                        .padding(.horizontal, geometry.size.width * 0.05)
                    }
                }
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: geometry.size.width * 0.8, height: 3)
                    .foregroundStyle(Color(red: 236/255, green: 178/255, blue: 183/255))
            }
            Spacer()
        }
        .padding(.top, geometry.size.height * 0.05)
    }

    private func logGrid(geometry: GeometryProxy) -> some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: geometry.size.width * 0.005) {
                ForEach(0..<allData.count, id: \.self) { index in
                    Button {
                        selectedIndex = nil
                        DispatchQueue.main.async {
                            selectedIndex = index
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

    private func addLogButton(geometry: GeometryProxy) -> some View {
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
}

#Preview {
    NewContentView()
        .environmentObject(UserData())
        .modelContainer(for: AjiwaiCardData.self)
}
