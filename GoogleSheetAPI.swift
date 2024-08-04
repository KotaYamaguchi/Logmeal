import SwiftUI

struct SpreadSheetResponse: Codable {
    let range: String
    let majorDimension: String
    let values: [[String]]
}

class SpreadSheetManager: ObservableObject {

    private let apiKey = "AIzaSyCbh9sY7BuFymjxUGQ8vlajBaGvgdOctzE"
    @Published private(set) var spreadSheetResponse = SpreadSheetResponse(range: "", majorDimension: "", values: [[""]])
    
    @MainActor
    func fetchGoogleSheetData(spreadsheetId: String, sheetName: String, cellRange: String) async throws {
        let baseURL = "https://sheets.googleapis.com/v4/spreadsheets"
        let url = "\(baseURL)/\(spreadsheetId)/values/\(sheetName)!\(cellRange)?key=\(apiKey)"
        guard let requestURL = URL(string: url) else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }
        
        let (data, _) = try await URLSession.shared.data(from: requestURL)
        let decoder = JSONDecoder()
        let spreadSheetResponse = try decoder.decode(SpreadSheetResponse.self, from: data)
        
        // 完全に空の場合のみ、空の配列を設定
        if spreadSheetResponse.values.isEmpty || spreadSheetResponse.values.allSatisfy({ $0.isEmpty }) {
            self.spreadSheetResponse = SpreadSheetResponse(
                range: "\(sheetName)!\(cellRange)",
                majorDimension: "ROWS",
                values: [[]]
            )
        } else {
            self.spreadSheetResponse = spreadSheetResponse
        }
    }
}
