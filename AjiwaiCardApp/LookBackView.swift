import SwiftUI
import SwiftData

struct LookBackView: View {
    @Environment(\.modelContext) private var context
    @Query private var allData: [AjiwaiCardData]
    @EnvironmentObject var user: UserData
    @State private var selectDate: Date = Date()
    @State private var showDetail: Bool = false
    @Environment(\.dismiss) private var dismiss
    var filteredData: AjiwaiCardData? {
        allData.first { Calendar.current.isDate($0.saveDay, inSameDayAs: selectDate) }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("bg_AjiwaiCardView")
                    .resizable()
                    .ignoresSafeArea()
                Button {
                    dismiss()
                } label: {
                    Image("bt_back")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
                .position(x: geometry.size.width * 0.05, y: geometry.size.height * 0.05)
                CalendarDisplayView(selectedDate: $selectDate, allData: allData)
                    .frame(width: geometry.size.width * 0.85, height: geometry.size.height)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
                AjiwaiCardDataPreview(selectedDate: selectDate, allData: allData, showDetail: $showDetail)
                    .position(x: geometry.size.width * 0.75, y: geometry.size.height * 0.5)
            }
            .fullScreenCover(isPresented: $showDetail) {
                if let data = filteredData {
                    AjiwaiCardDetailView(selectedDate: selectDate, data: data)
                }
            }
        }
    }
}

#Preview {
    LookBackView()
        .environmentObject(UserData())
        .modelContainer(for:AjiwaiCardData.self)
}

struct AjiwaiCardDataPreview: View {
    let selectedDate: Date
    let allData: [AjiwaiCardData]
    
    var filteredData: AjiwaiCardData? {
        allData.first { Calendar.current.isDate($0.saveDay, inSameDayAs: selectedDate) }
    }
    @Binding var showDetail: Bool
    var body: some View {
        VStack{
            Spacer()
            if let data = filteredData {
                
                AsyncImage(url: data.imagePath) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        ZStack{
                            
                            image
                                .resizable()
                                .frame(width: 400,height:300)
                                .offset(y:-40)
                            Image("mt_calenderView_imageFrame_Cat")
                                .resizable()
                                .frame(width: 650,height:400)
                        }
                        
                        
                        
                    case .failure(_):
                        ZStack{
                            Image("mt_No_Image")
                                .resizable()
                                .frame(width: 400,height:300)
                                .offset(y:-40)
                            Image("mt_calenderView_imageFrame_Cat")
                                .resizable()
                                .frame(width: 650,height:400)
                        }
                        
                        
                    @unknown default:
                        ZStack{
                            Image("mt_No_Image")
                                .resizable()
                                .frame(width: 400,height:300)
                                .offset(y:-40)
                            Image("mt_calenderView_imageFrame_Cat")
                                .resizable()
                                .frame(width: 650,height:400)
                        }
                    }
                }
                .offset(y:50)
                Image("mt_calenderView_menuList")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400)
                    .overlay{
                        VStack(alignment:.leading){
                            ForEach(data.menu, id: \.self) { content in
                                VStack(alignment: .leading, spacing: 0){
                                    Text("・" + content)
                                        .font(.title2)
                                        .foregroundStyle(Color.black)
                                    Rectangle()
                                        .frame(width: 300, height: 1)
                                        .foregroundStyle(Color.gray)
                                }
                                .padding(.vertical,2)
                            }
                        }
                    }
                Button {
                    showDetail = true
                } label: {
                    Text("詳しく見る")
                }
            } else {
                Text("データがありません")
            }
            Spacer()
        }
    }
}


import SwiftUI
import SwiftData

struct AjiwaiCardDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    let selectedDate: Date
    @Bindable var data: AjiwaiCardData
    @State private var editedLunchComments: String
    @State private var editedSight: String
    @State private var editedTaste: String
    @State private var editedTactile: String
    @State private var editedSmell: String
    @State private var editedHearing: String
    @State private var editedMenu: [String]
    @State private var showingSaveAlert = false

    init(selectedDate: Date, data: AjiwaiCardData) {
        self.selectedDate = selectedDate
        self.data = data
        _editedLunchComments = State(initialValue: data.lunchComments)
        _editedSight = State(initialValue: data.sight)
        _editedTaste = State(initialValue: data.taste)
        _editedTactile = State(initialValue: data.tactile)
        _editedSmell = State(initialValue: data.smell)
        _editedHearing = State(initialValue: data.hearing)
        _editedMenu = State(initialValue: data.menu)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    imageSection
                    menuSection
                    commentSection
                    sensesSection
                }
                .padding()
            }
            .background(Color(UIColor.systemGray6))
            .navigationTitle("味わいカード編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        showingSaveAlert = true
                    }
                    .foregroundColor(.blue)
                }
            }
            .alert("変更を保存", isPresented: $showingSaveAlert) {
                Button("キャンセル", role: .cancel) { }
                Button("保存") {
                    saveChanges()
                    dismiss()
                }
            } message: {
                Text("変更を保存しますか？")
            }
        }
    }
    
    private var imageSection: some View {
        VStack {
            Text("今日の一枚")
                .font(.headline)
                .padding(.bottom, 5)
            AsyncImage(url: data.imagePath) { image in
                image.resizable().aspectRatio(contentMode: .fit)
            } placeholder: {
                    Image("mt_No_Image")
                        .resizable()
                        .scaledToFit()
                        .frame(height:400)
                   
                
            }
            .frame(height: 400)
            .cornerRadius(5)
            .shadow(radius: 5)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
    }
    
    private var menuSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("メニュー")
                .font(.headline)
            ForEach($editedMenu.indices, id: \.self) { index in
                HStack {
                    Image(systemName: "fork.knife")
                        .foregroundColor(.orange)
                    TextField("メニュー項目", text: $editedMenu[index])
                }
            }
            .onDelete(perform: deleteMenuItem)
            Button(action: {
                editedMenu.append("")
            }) {
                Label("メニュー項目を追加", systemImage: "plus.circle.fill")
            }
            .foregroundColor(.green)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
    }
    
    private var commentSection: some View {
        VStack(alignment: .leading) {
            Text("感想")
                .font(.headline)
            TextEditor(text: $editedLunchComments)
                .frame(height: 100)
                .padding(5)
                .background(Color(UIColor.systemGray5))
                .cornerRadius(8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
    }
    
    private var sensesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("五感")
                .font(.headline)
            senseRow(icon: "eye.fill", title: "視覚", binding: $editedSight)
            senseRow(icon: "ear.fill", title: "聴覚", binding: $editedHearing)
            senseRow(icon: "nose.fill", title: "嗅覚", binding: $editedSmell)
            senseRow(icon: "mouth.fill", title: "味覚", binding: $editedTaste)
            senseRow(icon: "hand.point.up.fill", title: "触覚", binding: $editedTactile)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
    }
    
    private func senseRow(icon: String, title: String, binding: Binding<String>) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width:30,height: 30)
            Text(title)
                .foregroundColor(.gray)
            TextField(title, text: binding)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }

    private func deleteMenuItem(at offsets: IndexSet) {
        editedMenu.remove(atOffsets: offsets)
    }

    private func saveChanges() {
        data.lunchComments = editedLunchComments
        data.sight = editedSight
        data.taste = editedTaste
        data.tactile = editedTactile
        data.smell = editedSmell
        data.hearing = editedHearing
        data.menu = editedMenu
        try? context.save()
    }
}
