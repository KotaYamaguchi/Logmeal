import SwiftUI
import SwiftData

struct NewColumnView: View {
    @State private var searchText:String = ""
    @State private var isOpenSortMenu:Bool = false
    @State private var sortTitle:String = "新しい順"
    @Query private var allColumn: [ColumnData]
    var body: some View {
        ZStack{
            Image("bg_NewColumnView_dog")
                .resizable()
                .ignoresSafeArea()
            VStack{
                HStack{
                    Image("mt_ColumnViewTitle")
                    VStack{
                        TextField("", text: $searchText)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 420,height: 50)
                            .overlay{
                                if searchText.isEmpty{
                                    HStack{
                                        Image(systemName: "magnifyingglass")
                                        Text("キーワードで検索")
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    .foregroundStyle(.gray)
                                }
                            }
                        HStack{
                            Button{
                                
                            }label: {
                                RoundedRectangle(cornerRadius: 30)
                                    .foregroundStyle(Color(red: 243/255, green: 180/255, blue: 187/255))
                                    .frame(width: 200,height: 50)
                                    .overlay {
                                        Text("今日のコラム")
                                           
                                    }
                            }
                                Button{
                                    withAnimation {
                                        isOpenSortMenu.toggle()
                                    }
                                }label: {
                                    RoundedRectangle(cornerRadius: 30)
                                        .foregroundStyle(.white)
                                        .frame(width: 200,height: 50)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 30)
                                                .stroke(lineWidth: 2)
                                                .foregroundStyle(.gray)
                                            HStack{
                                                Text(sortTitle)
                                                Image(systemName: isOpenSortMenu ?  "chevron.compact.up": "chevron.compact.down")
                                            }
                                            
                                        }
                                }
                            
                        }
                        
                    }
                }
                ScrollView{
                    ForEach(0..<10){ i in
                        ZStack(alignment:.topLeading){
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: .infinity,height: 160)
                                .foregroundStyle(.white)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(lineWidth: 1)
                                        .frame(width: .infinity,height: 160)
                                }
                            HStack(alignment: .bottom){
                                VStack(alignment: .leading){
                                    Text("いわしで頭が良くなる！？")
                                        .font(.custom("GenJyuuGothicX-Bold", size: 40))
                                        .padding(.bottom)
                                    Text("イワシを食べると頭がよくなる！？🐟💡実は、イワシには**DHA（ドコサヘキサエン酸）**という脳にとって大切な栄養が入っているよ！✨DHAは「考える力」や「記憶する力」をパワーアップしてくれるんだ！📚✅ **集中力がアップ！** 宿題やテストのときに役立つよ✏️ ✅ **記憶力がアップ！** 新しいことをどんどん覚えられる✨✅ **元気な体をつくる！** イワシにはカルシウムも入っているよ💪イワシの缶詰や焼き魚を食べて、スーパーキッズになっちゃおう！💪✨")
                                        .lineLimit(2)
                                        .font(.custom("GenJyuuGothicX-Bold", size: 17))
                                }
                                Button{
                                    
                                }label:{
                                    Image(systemName: "chevron.compact.down")
                                }
                            }
                            .padding()
                        }
                        .padding(.horizontal,50)
                            
                    }
                }
                .padding()
            }
            VStack{
                Button{
                    
                    withAnimation {
                        sortTitle = "五十音順"
                        isOpenSortMenu = false
                    }
                    
                }label: {
                    Image("mt_AtoZ")
                        .resizable()
                        .scaledToFit()
                        .frame(height:50)
                }
                
                Button{
                    
                    withAnimation {
                        sortTitle = "新しい順"
                        isOpenSortMenu = false
                    }
                }label: {
                    Image("mt_newer")
                        .resizable()
                        .scaledToFit()
                        .frame(height:50)
                }
                
                Button{
                    
                    withAnimation {
                        sortTitle = "古い順"
                        isOpenSortMenu = false
                    }
                }label: {
                    Image("mt_older")
                        .resizable()
                        .scaledToFit()
                        .frame(height:50)
                }
            }
            .background{
                RoundedRectangle(cornerRadius: 20)
                    .frame(width:200,height: 200)
                    .foregroundStyle(.white)
                    .shadow(radius: 10)
            }
            .position(x:720,y:80)
            .offset(y: isOpenSortMenu ? 140 : 100)
            .opacity(isOpenSortMenu ? 1.0 : 0)
        }
        
    }
}
#Preview{
    NewColumnView()
        .environmentObject(UserData())
        .modelContainer(for: [AjiwaiCardData.self,MenuData.self,ColumnData.self])
}
