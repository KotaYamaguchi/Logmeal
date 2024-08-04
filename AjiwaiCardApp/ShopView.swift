import SwiftUI

struct ShopView: View {
    @EnvironmentObject var user: UserData
    @State var boughtItem: [String] = []
    @State var info = ""
    @State var selectedProduct: Product?
    @State var itemIndex: Int = 0
    @State var showAlert = false
    @State var insufficientPoints = false
    @State var gifData = NSDataAsset(name: "rabbit_breath")?.data
    @State var playGif = true
    @State var selectedProductIndex: Int? = nil
    @State var showPurchaseMessage = false
    @State private var buying:Bool = false
    @Environment(\.dismiss) private var dismiss
   @State var products: [Product] = [
        Product(name: "rabbit_breath", price: 100, img: "img_rabbit_breath"),
        Product(name: "rabbit_bow", price: 110, img: "img_rabbit_bow"),
        Product(name: "rabbit_question", price: 120, img: "img_rabbit_question"),
        Product(name: "rabbit_sleep", price: 130, img: "img_rabbit_sleep"),
        Product(name: "rabbit_surprised", price: 140, img: "img_rabbit_surprised"),
        Product(name: "rabbit_yell", price: 150, img: "img_rabbit_yell")
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment:.topLeading){
                Image("bg_shop_\(user.selectedCharactar)")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                Button{
                    print("オサレ")
                    dismiss()
                    
                }label: {
                    Image("bt_back")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                }
                .padding()
                .zIndex(2.0)
                .buttonStyle(PlainButtonStyle())
                .disabled(buying)
                Image("mt_bord_shop_\(user.selectedCharactar)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.4, height: geometry.size.height * 0.8)
                    .position(x: geometry.size.width * 0.75, y: geometry.size.height * 0.5)
                
                if let gifData = gifData {
                    GIFImage(data: gifData, playGif: $playGif) {
                        print("GIF animation finished!")
                    }
                    .frame(width: geometry.size.width)
                    .onTapGesture {
                        playGif = true
                    }
                    .position(x: geometry.size.width * 0.25, y: geometry.size.height * 0.38)
                }
                
                Button {
                    if let selectedIndex = selectedProductIndex {
                        if user.point >= products[selectedIndex].price {
                            selectedProduct = products[selectedIndex]
                            insufficientPoints = false
                        } else {
                            selectedProduct = nil
                            insufficientPoints = true
                        }
                        showAlert = true
                    }
                } label: {
                    Image("bt_buy_\(user.selectedCharactar)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.18)
                        
                }
                .position(x: geometry.size.width * 0.25, y: geometry.size.height * 0.9)
                
                List {
                    ForEach(Array(zip(products.indices, products)), id: \.1.id) { index, product in
                        Button {
                            selectedProductIndex = index
                            itemIndex = index
                            gifData = NSDataAsset(name: "\(product.name)")?.data
                            playGif = true
                        } label: {
                            HStack {
                                VStack {
                                    Image(product.img)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 90)
                                }
                                .frame(width: 90, height: 90)
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("商品名")
                                    Text("\(product.price) point")
                                }
                                .padding()
                            }
                            .padding()
                            .frame(width: 300, height: 80)
                            .background(selectedProductIndex == index ? Color.blue.opacity(0.3) : Color.clear)
                        }
                        .listRowBackground(Color.clear)
                        .disabled(buying)
                    }
                }
                .scrollContentBackground(.hidden)
                .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.6)
                .position(x: geometry.size.width * 0.75, y: geometry.size.height * 0.55)
                
