import SwiftUI
import SwiftData
import PhotosUI

struct LogCardlView: View {
    
    @Environment(\.modelContext) private var context
    @EnvironmentObject var user: UserData
    
    @State private var isEditing = false
    
    let dataIndex: Int
    @Query private var allData: [AjiwaiCardData]
    
    private let senseIcons = ["mt_Eye_icon", "mt_Ear_icon", "mt_Nose_icon", "mt_Tongue_icon", "mt_Hand_Icon"]
    
    var body: some View {
        ZStack{
            if isEditing{
                LogEditView(isEditing: $isEditing, dataIndex: dataIndex)
            }else{
                LogDetailView(dataIndex: dataIndex)
            }
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    if !isEditing{
                        Button{
                            isEditing.toggle()
                        }label: {
                            Text("書き直す")
                                .font(.custom("GenJyuuGothicX-Bold",size:15))
                                .frame(width: 180, height: 50)
                                .background(Color.white)
                                .foregroundStyle(Color.cyan)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .overlay{
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.cyan ,lineWidth: 4)
                                }
                        }
                        .padding()
                    }
                }
            }
        }
    }
}

struct LogDetailView:View {
    @EnvironmentObject var user: UserData
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var allData: [AjiwaiCardData]
    private let senseIcons = ["mt_Eye_icon", "mt_Ear_icon", "mt_Nose_icon", "mt_Tongue_icon", "mt_Hand_Icon"]
    private let senseTitles = ["みため", "おと", "におい", "あじ", "さわりごこち"]
    private let senseColors: [Color] = [
        Color(red: 240 / 255, green: 145 / 255, blue: 144 / 255),
        Color(red: 243 / 255, green: 179 / 255, blue: 67 / 255),
        Color(red: 105 / 255, green: 192 / 255, blue: 160 / 255),
        Color(red: 139 / 255, green: 194 / 255, blue: 222 / 255),
        Color(red: 196 / 255, green: 160 / 255, blue: 193 / 255)
    ]
    private func dateFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    let dataIndex :Int
    @State private var detailUIImage: UIImage? = nil   // ←追加

       // ① UIImage の URL から読み込むユーティリティ
       private func getImageByUrl(url: URL) -> UIImage? {
           guard let data = try? Data(contentsOf: url),
                 let uiImage = UIImage(data: data) else {
               return nil
           }
           return uiImage
       }

