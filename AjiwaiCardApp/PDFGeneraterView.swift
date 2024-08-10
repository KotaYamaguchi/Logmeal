import SwiftUI
import UIKit
import PDFKit
import SwiftData

struct MultiPageAchievementView: View {
    @Environment(\.modelContext) private var context
    @Query private var allData: [AjiwaiCardData]
    @EnvironmentObject var user: UserData
    @State private var currentPage = 0
    @State private var isGeneratingPDF = false
    @State private var pdfURL: URL?
    @State private var showShareSheet = false
    @State private var selectedImage: UIImage?
    let fixedImageWidth: CGFloat = 160
    let fixedImageHeight: CGFloat = 120
    @Binding var previewPDF: Bool

    private func dateFormat(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy年MM月dd日"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    var body: some View {
        NavigationStack {
            VStack {
                PageView(datas: allData, currentPage: $currentPage)

                HStack {
                    Button("前のページ") {
                        if currentPage > 0 {
                            currentPage -= 1
                        }
                    }
                    .disabled(currentPage == 0 || isGeneratingPDF)

                    Button("次のページ") {
                        if currentPage < allData.count - 1 {
                            currentPage += 1
                        }
                    }
                    .disabled(currentPage == allData.count - 1 || isGeneratingPDF)
                }

                if isGeneratingPDF {
                    ProgressView("PDFを生成中...")
                        .padding()
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = pdfURL {
                    ShareSheet(activityItems: [url])
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button("PDFを生成") {
                            Task {
                                await generatePDF()
                            }
                        }
                        .disabled(isGeneratingPDF)

                        if let _ = pdfURL {
                            Button("共有") {
                                showShareSheet = true
                            }
                        }
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        previewPDF = false
                    } label: {
                        Text("キャンセル")
                    }
                }
            }
        }
    }

    func generatePDF() async {
        await MainActor.run {
            isGeneratingPDF = true
        }
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
            await MainActor.run {
                self.pdfURL = pdfPath
                self.isGeneratingPDF = false
            }
        } catch {
            print("Failed to save PDF: \(error)")
            await MainActor.run {
                self.isGeneratingPDF = false
            }
        }
    }

    func drawPage(data: AjiwaiCardData, in context: CGContext, rect: CGRect) {
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
        
        // Draw user name
        drawText(user.name, in: context, rect: CGRect(x: leftMargin, y: currentY, width: contentWidth, height: 20), font: subtitleFont)
        currentY += 40
        
        // Draw menu title
        let menuTitleY = currentY
        drawText("この日の献立", in: context, rect: CGRect(x: leftMargin, y: currentY, width: contentWidth / 2, height: 20), font: subtitleFont)
        currentY += 30
        
        // Draw menu items
        for item in data.menu {
            drawText(item, in: context, rect: CGRect(x: leftMargin, y: currentY, width: contentWidth / 2 - 20, height: 20), font: bodyFont)
            currentY += 20
        }
        
        // Add image next to the menu
        let imageX = rect.width / 2
        let imageY = menuTitleY
        if let image = UIImage(contentsOfFile: "\(data.imagePath.path)") {
            addImage(context: context, pageRect: rect, image: image, imageTop: imageY, imageLeft: imageX, width: fixedImageWidth, height: fixedImageHeight)
        } else {
            let placeholderImage = UIImage(named: "mt_No_Image")!
            addImage(context: context, pageRect: rect, image: placeholderImage, imageTop: imageY, imageLeft: imageX, width: fixedImageWidth, height: fixedImageHeight)
        }

        currentY = max(currentY, imageY + fixedImageHeight) + 20

        // Draw impression title
        drawText("給食の感想", in: context, rect: CGRect(x: leftMargin, y: currentY, width: contentWidth, height: 20), font: subtitleFont)
        currentY += 30
        
        // Draw impression content
        drawText(data.lunchComments, in: context, rect: CGRect(x: leftMargin + 20, y: currentY, width: contentWidth - 40, height: 100), font: bodyFont)
        currentY += 110

        // Draw senses title
        drawText("五感の感想", in: context, rect: CGRect(x: leftMargin, y: currentY, width: contentWidth, height: 20), font: subtitleFont)
        currentY += 30
        
        // Draw senses content
        let senses = [
            ("味覚", data.taste),
            ("触覚", data.tactile),
            ("視覚", data.sight),
            ("嗅覚", data.smell),
            ("聴覚", data.hearing)
        ]
        for (sense, description) in senses {
            drawText("\(sense): \(description)", in: context, rect: CGRect(x: leftMargin + 20, y: currentY, width: contentWidth - 40, height: 60), font: bodyFont)
            currentY += 70
        }
    }

    func drawText(_ text: String, in context: CGContext, rect: CGRect, font: UIFont) {
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

    func addImage(context: CGContext, pageRect: CGRect, image: UIImage, imageTop: CGFloat, imageLeft: CGFloat, width: CGFloat, height: CGFloat) {
        // 画像を描画する矩形領域を定義
        let imageRect = CGRect(x: imageLeft, y: imageTop, width: width, height: height)

        // 画像を指定された矩形領域に描画
        // この方法では、画像が引き伸ばされたり縮小されたりする可能性がある
        image.draw(in: imageRect)

        // 画像の周りに枠線を描画
        context.setStrokeColor(UIColor.black.cgColor)  // 枠線の色を黒に設定
        context.setLineWidth(1.0)  // 枠線の幅を1ポイントに設定
        context.stroke(imageRect)  // 枠線を描画
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

struct PageView: View {
    let datas: [AjiwaiCardData]
    @Binding var currentPage: Int

    var body: some View {
        return TabView(selection: $currentPage) {
            ForEach(datas.indices, id: \.self) { index in
                SavedDataPageView(savedData: datas[index])
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
}

struct SavedDataPageView: View {
    private func dateFormat(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy年MM月dd日"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    let savedData: AjiwaiCardData

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Spacer()
            Text(dateFormat(date: savedData.saveDay) + "の味わいカード")
                .font(.system(size: 18, weight: .bold))
            Spacer()
            HStack {
                VStack {
                    Text("この日の献立")
                        .font(.system(size: 14, weight: .semibold))

                    ForEach(savedData.menu, id: \.self) { item in
                        Text(item)
                            .font(.system(size: 12))
                            .padding(.leading)
                    }
                }
                if let image = UIImage(contentsOfFile: savedData.imagePath.path) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160)
                } else {
                    Image("mt_No_Image")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160)
                }
            }
            Spacer()
            Text("給食の感想")
                .font(.system(size: 14, weight: .semibold))

            Text(savedData.lunchComments)
                .font(.system(size: 12))
                .padding(.leading)
            Spacer()
            Text("五感の感想")
                .font(.system(size: 14, weight: .semibold))

            Group {
                Text("味覚: \(savedData.taste)")
                Text("触覚: \(savedData.tactile)")
                Text("視覚: \(savedData.sight)")
                Text("嗅覚: \(savedData.smell)")
                Text("聴覚: \(savedData.hearing)")
            }
            .font(.system(size: 12))
            .padding(.leading)
            Spacer()
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 20)
        .frame(width: 476.16, height: 673.44) // A4 size
        .background(Color.white)
        .border(Color.black)
    }
}

#Preview {
    MultiPageAchievementView(previewPDF: .constant(false))
        .environmentObject(UserData())
        .modelContainer(for: AjiwaiCardData.self)
}
