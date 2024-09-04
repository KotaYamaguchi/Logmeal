//import SwiftUI
//
//struct AjiwaiFirstView: View {
//    @EnvironmentObject var user: UserData
//    @ObservedObject var sheetManager = SpreadSheetManager()
//    @State private var ajiwaiText = ""
//    @State private var GokanTexts = ["", "", "", "", ""]
//    @State private var menuList: [String] = []
//    
//    @State private var feelings = ["視覚", "聴覚", "嗅覚", "味覚", "触覚"]
//    private let iconArray = ["mt_Eye_icon", "mt_Ear_icon", "mt_Nose_icon", "mt_Tongue_icon", "mt_Hand_Icon"]
//    private let colors: [Color] = [
//        Color(red: 240/255, green: 145/255, blue: 144/255),
//        Color(red: 243/255, green: 179/255, blue: 67/255),
//        Color(red: 105/255, green: 192/255, blue: 160/255),
//        Color(red: 139/255, green: 194/255, blue: 222/255),
//        Color(red: 196/255, green: 160/255, blue: 193/255)
//    ]
//    @State private var isPresentedCameraView = false
//    @State private var image: UIImage?
//    @State private var showDatePicker = false
//    @State private var showImageView = false
//    @State private var showMenuView = false
//    @State private var showAjiwaiView = false
//    @State private var showGokanView = false
//    @State private var showQRScaner = false
//    @State private var showMenuTextFields = false
//    @FocusState private var isFocused: Bool
//    @FocusState private var focusedField: Int?
//    @State private var textFieldsCount: Int = 1
//    @State private var textValues: [String] = Array(repeating: "", count: 10)
//    @State var monthlyMenu: [String:[String]] = [:]
//    @State var monthlyColumnTitle: [String:String] = [:]
//    @State var monthlyColumnCaption: [String:String] = [:]
//    @State var saveForNow:[String:String] = [:]
//    @State var saveForNowMenu:[String:[String]] = [:]
//    
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack(alignment:.top){
//                HStack {
//                    backButton
//                        .padding()
//                    Spacer()
//                    dateButton
//                }
//                mainView(size: geometry.size)
//                    .position(x:geometry.size.width*0.5,y:geometry.size.height*0.5)
//                VStack {
//                    if !showDatePicker && !showAjiwaiView && !showGokanView && !showMenuTextFields {
//                            doneButton
//                            .position(x:geometry.size.width*0.9,y:geometry.size.height*0.95)
//                    }
//                }
//            }
//            .background {
//                Image("bg_AjiwaiCardView")
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: geometry.size.width, height: geometry.size.height)
//            }
//            .onAppear(){
//                print(user.monthlyMenu)
//            }
//            .fullScreenCover(isPresented: $isPresentedCameraView) {
//                CameraView(image: $image)
//                    .ignoresSafeArea()
//            }
//            .sheet(isPresented:$showQRScaner){
//                ScannerView(isPresentingScanner: $showQRScaner, monthlyMenu: $monthlyMenu, monthlyColumnTitle: $monthlyColumnTitle, monthlyColumnCaption: $monthlyColumnCaption)
//            }
//        }
//    }
//    
//    @ViewBuilder
//    private func mainView(size: CGSize) -> some View {
//        ZStack {
//            switchContent(size: size)
//            if showDatePicker {
//                datePickerOverlay(size: size)
//            }
//        }
//    }
//    
//    @ViewBuilder
//    private func switchContent(size: CGSize) -> some View {
//        if showAjiwaiView {
//            AjiwaiCardPlace(size: size)
//                .background(backgroundImage(size: size, showOverlay: false))
//        } else if showGokanView {
//            GokanTextPlace(size: size)
//                .background(backgroundImage(size: size, showOverlay: false))
//        } else if showMenuTextFields {
//            menuTextFieldView(size: size)
//        } else {
//            justApperView(size: size)
//                .disabled(showDatePicker)
//        }
//    }
//    
//    @ViewBuilder
//    private func menuTextFieldView(size: CGSize) -> some View {
//        VStack {
//            ForEach(0..<textFieldsCount, id: \.self) { index in
//                TextField("Text Field \(index + 1)", text: $textValues[index])
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .focused($focusedField, equals: index)
//                    .padding(.horizontal)
//            }
//            Button {
//                textFieldsCount += 1
//                focusedField! += 1
//            } label: {
//                Image(systemName: "plus")
//            }
//            Button{
//                showMenuTextFields = false
//            }label: {
//                Text("完了")
//            }
//        }
//        .onAppear {
//            focusedField = 0
//            textFieldsCount = 1
//        }
//        .onDisappear {
//            for value in 0..<textFieldsCount {
//                menuList.append(textValues[value])
//            }
//        }
//        .position(x: size.width * 0.5, y: size.height * 0.5)
//        .background(backgroundImage(size: size, showOverlay: true))
//    }
//    
//    @ViewBuilder
//    private func backgroundImage(size: CGSize, showOverlay: Bool) -> some View {
//        Image("bg_AjiwaiCardView")
//            .resizable()
//            .scaledToFill()
//            .frame(width: size.width, height: size.height)
//            .onTapGesture {
//                if isFocused{
//                    isFocused = false
//                }else if focusedField != nil{
//                    focusedField = nil
//                }
//            }
//    }
//    
//    @ViewBuilder
//    private func datePickerOverlay(size: CGSize) -> some View {
//        Color.black.opacity(0.4)
//            .edgesIgnoringSafeArea(.all)
//            .onTapGesture {
//                showDatePicker = false
//            }
//        VStack {
//            DatePicker("", selection: $user.saveDay, displayedComponents: [.date])
//                .datePickerStyle(.graphical)
//                .environment(\.locale, Locale(identifier: "ja_JP"))
//            Divider()
//            HStack {
//                Button {
//                    showDatePicker = false
//                } label: {
//                    Text("閉じる")
//                        .padding()
//                }
//                Spacer()
//            }
//        }
//        .frame(width: size.width * 0.3, height: size.height * 0.7)
//        .padding()
//        .background(
//            Color.white
//                .cornerRadius(15)
//        )
//        .zIndex(5)
//    }
//    
//    @ViewBuilder
//    private func AjiwaiCardPlace(size: CGSize) -> some View {
//        VStack{
//            TextField("給食の感想を書こう", text: $ajiwaiText, axis: .vertical)
//                .focused($isFocused)
//                .frame(width: size.width * 0.3, height: size.height * 0.3)
//                .scrollContentBackground(.hidden)
//                .background{
//                    Image("mt_AjiwaiCard")
//                        .frame(width: size.width * 0.4, height: size.height * 0.4)
////                        .onChange(of: ajiwaiText) { _, newValue in
////                            user.ajiwaiText = newValue.replacingOccurrences(of: ",", with: "、")
////                            user.ajiwaiText = newValue.replacingOccurrences(of: "\n", with: " ")
////                        }
//                }
//            Button{
//                showAjiwaiView = false
//            }label: {
//                Text("完了")
//            }
//            .padding(.top)
//        }
//        .onAppear {
//            isFocused = true
//        }
//        .onChange(of: ajiwaiText) { oldValue, newValue in
//            user.ajiwaiText = newValue
//        }
//    }
//    
//    @ViewBuilder
//    private func GokanTextPlace(size: CGSize) -> some View {
//        VStack(spacing: 0) {
//            ForEach(0..<feelings.count, id: \.self) { index in
//                TextField(feelings[index], text: $GokanTexts[index])
//                    .feelingsTextFieldStyle(image: iconArray[index], underlineColor: colors[index])
//                    .focused($focusedField, equals: index)
//                    .background(){
//                        RoundedRectangle(cornerRadius: 25.0)
//                            .foregroundColor(.white.opacity(0.01))
//                    }
//            }
//            Button{
//                showGokanView = false
//            }label: {
//                Text("完了")
//            }
//        }
//        .frame(width: size.width / 2.5, height: size.height / 2.5)
//        .onAppear {
//            focusedField = 0
//        }
//        .onChange(of: GokanTexts) { oldValue, newValue in
//            user.GokanTexts = newValue
//        }
//    }
//    
//    @ViewBuilder
//    private func justApperView(size: CGSize) -> some View {
//        ZStack {
//            HStack {
//                VStack {
//                    imageView(size: size)
//                    menuView(size: size)
//                }
//                .background{
//                        Image("bg_MenuList")
//                        .resizable()
//                        .frame(width:size.width*0.35,height: size.height*0.85)
//                }
//                VStack {
//                    
//                    Text(ajiwaiText)
//                        .frame(width: size.width * 0.3, height: size.height * 0.3)
//                        .background {
//                            Image("mt_AjiwaiCard")
//                                .resizable()
//                                .frame(width: size.width * 0.4, height: size.height * 0.4)
//                                .overlay(alignment: .topLeading) {
//                                    if ajiwaiText.isEmpty {
//                                        Text("給食の感想を書こう！")
//                                            .foregroundStyle(.gray)
//                                            .offset(x: size.width * 0.03, y: size.height * 0.07)
//                                    }
//                                }
//                        }
//                        .padding(.bottom)
//                        .onTapGesture {
//                            showAjiwaiView = true
//                        }
//                    
//                    gokanView(size: size)
//                    
//                }
//            }
//        }
//        .onChange(of: [monthlyColumnTitle, monthlyColumnCaption]) { oldValue, newValue in
//            //QRからのデータを追加、同じ日付のものを追加したときは新しい方が優先される
//            saveForNow = user.loadStringDictionary(forKey: "monthlyColumnTitle")
//            saveForNow.merge(monthlyColumnTitle){(current, new) in current}
//            user.monthlyColumnTitle = saveForNow
//            user.writeStringDictionary(user.monthlyColumnTitle, forKey: "monthlyColumnTitle")
//            
//            
//            saveForNow = user.loadStringDictionary(forKey: "monthlyColumnCaption")
//            saveForNow.merge(monthlyColumnCaption){(current, new) in current}
//            user.monthlyColumnCaption = saveForNow
//            user.writeStringDictionary(user.monthlyColumnCaption, forKey: "monthlyColumnCaption")
//            
//        }
//        .onChange(of: monthlyMenu) { oldValue, newValue in
//            saveForNowMenu = user.loadMonthlyMenu()
//            saveForNowMenu.merge(monthlyMenu){(current, new) in current}
//            user.monthlyMenu = saveForNowMenu
//            user.saveMonthlyMenu()
//            print(user.monthlyMenu)
//        }
//        .onAppear(){
//            print("メニュー\(user.monthlyMenu)")
//            print("コラムタイトル\(user.monthlyColumnTitle)")
//            print("コラム本文\(user.monthlyColumnCaption)")
//        }
//        
//    }
//    
//    @ViewBuilder
//    private func imageView(size: CGSize) -> some View {
//        let placeholderImage = Image("mt_No_Image")
//        
//        if let uiimage = user.uiimage ?? UIImage(systemName: "mt_No_Image") {
//            Image(uiImage: uiimage)
//                .resizable()
//                .scaledToFit()
//                .frame(width: size.width * 0.3)
//                .onChange(of: image) { _, newValue in
//                    user.uiimage = newValue ?? UIImage(systemName: "mt_No_Image")
//                }
//                .onTapGesture {
//                    isPresentedCameraView = true
//                }
//        } else {
//            placeholderImage
//                .resizable()
//                .scaledToFit()
//                .frame(width: size.width * 0.3)
//                .onTapGesture {
//                    isPresentedCameraView = true
//                }
//        }
//    }
//    
//    
//    @ViewBuilder
//    private func menuView(size: CGSize) -> some View {
//        VStack {
//            Text("今日の献立")
//                .padding(.bottom)
//            
//            ForEach(menuList, id: \.self) { menu in
//                Text(menu)
//            }
//            
//            if menuList.isEmpty {
//                VStack {
//                    Button {
//                        showQRScaner = true
//                    } label: {
//                        Text("QRコードから入力する")
//                    }
//                    Button {
//                        showMenuTextFields = true
//                    } label: {
//                        Text("自分で入力する")
//                    }
//                }
//            }
//        }
//        .onAppear {
//            readMenu()
//        }
//        .onChange(of: user.saveDay) { oldValue, newValue in
//            readMenu()
//        }
//        .onChange(of: user.monthlyMenu) { oldValue, newValue in
//            monthlyMenu = user.loadMonthlyMenu()
//            readMenu()
//        }
//        .onAppear(){
//            monthlyMenu = user.loadMonthlyMenu()
//            readMenu()
//        }
//        .frame(width: size.width * 0.4, height: size.height * 0.4)
//        .background {
//            Rectangle()
//                .foregroundStyle(.white.opacity(0.01))
//        }
//    }
//    
//    private func readMenu() {
//        monthlyMenu = user.loadMonthlyMenu()
//        if let data = monthlyMenu[user.dateFormatter(date: user.saveDay)] {
//            menuList = data
//            print("Menu loaded from monthlyMenu")
//        } else {
//            menuList = []
//            print("No menu available for this date")
//        }
//    }
//    
//    @ViewBuilder
//    private func gokanView(size: CGSize) -> some View {
//        VStack{
//            ForEach(0..<feelings.count, id: \.self) { i in
//                HStack {
//                    Image(iconArray[i])
//                        .resizable()
//                        .frame(width: 35, height: 35)
//                    VStack(alignment:.leading){
//                        Text(GokanTexts[i])
//                        if !GokanTexts[i].isEmpty {
//                            Text(user.GokanTexts[i])
//                        } else {
//                            Text(feelings[i])
//                                .foregroundStyle(.gray.opacity(0.5))
//                        }
//                        Rectangle()
//                            .frame(height: 2)
//                            .foregroundStyle(colors[i])
//                    }
//                }
//            }
//        }
//        .padding()
//        .frame(width: size.width / 2.5, height: size.height / 2.5)
//        .background {
//            Rectangle()
//                .foregroundStyle(.white.opacity(0.001))
//        }
//        .onTapGesture {
//            showGokanView = true
//        }
//    }
//    
//    private var backButton: some View {
//        Button {
//            user.path.removeLast()
//        } label: {
//            Image("bt_back")
//                .resizable()
//                .scaledToFit()
//                .frame(height: 50)
//        }
//        .buttonStyle(PlainButtonStyle())
//    }
//    
//    private var dateButton: some View {
//        Button {
//            showDatePicker.toggle()
//        } label: {
//            Image("mt_DateBar")
//                .resizable()
//                .scaledToFit()
//                .frame(height: 50)
//                .overlay {
//                    Text(user.dateFormatter(date: user.saveDay))
//                        .foregroundStyle(.white)
//                        .font(.title)
//                }
//        }
//        .offset(x:20)
//        .buttonStyle(PlainButtonStyle())
//    }
//    
//    private var doneButton: some View {
//        Button {
//            user.path.append(.reward)
//            user.todayMenu = menuList
//        } label: {
//            Image("bt_done")
//                .padding(.bottom)
//        }
//        .buttonStyle(PlainButtonStyle())
//    }
//    
//    private func getCurrentDate() -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        return dateFormatter.string(from: Date())
//    }
//}
//
//
//
//extension View {
//    func feelingsTextFieldStyle(image: String, underlineColor: Color) -> some View {
//        self.modifier(FeelingsTextFieldStyle(image: image, underlineColor: underlineColor))
//    }
//}
//
//public struct CameraView: UIViewControllerRepresentable {
//    @Binding private var image: UIImage?
//    
//    @Environment(\.dismiss) private var dismiss
//    
//    public init(image: Binding<UIImage?>) {
//        self._image = image
//    }
//    
//    public func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    public func makeUIViewController(context: Context) -> UIImagePickerController {
//        let viewController = UIImagePickerController()
//        viewController.delegate = context.coordinator
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            viewController.sourceType = .camera
//        }
//        
//        return viewController
//    }
//    
//    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
//}
//
//extension CameraView {
//    public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//        let parent: CameraView
//        
//        init(_ parent: CameraView) {
//            self.parent = parent
//        }
//        
//        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
//            if let uiImage = info[.originalImage] as? UIImage {
//                self.parent.image = uiImage
//            }
//            self.parent.dismiss()
//        }
//        
//        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//            self.parent.dismiss()
//        }
//    }
//}
//
//struct CustomDatePicker: View {
//    @Binding var showDatePicker: Bool
//    @Binding var savedDate: Date?
//    @State private var selectedDate: Date = Date()
//    
//    var body: some View {
//        ZStack {
//            Color.black.opacity(0.3)
//                .edgesIgnoringSafeArea(.all)
//                .onTapGesture {
//                    showDatePicker = false
//                }
//            VStack {
//                DatePicker("", selection: $selectedDate, displayedComponents: [.date])
//                    .datePickerStyle(.graphical)
//            }
//            .background(
//                Color.white
//                    .cornerRadius(30)
//            )
//        }
//    }
//}
//
//#Preview {
//    AjiwaiFirstView()
//        .environmentObject(UserData())
//}
