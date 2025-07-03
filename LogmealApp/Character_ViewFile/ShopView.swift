//
//  ShopView.swift
//  LogmealApp
//
//  Created by 山口昂大 on 2025/04/11.
//

import SwiftUI

struct NewShopView: View {
    @EnvironmentObject var user: UserData
    @State private var isFrontItemsBoard: Bool = true // ショップか購入済みかタブ切り替え
    @State private var showPurchaseAlert: Bool = false // 購入確認アラート表示
    @State private var showInsufficientAlert: Bool = false // ポイント不足アラート表示
    @State private var products: [Product] = [] // 商品一覧
    @State private var boughtProducts: [Product] = [] // 購入済み商品一覧
    @State private var selectedItemIndex: Int? = nil // 選択中の商品インデックス
    @State private var displayImage: String = "" // 詳細表示用画像
    @State private var gifData:Data? = nil
    @AppStorage("dogLoaded")var dogLoaded: Bool = false
    @AppStorage("catLoaded")var catLoaded: Bool = false
    @AppStorage("rabbitLoaded")var rabbitLoaded: Bool = false
    // キャラクターごとの背景色
    private var displayContentColor: Color {
        switch user.currentCharacter.name {
        case "Dog": return Color(red: 248/255, green: 201/255, blue: 201/255)
        case "Cat": return Color(red: 198/255, green: 166/255, blue: 208/255)
        case "Rabbit": return Color(red: 251/255, green: 233/255, blue: 184/255)
        default: return Color.white
        }
    }
    
    // キャラクターごとの背景画像
    private var backgroundImage: String {
        switch user.currentCharacter.name {
        case "Dog": return "bg_shop_Dog"
        case "Cat": return "bg_shop_Cat"
        case "Rabbit": return "bg_shop_Rabbit"
        default: return "bg_shop_Dog"
        }
    }
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                ZStack {
                    // 背景
                    Image(backgroundImage)
                        .resizable()
                        .ignoresSafeArea()
                        .scaledToFill()
                        .frame(width: geometry.size.width,height: geometry.size.height)
                        .scaleEffect(1.1)
                        .position(x:geometry.size.width*0.5,y:geometry.size.height*0.5)
                    
                    
                    
                    // 右側の説明・詳細画像エリア
                    detailView(geometry: geometry)
                        .position(x:geometry.size.width*0.3,y:geometry.size.height*0.5)
                    // 商品リストおよび購入ボタン
                    shopBoardView(geometry: geometry)
                    
                    // 購入確認アラート
                    if showPurchaseAlert {
                        purchaseAlertView
                    }
                }
                
                // debug
                debugBorder
                    .position(x:120,y:100)
            }
            // ポイント不足時のシステムアラート
            .alert("ポイントが足りません", isPresented: $showInsufficientAlert) {
                Button("閉じる") {}
            } message: {
                Text("所持ポイントが不足しているため、購入できません。")
            }
            .onAppear {
                user.initCharacterData()
                if user.loadProducts(key: "products").isEmpty{
                    loadProducts()
                }else{
                    products = user.loadProducts(key: "products")
                }
                updateBoughtProducts()
            }
        }
    }
}

