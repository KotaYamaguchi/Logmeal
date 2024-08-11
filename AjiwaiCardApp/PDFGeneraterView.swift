import SwiftUI
import UIKit
import PDFKit

struct MultiPagePDFGenerator {
    let allData: [AjiwaiCardData]
    let userName: String
    let userGrade: Int
    let userClass: Int

    func generatePDF() async -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "味わいカード",
            kCGPDFContextAuthor: "飯村研究室"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4 size
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let pdfData = renderer.pdfData { context in
            for data in allData {
                context.beginPage()
                drawPage(data: data, in: context.cgContext, rect: pageRect)
            }
        }

        let tempDir = FileManager.default.temporaryDirectory
        let pdfName = "achievements_\(UUID().uuidString).pdf"
        let pdfPath = tempDir.appendingPathComponent(pdfName)

        do {
            try pdfData.write(to: pdfPath)
            return pdfPath
        } catch {
            print("Failed to save PDF: \(error)")
            return nil
        }
    }

    private func drawPage(data: AjiwaiCardData, in context: CGContext, rect: CGRect) {
        let titleFontSize: CGFloat = 16
        let subtitleFontSize: CGFloat = 14
        let bodyFontSize: CGFloat = 12

        let titleFont = UIFont.systemFont(ofSize: titleFontSize, weight: .bold)
        let subtitleFont = UIFont.systemFont(ofSize: subtitleFontSize, weight: .semibold)
        let bodyFont = UIFont.systemFont(ofSize: bodyFontSize)

        let leftMargin: CGFloat = 40
        let rightMargin: CGFloat = 40
        let topMargin: CGFloat = 40
        let bottomMargin: CGFloat = 40
        let contentWidth = rect.width - leftMargin - rightMargin

        var currentY: CGFloat = topMargin

        // Draw title
        drawText(dateFormat(date: data.saveDay) + "の味わいカード", in: context, rect: CGRect(x: leftMargin, y: currentY, width: contentWidth, height: 30), font: titleFont)
        currentY += 30

        // Draw user grade and class with name
        let gradeClassText = "\(userGrade)年 \(userClass)組"
        let userInfoText = "\(gradeClassText) \(userName)"
        drawText(userInfoText, in: context, rect: CGRect(x: leftMargin, y: currentY, width: contentWidth, height: 20), font: subtitleFont)
        currentY += 40

        // Draw user profile image
        if let image = UIImage(contentsOfFile: "\(data.imagePath.path)") {
            addImage(context: context, pageRect: rect, image: image, imageTop: currentY, imageLeft: leftMargin, width: 160, height: 120)
        } else {
            let placeholderImage = UIImage(named: "mt_No_Image")!
            addImage(context: context, pageRect: rect, image: placeholderImage, imageTop: currentY, imageLeft: leftMargin, width: 160, height: 120)
        }
        currentY += 140

        // Draw menu title
        drawText("この日の献立", in: context, rect: CGRect(x: leftMargin, y: currentY, width: contentWidth / 2, height: 20), font: subtitleFont)
        currentY += 30

        // Draw menu items with icons
        for item in data.menu {
            drawSymbolText("fork.knife", text: item, in: context, rect: CGRect(x: leftMargin, y: currentY, width: contentWidth / 2 - 20, height: 20), font: bodyFont)
            currentY += 20
        }

        currentY += 20

        // Draw impression title
        drawText("給食の感想", in: context, rect: CGRect(x: leftMargin, y: currentY, width: contentWidth, height: 20), font: subtitleFont)
        currentY += 30

        // Draw impression content with a border
        let impressionRect = CGRect(x: leftMargin, y: currentY, width: contentWidth - 40, height: 100)
        context.setStrokeColor(UIColor.gray.cgColor)
        context.setLineWidth(3)
        context.stroke(impressionRect)
        drawText(data.lunchComments, in: context, rect: impressionRect.insetBy(dx: 10, dy: 10), font: bodyFont)
        currentY += 110

        // Draw senses title
        drawText("五感の感想", in: context, rect: CGRect(x: leftMargin, y: currentY, width: contentWidth, height: 20), font: subtitleFont)
        currentY += 30

        // Draw senses content with icons
        let senses = [
            ("eye.fill", "視覚", data.sight),
            ("hearingdevice.ear.fill", "聴覚", data.hearing),
            ("nose.fill", "嗅覚", data.smell),
            ("mouth.fill", "味覚", data.taste),
            ("hand.point.up.fill", "触覚", data.tactile)
        ]
        for (icon, sense, description) in senses {
            drawSymbolText(icon, text: "\(sense): \(description)", in: context, rect: CGRect(x: leftMargin, y: currentY, width: contentWidth - 40, height: 20), font: bodyFont)
            currentY += 30
        }
    }

    private func drawText(_ text: String, in context: CGContext, rect: CGRect, font: UIFont) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineBreakMode = .byWordWrapping

        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: font,
            .foregroundColor: UIColor.black
        ]

        let attributedString = NSAttributedString(string: text, attributes: attributes)
        attributedString.draw(in: rect)
    }

    private func drawSymbolText(_ symbolName: String, text: String, in context: CGContext, rect: CGRect, font: UIFont) {
        let symbol = UIImage(systemName: symbolName)!
        let symbolRect = CGRect(x: rect.origin.x, y: rect.origin.y, width: 20, height: 20)
        symbol.draw(in: symbolRect)

        let textRect = CGRect(x: rect.origin.x + 30, y: rect.origin.y, width: rect.width - 30, height: rect.height)
        drawText(text, in: context, rect: textRect, font: font)
    }

    private func addImage(context: CGContext, pageRect: CGRect, image: UIImage, imageTop: CGFloat, imageLeft: CGFloat, width: CGFloat, height: CGFloat) {
        let imageRect = CGRect(x: imageLeft, y: imageTop, width: width, height: height)
        image.draw(in: imageRect)
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(1.0)
        context.stroke(imageRect)
    }

    private func dateFormat(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy年MM月dd日"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}


struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview{
    ChildHomeView()
        .environmentObject(UserData())
        .modelContainer(for: [AjiwaiCardData.self, MenuData.self, ColumnData.self])
}
