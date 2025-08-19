import SwiftUI
import SwiftData
struct LaunchScreen: View {
    @State private var isLoading = true
    @EnvironmentObject var user: UserData
    @Environment(\.modelContext) private var context
    @Query private var allData: [AjiwaiCardData]
    @Query private var characters: [Character]
    var body: some View {
        GeometryReader{ geometry in
            if isLoading{
                ZStack{
                    Image("logmeal_icon_view")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 50))
                        .frame(width:geometry.size.width*0.5,height: geometry.size.height*0.5)
                        .position(x:geometry.size.width*0.5,y: geometry.size.height*0.5)
                    Text("© 2024 Iimura Laboratory , Prefectural University of Kumamoto")
                        .font(.custom("GenJyuuGothicX-Bold", size: 18))
                        .position(x:geometry.size.width*0.5,y: geometry.size.height*0.9
                        )
                }
                .onAppear {
                    user.migrateLegacyData(context: context)
                    for card in allData{
                        if card.uuid == nil{
                            card.uuid = UUID()
                            print("card.uuid", card.uuid)
                        }
                        if card.time == nil{
                            card.time = .lunch
                            print("card.time", card.time)
                        }
                        do{
                            try context.save()
                        } catch {
                            print("マイグレーションエラー")
                        }
                    }
                    if characters.isEmpty {
                        let dogData = Character(name: "Dog", level: 0, exp: 0, growthStage: 1, isSelected: false)
                        let rabbitData = Character(name: "Rabbit", level: 0, exp: 0, growthStage: 1, isSelected: false)
                        let catData = Character(name: "Cat", level: 0, exp: 0, growthStage: 1, isSelected: false)
                        
                        context.insert(dogData)
                        context.insert(rabbitData)
                        context.insert(catData)
                        
                        do{
                            try context.save()
                            print("初期キャラクターデータを保存しました。")
                        }catch{
                            print("Failed to save initial character data: \(error)")
                        }
                    }else{
                        print("キャラクターデータは既に存在します。")
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation {
                            isLoading = false
                        }
                    }
                    
                }
            }else{
                TitleView()
            }
        }
    }
}

#Preview {
    LaunchScreen()
        .environmentObject(UserData())
}
