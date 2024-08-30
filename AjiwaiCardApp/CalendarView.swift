import SwiftUI
import SwiftData

struct CalendarDisplayView: View {
    @EnvironmentObject var user: UserData
    @State private var currentDate = Date()
    @Binding var selectedDate: Date
    @State private var opacity: Double = 1.0
    private let calendar = Calendar(identifier: .gregorian)
    private let soundManager:SoundManager = SoundManager()
    let allData: [AjiwaiCardData]
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            ZStack {
                CalendarView(baseDate: currentDate, selectedDate: $selectedDate, width: width * 0.5, allData: allData)
                    .opacity(opacity)
                    .frame(width: width * 0.5, height: height * 0.8)
                    .position(x: width * 0.25, y: height * 0.5)
                    .padding(.horizontal)
                Button{
                    todayMonth()
                }label: {
                    Image("bt_base")
                        .resizable()
                        .overlay{
                            Text("今日")
                                .font(.custom("GenJyuuGothicX-Bold", size: 15))
                                .foregroundStyle(Color.buttonColor)
                        }
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width:120,height: 45)
                .position(x:width*0.4,y:height*0.18)
                
                Button{
                    previousMonth()
                }label: {
                    Image("bt_calendar_progress&back")
                        .rotationEffect(Angle.degrees(180))
                }
                .buttonStyle(PlainButtonStyle())
                .position(x: width * 0.035, y: height * 0.5)
                Button{
                    nextMonth()
                }label: {
                    Image("bt_calendar_progress&back")
                }
                .position(x: width * 0.495, y: height * 0.5)
                .buttonStyle(PlainButtonStyle())
                
            }
            .frame(width: width * 0.5, height: height * 0.9)
        }
    }
    
    private var yearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年"
        return formatter.string(from: currentDate)
    }
    
    private var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月"
        return formatter.string(from: currentDate)
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = newDate
        }
    }

    private func todayMonth() {
        currentDate = Date()
        selectedDate = Date()
    }
}


struct CalendarView: View {
    @EnvironmentObject var user: UserData
    let baseDate: Date
    @Binding var selectedDate: Date
    var width: CGFloat
    let allData: [AjiwaiCardData]
    
    private let calendar = Calendar(identifier: .gregorian)
    private let weeksInView = 6
    let subColors:[Color] = [
        Color(red: 219 / 255.0, green: 161 / 255.0, blue: 214 / 255.0), // 濃い紫
        Color(red: 249 / 255.0, green: 183 / 255.0, blue: 190 / 255.0), // 濃いピンク
        Color(red: 255 / 255.0, green: 153 / 255.0, blue: 102 / 255.0)  // 濃いオレンジ
    ]
    let mainColors:[Color] = [Color(red: 229 / 255.0, green: 221 / 255.0, blue: 237 / 255.0), // 薄い紫
                              Color(red: 247 / 255.0, green: 210 / 255.0, blue: 216 / 255.0), // 薄いピンク
                              Color(red: 239 / 255.0, green: 212 / 255.0, blue: 178 / 255.0) // 薄いオレンジ
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack{
                Text(yearString)
                    .font(.custom("GenJyuuGothicX-Bold", size: 15))
                Text(monthString)
                    .font(.custom("GenJyuuGothicX-Bold", size: 30))
            }
            
            HStack(spacing: 0) {
                ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { day in
                    Text(day)
                        .font(.custom("GenJyuuGothicX-Bold", size: 15))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
            }
            .background(
                ZStack{
                    RoundedRectangle(cornerRadius: 20)
                        .fill(backgroundSubColor)
                        .padding(.horizontal, -16)
                        .offset(x:5,y:5)
                    RoundedRectangle(cornerRadius: 20)
                        .fill(backgroundMainColor)
                        .padding(.horizontal, -16)
                }
            )
            .padding(.all)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
                ForEach(0..<(7 * weeksInView), id: \.self) { index in
                    let date = self.getDateForIndex(index)
                    DayView(date: date, isCurrentMonth: isDateInCurrentMonth(date), selectedDate: $selectedDate, width: width, allData: allData)
                }
            }
        }
        .padding(.all, 50)
        .background(
            ZStack{
                RoundedRectangle(cornerRadius: 40)
                    .foregroundStyle(.white)
                    .shadow(radius: 3,x: 10,y: 10)
                RoundedRectangle(cornerRadius: 40)
                    .stroke(Color.black.opacity(0.5),lineWidth: 2)
            }
        )
    }
    
    private var yearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年"
        return formatter.string(from: baseDate)
    }
    
    private var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月"
        return formatter.string(from: baseDate)
    }
    
    private var backgroundMainColor: Color {
        switch user.selectedCharacter {
        case "Dog":
            return mainColors[1]
        case "Cat":
            return mainColors[0]
        case "Rabbit":
            return mainColors[2]
        default:
            return mainColors[0]
        }
    }
    private var backgroundSubColor: Color {
        switch user.selectedCharacter {
        case "Dog":
            return subColors[1]
        case "Cat":
            return subColors[0]
        case "Rabbit":
            return subColors[2]
        default:
            return subColors[0]
        }
    }
    
    private func getDateForIndex(_ index: Int) -> Date? {
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: baseDate)),
              let weekStart = calendar.date(byAdding: .day, value: -calendar.component(.weekday, from: monthStart) + 1, to: monthStart) else {
            return nil
        }
        return calendar.date(byAdding: .day, value: index, to: weekStart)
    }
    
    private func isDateInCurrentMonth(_ date: Date?) -> Bool {
        guard let date = date else { return false }
        return calendar.isDate(date, equalTo: baseDate, toGranularity: .month)
    }
}

struct DayView: View {
    @EnvironmentObject var user: UserData
    let date: Date?
    let isCurrentMonth: Bool
    @Binding var selectedDate: Date
    let width: CGFloat
    let allData: [AjiwaiCardData]
    private let calendar = Calendar(identifier: .gregorian)
    
    private var fillColor:Color {
        switch user.selectedCharacter{
        case "Dog":
            return .red
        case "Cat":
            return .purple
        case "Rabbit":
            return .orange
        default:
            return .purple
        }
    }
    
    var body: some View {
        if let date = date {
            VStack {
                HStack {
                    Text(String(calendar.component(.day, from: date)))
                        .font(.custom("GenJyuuGothicX-Bold", size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.top, .leading], 4)
                        .foregroundColor(isCurrentMonth ? .black : .gray)
                    Spacer()
                }
                Spacer()
                if hasDataForDate(date) {
                    Image("mt_dotImage")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width * 0.06)
                        .padding(.bottom, 4)
                        .offset(y: -width * 0.04)
                }
            }
            .frame(maxWidth: .infinity, minHeight: width / 7)
            .background(
                Group {
                    if calendar.isDate(date, inSameDayAs: selectedDate) {
                        fillColor.opacity(0.3)
                    } else if calendar.isDate(date, inSameDayAs: Date()) {
                        Color.cyan.opacity(0.3)
                    } else {
                        Color.white
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
            )
            .onTapGesture {
                selectedDate = date
            }
        } else {
            Color.clear
                .frame(maxWidth: .infinity, minHeight: width / 7)
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
                )
        }
    }
    
    private func hasDataForDate(_ date: Date) -> Bool {
        return allData.contains { Calendar.current.isDate($0.saveDay, inSameDayAs: date) }
    }
}

#Preview(body: {
    LookBackView()
        .modelContainer(for:AjiwaiCardData.self)
        .environmentObject(UserData())
})
