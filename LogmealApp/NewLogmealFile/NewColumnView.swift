import SwiftUI
import SwiftData

struct NewColumnView: View {
    @State private var searchText: String = ""
    @State private var isOpenSortMenu: Bool = false
    @State private var sortTitle: String = "新しい順"
    @Query private var allColumn: [ColumnData]
    // ソート済みのカラムリスト
    private var sortedColumns: [ColumnData] {
        switch sortTitle {
        case "新しい順":
            return allColumn.sorted(by: { $0.columnDay > $1.columnDay })
        case "古い順":
            return allColumn.sorted(by: { $0.columnDay < $1.columnDay })
        case "五十音順":
            return allColumn.sorted(by: { $0.title < $1.title })
        default:
            return allColumn
        }
    }
    // フィルタリングされたカラムリスト
    private var filteredColumns: [ColumnData] {
        if searchText.isEmpty {
            return sortedColumns
        } else {
            return sortedColumns.filter { column in
                column.title.contains(searchText) || column.caption.contains(searchText)
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
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
                                .frame(width: geometry.size.width * 0.4, height: geometry.size.height * 0.06)
                                .overlay {
                                    if searchText.isEmpty {
                                        HStack {
                                            Image(systemName: "magnifyingglass")
                                            Text("キーワードで検索")
                                                .font(.custom("GenJyuuGothicX-Bold", size: geometry.size.width * 0.02))
                                            Spacer()
                                        }
                                        .padding(.horizontal)
                                        .foregroundStyle(.gray)
                                    }else{
                                        HStack{
                                            Spacer()
                                            Button{
                                                searchText = ""
                                            }label:{
                                                Image(systemName:"xmark.circle.fill")
                                                    .foregroundStyle(.gray)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            
                            HStack {
                                Button {} label: {
                                    RoundedRectangle(cornerRadius: 30)
                                        .foregroundStyle(Color(red: 243/255, green: 180/255, blue: 187/255))
                                        .frame(width: geometry.size.width * 0.2, height: geometry.size.height * 0.06)
                                        .overlay {
                                            Text("今日のコラム")
                                                .font(.custom("GenJyuuGothicX-Bold", size: geometry.size.width * 0.02))
                                        }
                                }
                                
                                Button {
                                    withAnimation {
                                        isOpenSortMenu.toggle()
                                    }
                                } label: {
                                    RoundedRectangle(cornerRadius: 30)
                                        .foregroundStyle(.white)
                                        .frame(width: geometry.size.width * 0.2, height: geometry.size.height * 0.06)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 30)
                                                .stroke(lineWidth: 2)
                                                .foregroundStyle(.gray)
                                            HStack {
                                                Text(sortTitle)
                                                    .font(.custom("GenJyuuGothicX-Bold", size: geometry.size.width * 0.02))
                                                Image(systemName: isOpenSortMenu ? "chevron.compact.up" : "chevron.compact.down")
                                            }
                                        }
                                }
                            }
                        }
                    }
                    ScrollView {
                        ForEach(filteredColumns) { column in
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(.white)
                                    .frame(width: geometry.size.width * 0.95)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(lineWidth: 1)
                                    }
                                HStack(alignment: .bottom) {
                                    VStack(alignment: .leading) {
                                        Text(column.title)
                                            .font(.custom("GenJyuuGothicX-Bold", size: geometry.size.width * 0.05))
                                            .padding(.bottom)
                                        
                                        Text(column.caption)
                                            .lineLimit(column.isExpanded ? nil : 2)
                                            .font(.custom("GenJyuuGothicX-Bold", size: geometry.size.width * 0.025))
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
                                .frame(width: geometry.size.width * 0.9)
                                .padding()
                            }
                            .padding(.horizontal, geometry.size.width * 0.05)
                        }
                    }
                    .padding()
                }
                
                VStack {
                    Button {
                        sortTitle = "五十音順"
                        withAnimation {
                            isOpenSortMenu = false
                        }
                    } label: {
                        Image("mt_AtoZ")
                            .resizable()
                            .scaledToFit()
                            .frame(height: geometry.size.height * 0.06)
                    }
                    
                    Button {
                        sortTitle = "新しい順"
                        withAnimation {
                            isOpenSortMenu = false
                        }
                    } label: {
                        Image("mt_newer")
                            .resizable()
                            .scaledToFit()
                            .frame(height: geometry.size.height * 0.06)
                    }
                    
                    Button {
                        sortTitle = "古い順"
                        withAnimation {
                            isOpenSortMenu = false
                        }
                    } label: {
                        Image("mt_older")
                            .resizable()
                            .scaledToFit()
                            .frame(height: geometry.size.height * 0.06)
                    }
                }
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: geometry.size.width * 0.2, height: geometry.size.height * 0.2)
                        .foregroundStyle(.white)
                        .shadow(radius: 10)
                }
                .position(x: geometry.size.width * 0.92, y: geometry.size.height * 0.15)
                .offset(y: isOpenSortMenu ? geometry.size.height * 0.1 : geometry.size.height * 0.07)
                .opacity(isOpenSortMenu ? 1.0 : 0)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .position(x:geometry.size.width*0.5,y:geometry.size.height*0.5)
        }
    }
}
#Preview{
    NewHomeView()
        .environmentObject(UserData())
        .modelContainer(for: [AjiwaiCardData.self,MenuData.self,ColumnData.self])
}
