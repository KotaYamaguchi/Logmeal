//
//  OtherSettingView.swift
//  LogmealApp
//
//  Created by Kota Yamaguchi on 2025/08/19.
//

import SwiftUI
import SwiftData
struct OtherSettingView:View {
    @Environment(\.modelContext) private var context
    @Query private var allColumns: [ColumnData]
    @Query private var allMenus: [MenuData]
    @EnvironmentObject var user: UserData
    
    let rowTitles = ["メニューとコラムを入力する","メニューを削除する","コラムを削除する"]
    let rowIcons = ["qrcode","trash","trash"]
    
    @State private var showQRreader:Bool = false
    @State private var showDeleteView:Bool = false
    @State private var selectedDates: Set<DateComponents> = []
    @State private var isColumn = false
    
    @State private var showConfirmAlert = false

    var body: some View {
        ZStack{
            Image("bg_newSettingView.png")
                .resizable()
                .ignoresSafeArea()
            VStack(spacing:10){
                UnevenRoundedRectangle(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20, style: .continuous)
                    .frame(width: 550, height: 40)
                    .foregroundStyle(.white)
                    .overlay{
                        HStack{
                            Text("その他")
                                .padding()
                                .font(.custom("GenJyuuGothicX-Bold", size: 23))
                            Spacer()
                        }
                    }
                VStack(spacing:5){
                    Button{
                        showQRreader = true
                    }label: {
                        SettingRowDesign(withImage: false, rowTitle: rowTitles[0], iconName: rowIcons[0])
                    }
                    Button{
                        isColumn = false
                        showDeleteView = true
                    }label: {
                        SettingRowDesign(withImage: false, rowTitle: rowTitles[1], iconName: rowIcons[1],textColor: .red,icnoColor: .red)
                    }
                    Button{
                        isColumn = true
                        showDeleteView = true
                    }label: {
                        UnevenRoundedRectangle(topLeadingRadius: 0,bottomLeadingRadius: 20,bottomTrailingRadius: 20,topTrailingRadius: 0)
                            .foregroundStyle(.white)
                            .frame(width:550,height: 50)
                            .overlay{
                                HStack(spacing:30){
                                    Image(systemName: "trash")
                                        .font(.system(size: 30))
                                        .foregroundStyle(.red)
                                    Text("コラムを削除する")
                                        .font(.custom("GenJyuuGothicX-Bold", size: 28))
                                        .foregroundStyle(.red)
                                    Spacer()
                                    
                                }
                                .padding(.horizontal)
                            }
                    }
                }
                
            }
            .frame(width: 600, height: 250)
            .background(){
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(Color(red: 220/255, green: 221/255, blue: 221/255))
            }
        }
        .sheet(isPresented: $showQRreader) {
            ScannerView(isPresentingScanner: $showQRreader)
        }
        .sheet(isPresented: $showDeleteView) {
            DeleteColumnAndMenuView(isColumn: isColumn)
        }
    }
    
    private func DeleteColumnAndMenuView(isColumn: Bool) -> some View {
        VStack {
            Text(isColumn ? "削除するコラムの日付を選ぶ" : "削除するメニューの日付を選ぶ")
                .font(.custom("GenJyuuGothicX-Bold", size: 20))

            MultiDatePicker("選択", selection: $selectedDates)
                .environment(\.locale, Locale(identifier: "ja_JP"))
                .frame(maxHeight: 400)

            Button("選択した日付のデータを削除") {
                showConfirmAlert = true
            }
            .font(.custom("GenJyuuGothicX-Bold", size: 20))
            .padding()
            .background(Color.red)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .alert(isPresented: $showConfirmAlert) {
                Alert(
                    title: Text("本当に削除しますか？"),
                    message: Text("一度削除すると元に戻せません。"),
                    primaryButton: .destructive(Text("削除")) {
                        deleteSelectedData(isColumn: isColumn)
                        showDeleteView = false // モーダルを閉じる
                    },
                    secondaryButton: .cancel(Text("キャンセル"))
                )
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }

    private func deleteSelectedData(isColumn:Bool) {
          let dateStrings = selectedDates.compactMap { comp -> String? in
              guard let date = Calendar.current.date(from: comp) else { return nil }
              return user.dateFormatter(date: date)
          }
        if isColumn{
            // ColumnData 削除
            for column in allColumns {
                if dateStrings.contains(column.columnDay) {
                    context.delete(column)
                }
            }
            print("\(selectedDates)のコラムを削除完了")
        }else{
            // MenuData 削除
            for menu in allMenus {
                if dateStrings.contains(menu.day) {
                    context.delete(menu)
                }
            }
            print("\(selectedDates)のメニューを削除完了")
        }
        try? context.save()
      }
}
