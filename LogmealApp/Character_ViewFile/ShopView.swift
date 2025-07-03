//
//  ShopView.swift
//  LogmealApp
//
//  Created by 山口昂大 on 2025/04/11.
//

import SwiftUI

struct NewShopView: View {
    @EnvironmentObject var user: UserData
    @State private var isFrontItemsBoard: Bool = true
    @State private var showPurchaseAlert: Bool = false
    @State private var showInsufficientAlert: Bool = false
    @State private var products: [Product] = []
    @State private var boughtProducts: [Product] = []
    @State private var selectedItemIndex: Int? = nil
    @State private var displayImage: String = ""
    @State private var gifData: Data? = nil
    @AppStorage("dogLoaded") var dogLoaded: Bool = false
    @AppStorage("catLoaded") var catLoaded: Bool = false
    @AppStorage("rabbitLoaded") var rabbitLoaded: Bool = false
    
    @State private var isLoading: Bool = true   // ★追加: ローディング状態
    // 背景色
    private var displayContentColor: Color {
        switch user.currentCharacter.name {
        case "Dog": return Color(red: 248/255, green: 201/255, blue: 201/255)
        case "Cat": return Color(red: 198/255, green: 166/255, blue: 208/255)
        case "Rabbit": return Color(red: 251/255, green: 233/255, blue: 184/255)
        default: return Color.white
        }
    }
    