                if showAlert {
                    ZStack{
                        Color.gray.opacity(0.8)
                            .ignoresSafeArea()
                        
                        AlertView(size: geometry.size, showAlert: $showAlert, confirmAction: confirmPurchase, insufficientPoints: insufficientPoints)
                            .position(x:geometry.size.width*0.5,y:geometry.size.height*0.5)
                    }
                    .zIndex(3.0)
                }
                if showPurchaseMessage {
                    Text("購入しました！")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                        .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.1)
                        .transition(.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showPurchaseMessage = false
                                }
                            }
                        }
                }
            }
            .onAppear(){
                switch user.selectedCharactar {
                case "Dog":
                    products =  [
                        Product(name: "rabbit_breath", price: 100, img: "img_rabbit_breath"),
                        Product(name: "rabbit_bow", price: 110, img: "img_rabbit_bow"),
                        Product(name: "rabbit_question", price: 120, img: "img_rabbit_question"),
                        Product(name: "rabbit_sleep", price: 130, img: "img_rabbit_sleep"),
                        Product(name: "rabbit_surprised", price: 140, img: "img_rabbit_surprised"),
                        Product(name: "rabbit_yell", price: 150, img: "img_rabbit_yell")
                    ]
                case "Cat":
                    products =  [
                        Product(name: "rabbit_breath", price: 100, img: "img_rabbit_breath"),
                        Product(name: "rabbit_bow", price: 110, img: "img_rabbit_bow"),
                        Product(name: "rabbit_question", price: 120, img: "img_rabbit_question"),
                        Product(name: "rabbit_sleep", price: 130, img: "img_rabbit_sleep"),
                        Product(name: "rabbit_surprised", price: 140, img: "img_rabbit_surprised"),
                        Product(name: "rabbit_yell", price: 150, img: "img_rabbit_yell")
                    ]

                case "Rabbit":
                    products =  [
                        Product(name: "rabbit_breath", price: 100, img: "img_rabbit_breath"),
                        Product(name: "rabbit_bow", price: 110, img: "img_rabbit_bow"),
                        Product(name: "rabbit_question", price: 120, img: "img_rabbit_question"),
                        Product(name: "rabbit_sleep", price: 130, img: "img_rabbit_sleep"),
                        Product(name: "rabbit_surprised", price: 140, img: "img_rabbit_surprised"),
                        Product(name: "rabbit_yell", price: 150, img: "img_rabbit_yell")
                    ]

                default:
                    products =  [
                        Product(name: "rabbit_breath", price: 100, img: "img_rabbit_breath"),
                        Product(name: "rabbit_bow", price: 110, img: "img_rabbit_bow"),
                        Product(name: "rabbit_question", price: 120, img: "img_rabbit_question"),
                        Product(name: "rabbit_sleep", price: 130, img: "img_rabbit_sleep"),
                        Product(name: "rabbit_surprised", price: 140, img: "img_rabbit_surprised"),
                        Product(name: "rabbit_yell", price: 150, img: "img_rabbit_yell")
                    ]

                }
            }
        }
    }
    
    func confirmPurchase() {
        if let product = selectedProduct, user.purchaseProduct(product) {
            info = "商品を購入しました"
            boughtItem.append(product.name)
            withAnimation {
                showPurchaseMessage = true
            }
        } else {
            info = "ポイントが足りません"
        }
        showAlert = false
    }
}

#Preview{
    ShopView()
        .environmentObject(UserData())
}

struct AlertView: View {
    @State var size: CGSize
    @Binding var showAlert: Bool
    var confirmAction: () -> Void
    var insufficientPoints: Bool
    
    var body: some View {
        VStack {
            if insufficientPoints {
                InsufficientPointsView()
            } else {
                PurchasableView()
            }
        }
        .frame(width: size.width * 0.5, height: 200)
        .background(Color.white.opacity(0.9))
        .cornerRadius(12)
        .clipped()
    }
    
    @ViewBuilder
    func PurchasableView() -> some View {
        VStack {
            Spacer()
            Text("購入しますか？")
                .foregroundColor(Color.black)
                .font(.system(size: 30))
            Spacer()
            Divider()
            Spacer()
            HStack(spacing: 0) {
                Button(action: {
                    showAlert = false
                }) {
                    Rectangle()
                        .foregroundStyle(.clear)
                        .overlay {
                            Text("いいえ")
                                .foregroundColor(.red)
                            
                        }
                }
                .buttonStyle(PlainButtonStyle())
                Button(action: {
                    confirmAction()
                }) {
                    Rectangle()
                        .foregroundStyle(.clear)
                        .overlay {
                            Text("はい")
                                .foregroundColor(.blue)
                        }
                        
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(height: 10)
            Spacer()
        }
    }
    
    @ViewBuilder
    func InsufficientPointsView() -> some View {
        VStack {
            Spacer()
            Text("ポイントが足りません")
                .foregroundColor(Color.white)
                .font(.system(size: 30))
            Spacer()
            Divider()
            Spacer()
            Button(action: {
                showAlert = false
            }) {
                Rectangle()
                    .foregroundStyle(.clear)
                    .overlay {
                        Text("閉じる")
                            .foregroundColor(.black)
                    }
            }
            .frame(height: 10)
            Spacer()
        }
    }
}
