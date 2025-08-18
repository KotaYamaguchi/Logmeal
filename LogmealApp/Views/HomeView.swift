import SwiftUI

// MARK: - MVVM Enhanced HomeView

struct MVVMEnhancedHomeView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var userData: UserData
    @StateObject private var ajiwaiCardViewModel: AjiwaiCardViewModel
    @StateObject private var characterViewModel: CharacterViewModel
    @StateObject private var bridge: UserDataBridge
    
    init(userData: UserData) {
        self._ajiwaiCardViewModel = StateObject(wrappedValue: AjiwaiCardViewModel())
        self._characterViewModel = StateObject(wrappedValue: CharacterViewModel())
        let bridge = UserDataBridgeFactory.createBridge(for: userData)
        self._bridge = StateObject(wrappedValue: bridge)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                backgroundView(geometry: geometry)
                
                // Main Content
                mainContentView(geometry: geometry)
                
                // Character Animation Overlay
                if characterViewModel.showAnimation {
                    characterAnimationOverlay
                }
            }
        }
        .onAppear {
            characterViewModel.initCharacterData()
            ajiwaiCardViewModel.fetchAjiwaiCards()
            bridge.syncUserDataToServices()
        }
        .sheet(isPresented: $ajiwaiCardViewModel.showCreateView) {
            MVVMAjiwaiCardCreateView()
        }
        .sheet(isPresented: $characterViewModel.showCharacterSelection) {
            MVVMCharacterSelectionView()
        }
    }
    
    // MARK: - Background View
    @ViewBuilder
    private func backgroundView(geometry: GeometryProxy) -> some View {
        Image(characterViewModel.currentCharacterBackgroundImageName)
            .resizable()
            .ignoresSafeArea()
            .scaledToFill()
            .frame(width: geometry.size.width, height: geometry.size.height)
    }
    
    // MARK: - Main Content
    @ViewBuilder
    private func mainContentView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // Header with character and stats
            headerView(geometry: geometry)
            
            // Content area with cards
            contentView(geometry: geometry)
            
            // Add button
            addButtonView(geometry: geometry)
        }
    }
    
    // MARK: - Header View
    @ViewBuilder
    private func headerView(geometry: GeometryProxy) -> some View {
        HStack {
            // Character display
            CharacterDisplayView(
                characterViewModel: characterViewModel,
                showStats: true,
                size: CGSize(width: 120, height: 120),
                enableTapAnimation: true
            )
            .onTapGesture {
                characterViewModel.showCharacterSelectionView()
            }
            
            Spacer()
            
            // Stats and info
            VStack(alignment: .trailing, spacing: 8) {
                Text("ログ数: \(ajiwaiCardViewModel.logCount)")
                    .font(.custom("GenJyuuGothicX-Bold", size: 16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.black.opacity(0.6))
                    )
                
                if characterViewModel.canGrow {
                    Button(action: {
                        characterViewModel.growCurrentCharacter()
                    }) {
                        Text("成長！")
                            .font(.custom("GenJyuuGothicX-Bold", size: 14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.orange)
                            )
                    }
                    .scaleEffect(1.1)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: characterViewModel.canGrow)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
    }
    
    // MARK: - Content View
    @ViewBuilder
    private func contentView(geometry: GeometryProxy) -> some View {
        ScrollView {
            if ajiwaiCardViewModel.hasAjiwaiCards {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(Array(ajiwaiCardViewModel.ajiwaiCards.enumerated()), id: \.element.id) { index, card in
                        AjiwaiCardThumbnailView(card: card)
                            .onTapGesture {
                                ajiwaiCardViewModel.selectCard(at: index)
                            }
                    }
                }
                .padding(.horizontal, 20)
            } else {
                emptyStateView(geometry: geometry)
            }
        }
        .frame(maxHeight: geometry.size.height * 0.5)
    }
    
    // MARK: - Empty State
    @ViewBuilder
    private func emptyStateView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "plus.circle")
                .font(.system(size: 80))
                .foregroundColor(characterViewModel.currentCharacterThemeColor.opacity(0.6))
            
            Text("まだ味わいカードがありません\n最初のカードを作成しましょう！")
                .font(.custom("GenJyuuGothicX-Bold", size: 18))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black.opacity(0.6))
                )
        }
        .frame(height: geometry.size.height * 0.3)
    }
    
    // MARK: - Add Button
    @ViewBuilder
    private func addButtonView(geometry: GeometryProxy) -> some View {
        Button(action: {
            ajiwaiCardViewModel.showCreateCardView()
        }) {
            Image(characterViewModel.currentCharacterAddButtonImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
        }
        .padding(.bottom, 30)
        .scaleEffect(1.05)
        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: true)
    }
    
    // MARK: - Character Animation Overlay
    @ViewBuilder
    private var characterAnimationOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    characterViewModel.hideAnimation()
                }
            
            VStack {
                if !characterViewModel.currentAnimation.isEmpty {
                    // This would display a GIF or animation
                    Text("アニメーション: \(characterViewModel.currentAnimation)")
                        .font(.custom("GenJyuuGothicX-Bold", size: 24))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.black.opacity(0.8))
                        )
                }
                
                Button("閉じる") {
                    characterViewModel.hideAnimation()
                }
                .font(.custom("GenJyuuGothicX-Bold", size: 18))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(characterViewModel.currentCharacterThemeColor)
                )
                .padding(.top, 20)
            }
        }
    }
}

// MARK: - AjiwaiCard Thumbnail View

struct AjiwaiCardThumbnailView: View {
    let card: AjiwaiCardData
    
    var body: some View {
        VStack(spacing: 8) {
            // Card image
            AsyncImage(url: card.imagePath) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 120, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Card info
            VStack(spacing: 4) {
                Text(formatDate(card.saveDay))
                    .font(.custom("GenJyuuGothicX-Bold", size: 12))
                    .foregroundColor(.white)
                
                if let time = card.time {
                    Text(timeDisplayName(time))
                        .font(.custom("GenJyuuGothicX-Bold", size: 10))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.7))
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
    
    private func timeDisplayName(_ time: TimeStamp) -> String {
        switch time {
        case .morning: return "朝"
        case .lunch: return "昼"
        case .dinner: return "夜"
        }
    }
}

// MARK: - Placeholder Views for MVVM

struct MVVMAjiwaiCardCreateView: View {
    var body: some View {
        NavigationView {
            Text("味わいカード作成画面（MVVM）")
                .navigationTitle("カード作成")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MVVMCharacterSelectionView: View {
    var body: some View {
        NavigationView {
            Text("キャラクター選択画面（MVVM）")
                .navigationTitle("キャラクター選択")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Preview

struct MVVMEnhancedHomeView_Previews: PreviewProvider {
    static var previews: some View {
        MVVMEnhancedHomeView(userData: UserData())
            .environmentObject(AppCoordinator())
            .environmentObject(UserData())
    }
}