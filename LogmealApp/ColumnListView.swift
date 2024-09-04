import SwiftUI
import SwiftData


struct ColumnListView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var allColumn: [ColumnData]
    @State private var sortedDates: [String] = []
    @State private var selectedDate: String?
    @State private var searchText = ""
    @State private var selectedMonth: String?
    @State private var sortAscending = true
    @State private var scrollProxy: ScrollViewProxy?
    private let soundManager = SoundManager.shared
    @AppStorage("hasSeenColumnListViewTutorial") private var hasSeenTutorial = false
    @State private var showHowToUseView = false

    private func loadColumnData() {
        updateSortedDates()
    }
    
    private func updateSortedDates() {
        var filteredDates = allColumn.map { $0.columnDay }.filter { date in
            let lowercaseSearch = searchText.lowercased()
            return searchText.isEmpty ||
            normalizeJapanese(date).contains(normalizeJapanese(lowercaseSearch)) ||
            normalizeJapanese(allColumn.first(where: { $0.columnDay == date })?.title ?? "").contains(normalizeJapanese(lowercaseSearch))
        }
        
        if let selectedMonth = selectedMonth {
            filteredDates = filteredDates.filter { $0.prefix(7) == selectedMonth }
        }
        
        sortedDates = filteredDates.sorted(by: sortAscending ? (<) : (>))
    }
    
    private func normalizeJapanese(_ text: String) -> String {
        text.applyingTransform(.hiraganaToKatakana, reverse: false)?
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased() ?? text
    }
    
    private var months: [String] {
        let allDates = allColumn.map { $0.columnDay }
        let months = Set(allDates.map { String($0.prefix(7)) })
        return Array(months).sorted(by: <)
    }
    
    private var todayString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }
    
    private func getClosestColumnId() -> String? {
        let sortedDatesAscending = allColumn.map { $0.columnDay }.sorted(by: <)
        return sortedDatesAscending.first { $0 >= todayString }
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            NavigationSplitView {
                ZStack {
                    Color.white.edgesIgnoringSafeArea(.all)
                    VStack(spacing: 16) {
                        HStack {
                            Picker("月を選択", selection: $selectedMonth) {
                                Text("全て").tag(String?.none)
                                
                                ForEach(months, id: \.self) { month in
                                    Text(formatMonth(month)).tag(String?.some(month))
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            
                            Spacer()
                            
                            Button {
                                sortAscending.toggle()
                                updateSortedDates()
                                soundManager.playSound(named: "se_negative")
                            } label: {
                                Image(systemName: sortAscending ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                    .foregroundColor(Color.buttonColor)
                                    .font(.title2)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button {
                                if let closestColumnId = getClosestColumnId() {
                                    soundManager.playSound(named: "se_negative")
                                    withAnimation {
                                        scrollProxy?.scrollTo(closestColumnId, anchor: .top)
                                        selectedDate = closestColumnId  // 今日のコラムを選択状態にする
                                    }
                                }
                            } label: {
                                Text("今日のコラム")
                            }
                            .font(.custom("GenJyuuGothicX-Bold", size: 15))
                            .buttonStyle(CustomButtonStyle())
                        }
                        .padding(.horizontal)
                        
                        ScrollViewReader { proxy in
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(sortedDates, id: \.self) { date in
                                        Button {
                                            soundManager.playSound(named: "se_negative")
                                            selectedDate = date
                                        } label: {
                                            if let column = allColumn.first(where: { $0.columnDay == date }) {
                                                ColumnCard(date: date, title: column.title)
                                            }
                                        }
                                        .id(date)
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .onAppear {
                                loadColumnData()
                                scrollProxy = proxy
                            }
                        }
                    }
                }
                .navigationTitle("コラム一覧")
                .onAppear {
                    loadColumnData()
                    if !hasSeenTutorial {
                        showHowToUseView = true
                    }
                }
                .onChange(of: searchText) { _, _ in
                    updateSortedDates()
                }
                .onChange(of: selectedMonth) { _, _ in
                    updateSortedDates()
                }
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "検索...")
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .toolbar(removing: .sidebarToggle) // Remove the default sidebar toggle button
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            HStack(spacing: 7) {
                                Image(systemName: "chevron.backward")
                                    .bold()
                                    .foregroundStyle(Color.buttonColor)
                                Text("もどる")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 16))
                                    .foregroundStyle(Color.buttonColor)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            } detail: {
                if let selectedDate = selectedDate,
                   let column = allColumn.first(where: { $0.columnDay == selectedDate }) {
                    DestinationCard(title: column.title, description: column.caption)
                } else {
                    ZStack {
                        Image("bg_AjiwaiCardView")
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                        Text("コラムを選択してください")
                            .font(.custom("GenJyuuGothicX-Bold", size: 25))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showHowToUseView) {
                TutorialView(imageArray: ["HowToUseColumnList"])
                    .interactiveDismissDisabled()
                    .onDisappear() {
                        hasSeenTutorial = true
                    }
            }
            
            Button {
                showHowToUseView = true
                soundManager.playSound(named: "se_positive")
            } label: {
                Image("bt_description")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
            .buttonStyle(PlainButtonStyle())
            .padding()
        }
    }
    
    private func formatMonth(_ month: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        dateFormatter.locale = Locale(identifier: "ja_JP")
        
        if let date = dateFormatter.date(from: month) {
            dateFormatter.dateFormat = "yyyy年M月"
            return dateFormatter.string(from: date)
        }
        return month
    }
}



struct ColumnCard: View {
    let date: String
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(date)
                .font(.custom("GenJyuuGothicX-Bold", size: 13))
                .foregroundColor(.secondary)
            Text(title)
                .font(.custom("GenJyuuGothicX-Bold", size: 17))
                .lineLimit(2)
            HStack {
                Spacer()
                Image(systemName: "book.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.white)
        .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.blue.opacity(0.3), lineWidth: 2)
        )
    }
}

struct DestinationCard: View {
    let imageName: String = "fork.knife"
    let title: String
    let description: String
    let systemNames:[String] = ["cup.and.saucer.fill","mug.fill","takeoutbag.and.cup.and.straw.fill","wineglass.fill","waterbottle.fill","birthday.cake.fill","carrot.fill","fork.knife"]
    var body: some View {
        GeometryReader{ geometry in
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    VStack(alignment: .center) {
                        Spacer()
                        Image(systemName: systemNames.randomElement()!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundColor(.blue)
                            .padding()
                            .background(Circle().fill(Color.blue.opacity(0.1)))
                        Spacer()
                        Text(title)
                            .font(.custom("GenJyuuGothicX-Bold", size: 25))
                        Divider()
                        Text(description)
                            .font(.custom("GenJyuuGothicX-Bold", size: 17))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Spacer()
                    }
                    .padding()
                    .frame(width: geometry.size.width*0.7, height: geometry.size.height*0.9)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 2)
                    Spacer()
                }
                Spacer()
            }
            .background(){
                Image("bg_AjiwaiCardView")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
        }
    }
}
struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.buttonColor)
            .foregroundColor(.white)
            .cornerRadius(20)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut, value: configuration.isPressed)
    }
}

#Preview{
    ColumnListView()
        .environmentObject(UserData())
        .modelContainer(for: [AjiwaiCardData.self,MenuData.self,ColumnData.self])
}
