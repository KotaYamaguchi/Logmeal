import SwiftUI
import SwiftData

struct NewColumnView: View {
    @State private var searchText: String = ""
    @State private var isOpenSortMenu: Bool = false
    @State private var sortTitle: String = "新しい順"
    @State private var showQRscanner:Bool = false
    @EnvironmentObject var user:UserData
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
    private var backgoundImage:String{
        switch user.selectedCharacter{
        case "Dog":"bg_column_Dog"
        case "Cat":"bg_column_Cat"
        case "Rabbit":"bg_column_Rabbit"
        default:
            "bg_column_Dog"
        }
    }
    // 今日の日付を "yyyy-MM-dd" 形式で取得
    private func formattedToday() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(backgoundImage)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                ScrollViewReader{ proxy in
                ZStack{
                    VStack {
                        HStack {
                            Spacer()
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
                                    Button {
                                        if let todayColumn = sortedColumns.first(where: {
                                            $0.columnDay == formattedToday()
                                        }) {
                                            withAnimation {
                                                proxy.scrollTo(todayColumn.id, anchor: .top)
                                            }
                                        }
                                    } label: {
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
                            Spacer()
                            Button{
                                showQRscanner = true
                            }label:{
                                Circle()
                                    .foregroundStyle(.cyan)
                                    .frame(width:60)
                                    .overlay{
                                        Image(systemName:"plus")
                                            .font(.system(size: 40))
                                            .foregroundStyle(.white)
                                    }
                            }
                            Spacer()
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
                                            HStack{
                                                Text(column.title)
                                                    .font(.custom("GenJyuuGothicX-Bold", size: geometry.size.width * 0.05))
                                                    .padding(.bottom)
                                                Spacer()
                                                Text(column.columnDay)
                                                    .font(.custom("GenJyuuGothicX-Bold", size: geometry.size.width * 0.02))
                                                    .padding(.bottom)
                                            }
                                            
                                            Text(column.caption)
                                                .lineLimit(column.isExpanded ? nil : 2)
                                                .font(.custom("GenJyuuGothicX-Bold", size: geometry.size.width * 0.025))
                                        }
                                        Spacer()
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
                                .id(column.id)
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
            }
            }
            .position(x:geometry.size.width*0.5,y:geometry.size.height*0.5)
            .sheet(isPresented:$showQRscanner){
                ScannerView(isPresentingScanner: $showQRscanner)
            }
        }
    }
}
#Preview{
    let previewContainer = try! ModelContainer(
        for: ColumnData.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    // 今日の日付をフォーマット
    let today: String = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }()
    
    let sampleData: [ColumnData] = [
        ColumnData(columnDay: "2025-04-01", title: "春の味覚", caption: "春の食材を楽しもう"),
        ColumnData(columnDay: "2025-04-02", title: "栄養バランス", caption: "色とりどりの野菜を取り入れよう"),
        ColumnData(columnDay: "2025-04-03", title: "食育ってなに？", caption: "食育の意味を考えよう"),
        ColumnData(columnDay: "2025-04-04", title: "和食の魅力", caption: "味噌汁とご飯の組み合わせ"),
        ColumnData(columnDay: "2025-04-05", title: "朝ごはんの大切さ", caption: "一日の元気は朝ごはんから"),
        ColumnData(columnDay: today, title: "今日のおすすめ", caption: "今日の給食に使われている旬の野菜！"),
        ColumnData(columnDay: "2025-04-07", title: "噛む力", caption: "よく噛むことで脳が活性化"),
        ColumnData(columnDay: "2025-04-08", title: "水分補給", caption: "ジュースよりお水やお茶を"),
        ColumnData(columnDay: "2025-04-09", title: "おやつの選び方", caption: "体に優しいおやつとは？"),
        ColumnData(columnDay: "2025-04-10", title: "マナーを学ぼう", caption: "いただきますの意味")
    ]
    
    for column in sampleData {
        previewContainer.mainContext.insert(column)
    }
    
    return NewContentView()
        .environmentObject(UserData())
        .modelContainer(previewContainer)
}

#Preview {
    let previewContainer = try! ModelContainer(
        for: ColumnData.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    // 今日の日付をフォーマット
    let today: String = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }()
    
    let sampleData: [ColumnData] = [
        ColumnData(columnDay: "2025-04-01", title: "春の味覚", caption: "春の食材を楽しもう"),
        ColumnData(columnDay: "2025-04-02", title: "栄養バランス", caption: "色とりどりの野菜を取り入れよう"),
        ColumnData(columnDay: "2025-04-03", title: "食育ってなに？", caption: "食育の意味を考えよう"),
        ColumnData(columnDay: "2025-04-04", title: "和食の魅力", caption: "味噌汁とご飯の組み合わせ"),
        ColumnData(columnDay: "2025-04-05", title: "朝ごはんの大切さ", caption: "一日の元気は朝ごはんから"),
        ColumnData(columnDay: today, title: "今日のおすすめ", caption: "今日の給食に使われている旬の野菜！"),
        ColumnData(columnDay: "2025-04-07", title: "噛む力", caption: "よく噛むことで脳が活性化"),
        ColumnData(columnDay: "2025-04-08", title: "水分補給", caption: "ジュースよりお水やお茶を"),
        ColumnData(columnDay: "2025-04-09", title: "おやつの選び方", caption: "体に優しいおやつとは？"),
        ColumnData(columnDay: "2025-04-10", title: "マナーを学ぼう", caption: "いただきますの意味")
    ]
    
    for column in sampleData {
        previewContainer.mainContext.insert(column)
    }
    
    return NewColumnView()
        .modelContainer(previewContainer)
        .environmentObject(UserData())
}
