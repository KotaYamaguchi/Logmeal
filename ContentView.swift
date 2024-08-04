//
//  ContentView.swift
//  Gohan_Navigation_ver.1
//
//  Created by 山口昂大 on 2023/12/15.
//
//ellipsis,text.justify
import SwiftUI
import SwiftData
struct ContentView: View {
    //App内全体で共有する変数
    @EnvironmentObject var user:UserData
    @Environment(\.modelContext) private var context
    @Query private var allData: [AjiwaiCardData]
    //開発用：ファイルネーム
    @State var itemName = ""
    @State var develop = false
    //アラート表示
    @State var showMenu = false

    private var gridItem = [GridItem(.flexible()),GridItem(.flexible())]
    func removeDocumentFile(itemName:String){
        let fileManager = FileManager.default
        var pathString = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0]
        if !fileManager.fileExists(atPath: pathString + "/" + itemName){
            print("そのファイルは存在しません")
        }
        pathString = "file://" + pathString + "/" + itemName
        guard let path = URL(string: pathString) else {return}
        do {
            try fileManager.removeItem(at: path)
            print("ファイルの削除に成功しました")
        }catch {
            print("ファイルの削除に失敗しました")
        }
    }
    var body: some View {
        NavigationStack(path:$user.path){
            GeometryReader{ geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                ZStack(alignment:.topLeading){
                    Image("bg_TitleView")
                        .resizable()
                        .ignoresSafeArea()
                        .scaledToFill()
                        .frame(width:geometry.size.width*1.05,height: geometry.size.height)
                        .position(x:geometry.size.width*0.5,y:geometry.size.height*0.5)
                        
                        .onTapGesture {
                            if !develop{
                                
                                user.path.append(.home)
                            }
                        }
                        Button{
                            showMenu = true
                        }label: {
                            Text("開発者用")
                                .font(.title)
                                
                        }.padding(.all)
                    
                    if develop{
                        forDevelop()
                            .position(x:width/2,y:height/2)
                            .background(){
                                Color.white
                                    .ignoresSafeArea()
                                    .frame(width:width,height: height)
                            }
                    }else{
                        Text("画面をタップしてゲームを始めよう")
                            .foregroundStyle(.gray)
                            .padding(.top, 30)
                            .position(x: width * 0.5, y: height * 0.8)
                    }
                }//Zstack
            }//GeometryReader
            .navigationDestination(for: Homepath.self) { value in
                    switch value {
                    case .home:
                        ChildHomeView()
                            .navigationBarBackButtonHidden(true)
                    case .ajiwaiCard:
                        WritingAjiwaiCardView()
                            .navigationBarBackButtonHidden(true)
                    case .reward:
                        AjiwaiThirdView()
                            .navigationBarBackButtonHidden(true)
                    }
                }
            .sheet(isPresented: $showMenu){
                VStack{
                    HStack{
                        Button{
                            develop.toggle()
                            showMenu.toggle()
                        }label: {
                            Text("開発用")
                                .frame(width: 300,height: 50)
                                .background(Color.cyan)
                                .foregroundStyle(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        Button{
                           
                        }label: {
                            Text("利用規約")
                                .frame(width: 300,height: 50)
                                .background(Color.cyan)
                                .foregroundStyle(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                    HStack{
                      
                        Button{
                           
                        }label: {
                            Text("研究について")
                                .frame(width: 300,height: 50)
                                .background(Color.cyan)
                                .foregroundStyle(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        Button{
                           
                        }label: {
                            Text("設定")
                                .frame(width: 300,height: 50)
                                .background(Color.cyan)
                                .foregroundStyle(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                    Button{
                        showMenu = false
                    }label: {
                        Text("戻る")
                    }
                }
            }
        }
        //NavifationStack
        
        //NavigationStackとNavigationPathを設定
        
    }//body
    @ViewBuilder func forDevelop() ->some View{
        VStack{
            //開発用
            Button{
                UserDefaults.standard.removeObject(forKey: "isLogined")
            }label: {
                Text("もう一度、初めてログイン画面にする")
                    .frame(width: 350,height: 50)
                    .background(Color.cyan)
                    .foregroundStyle(Color.white)
                    .cornerRadius(20)

            }
            Button{
                let appDomain = Bundle.main.bundleIdentifier
                UserDefaults.standard.removePersistentDomain(forName: appDomain!)
            }label: {
                Text("全てのアプリデータを削除")
                    .frame(width: 350,height: 50)
                    .background(Color.cyan)
                    .foregroundStyle(Color.white)
                    .cornerRadius(20)
            }
            Button{
                DeleteAll(modelContext: context)
            }label: {
                Text("SwiftDataのデータをすべて削除")
                    .frame(width: 350,height: 50)
                    .background(Color.cyan)
                    .foregroundStyle(Color.white)
                    .cornerRadius(20)
            }
            TextField("ファイル名を入力して下のボタンをタップ", text: $itemName)
                .frame(width: 350)
                .textFieldStyle(.roundedBorder)
            Button{
                removeDocumentFile(itemName: itemName)
            }label: {
                Text("DocumentFolderのデータ削除")
                    .frame(width: 350,height: 50)
                    .background(Color.cyan)
                    .foregroundStyle(Color.white)
                    .cornerRadius(20)
            }
            Button{
                develop = false
            }label: {
                Text("戻る")
            }
        }
    }
}//View

#Preview {
    ContentView()
        .environmentObject(UserData())
}
struct teacherView: View {
    var body: some View {
        GeometryReader{
            let size = $0.size
            
            Image("column3:4")
                .resizable()
                .ignoresSafeArea(.all)
                .frame(width: size.width,height: size.height)
                .position(x:size.width*0.5,y:size.height*0.5)
                .navigationBarBackButtonHidden(true)
        }
    }
}
