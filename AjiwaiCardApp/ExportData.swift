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

    private func escapeForCSV(_ value: String) -> String {
        var escapedValue = value
        if escapedValue.contains(",") || escapedValue.contains("\"") || escapedValue.contains("\n") {
            escapedValue = escapedValue.replacingOccurrences(of: "\"", with: "\"\"")
            escapedValue = "\"\(escapedValue)\""
        }
        return escapedValue
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
                let escapedMenu = escapeForCSV(content.menu.joined(separator: "/"))
                let escapedComments = escapeForCSV(content.lunchComments)
                let escapedSight = escapeForCSV(content.sight)
                let escapedHearing = escapeForCSV(content.hearing)
                let escapedSmell = escapeForCSV(content.smell)
                let escapedTaste = escapeForCSV(content.taste)
                let escapedTactile = escapeForCSV(content.tactile)
                let joinedContent = "\(dateFormat(date: content.saveDay)),\(escapedMenu),\(escapedComments),\(escapedSight),\(escapedHearing),\(escapedSmell),\(escapedTaste),\(escapedTactile)\r\n"
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
