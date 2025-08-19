
import SwiftUI
import SwiftData
// MARK: - Info View
 struct CharacterInfoView: View {
    let size: CGSize
    @EnvironmentObject var userData: UserData
    private let baseSize = CGSize(width: 1210, height: 785)
    @Query private var characters: [Character]
    private func calculateProgress(for character: Character) -> CGFloat {
        let currentLevel = character.level
        let currentExp = Double(character.exp)
        let thresholds = userData.levelThresholds

        // 1. 最大レベルに達しているかチェック
        guard currentLevel < thresholds.count - 1 else {
            return 1.0 // 最大レベルならバーは100%
        }

        // 2. 現在のレベルと次のレベルに必要な経験値を取得
        let expForCurrentLevel = Double(thresholds[currentLevel])
        let expForNextLevel = Double(thresholds[currentLevel + 1])

        // 3. レベルアップに必要な経験値の総量を計算
        let totalExpForLevel = expForNextLevel - expForCurrentLevel
        
        // ゼロ除算を避ける
        guard totalExpForLevel > 0 else { return 0.0 }

        // 4. 現在のレベルで既に獲得した経験値を計算
        let progressInLevel = currentExp - expForCurrentLevel

        // 5. 割合を計算して返す (0.0〜1.0の範囲に収める)
        let percentage = progressInLevel / totalExpForLevel
        return max(0.0, min(1.0, percentage))
    }
    var body: some View {
        guard let selectedCharacter = characters.first(where: { $0.isSelected }) else {
            // 選択中のキャラクターがいない場合は何も表示しない（クラッシュを防止）
            return AnyView(EmptyView())
        }
        
        // プログレスを計算
        let progressBarWidth = calculateProgress(for: selectedCharacter)
        return AnyView(
            ZStack {
                Image("House_\(characters.first(where: {$0.isSelected})!.name)")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 590 * (size.width / baseSize.width))
                    .offset(x: -50 * (size.width / baseSize.width),
                            y: 130 * (size.height / baseSize.height))
                VStack {
                    HStack(spacing:20){
                        Image("mt_PointBadge")
                            .resizable()
                            .scaledToFit()
                            .frame(width:50)
                        Text("\(userData.point)")
                            .foregroundStyle(.white)
                            .font(.custom("GenJyuuGothicX-Bold", size: 35))
                        Text("pt")
                            .foregroundStyle(.white)
                            .font(.custom("GenJyuuGothicX-Bold", size: 30))
                    }
                    .offset(x: -95 * (size.width / baseSize.width),
                            y: -25 * (size.height / baseSize.height))
                    VStack(spacing:0){
                        Text("\(userData.name)のレーク")
                            .foregroundStyle(.white)
                            .font(.custom("GenJyuuGothicX-Bold", size: 30))
                        HStack(spacing:0){
                            Image("mt_LvBadge")
                                .resizable()
                                .scaledToFit()
                                .frame(width:50)
                            //経験値のプログレスバーの表示
                            ZStack(alignment:.leading){
                                RoundedRectangle(cornerRadius: 20)
                                    .frame(width:260,height: 15)
                                    .foregroundStyle(.white)
                                
                                // プログレスバー（赤色）
                                RoundedRectangle(cornerRadius: 20)
                                    .frame(width: 260 * progressBarWidth, height: 15) // パーセンテージを使用
                                    .foregroundStyle(.red)
                            }
                            Text("LV.\(characters.first(where: {$0.isSelected})!.level)") // currentCharacterのレベルを表示
                                .foregroundStyle(.white)
                                .font(.custom("GenJyuuGothicX-Bold", size: 30))
                                .padding(.horizontal)
                        }
                    }
                    .offset(x: -35 * (size.width / baseSize.width),
                            y: -1 * (size.height / baseSize.height))
                }
            }
        )
    }
    
}
