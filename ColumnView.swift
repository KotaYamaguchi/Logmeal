import SwiftUI
import SwiftData

struct ColumnView: View {
    @Environment(\.modelContext) private var context
    @Query private var allColumn: [ColumnData]
    @EnvironmentObject var user: UserData
    @State private var currentColumn: ColumnData?
    @State private var showNoColumnAlert: Bool = false

    private func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }

    private func loadColumnData() {
        let currentDate = getCurrentDate()
        currentColumn = allColumn.first(where: { $0.columnDay == currentDate })
        
        if currentColumn != nil && !currentColumn!.isRead {
            currentColumn!.isRead = true
            try? context.save()
        }
        
        if currentColumn == nil {
            showNoColumnAlert = true
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack{
                Image("bg_ColumnView")
                    .resizable()
                    .scaledToFit()
                    .frame(height: geometry.size.height*1)
                    .overlay{
                        VStack {
                            if let column = currentColumn {
                                Text(column.title)
                                    .font(.custom("GenJyuuGothicX-Bold", size: 25))
                                    .padding(.all, 5)
                                Divider()
                                ScrollView {
                                    Text(column.caption)
                                        .font(.custom("GenJyuuGothicX-Bold", size: 17))
                                }
                                .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.4)
                            } else {
                                Text("今日のコラムはありません")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 17))
                            }
                        }
                        .offset(y:geometry.size.height*0.1)
                        .frame(width: geometry.size.width * 0.5)

                    }
            }
            .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.6)
            .background {

            }
            .onAppear {
                loadColumnData()
            }
            
        }
    }
}

#Preview{
    ChildHomeView()
        .environmentObject(UserData())
        .modelContainer(for: [AjiwaiCardData.self, MenuData.self, ColumnData.self])
}
