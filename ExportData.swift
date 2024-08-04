import SwiftUI

class ExportData {
    private func dateFormat(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func createCSV(filename: String, datas: [AjiwaiCardData]) {
        let fileManager = FileManager.default
        guard let docURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("URL取得失敗")
        }
        let filePath = docURL.appendingPathComponent("\(filename).csv")
        if let strm = OutputStream(url: filePath, append: false) {
            strm.open()
            defer {
                strm.close()
            }
            
            let BOM = "\u{feff}"
            
            strm.write(BOM, maxLength: 3)
            let header = "日付,献立,給食の感想,視覚,聴覚,嗅覚,味覚,触覚\r\n"
            var row = ""
            for content in datas {
                let joinedContent = "\(dateFormat(date: content.saveDay)),\(content.menu.joined(separator: "/")),\(content.lunchComments),\(content.sight),\(content.hearing),\(content.smell),\(content.taste),\(content.tactile)\r\n"
                row += joinedContent
            }
            let csv = header + row
            
            if let data = csv.data(using: .utf8) {
                data.withUnsafeBytes {
                    strm.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: data.count)
                }
            }
        } else {
            print("false")
        }
    }
}