// MARK: - サブビュー
extension NewShopView {
    // 詳細表示エリア
    private func detailView(geometry:GeometryProxy) -> some View {
        ZStack{
            if let gifData = self.gifData {
                GIFImage(data: gifData)
                    .frame(width: geometry.size.width*0.4)
                    .offset(x:-geometry.size.width*0.05)
            } else {
                Text("右側の一覧から\n買いたい商品を選んでね")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
        }
    }

    // 商品リストおよび購入ボタン
    private func shopBoardView(geometry:GeometryProxy) -> some View {
        ZStack(alignment: .trailing){
            // ポイント表示
            shopPointView
                .position(x:geometry.size.width*0.85,y:geometry.size.height*0.06)
            //                    // タブ切り替え
            shopTabView
                .position(x:geometry.size.width*0.7,y:geometry.size.height*0.18)
            //                    // 商品リスト
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 460, height: 500)
                    .foregroundStyle(isFrontItemsBoard ? .white : displayContentColor)
                RoundedRectangle(cornerRadius: 20)
                    .stroke(lineWidth: 5)
                    .frame(width: 460, height: 500)
                    .foregroundStyle(Color(red: 175/255, green: 170/255, blue: 170/255))
            }
            .position(x:geometry.size.width*0.7,y:geometry.size.height*0.55)
            .overlay {
                if isFrontItemsBoard {
                    productListView
                        .frame(width: 460, height: 490)
                        .position(x:geometry.size.width*0.7,y:geometry.size.height*0.55)
                } else {
                    boughtItemListView
                        .frame(width: 460, height: 490)
                        .position(x:geometry.size.width*0.7,y:geometry.size.height*0.55)
                }
            }
            // 「買う」ボタン（ショップタブ時のみ）
            if isFrontItemsBoard {
                buyButton
                    .position(x:geometry.size.width*0.7,y:geometry.size.height*0.95)
            }
        }
    }
    
    // ポイント表示
    private var shopPointView: some View {
        Image("shop_point_display")
            .overlay {
                Text("\(user.point)")
                    .foregroundStyle(.white)
                    .font(.custom("GenJyuuGothicX-Bold", size: 30))
                    .offset(x: 20)
            }
    }
    
    // タブ切り替え
    private var shopTabView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Button {
                    isFrontItemsBoard = true
                } label: {
                    tabLabel(title: "ショップ", icon: "cart.fill", isActive: isFrontItemsBoard, color: .white)
                }
                .disabled(isFrontItemsBoard)
                
                Button {
                    isFrontItemsBoard = false
                } label: {
                    tabLabel(title: "買ったもの", icon: nil, isActive: !isFrontItemsBoard, color: displayContentColor)
                }
                .disabled(!isFrontItemsBoard)
            }
            .offset(y: 5)
        }
    }
    
    // タブラベル共通化
    private func tabLabel(title: String, icon: String?, isActive: Bool,color:Color) -> some View {
        ZStack {
            UnevenRoundedRectangle(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20, style: .continuous)
                .frame(width: 195, height: 70)
                .foregroundStyle(color)
            UnevenRoundedRectangle(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20, style: .continuous)
                .stroke(lineWidth: 5)
                .frame(width: 195, height: 70)
                .foregroundStyle(Color(red: 175/255, green: 170/255, blue: 170/255))
        }
        .overlay {
            if let icon = icon {
                Label(title, systemImage: icon)
                    .font(.custom("GenJyuuGothicX-Bold", size: 23))
                    .foregroundStyle(.black)
            } else {
                Text(title)
                    .font(.custom("GenJyuuGothicX-Bold", size: 23))
                    .foregroundStyle(.black)
            }
        }
    }
    
    // 商品一覧リスト
    @ViewBuilder
    private var productListView: some View {
        ZStack {
            List {
                ForEach(Array(zip(products.indices, products)), id: \.1.id) { index, product in
                    productRow(product: product, isSelected: selectedItemIndex == index, isBought: product.isBought)
                        .onTapGesture {
                            selectedItemIndex = index
                            gifData = NSDataAsset(name: product.name)?.data
                            displayImage = product.img
                        }
                        .disabled(product.isBought)
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            // キャラクター選択時にリストを更新
            loadProducts()
        }
    }
    
    // 購入済み商品リスト
    @ViewBuilder
    private var boughtItemListView: some View {
        ZStack {
            List {
                ForEach(Array(zip(boughtProducts.indices, boughtProducts)), id: \.1.id) { index, product in
                    productRow(product: product, isSelected: selectedItemIndex == index, isBought: false)
                        .onTapGesture {
                            selectedItemIndex = index
                            gifData = NSDataAsset(name: product.name)?.data
                            displayImage = product.img
                        }
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            updateBoughtProducts()
        }
    }
    
    // 商品行の共通ビュー
    private func productRow(product: Product, isSelected: Bool, isBought: Bool) -> some View {
        HStack {
            Image(product.img)
                .resizable()
                .scaledToFit()
                .frame(width: 50)
            Spacer()
            VStack(alignment: .trailing) {
                VStack(alignment: .leading) {
                    Text("つままれる")
                    Text("ポチッとつまんで、キャラクターと遊ぼう！")
                }
                HStack {
                    Text("\(product.price)")
                    Text("pt")
                }
            }
        }
        .padding()
        .background {
            if isSelected {
                (isBought ? Color.white : Color(red: 248/255, green: 201/255, blue: 201/255))
                    .ignoresSafeArea()
            }
        }
        .overlay {
            if isBought {
                Color.gray.opacity(0.6)
                    .overlay {
                        Text("SOLD OUT")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundStyle(.red)
                    }
            }
        }
    }
    
    // 「買う」ボタン
    private var buyButton: some View {
        Button {
            showPurchaseAlert = true
        } label: {
            RoundedRectangle(cornerRadius: 50)
                .frame(width: 400, height: 70)
                .foregroundStyle(selectedItemIndex == nil ? Color.gray : Color(red: 225/255, green: 108/255, blue: 68/255))
                .overlay {
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(.white, lineWidth: 5)
                    Text("買う")
                        .foregroundStyle(.white)
                        .font(.custom("GenJyuuGothicX-Bold", size: 45))
                }
        }
        .disabled(selectedItemIndex == nil)
    }
    
    // 購入確認アラートのカスタムView
    private var purchaseAlertView: some View {
        return ZStack{
            Color.gray.opacity(0.6)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                ZStack {
                    UnevenRoundedRectangle(topLeadingRadius: 40, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 40, style: .continuous)
                        .frame(width: 400, height: 80)
                        .foregroundStyle(.white)
                    UnevenRoundedRectangle(topLeadingRadius: 40, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 40, style: .continuous)
                        .stroke(lineWidth: 2)
                        .frame(width: 400, height: 80)
                        .foregroundStyle(.gray)
                }
                .overlay {
                    Text("購入しますか？")
                        .font(.custom("GenJyuuGothicX-Bold", size: 30))
                }
                HStack(spacing: 0) {
                    Button {
                        confirmPurchase()
                    } label: {
                        ZStack {
                            UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 40, bottomTrailingRadius: 0, topTrailingRadius: 0, style: .continuous)
                                .frame(width: 200, height: 80)
                                .foregroundStyle(.white)
                            UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 40, bottomTrailingRadius: 0, topTrailingRadius: 0, style: .continuous)
                                .stroke(lineWidth: 2)
                                .frame(width: 200, height: 80)
                                .foregroundStyle(.gray)
                        }
                        .overlay {
                            Text("する")
                                .font(.custom("GenJyuuGothicX-Bold", size: 30))
                        }
                    }
                    Button {
                        showPurchaseAlert = false
                    } label: {
                        ZStack {
                            UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 40, topTrailingRadius: 0, style: .continuous)
                                .frame(width: 200, height: 80)
                                .foregroundStyle(.white)
                            UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 40, topTrailingRadius: 0, style: .continuous)
                                .stroke(lineWidth: 2)
                                .frame(width: 200, height: 80)
                                .foregroundStyle(.gray)
                        }
                        .overlay {
                            Text("しない")
                                .font(.custom("GenJyuuGothicX-Bold", size: 30))
                        }
                    }
                }
            }
        }
    }
}

