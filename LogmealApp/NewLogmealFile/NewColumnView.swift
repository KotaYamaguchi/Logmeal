import SwiftUI
import SwiftData

struct NewColumnView: View {
    @State private var searchText:String = ""
    @State private var isOpenSortMenu:Bool = false
    @State private var sortTitle:String = "新しい順"
    @Query private var allColumn: [ColumnData]
    var body: some View {
        ZStack{
            Image("bg_HomeView_dog")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            VStack {
                HStack {
                    Image("mt_ColumnViewTitle")
                    VStack {
                        TextField("", text: $searchText)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 420, height: 50)
                            .overlay {
                                if searchText.isEmpty {
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                        Text("キーワードで検索")
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    .foregroundStyle(.gray)
                                }
                            }
                        HStack {
                            Button {} label: {
                                RoundedRectangle(cornerRadius: 30)
                                    .foregroundStyle(Color(red: 243/255, green: 180/255, blue: 187/255))
                                    .frame(width: 200, height: 50)
                                    .overlay {
                                        Text("今日のコラム")
                                    }
                            }
                            Button {
                                withAnimation {
                                    isOpenSortMenu.toggle()
                                }
                            } label: {
                                RoundedRectangle(cornerRadius: 30)
                                    .foregroundStyle(.white)
                                    .frame(width: 200, height: 50)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(lineWidth: 2)
                                            .foregroundStyle(.gray)
                                        HStack {
                                            Text(sortTitle)
                                            Image(systemName: isOpenSortMenu ? "chevron.compact.up" : "chevron.compact.down")
                                        }
                                    }
                            }
                        }
                    }
                }
                ScrollView {
                    ForEach(allColumn) { column in
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(.white)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(lineWidth: 1)
                                }
                            HStack(alignment: .bottom) {
                                VStack(alignment: .leading) {
                                    Text(column.title) // ColumnData の title を表示
                                        .font(.custom("GenJyuuGothicX-Bold", size: 40))
                                        .padding(.bottom)
                                    
                                    
                                  
                                    Text(column.caption) // ColumnData の content を表示
                                        .lineLimit(column.isExpanded ? nil : 2)
                                        .font(.custom("GenJyuuGothicX-Bold", size: 17))
                                }
                                
                                Button {
                                    withAnimation {
                                        column.isExpanded.toggle()
                                    }
                                } label: {
                                    Image(systemName: column.isExpanded ? "chevron.compact.up" : "chevron.compact.down")
                                        .font(.title)
                                }
                            }
                            .padding()
                        }
                        .padding(.horizontal, 50)
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