    // 背景画像
    private var backgroundImage: String {
        switch user.currentCharacter.name {
        case "Dog": return "bg_shop_Dog"
        case "Cat": return "bg_shop_Cat"
        case "Rabbit": return "bg_shop_Rabbit"
        default: return "bg_shop_Dog"
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            // 基準サイズ
            let baseWidth: CGFloat = 1180.0
            let baseHeight: CGFloat = 820.0
            let wRatio = geometry.size.width / baseWidth
            let hRatio = geometry.size.height / baseHeight
            let scale = min(wRatio, hRatio)
            
            ZStack {
                // 背景
                Image(backgroundImage)
                    .resizable()
                    .ignoresSafeArea()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .scaleEffect(1.1)
                    .position(x:geometry.size.width * 0.5, y:geometry.size.height * 0.5)
                
                if isLoading {
                    // ★ローディング時
                    Color.black.opacity(0.3).ignoresSafeArea()
                    ProgressView("読み込み中...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                        .scaleEffect(1.8)
                        .foregroundColor(.white)
                } else {
                    // 詳細画像・説明
                    detailView(geometry: geometry, scale: scale)
                        .frame(width: baseWidth * 0.38 * scale, height: baseHeight * 0.85 * scale)
                        .position(x: geometry.size.width * 0.22, y: geometry.size.height * 0.5)
                    
                    // 商品リスト＆ボード
                    shopBoardView(geometry: geometry, scale: scale)
                        .frame(width: baseWidth * 0.55 * scale, height: baseHeight * 0.9 * scale)
                    
                    // 購入アラート
                    if showPurchaseAlert {
                        purchaseAlertView(scale: scale)
                    }
                    
                    // debug
                    debugBorder
                        .position(x: 120 * scale, y: 100 * scale)
                        .scaleEffect(scale)
                }
            }
            .alert("ポイントが足りません", isPresented: $showInsufficientAlert) {
                Button("閉じる") {}
            } message: {
                Text("所持ポイントが不足しているため、購入できません。")
            }
            .onAppear {
                print("=== onAppear Debug Log ===")
                print("geometry.size: (width: \(geometry.size.width), height: \(geometry.size.height))")
                print("user.initCharacterData() 実行")
                user.initCharacterData()
                // ★ 非同期でマイグレーション・ロード
                isLoading = true
                Task {
                    await asyncLoadProducts()
                    updateBoughtProducts()
                    isLoading = false
                    print("updateBoughtProducts() 実行")
                    print("boughtProducts: \(boughtProducts)")
                    print("user.currentCharacter: name=\(user.currentCharacter.name), level=\(user.currentCharacter.level), exp=\(user.currentCharacter.exp), growthStage=\(user.currentCharacter.growthStage)")
                    print("================================")
                }
            }
            .onDisappear(){
                // キャラごとのキーで保存
                let charName = user.currentCharacter.name
                user.saveProducts(products: products, key: "\(charName)_products")
                user.saveProducts(products: boughtProducts, key: "\(charName)_boughtItem")
            }
        }
    }
}

// MARK: - サブビュー
extension NewShopView {
    // 詳細表示エリア（可変幅対応）
    private func detailView(geometry: GeometryProxy, scale: CGFloat) -> some View {
        ZStack {
            if let gifData = self.gifData {
                GIFImage(data: gifData)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("アイテムを選んでね")
                    .font(.custom("GenJyuuGothicX-Bold", size: 35 * scale))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color.white.opacity(0.05))
        .cornerRadius(24 * scale)
        .shadow(radius: 8 * scale)
    }
    
    // 商品ボード（StackやSpacerを使わず.positionで直接配置）
    private func shopBoardView(geometry: GeometryProxy, scale: CGFloat) -> some View {
        // 右上基準で各要素を直接配置
        ZStack {
            // ポイント表示
            shopPointView(scale: scale)
                .frame(width: 210 * scale, height: 60 * scale)
                .position(x: geometry.size.width * 0.48, y: geometry.size.height * 0.08)
            
            // タブ
            shopTabView(scale: scale)
                .frame(width: 390 * scale, height: 70 * scale)
                .position(x: geometry.size.width * 0.48, y: geometry.size.height * 0.19)
            
            // 商品リスト
            ZStack {
                RoundedRectangle(cornerRadius: 20 * scale)
                    .foregroundStyle(isFrontItemsBoard ? .white : displayContentColor)
                    .shadow(radius: 4 * scale)
                RoundedRectangle(cornerRadius: 20 * scale)
                    .stroke(lineWidth: 5 * scale)
                    .foregroundStyle(Color(red: 175/255, green: 170/255, blue: 170/255))
            }
            .frame(width: 460 * scale, height: 500 * scale)
            .position(x: geometry.size.width * 0.48, y: geometry.size.height * 0.53)
            .overlay {
                if isFrontItemsBoard {
                    productListView(scale: scale)
                        .frame(width: 440 * scale, height: 470 * scale)
                        .position(x: geometry.size.width * 0.48, y: geometry.size.height * 0.53)
                } else {
                    boughtItemListView(scale: scale)
                        .frame(width: 440 * scale, height: 470 * scale)
                        .position(x: geometry.size.width * 0.48, y: geometry.size.height * 0.53)
                }
            }
            
            // 「買う」ボタン
            if isFrontItemsBoard {
                buyButton(scale: scale)
                    .frame(width: 400 * scale, height: 70 * scale)
                    .position(x: geometry.size.width * 0.48, y: geometry.size.height * 0.92)
            }
        }
    }
    
    // ポイント表示
    private func shopPointView(scale: CGFloat) -> some View {
        Image("shop_point_display")
            .resizable()
            .frame(width: 210 * scale, height: 60 * scale)
            .overlay {
                Text("\(user.point)")
                    .foregroundStyle(.white)
                    .font(.custom("GenJyuuGothicX-Bold", size: 30 * scale))
                    .offset(x: 20 * scale)
            }
    }
    
    // タブ切り替え
    private func shopTabView(scale: CGFloat) -> some View {
        HStack(spacing: 0) {
            Button {
                isFrontItemsBoard = true
            } label: {
                tabLabel(title: "ショップ", icon: "cart.fill", isActive: isFrontItemsBoard, color: .white, scale: scale)
            }
            .disabled(isFrontItemsBoard)
            
            Button {
                isFrontItemsBoard = false
            } label: {
                tabLabel(title: "買ったもの", icon: nil, isActive: !isFrontItemsBoard, color: displayContentColor, scale: scale)
            }
            .disabled(!isFrontItemsBoard)
        }
    }
    
    // タブラベル 共通化
    private func tabLabel(title: String, icon: String?, isActive: Bool, color: Color, scale: CGFloat) -> some View {
        ZStack {
            UnevenRoundedRectangle(topLeadingRadius: 20 * scale, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20 * scale, style: .continuous)
                .frame(width: 195 * scale, height: 70 * scale)
                .foregroundStyle(color)
            UnevenRoundedRectangle(topLeadingRadius: 20 * scale, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20 * scale, style: .continuous)
                .stroke(lineWidth: 5 * scale)
                .frame(width: 195 * scale, height: 70 * scale)
                .foregroundStyle(Color(red: 175/255, green: 170/255, blue: 170/255))
        }
        .overlay {
            if let icon = icon {
                Label(title, systemImage: icon)
                    .font(.custom("GenJyuuGothicX-Bold", size: 23 * scale))
                    .foregroundStyle(.black)
            } else {
                Text(title)
                    .font(.custom("GenJyuuGothicX-Bold", size: 23 * scale))
                    .foregroundStyle(.black)
            }
        }
    }
    
    // 商品一覧リスト
    private func productListView(scale: CGFloat) -> some View {
        List {
            ForEach(Array(zip(products.indices, products)), id: \.1.id) { index, product in
                productRow(product: product, isSelected: selectedItemIndex == index, isBought: product.isBought, scale: scale)
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
    
    // 購入済み商品リスト
    private func boughtItemListView(scale: CGFloat) -> some View {
        List {
            ForEach(Array(zip(boughtProducts.indices, boughtProducts)), id: \.1.id) { index, product in
                productRow(product: product, isSelected: selectedItemIndex == index, isBought: false, scale: scale)
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
    
    // 商品行の共通ビュー
    private func productRow(product: Product, isSelected: Bool, isBought: Bool, scale: CGFloat) -> some View {
        HStack {
            Image(product.img)
                .resizable()
                .scaledToFit()
                .frame(width: 50 * scale)
            Spacer()
            VStack(alignment: .trailing) {
                VStack(alignment: .leading) {
                    Text("つままれる")
                        .font(.system(size: 16 * scale))
                    Text("ポチッとつまんで、キャラクターと遊ぼう！")
                        .font(.system(size: 13 * scale))
                }
                HStack {
                    Text("\(product.price)")
                    Text("pt")
                }
                .font(.system(size: 15 * scale))
            }
        }
        .padding(.vertical, 8 * scale)
        .padding(.horizontal, 10 * scale)
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
                        Text("うりきれ")
                            .font(.custom("GenJyuuGothicX-Bold", size: 35 * scale))
                            .fontWeight(.heavy)
                            .foregroundStyle(.red)
                    }
            }
        }
    }
    
    // 「買う」ボタン
    private func buyButton(scale: CGFloat) -> some View {
        Button {
            showPurchaseAlert = true
        } label: {
            RoundedRectangle(cornerRadius: 50 * scale)
                .frame(width: 400 * scale, height: 70 * scale)
                .foregroundStyle(selectedItemIndex == nil ? Color.gray : Color(red: 225/255, green: 108/255, blue: 68/255))
                .overlay {
                    RoundedRectangle(cornerRadius: 50 * scale)
                        .stroke(.white, lineWidth: 5 * scale)
                    Text("買う")
                        .foregroundStyle(.white)
                        .font(.custom("GenJyuuGothicX-Bold", size: 45 * scale))
                }
        }
        .disabled(selectedItemIndex == nil)
    }
    
    // 購入確認アラートのカスタムView
    private func purchaseAlertView(scale: CGFloat) -> some View {
        ZStack {
            Color.gray.opacity(0.6)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                ZStack {
                    UnevenRoundedRectangle(topLeadingRadius: 40 * scale, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 40 * scale, style: .continuous)
                        .frame(width: 400 * scale, height: 80 * scale)
                        .foregroundStyle(.white)
                    UnevenRoundedRectangle(topLeadingRadius: 40 * scale, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 40 * scale, style: .continuous)
                        .stroke(lineWidth: 2 * scale)
                        .frame(width: 400 * scale, height: 80 * scale)
                        .foregroundStyle(.gray)
                }
                .overlay {
                    Text("購入しますか？")
                        .font(.custom("GenJyuuGothicX-Bold", size: 30 * scale))
                }
                HStack(spacing: 0) {
                    Button {
                        confirmPurchase()
                    } label: {
                        ZStack {
                            UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 40 * scale, bottomTrailingRadius: 0, topTrailingRadius: 0, style: .continuous)
                                .frame(width: 200 * scale, height: 80 * scale)
                                .foregroundStyle(.white)
                            UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 40 * scale, bottomTrailingRadius: 0, topTrailingRadius: 0, style: .continuous)
                                .stroke(lineWidth: 2 * scale)
                                .frame(width: 200 * scale, height: 80 * scale)
                                .foregroundStyle(.gray)
                        }
                        .overlay {
                            Text("する")
                                .font(.custom("GenJyuuGothicX-Bold", size: 30 * scale))
                        }
                    }
                    Button {
                        showPurchaseAlert = false
                    } label: {
                        ZStack {
                            UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 40 * scale, topTrailingRadius: 0, style: .continuous)
                                .frame(width: 200 * scale, height: 80 * scale)
                                .foregroundStyle(.white)
                            UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 40 * scale, topTrailingRadius: 0, style: .continuous)
                                .stroke(lineWidth: 2 * scale)
                                .frame(width: 200 * scale, height: 80 * scale)
                                .foregroundStyle(.gray)
                        }
                        .overlay {
                            Text("しない")
                                .font(.custom("GenJyuuGothicX-Bold", size: 30 * scale))
                        }
                    }
                }
            }
        }
    }
}

