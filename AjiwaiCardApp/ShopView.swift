import SwiftUI

struct ShopView: View {
    @EnvironmentObject var user: UserData
    @State var boughtItem: [Product] = []
    @AppStorage("NumberOfVisits") var NumberOfVisits: Int = 0
    @State var info = ""
    @State var selectedProduct: Product?
    @State var itemIndex: Int = 0
    @State var showAlert = false
    @State var insufficientPoints = false
    @State var gifData: Data? = nil
    @State var playGif = true
    @State var selectedProductIndex: Int? = nil
    @State var showPurchaseMessage = false
    @State private var buying: Bool = false
    @Environment(\.dismiss) private var dismiss
    @State var products: [Product] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                Image("bg_shop_\(user.selectedCharacter)")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                VStack{
                    Button {
                        dismiss()
                    } label: {
                        Image("bt_back")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)
                    }
                    .padding()
                    .buttonStyle(PlainButtonStyle())
                    .disabled(buying)
                }
                Image("mt_bord_shop_\(user.selectedCharacter)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.4, height: geometry.size.height * 0.8)
                    .position(x: geometry.size.width * 0.75, y: geometry.size.height * 0.5)
                if let gifData = gifData {
                    GIFImage(data: gifData, playGif: $playGif) {
                        print("GIF animation finished!")
                    }
                    .frame(width: geometry.size.width*0.4)
                    .onTapGesture {
                        playGif = true
                    }
                    .position(x: geometry.size.width * 0.25, y: geometry.size.height * 0.5)
                } else {
                    Text("右側から商品を選んでね")
                        .font(.custom("GenJyuuGothicX-Bold", size: 17))
                        .position(x: geometry.size.width * 0.25, y: geometry.size.height * 0.5)
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
                    Image("bt_buy_\(user.selectedCharacter)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.18)
                }
                .position(x: geometry.size.width * 0.25, y: geometry.size.height * 0.9)
                .buttonStyle(PlainButtonStyle())
                HStack{
                    Text("今持っているpoint：")
                        .font(.custom("GenJyuuGothicX-Bold", size: 15))
                    Text("\(user.point)")
                        .font(.custom("GenJyuuGothicX-Bold", size: 20))
                }
                .position(x: geometry.size.width * 0.83, y: geometry.size.height * 0.27)
                
                List {
                    ForEach(Array(zip(products.indices, products)), id: \.1.id) { index, product in
                        Button {
                            selectedProductIndex = index
                            itemIndex = index
                            gifData = NSDataAsset(name: product.name)?.data
                            playGif = true
                        } label: {
                            HStack {
                                VStack {
                                    Image(product.img)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 65)
                                        .brightness(product.isBought ? -0.2 : 0.0) // 購入された商品の画像を暗くする
                                    if product.isBought {
                                        Text("買ったよ")
                                            .font(.custom("GenJyuuGothicX-Bold", size: 14))
                                            .foregroundColor(.red)
                                    }
                                }
                                .frame(width: 90, height: 90)
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text(" ")
                                        .font(.custom("GenJyuuGothicX-Bold", size: 17))
                                    Text("\(product.price) point")
                                        .font(.custom("GenJyuuGothicX-Bold", size: 17))
                                        .foregroundColor(product.isBought ? .gray : (user.point < product.price ? .red : .black))
                                }
                                .padding()
                            }
                            .padding()
                            .frame(width: 300, height: 80)
                            .foregroundColor(product.isBought ? .gray : .black)
                            .background(selectedProductIndex == index ? Color.black.opacity(0.1) : Color.clear)
                        }
                        .listRowBackground(Color.clear)
                        .disabled(buying || product.isBought)
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .scrollContentBackground(.hidden)
                .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.6)
                .position(x: geometry.size.width * 0.75, y: geometry.size.height * 0.55)
                
                if showPurchaseMessage {
                    Text("購入しました！\nホーム画面でのキャラクターの動きが変化したよ！")
                        .font(.custom("GenJyuuGothicX-Bold", size: 17))
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
            .alert(isPresented: $showAlert) {
                if insufficientPoints {
                    return Alert(
                        title: Text("ポイントが足りません"),
                        message: Text(""),
                        dismissButton: .default(Text("閉じる"))
                    )
                } else {
                    return Alert(
                        title: Text("購入しますか？"),
                        primaryButton: .cancel(Text("いいえ")),
                        secondaryButton: .default(Text("はい"), action: confirmPurchase)
                    )
                }
            }
            .onAppear {
                print("訪問回数：\(NumberOfVisits)")
                print("1回目：\(products)")
                print("2回目以降：\(products = user.loadProducts(key: "products"))")
                //ビジット回数が1回目の時はデフォルトのものを表示、2回目以降はユーザーデフォルトから持ってくる
                if NumberOfVisits <= 1 {
                    switch user.selectedCharacter {
                    case "Dog":
                        products = [
                            Product(name: "Dog3_animation_applause", price: 200, img: "img_dog_applause", isBought: false),
                            Product(name: "Dog3_animation_bow", price: 400, img: "img_dog_bow", isBought: false),
                            Product(name: "Dog3_animation_byebye", price: 600, img: "img_dog_byebye", isBought: false),
                            Product(name: "Dog3_animation_eat", price: 800, img: "img_dog_eat", isBought: false),
                            Product(name: "Dog3_animation_question", price: 1000, img: "img_dog_question", isBought: false),
                            Product(name: "Dog3_animation_sit", price: 300, img: "img_dog_sit", isBought: false),
                            Product(name: "Dog3_animation_sleep", price: 500, img: "img_dog_sleep", isBought: false),
                            Product(name: "Dog3_animation_surprised", price: 700, img: "img_dog_surprised", isBought: false),
                            Product(name: "Dog3_animation_yawn", price: 900, img: "img_dog_yawn", isBought: false),
                            Product(name: "Dog3_animation_yell", price: 150, img: "img_dog_yell", isBought: false)
                        ]
                    case "Cat":
                        products = [
                            Product(name: "Cat3_animation_applause", price: 250, img: "img_cat_applause", isBought: false),
                            Product(name: "Cat3_animation_bow", price: 500, img: "img_cat_bow", isBought: false),
                            Product(name: "Cat3_animation_byebye", price: 750, img: "img_cat_byebye", isBought: false),
                            Product(name: "Cat3_animation_eat", price: 1000, img: "img_cat_eat", isBought: false),
                            Product(name: "Cat3_animation_question", price: 350, img: "img_cat_question", isBought: false),
                            Product(name: "Cat3_animation_sit", price: 600, img: "img_cat_sit", isBought: false),
                            Product(name: "Cat3_animation_sleep", price: 850, img: "img_cat_sleep", isBought: false),
                            Product(name: "Cat3_animation_surprised", price: 150, img: "img_cat_surprised", isBought: false),
                            Product(name: "Cat3_animation_yawn", price: 400, img: "img_cat_yawn", isBought: false),
                            Product(name: "Cat3_animation_yell", price: 650, img: "img_cat_yell", isBought: false)
                        ]
                    case "Rabbit":
                        products = [
                            Product(name: "Rabbit3_animation_applause", price: 150, img: "img_rabbit_applause", isBought: false),
                            Product(name: "Rabbit3_animation_bow", price: 300, img: "img_rabbit_bow", isBought: false),
                            Product(name: "Rabbit3_animation_byebye", price: 450, img: "img_rabbit_byebye", isBought: false),
                            Product(name: "Rabbit3_animation_eat", price: 600, img: "img_rabbit_eat", isBought: false),
                            Product(name: "Rabbit3_animation_question", price: 750, img: "img_rabbit_question", isBought: false),
                            Product(name: "Rabbit3_animation_sit", price: 900, img: "img_rabbit_sit", isBought: false),
                            Product(name: "Rabbit3_animation_sleep", price: 1000, img: "img_rabbit_sleep", isBought: false),
                            Product(name: "Rabbit3_animation_surprised", price: 200, img: "img_rabbit_surprised", isBought: false),
                            Product(name: "Rabbit3_animation_yawn", price: 350, img: "img_rabbit_yawn", isBought: false),
                            Product(name: "Rabbit3_animation_yell", price: 500, img: "img_rabbit_yell", isBought: false)
                        ]
                    default:
                        products = []
                    }
                } else {
                    products = user.loadProducts(key: "products")
                }
            }
        }
    }
    
    func confirmPurchase() {
        if let product = selectedProduct, user.purchaseProduct(product) {
            info = "商品を購入しました"
            boughtItem.append(product)
            user.saveProducts(products: self.boughtItem, key: "boughtItem")
            if let index = products.firstIndex(where: { $0.id == product.id }) {
                products[index].isBought = true
                user.saveProducts(products: self.products, key: "products")
            }
            withAnimation {
                showPurchaseMessage = true
            }
            NumberOfVisits += 1
        } else {
            info = "ポイントが足りません"
        }
    }
}

#Preview {
    ShopView()
        .environmentObject(UserData())
}
