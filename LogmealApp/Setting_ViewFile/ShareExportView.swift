//
//  ShareExportView.swift
//  LogmealApp
//
//  Created by Kota Yamaguchi on 2025/08/19.
//

import SwiftUI
import SwiftData

struct ShareExportView: View {
    @Environment(\.modelContext) private var context
    @Query private var allData: [AjiwaiCardData]
    @EnvironmentObject var user: UserData
    
    @State private var pdfURL: URL?
    @State private var showShareSheet = false
    @State private var isGenerating = false
    @State private var showActionSheet = false
    @State private var showDatePicker = false
    @State private var selectedFileType: FileType = .pdf
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var isSelctedPDF = false
    @State private var isSelctedCSV = false
    enum FileType {
        case pdf, csv
    }
    
    var body: some View {
        ZStack{
            Image("bg_newSettingView.png")
                .resizable()
                .ignoresSafeArea()
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 600, height: 250)
                .foregroundStyle(Color(red: 220/255, green: 221/255, blue: 221/255))
            VStack(spacing:10){
                UnevenRoundedRectangle(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20, style: .continuous)
                    .frame(width: 550, height: 40)
                    .foregroundStyle(.white)
                    .overlay{
                        HStack{
                            Text("共有")
                                .padding()
                                .font(.custom("GenJyuuGothicX-Bold", size: 23))
                            Spacer()
                        }
                    }
                VStack(spacing:5){
                    Button{
                        selectedFileType = .pdf
                        isSelctedCSV = false
                        isSelctedPDF.toggle()
                    }label:{
                        ZStack{
                            SettingRowDesign(withImage: false, rowTitle: "PDFで共有", iconName: isSelctedPDF ? "checkmark.circle.fill" : "circle", textColor: allData.isEmpty ? .gray :  .black, icnoColor:isSelctedPDF ? .orange : .gray)

                        }
                    }
                    .disabled(allData.isEmpty)
                    Button{
                        selectedFileType = .csv
                        isSelctedPDF = false
                        isSelctedCSV .toggle()
                    }label:{
                        ZStack{
                            UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 20, bottomTrailingRadius: 20, topTrailingRadius: 0, style: .continuous)
                                .foregroundStyle(.white)
                                .frame(width:550,height: 50)
                                .overlay{
                                    HStack(spacing:30){
                                        Image(systemName: isSelctedCSV ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 30))
                                            .foregroundStyle(isSelctedCSV ? .orange : .gray)
                                        Text("CSVで共有")
                                            .font(.custom("GenJyuuGothicX-Bold", size: 28))
                                            .foregroundStyle(allData.isEmpty ? .gray : .black)
                                        Spacer()
                                        
                                    }
                                    .padding(.horizontal)
                                }
                        }
                    }
                    .disabled(allData.isEmpty)
                }
            }
            .sheet(isPresented: $showDatePicker) {
                VStack {
                    HStack {
                        VStack {
                            Text("この日から")
                                .font(.custom("GenJyuuGothicX-Bold", size: 17))
                            DatePicker("開始日", selection: $startDate, displayedComponents: .date)
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .padding()
                        }
                        Divider()
                            .frame(height: 400)
                        VStack {
                            Text("この日まで")
                                .font(.custom("GenJyuuGothicX-Bold", size: 17))
                            DatePicker("終了日", selection: $endDate, displayedComponents: .date)
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .padding()
                        }
                    }
                    Button("データを共有する") {
                        
                        showDatePicker = false
                        isGenerating = true
                        Task {
                            await generateAndShareFile()
                        }
                    }
                    .font(.custom("GenJyuuGothicX-Bold", size: 15))
                    .frame(width: 220, height: 50)
                    .background(Color.cyan)
                    .foregroundStyle(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .buttonStyle(PlainButtonStyle())
                    Button("キャンセル") {
                        showDatePicker = false
                        
                    }
                    .font(.custom("GenJyuuGothicX-Bold", size: 15))
                    .frame(width: 220, height: 50)
                    .background(Color.gray)
                    .foregroundStyle(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = pdfURL {
                    ShareSheet(activityItems: [url])
                        .onAppear() {
                            isGenerating = false
                        }
                }
            }
            .overlay {
                if isGenerating {
                    ZStack {
                        Color.gray.opacity(0.5).ignoresSafeArea()
                        ProgressView("共有の準備中...")
                            .font(.custom("GenJyuuGothicX-Bold", size: 17))
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .tint(.white)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            VStack{
                Spacer()
                Button{
                    showDatePicker = true
                }label: {
                    Capsule()
                        .frame(width:400,height: 70)
                        .foregroundStyle(isSelctedPDF || isSelctedCSV ? Color(red: 215/255, green: 97/255, blue: 68/255) : .gray)
                        .overlay{
                            Text("完了")
                                .font(.custom("GenJyuuGothicX-Bold", size: 40))
                                .foregroundStyle(.white)
                                .kerning(5)
                        }
                }
                .disabled(!isSelctedPDF && !isSelctedCSV)
            }
        }
    }
    
    @MainActor
    func generateAndShareFile() async {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: startDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate))!
        
        let filteredData = allData
            .filter { $0.saveDay >= startOfDay && $0.saveDay < endOfDay }
            .sorted(by: { $0.saveDay < $1.saveDay })
        
        switch selectedFileType {
        case .pdf:
            let pdfGenerator = MultiPagePDFGenerator(
                allData: filteredData,
                userName: user.name,
                userGrade: user.grade,
                userClass: user.yourClass,
                userAge: String(user.age),
                userSex: user.gender
            )
            let pdfPath = await pdfGenerator.generatePDF()
            
            await MainActor.run {
                self.pdfURL = pdfPath
                self.isGenerating = false
                self.showShareSheet = true
            }
            
        case .csv:
            let exportData = ExportData(
                userName: user.name,
                userGrade: user.grade,
                userClass: user.yourClass,
                userAge: String(user.age),
                userSex: user.gender
            )
            let filename = "\(user.grade)年 \(user.yourClass)組\(user.name)の給食の記録"
            exportData.createCSV(filename: filename, datas: filteredData)
            
            let documentsPath = exportData.getDocumentsDirectory()
            let csvPath = documentsPath.appendingPathComponent("\(filename).csv")
            
            await MainActor.run {
                self.pdfURL = csvPath
                self.isGenerating = false
                self.showShareSheet = true
            }
        }
    }
}
