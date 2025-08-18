import SwiftUI

/// MVVM対応のキャラクター選択ビュー
struct MVVMCharacterSelectView: View {
    @StateObject private var characterViewModel = CharacterViewModel()
    @StateObject private var shopViewModel = ShopViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景
                Image(characterViewModel.backgroundImageName)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // タイトル
                    Text("キャラクター選択")
                        .font(.custom("GenJyuuGothicX-Bold", size: 24))
                        .foregroundColor(.white)
                        .padding(.top, 50)
                    
                    // キャラクター表示エリア
                    VStack(spacing: 30) {
                        currentCharacterDisplay(geometry: geometry)
                        characterSelectionGrid(geometry: geometry)
                    }
                    
                    Spacer()
                    
                    // ショップボタン（レベル3以上で表示）
                    if characterViewModel.currentCharacter.growthStage >= 3 {
                        NavigationLink {
                            MVVMShopViewImpl()
                        } label: {
                            HStack {
                                Image(systemName: "bag.fill")
                                Text("ショップ")
                                    .font(.custom("GenJyuuGothicX-Bold", size: 18))
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(20)
                        }
                    }
                    
                    // 閉じるボタン
                    Button("閉じる") {
                        dismiss()
                    }
                    .font(.custom("GenJyuuGothicX-Bold", size: 18))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(15)
                    .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            characterViewModel.initCharacterData()
            shopViewModel.reloadShopData()
        }
    }
    
    private func currentCharacterDisplay(geometry: GeometryProxy) -> some View {
        VStack(spacing: 15) {
            // キャラクター名
            Text(characterViewModel.characterDisplayName)
                .font(.custom("GenJyuuGothicX-Bold", size: 22))
                .foregroundColor(.white)
            
            // キャラクター画像
            Image(characterViewModel.getCharacterWindowImageName())
                .resizable()
                .scaledToFit()
                .frame(width: geometry.size.width * 0.6, height: geometry.size.width * 0.6)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(characterViewModel.displayContentColor, lineWidth: 4)
                )
            
            // ステータス表示
            VStack(spacing: 10) {
                HStack {
                    Text("レベル: \(characterViewModel.currentCharacter.level)")
                    Spacer()
                    Text("経験値: \(characterViewModel.currentCharacter.exp)")
                }
                .font(.custom("GenJyuuGothicX-Bold", size: 16))
                .foregroundColor(.white)
                
                // 経験値バー
                ProgressView(value: characterViewModel.expProgressPercentage, total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: characterViewModel.displayContentColor))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                
                Text("次のレベルまで: \(characterViewModel.expToNextLevel) EXP")
                    .font(.custom("GenJyuuGothicX-Bold", size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .background(Color.black.opacity(0.3))
            .cornerRadius(15)
        }
        .frame(width: geometry.size.width * 0.8)
    }
    
    private func characterSelectionGrid(geometry: GeometryProxy) -> some View {
        VStack(spacing: 15) {
            Text("他のキャラクター")
                .font(.custom("GenJyuuGothicX-Bold", size: 18))
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                ForEach(characterViewModel.getAllCharacters(), id: \.id) { character in
                    characterSelectionCard(character: character, geometry: geometry)
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.2))
        .cornerRadius(20)
        .frame(width: geometry.size.width * 0.9)
    }
    
    private func characterSelectionCard(character: Character, geometry: GeometryProxy) -> some View {
        VStack(spacing: 8) {
            // キャラクター画像
            Image("\(character.name)_window_\(character.growthStage)")
                .resizable()
                .scaledToFit()
                .frame(width: geometry.size.width * 0.2, height: geometry.size.width * 0.2)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // キャラクター名
            Text(getCharacterDisplayName(character.name))
                .font(.custom("GenJyuuGothicX-Bold", size: 14))
                .foregroundColor(.white)
            
            // レベル表示
            Text("Lv.\(character.level)")
                .font(.custom("GenJyuuGothicX-Bold", size: 12))
                .foregroundColor(.white.opacity(0.8))
            
            // 切り替えボタン
            Button {
                if let characterType = CharacterType(rawValue: character.name) {
                    let result = characterViewModel.switchCharacter(to: characterType)
                    if result == .success {
                        print("キャラクターを\(character.name)に切り替えました")
                    } else {
                        print("キャラクターの切り替えに失敗しました")
                    }
                }
            } label: {
                Text(canSwitchToCharacter(character) ? "選択" : "解放中")
                    .font(.custom("GenJyuuGothicX-Bold", size: 12))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(canSwitchToCharacter(character) ? Color.green : Color.gray)
                    .cornerRadius(8)
            }
            .disabled(!canSwitchToCharacter(character))
        }
        .padding(8)
        .background(
            character.name == characterViewModel.currentCharacter.name 
            ? Color.yellow.opacity(0.3) 
            : Color.clear
        )
        .cornerRadius(15)
    }
    
    private func canSwitchToCharacter(_ character: Character) -> Bool {
        // 現在のキャラクターが成長段階3でない場合は切り替え不可
        guard characterViewModel.canSwitchToOtherCharacters else { return false }
        
        // 同じキャラクターの場合は切り替え不要
        if character.name == characterViewModel.currentCharacter.name { return false }
        
        // 対象キャラクターが成長段階1以上の場合は切り替え可能
        return character.growthStage >= 1
    }
    
    private func getCharacterDisplayName(_ name: String) -> String {
        switch name {
        case "Dog": return "レーク"
        case "Cat": return "ティナ"
        case "Rabbit": return "ラン"
        default: return name
        }
    }
}

/// プレースホルダー: MVVM対応のShopView実装
struct MVVMShopViewImpl: View {
    @StateObject private var shopViewModel = ShopViewModel()
    @StateObject private var userProfileViewModel = UserProfileViewModel()
    
    var body: some View {
        VStack {
            Text("MVVM Shop View")
                .font(.custom("GenJyuuGothicX-Bold", size: 24))
            
            Text("ポイント: \(userProfileViewModel.userProfile.point)")
                .font(.custom("GenJyuuGothicX-Bold", size: 18))
            
            // カテゴリー選択
            Picker("カテゴリー", selection: $shopViewModel.selectedCategory) {
                ForEach(ShopCategory.allCases, id: \.self) { category in
                    Text(category.displayName).tag(category)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // 商品一覧
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2)) {
                    ForEach(shopViewModel.currentCategoryProducts) { product in
                        productCard(product: product)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("ショップ")
        .alert("購入完了", isPresented: $shopViewModel.showPurchaseAlert) {
            Button("OK") {
                shopViewModel.clearPurchaseMessage()
            }
        } message: {
            Text(shopViewModel.purchaseMessage ?? "")
        }
    }
    
    private func productCard(product: Product) -> some View {
        VStack {
            Image(product.img)
                .resizable()
                .scaledToFit()
                .frame(height: 100)
            
            Text(shopViewModel.getProductDisplayName(product))
                .font(.custom("GenJyuuGothicX-Bold", size: 14))
            
            Text("\(product.price) ポイント")
                .font(.custom("GenJyuuGothicX-Bold", size: 12))
                .foregroundColor(.gray)
            
            Button {
                shopViewModel.purchaseProduct(product)
            } label: {
                Text(product.isBought ? "購入済み" : "購入")
                    .font(.custom("GenJyuuGothicX-Bold", size: 12))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(product.isBought ? Color.gray : Color.blue)
                    .cornerRadius(10)
            }
            .disabled(product.isBought || !shopViewModel.canPurchase(product))
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

#Preview {
    NavigationView {
        MVVMCharacterSelectView()
    }
}