// MARK: - ロジック・データ操作
extension NewShopView {
    // ★非同期対応マイグレーション
    // ★マイグレーション処理（nameにDog/Cat/Rabbitが含まれていればキャラごとに振り分け）

    
    // ★非同期対応ロード
    private func asyncLoadProducts() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                loadProducts()
                continuation.resume()
            }
        }
    }
    
    private func loadProducts() {
        print("=== loadProducts Debug Log ===")
        let charName = user.currentCharacter.name
        let productKey = "\(charName)_products"
        print("currentCharacter: \(charName), 使用キー: \(productKey)")
        var loadedProducts = user.loadProducts(key: productKey)
        
        // キャラごとの初期商品リスト作成
        let defaultProducts: [Product]
        switch charName {
        case "Dog":
            defaultProducts = [
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
            defaultProducts = [
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
            defaultProducts = [
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
            defaultProducts = []
        }
        
        // すでに保存されている商品＋初期商品（重複を排除）
        let existingNames = Set(loadedProducts.map { $0.name })
        let merged = loadedProducts + defaultProducts.filter { !existingNames.contains($0.name) }
        products = merged
        user.saveProducts(products: merged, key: productKey)
        print("[\(charName)] merged products: \(products.map { $0.name })")
        print("=== /loadProducts Debug Log ===")
    }
    
    private func updateBoughtProducts() {
        boughtProducts = products.filter { $0.isBought }
    }
    private func confirmPurchase() {
        guard let index = selectedItemIndex else { return }
        let selectedProduct = products[index]
        if user.point < selectedProduct.price {
            showInsufficientAlert = true
            showPurchaseAlert = false
            selectedItemIndex = nil
            return
        }
        // キャラごとのキーで保存
        let charName = user.currentCharacter.name
        products[index].isBought = true
        user.point -= products[index].price
        boughtProducts.append(selectedProduct)
        user.saveProducts(products: products, key: "\(charName)_products")
        user.saveProducts(products: boughtProducts, key: "\(charName)_boughtItem")
        showPurchaseAlert = false
        selectedItemIndex = nil
        print(boughtProducts)
    }
}

extension NewShopView {
    var debugBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .frame(width: 200, height: 200)
            .foregroundStyle(.ultraThinMaterial)
            .shadow(radius: 10, y: 5)
            .overlay {
                VStack(spacing: 20) {
                    Button {
                        user.point += 100
                    } label: {
                        Label("Add Points", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .foregroundColor(.green)
                            .frame(width: 140, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.green.opacity(0.2))
                            )
                    }
                    
                    Button {
                        user.point -= 100
                    } label: {
                        Label("Remove Points", systemImage: "minus.circle.fill")
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(width: 140, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.red.opacity(0.2))
                            )
                    }
                    Button{
                        dogLoaded = false
                        rabbitLoaded = false
                        catLoaded = false
                    }label:{
                        Label("Reset AppStrage", systemImage: "arrow.counterclockwise")
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(width: 140, height: 44)
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
