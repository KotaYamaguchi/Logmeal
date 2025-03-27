import SwiftUI

struct TypeWriterTextView: View {
    private let text: String
    private let speed: TimeInterval
    private let font: Font
    private let textColor: Color
    private let onAnimationCompleted: () -> Void
    
    @State private var textArray: String = ""
    
    init(_ text: String, speed: TimeInterval = 0.1, font: Font = .body, textColor: Color = .primary, onAnimationCompleted: @escaping () -> Void) {
        self.text = text
        self.speed = speed
        self.font = font
        self.textColor = textColor
        self.onAnimationCompleted = onAnimationCompleted
    }
    
    var body: some View {
        Text(textArray)
            .font(font)
            .foregroundColor(textColor)
            .onAppear {
                startAnimation()
            }
    }
    
    private func startAnimation() {
        DispatchQueue.global().async {
            for character in text {
                Thread.sleep(forTimeInterval: speed)
                DispatchQueue.main.async {
                    textArray += String(character)
                }
            }
            DispatchQueue.main.async {
                onAnimationCompleted()
            }
        }
    }
}
