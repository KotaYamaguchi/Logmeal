import SwiftUI

struct ColumnView: View {
    @EnvironmentObject var user: UserData
    @State private var columnTitle: String = ""
    @State private var columnContent: String = ""
    @State private var columnnTitleArray: [String: String] = [:]
    @State private var columnnCaptionArray: [String: String] = [:]

    private func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }

    private func loadColumnData() {
        columnnTitleArray = user.loadStringDictionary(forKey: "monthlyColumnTitle")
        columnnCaptionArray = user.loadStringDictionary(forKey: "monthlyColumnCaption")
        
        let dateKey = user.dateFormatter(date: user.saveDay)
        
        columnTitle = columnnTitleArray[dateKey] ?? "No title available"
        columnContent = columnnCaptionArray[dateKey] ?? "No content available"
        
        print(columnTitle)
        print(columnContent)
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text(columnTitle)
                    
                    .padding(.bottom, 5)
                Divider()
                ScrollView {
                    Text(columnContent)
                        .font(.body)
                }
                .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.5)
            }
            .frame(width: geometry.size.width * 0.5)
            .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.6)
            .background {
                Image("bg_ColumnView")
                    .resizable()
                    .scaledToFit()
                    .frame(height: geometry.size.height*1.3)
            }
            .onAppear {
                loadColumnData()
            }
        }
    }
}

#Preview {
    ChildHomeView()
        .environmentObject(UserData())
}