       // ② アスペクト比に応じたサイズを返す関数（NewWritingView と同じ）
       private func frameSize(for image: UIImage) -> CGSize {
           let aspectRatio = image.size.width / image.size.height
           let tolerance: CGFloat = 0.01
           // 3:4 に「ほぼ一致」→幅300、その他→幅400
           let width: CGFloat = abs(aspectRatio - (3.0/4.0)) < tolerance
               ? 300.0
               : 400.0
           let height = width / aspectRatio
           return CGSize(width: width, height: height)
       }

    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                Image("bg_AjiwaiCardView")
                    .resizable()
                    .scaledToFill()
                    .blur(radius: 3)
                    .position(x:geometry.size.width*0.5,y:geometry.size.height*0.5)
                VStack{
                    HStack{
                        Button{
                            dismiss()
                        }label:{
                            Image("bt_close")
                                .resizable()
                                .scaledToFit()
                                .frame(width:geometry.size.width*0.05)
                        }
                        .padding(.horizontal)
                        Spacer()
                        dateBar(geometry: geometry)
                    }
                    
                    ScrollView{
                        HStack(alignment:.top){
                            VStack{
                                VStack{
                                    Text("今日のごはん")
                                        .font(.custom("GenJyuuGothicX-Bold", size: 25))
                                    Text("ごはんの写真を撮ろう！")
                                        .font(.custom("GenJyuuGothicX-Bold", size: 20))
                                        .foregroundStyle(.secondary)
                                    if let image = detailUIImage {
                                           // ③ フレームサイズを計算
                                           let size = frameSize(for: image)
                                           Image(uiImage: image)
                                               .resizable()
                                               .scaledToFill()
                                               .frame(width: size.width, height: size.height)
                                               .cornerRadius(15)
                                               .shadow(radius: 5)
                                               .padding()
                                       } else {
                                           // ロード中 or 失敗時
                                           Image("mt_No_Image")
                                               .resizable()
                                               .scaledToFill()
                                               .frame(width: 400, height: 300)
                                               .cornerRadius(15)
                                               .shadow(radius: 5)
                                               .padding()
                                       }
                                }
                                .padding()
                                .background{
                                    backgroundCard(geometry: geometry)
                                }
                                VStack{
                                    Text("今日のメニュー")
                                        .font(.custom("GenJyuuGothicX-Bold", size: 25))
                                    List{
                                        ForEach(0..<allData[dataIndex].menu.count,id:\.self){ index in
                                            Text(allData[dataIndex].menu[index])
                                                .frame(width: geometry.size.width*0.4)
                                        }
                                    }
                                    .scrollContentBackground(.hidden)
                                }
                                .padding()
                                .background{
                                    backgroundCard(geometry: geometry)
                                }
                                
                            }
                            VStack{
                                VStack{
                                    VStack{
                                        Text("五感で味わってみよう！")
                                            .font(.custom("GenJyuuGothicX-Bold", size: 25))
                                    }
                                    VStack(spacing:10){
                                        HStack(alignment:.bottom){
                                            Image("\(senseIcons[0])")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width:geometry.size.width*0.04)
                                            VStack(alignment:.leading){
                                                Text(allData[dataIndex].sight)
                                                    .frame(width:geometry.size.width*0.4)
                                                Rectangle()
                                                    .frame(width:geometry.size.width*0.4,height:1)
                                                    .foregroundStyle(senseColors[0])
                                            }
                                        }
                                        .padding()
                                    }
                                    VStack(spacing:10){
                                        HStack(alignment:.bottom){
                                            Image("\(senseIcons[1])")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width:geometry.size.width*0.04)
                                            VStack(alignment:.leading){
                                                Text(allData[dataIndex].hearing)
                                                    .frame(width:geometry.size.width*0.4)
                                                Rectangle()
                                                    .frame(width:geometry.size.width*0.4,height:1)
                                                    .foregroundStyle(senseColors[1])
                                            }
                                        }
                                        .padding()
                                    }
                                    VStack(spacing:10){
                                        HStack(alignment:.bottom){
                                            Image("\(senseIcons[2])")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width:geometry.size.width*0.04)
                                            VStack(alignment:.leading){
                                                Text(allData[dataIndex].smell)
                                                    .frame(width:geometry.size.width*0.4)
                                                Rectangle()
                                                    .frame(width:geometry.size.width*0.4,height:1)
                                                    .foregroundStyle(senseColors[2])
                                            }
                                        }
                                        .padding()
                                    }
                                    VStack(spacing:10){
                                        HStack(alignment:.bottom){
                                            Image("\(senseIcons[3])")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width:geometry.size.width*0.04)
                                            VStack(alignment:.leading){
                                                Text(allData[dataIndex].taste)
                                                    .frame(width:geometry.size.width*0.4)
                                                Rectangle()
                                                    .frame(width:geometry.size.width*0.4,height:1)
                                                    .foregroundStyle(senseColors[3])
                                            }
                                        }
                                        .padding()
                                    }
                                    VStack(spacing:10){
                                        HStack(alignment:.bottom){
                                            Image("\(senseIcons[4])")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width:geometry.size.width*0.04)
                                            VStack(alignment:.leading){
                                                Text(allData[dataIndex].tactile)
                                                    .frame(width:geometry.size.width*0.4)
                                                Rectangle()
                                                    .frame(width:geometry.size.width*0.4,height:1)
                                                    .foregroundStyle(senseColors[4])
                                            }
                                        }
                                        .padding()
                                    }
                                }
                                .padding()
                                .background{
                                    backgroundCard(geometry: geometry)
                                }
                                
                            }
                            
                        }
                        .padding()
                    }
                }
            }
            .onAppear {
                // 非同期化せず同期的にロードしていますが、
                // サイズ計算だけなら問題ありません
                detailUIImage = getImageByUrl(
                    url: allData[dataIndex].imagePath
                )
            }
        }
    }
    @ViewBuilder private func backgroundCard(geometry:GeometryProxy) -> some View{
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .frame(width: geometry.size.width*0.47)
                .foregroundStyle(.white)
                .shadow(radius: 10)
                .overlay {
                    VStack{
                        
                        HStack{
                            ZStack{
                                Circle()
                                    .frame(width: 13)
                                    .foregroundStyle(.gray)
                                Circle()
                                    .frame(width: 10)
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                            ZStack{
                                Circle()
                                    .frame(width: 13)
                                    .foregroundStyle(.gray)
                                Circle()
                                    .frame(width: 10)
                                    .foregroundStyle(.white)
                            }
                        }
                        Spacer()
                        HStack{
                            ZStack{
                                Circle()
                                    .frame(width: 13)
                                    .foregroundStyle(.gray)
                                Circle()
                                    .frame(width: 10)
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                            ZStack{
                                Circle()
                                    .frame(width: 13)
                                    .foregroundStyle(.gray)
                                Circle()
                                    .frame(width: 10)
                                    .foregroundStyle(.white)
                            }
                        }
                        
                    }
                    .padding()
                }
        }
    }
    
    private func dateBar(geometry: GeometryProxy) -> some View {
        VStack(alignment:.trailing){
            
            Image("mt_DateBar")
                .resizable()
                .scaledToFit()
                .frame(width:geometry.size.width*0.32)
                .shadow(radius: 3,y:10)
                .overlay {
                    HStack {
                        Text(dateFormatter(date: allData[dataIndex].saveDay))
                        Text("：")
                        if let time = allData[dataIndex].time{
                            Text(changeTimeStamp(timeStamp: time))
                        }else{
                            Text("-")
                        }
                    }
                    .font(.custom("GenJyuuGothicX-Bold", size: 28))
                    .foregroundColor(.white)
                }
            
        }
    }
    private func changeTimeStamp(timeStamp:TimeStamp) -> String{
        switch timeStamp{
        case .morning:
            return "あさ"
        case .lunch:
            return "ひる"
        case .dinner:
            return "よる"
        default:
            return "ー"
        }
    }
    
    private func labelFor(time: TimeStamp) -> String {
        switch time {
        case .morning:
            return "あさ"
        case .lunch:
            return "ひる"
        case .dinner:
            return "よる"
        }
    }
}