// MARK: - ロジック・データ操作
extension NewShopView {
    /// キャラクターごとの商品リストをロード
    private func loadProducts() {
        switch user.currentCharacter.name {
        case "Dog":
            if !dogLoaded{
                let dogProducts: [Product] = [
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
                products += dogProducts
                dogLoaded = true
            }else{
                products = user.loadProducts(key: "products")
            }
        case "Cat":
            if !catLoaded{
                let catProducts = [
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
                products += catProducts
                catLoaded = true
            }else{
                products = user.loadProducts(key: "products")
            }
          
        case "Rabbit":
            if !rabbitLoaded{
                let rabbitProducts = [
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
                products += rabbitProducts
                rabbitLoaded = true
            }else{
                products = user.loadProducts(key: "products")
            }
        default:
            products = []
        }
    }
    
    /// 購入済み商品リストを更新
    private func updateBoughtProducts() {
        boughtProducts = products.filter { $0.isBought }
    }
    
    /// 購入処理・永続化
    private func confirmPurchase() {
        guard let index = selectedItemIndex else { return }
        let selectedProduct = products[index]
        
        // ポイント不足チェック
        if user.point < selectedProduct.price {
            showInsufficientAlert = true
            showPurchaseAlert = false
            selectedItemIndex = nil
            return
        }
        
        // 購入処理
        if user.purchaseProduct(selectedProduct) {
            // ステータス更新
            products[index].isBought = true
            boughtProducts.append(selectedProduct)
            // 永続化
            user.saveProducts(products: products, key: "products")
            user.saveProducts(products: boughtProducts, key: "boughtItem")
        } else {
            showInsufficientAlert = true
        }
        
        showPurchaseAlert = false
        selectedItemIndex = nil
    }
}

extension NewShopView{
    var debugBorder: some View {
        RoundedRectangle(cornerRadius: 16) // Slightly larger corner radius for a modern look
            .frame(width: 200, height: 200)
            .foregroundStyle(.ultraThinMaterial) // Using materials for a more modern look
            .shadow(radius: 10, y: 5) // Adding subtle shadow for depth
            .overlay {
                VStack(spacing: 20) { // Added spacing between buttons
                    Button {
                        user.point += 100
                    } label: {
                        Label("Add Points", systemImage: "plus.circle.fill") // Using filled icon
                            .font(.headline)
                            .foregroundColor(.green)
                            .frame(width: 140, height: 44) // Fixed size for better touch targets
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.green.opacity(0.2))
                            )
                    }
                    
                    Button {
                        user.point -= 100
                    } label: {
                        Label("Remove Points", systemImage: "minus.circle.fill") // Using filled icon
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(width: 140, height: 44) // Fixed size for better touch targets
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.red.opacity(0.2))
                            )
                    }
                }
                .padding()
            }
    }
}

#Preview {
    NewShopView()
        .environmentObject(UserData())
}


