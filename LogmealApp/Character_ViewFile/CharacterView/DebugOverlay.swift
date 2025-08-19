
import SwiftUI
import SwiftData
// MARK: - デバッグ用オーバーレイコントロール
 struct DebugOverlay: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject var userData: UserData
    @State private var isExpanded = true
    @State private var dragOffset = CGSize.zero
    @State private var position = CGPoint(x: 100, y: 200) // ★初期位置: 左寄せ
    @Query private var characters: [Character]
    // サイズを小さく、正方形に
    private let panelSize: CGFloat = 220

    var body: some View {
        VStack(spacing: 0) {
            headerView

            if isExpanded {
                ScrollView { // ★内容をスクロール可能に
                    debugContent
                        .frame(width: panelSize - 24) // パディング分を引く
                }
                .frame(width: panelSize, height: panelSize - 48) // header分を引く
                .clipped()
                .transition(.opacity.combined(with: .scale(scale: 0.9, anchor: .top)))
            }
        }
        .frame(width: panelSize, height: panelSize) // ★正方形
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.23), radius: 8, x: 0, y: 4)
        .position(x:500, y:200)
//        .offset(x: position.x + dragOffset.width - panelSize/2, y: position.y + dragOffset.height - panelSize/2)
//       .gesture(dragGesture)
//        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)
//        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: dragOffset)
        .zIndex(999)
        .onAppear(){
            print("DebugOverlay: ", ObjectIdentifier(userData))
        }
    }
    
    private var headerView: some View {
        HStack(spacing: 10) {
            Image(systemName: "ladybug.circle.fill")
                .foregroundColor(.orange)
                .font(.title2)
            
            Text("Debug")
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.clear)
    }
    
    private var debugContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
            characterBasicSection
            Divider()
            growthStageSection
            Divider()
            actionButtonsSection
        }
        .padding(.vertical, 8)
    }
    
    private var characterBasicSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("📊 Character Stats")
            stepperRow(
                label: "Level",
                value: characters.first(where: {$0.isSelected})!.level,
                range: 0...50,
                onChange: { characters.first(where: {$0.isSelected})!.level = $0 }
            )
            stepperRow(
                label: "EXP",
                value: characters.first(where: {$0.isSelected})!.exp,
                range: 0...1000,
                onChange: { characters.first(where: {$0.isSelected})!.exp = $0 }
            )
        }
    }
    
    private var growthStageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("🌱 Growth Stages")
            stepperRow(
                label: "選択中",
                value: characters.first(where: {$0.isSelected})!.growthStage,
                range: 0...3,
                onChange: { newValue in
                    characters.first(where: {$0.isSelected})!.growthStage = newValue
                }
            )
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 6) {
            Button{
                do{
                    try context.save()
                }catch{
                    print("Failed to save context: \(error)")
                }
            }label:{
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Save All")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.16))
                .foregroundColor(.blue)
                .cornerRadius(7)
            }
            .buttonStyle(PlainButtonStyle())
            
            HStack(spacing: 6) {
                Button("Reset") {
                    characters.first(where: {$0.isSelected})!.level = 1
                    characters.first(where: {$0.isSelected})!.exp = 0
                }
                .buttonStyle(compactButtonStyle(color: .red))
            }
        }
    }
    
    // MARK: - Helper Views
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundColor(.secondary)
    }
    
    private func stepperRow<T: BinaryInteger>(
        label: String,
        value: T,
        range: ClosedRange<T>,
        onChange: @escaping (T) -> Void
    ) -> some View {
        HStack {
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundColor(.primary)
                .frame(width: 50, alignment: .leading)
            Spacer()
            Text("\(value)")
                .font(.caption.monospacedDigit())
                .foregroundColor(.secondary)
                .frame(width: 28, alignment: .trailing)
            Stepper("", value: Binding(
                get: { value },
                set: onChange
            ), in: range)
            .labelsHidden()
            .scaleEffect(0.8)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Color.gray.opacity(0.07))
        .cornerRadius(5)
    }
    
    private func compactButtonStyle(color: Color) -> some ButtonStyle {
        CompactDebugButtonStyle(color: color)
    }
    
    // MARK: - Gestures
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
            }
            .onEnded { value in
                position.x += value.translation.width
                position.y += value.translation.height
                // 左寄せ・画面境界内に収める
                let screenWidth = UIScreen.main.bounds.width
                let screenHeight = UIScreen.main.bounds.height
                let minX = panelSize / 2 + 8
                let maxX = screenWidth / 2
                let minY = panelSize / 2 + 8
                let maxY = screenHeight - panelSize / 2 - 8
                position.x = min(max(position.x, minX), maxX)
                position.y = min(max(position.y, minY), maxY)
                dragOffset = .zero
            }
    }
}
