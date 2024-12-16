import SwiftUI

struct NewColumnView: View {
    @State private var searchText:String = ""
    @State private var isOpenSortMenu:Bool = false
    var body: some View {
        ZStack{
            Image("bg_NewColumnView_tomato")
                .resizable()
                .ignoresSafeArea()
            VStack{
                HStack{
                    Image("mt_ColumnViewTitle")
                    VStack{
                        TextField("", text: $searchText)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 420,height: 50)
                            .overlay{
                                if searchText.isEmpty{
                                    HStack{
                                        Image(systemName: "magnifyingglass")
                                        Text("キーワードで検索")
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    .foregroundStyle(.gray)
                                }
                            }
                        HStack{
                            Button{
                                
                            }label: {
                                RoundedRectangle(cornerRadius: 30)
                                    .foregroundStyle(Color(red: 243/255, green: 180/255, blue: 187/255))
                                    .frame(width: 200,height: 50)
                                    .overlay {
                                        Text("今日のコラム")
                                    }
                            }
                                Button{
                                    withAnimation {
                                        isOpenSortMenu.toggle()
                                    }
                                }label: {
                                    RoundedRectangle(cornerRadius: 30)
                                        .foregroundStyle(.white)
                                        .frame(width: 200,height: 50)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 30)
                                                .stroke(lineWidth: 2)
                                                .foregroundStyle(.gray)
                                            HStack{
                                                Text("新しい順")
                                                Image(systemName: isOpenSortMenu ?  "chevron.compact.up": "chevron.compact.down")
                                            }
                                            
                                        }
                                }
                            
                        }
                        
                    }
                }
                ScrollView{
                    ForEach(0..<10){ i in
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: .infinity,height: 200)
                            .padding(.horizontal,50)
                            .foregroundStyle(.white)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(lineWidth: 1)
                                    .frame(width: .infinity,height: 200)
                                    .padding(.horizontal,50)
                                
                                
                            }
                        
                        
                    }
                }
                .padding()
            }
            VStack{
                Button{
                    
                }label: {
                    Image("mt_AtoZ")
                        .resizable()
                        .scaledToFit()
                        .frame(height:50)
                }
                
                Button{
                    
                }label: {
                    Image("mt_newer")
                        .resizable()
                        .scaledToFit()
                        .frame(height:50)
                }
                
                Button{
                    
                }label: {
                    Image("mt_older")
                        .resizable()
                        .scaledToFit()
                        .frame(height:50)
                }
            }
            .background{
                RoundedRectangle(cornerRadius: 20)
                    .frame(width:200,height: 200)
                    .foregroundStyle(.white)
                    .shadow(radius: 10)
            }
            .position(x:720,y:80)
            .offset(y: isOpenSortMenu ? 140 : 100)
            .opacity(isOpenSortMenu ? 1.0 : 0)
        }
        
    }
}
