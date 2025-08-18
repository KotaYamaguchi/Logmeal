import SwiftUI

// MARK: - Character Display Component with MVVM

struct CharacterDisplayView: View {
    @ObservedObject var characterViewModel: CharacterViewModel
    let showStats: Bool
    let size: CGSize
    let enableTapAnimation: Bool
    
    @State private var isAnimating: Bool = false
    
    init(
        characterViewModel: CharacterViewModel,
        showStats: Bool = true,
        size: CGSize = CGSize(width: 200, height: 200),
        enableTapAnimation: Bool = true
    ) {
        self.characterViewModel = characterViewModel
        self.showStats = showStats
        self.size = size
        self.enableTapAnimation = enableTapAnimation
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Character Image
            characterImageView
            
            // Character Stats (if enabled)
            if showStats {
                characterStatsView
            }
        }
        .onTapGesture {
            if enableTapAnimation {
                playRandomAnimation()
            }
        }
    }
    
    // MARK: - Character Image
    @ViewBuilder
    private var characterImageView: some View {
        ZStack {
            // Background circle with character theme color
            Circle()
                .fill(characterViewModel.currentCharacterThemeColor.opacity(0.2))
                .frame(width: size.width, height: size.height)
            
            // Character image
            Image(characterViewModel.currentCharacterImageName)
                .resizable()
                .scaledToFit()
                .frame(width: size.width * 0.8, height: size.height * 0.8)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: isAnimating)
            
            // Growth stage indicator
            if characterViewModel.currentCharacterGrowthStage > 0 {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        growthStageIndicator
                    }
                }
                .frame(width: size.width, height: size.height)
            }
        }
    }
    
    // MARK: - Character Stats
    @ViewBuilder
    private var characterStatsView: some View {
        VStack(spacing: 8) {
            // Character name and level
            HStack {
                Text(characterViewModel.currentCharacterDisplayName)
                    .font(.custom("GenJyuuGothicX-Bold", size: 18))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("Lv.\(characterViewModel.currentCharacterLevel)")
                    .font(.custom("GenJyuuGothicX-Bold", size: 16))
                    .foregroundColor(.secondary)
            }
            
            // Experience progress bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("EXP")
                        .font(.custom("GenJyuuGothicX-Bold", size: 12))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(characterViewModel.currentCharacterExp)/\(characterViewModel.expRequiredForNextLevel)")
                        .font(.custom("GenJyuuGothicX-Bold", size: 12))
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: characterViewModel.expProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: characterViewModel.currentCharacterThemeColor))
                    .frame(height: 6)
            }
            
            // Points display
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 14))
                
                Text("\(characterViewModel.currentCharacterPoints)P")
                    .font(.custom("GenJyuuGothicX-Bold", size: 14))
                    .foregroundColor(.primary)
                
                Spacer()
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Growth Stage Indicator
    @ViewBuilder
    private var growthStageIndicator: some View {
        ZStack {
            Circle()
                .fill(Color.yellow)
                .frame(width: 30, height: 30)
            
            Text("\(characterViewModel.currentCharacterGrowthStage)")
                .font(.custom("GenJyuuGothicX-Bold", size: 16))
                .foregroundColor(.black)
        }
        .shadow(radius: 3)
    }
    
    // MARK: - Animations
    private func playRandomAnimation() {
        // Trigger bounce animation
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isAnimating = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isAnimating = false
            }
        }
        
        // Play character animation if available
        let availableAnimations = ["sit", "eat", "sleep", "happy"]
        if let randomAnimation = availableAnimations.randomElement() {
            let animationName = "\(characterViewModel.currentCharacterName)3_animation_\(randomAnimation)"
            characterViewModel.playAnimation(animationName)
        }
    }
}

// MARK: - Preview

struct CharacterDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            CharacterDisplayView(
                characterViewModel: CharacterViewModel(),
                showStats: true,
                size: CGSize(width: 200, height: 200),
                enableTapAnimation: true
            )
            
            CharacterDisplayView(
                characterViewModel: CharacterViewModel(),
                showStats: false,
                size: CGSize(width: 100, height: 100),
                enableTapAnimation: false
            )
        }
        .padding()
    }
}