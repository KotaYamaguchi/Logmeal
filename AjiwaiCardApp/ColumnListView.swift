import SwiftUI

struct ColumnListView: View {
    @EnvironmentObject var user: UserData
    @State private var sortedDates: [String] = []
    @State private var selectedDate: String?
    @State private var searchText = ""
    @State private var selectedMonth: String?
    @State private var sortAscending = true
    @State private var scrollProxy: ScrollViewProxy?
    
    private func loadColumnData() {
        user.monthlyColumnTitle = user.loadStringDictionary(forKey: "monthlyColumnTitle")
        user.monthlyColumnCaption = user.loadStringDictionary(forKey: "monthlyColumnCaption")
        updateSortedDates()
    }
    
    private func updateSortedDates() {
        var filteredDates = user.monthlyColumnTitle.keys.filter { date in
            let lowercaseSearch = searchText.lowercased()
            return searchText.isEmpty ||
            normalizeJapanese(date).contains(normalizeJapanese(lowercaseSearch)) ||
            normalizeJapanese(user.monthlyColumnTitle[date] ?? "").contains(normalizeJapanese(lowercaseSearch))
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
        let allDates = user.monthlyColumnTitle.keys
        let months = Set(allDates.map { String($0.prefix(7)) })
        return Array(months).sorted(by: <)
    }
    
    private var todayString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }
    
    private func getClosestColumnId() -> String? {
        let sortedDatesAscending = user.monthlyColumnTitle.keys.sorted(by: <)
        return sortedDatesAscending.first { $0 >= todayString }
    }
    
    var body: some View {
            NavigationSplitView {
                ZStack {
                    // 背景を白に
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
                            
                            Button(action: {
                                sortAscending.toggle()
                                updateSortedDates()
                            }) {
                                Image(systemName: sortAscending ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                            }
                            
                            Button("今日のコラム") {
                                if let closestColumnId = getClosestColumnId() {
                                    withAnimation {
                                        scrollProxy?.scrollTo(closestColumnId, anchor: .top)
                                    }
                                }
                            }
                            .buttonStyle(CustomButtonStyle())
                        }
                        .padding(.horizontal)
                        
                        ScrollViewReader { proxy in
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(sortedDates, id: \.self) { date in
                                        Button(action: {
                                            selectedDate = date
                                        }) {
                                            ColumnCard(date: date, title: user.monthlyColumnTitle[date] ?? "")
                                        }

                                        .id(date)
                                       
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
                }
                .onChange(of: searchText, { _, _ in
                    updateSortedDates()
                })
                .onChange(of: selectedMonth, { _, _ in
                    updateSortedDates()
                })
                
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "検索...")
                .disableAutocorrection(true)
                .autocapitalization(.none)
            } detail: {
                if let selectedDate = selectedDate,
                   let title = user.monthlyColumnTitle[selectedDate],
                   let content = user.monthlyColumnCaption[selectedDate] {
                    ColumnDetailView(title: title, content: content)
                } else {
                    Text("コラムを選択してください")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
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
                .font(.caption)
                .foregroundColor(.secondary)
            Text(title)
                .font(.headline)
                .lineLimit(2)
            HStack {
                Spacer()
                Image(systemName: "book.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ColumnDetailView: View {
    let title: String
    let content: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.bottom, 10)
                Text(content)
                    .font(.body)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
            }
            .padding()
        }
        .navigationTitle("コラム詳細")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(20)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut, value: configuration.isPressed)
    }
}

// Preview用のサンプルデータ
struct ColumnListView_Previews: PreviewProvider {
    static var previews: some View {
        let userData = UserData()
        userData.monthlyColumnTitle = [
            "2024-07-15": "夏の健康管理について",
            "2024-07-10": "効果的な学習方法",
            "2024-07-05": "環境にやさしい生活習慣"
        ]
        userData.monthlyColumnCaption = [
            "2024-07-15": "夏の健康管理に関する詳細な内容...",
            "2024-07-10": "効果的な学習方法についての詳細...",
            "2024-07-05": "環境にやさしい生活習慣についての詳細..."
        ]
        
        return ColumnListView()
            .environmentObject(userData)
    }
}

