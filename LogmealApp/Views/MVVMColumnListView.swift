import SwiftUI

/// MVVM対応のコラム一覧画面
struct MVVMColumnListViewImplementation: View {
    @StateObject private var columnViewModel = ColumnViewModel()
    @StateObject private var characterViewModel = CharacterViewModel()
    @State private var showSortMenu = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景
                Image(characterViewModel.backgroundImageName)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // ヘッダー
                    headerView(geometry: geometry)
                    
                    // 検索バー
                    searchBar(geometry: geometry)
                    
                    // コラム一覧
                    columnList(geometry: geometry)
                }
            }
        }
        .onAppear {
            columnViewModel.fetchColumns()
            characterViewModel.initCharacterData()
        }
        .sheet(isPresented: $columnViewModel.showQRScanner) {
            MVVMQRScannerView()
        }
        .alert("エラー", isPresented: .constant(columnViewModel.errorMessage != nil)) {
            Button("OK") {
                columnViewModel.clearErrorMessage()
            }
        } message: {
            Text(columnViewModel.errorMessage ?? "")
        }
    }
    
    private func headerView(geometry: GeometryProxy) -> some View {
        HStack {
            Text("コラム")
                .font(.custom("GenJyuuGothicX-Bold", size: geometry.size.width * 0.08))
                .foregroundColor(.white)
            
            Spacer()
            
            // ソートボタン
            Button {
                showSortMenu.toggle()
            } label: {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
            }
            .popover(isPresented: $showSortMenu) {
                sortMenu()
            }
            
            // QRスキャンボタン
            Button {
                columnViewModel.showQRScannerView()
            } label: {
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private func searchBar(geometry: GeometryProxy) -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("コラムを検索...", text: $columnViewModel.searchQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
    private func columnList(geometry: GeometryProxy) -> some View {
        ScrollView {
            if columnViewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(50)
            } else if columnViewModel.filteredColumns.isEmpty {
                emptyStateView()
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(columnViewModel.filteredColumns, id: \.columnDay) { column in
                        columnCard(column: column, geometry: geometry)
                    }
                }
                .padding(.horizontal, 15)
            }
        }
    }
    
    private func columnCard(column: ColumnData, geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(column.title)
                        .font(.custom("GenJyuuGothicX-Bold", size: 18))
                        .foregroundColor(.primary)
                    
                    Text(formatDate(column.columnDay))
                        .font(.custom("GenJyuuGothicX-Bold", size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 既読・未読インジケーター
                Circle()
                    .fill(column.isRead ? Color.gray : Color.blue)
                    .frame(width: 12, height: 12)
            }
            
            // キャプション
            Text(column.caption)
                .font(.custom("GenJyuuGothicX-Bold", size: 16))
                .foregroundColor(.secondary)
                .lineLimit(column.isExpanded ? nil : 3)
                .animation(.easeInOut(duration: 0.3), value: column.isExpanded)
            
            // 操作ボタン
            HStack {
                Button {
                    columnViewModel.toggleExpanded(column)
                } label: {
                    Text(column.isExpanded ? "折りたたむ" : "もっと読む")
                        .font(.custom("GenJyuuGothicX-Bold", size: 14))
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                if !column.isRead {
                    Button {
                        columnViewModel.markAsRead(column)
                    } label: {
                        Text("既読にする")
                            .font(.custom("GenJyuuGothicX-Bold", size: 14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(column.isRead ? Color.clear : Color.blue.opacity(0.3), lineWidth: 2)
        )
    }
    
    private func sortMenu() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(ColumnSortOption.allCases, id: \.self) { option in
                Button {
                    columnViewModel.setSortOption(option)
                    showSortMenu = false
                } label: {
                    HStack {
                        Text(option.displayName)
                            .font(.custom("GenJyuuGothicX-Bold", size: 16))
                        
                        Spacer()
                        
                        if columnViewModel.sortOption == option {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .foregroundColor(.primary)
                }
                .buttonStyle(PlainButtonStyle())
                
                if option != ColumnSortOption.allCases.last {
                    Divider()
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .frame(width: 200)
    }
    
    private func emptyStateView() -> some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("コラムが見つかりません")
                .font(.custom("GenJyuuGothicX-Bold", size: 20))
                .foregroundColor(.gray)
            
            if !columnViewModel.searchQuery.isEmpty {
                Text("「\(columnViewModel.searchQuery)」に一致するコラムがありません")
                    .font(.custom("GenJyuuGothicX-Bold", size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button("検索をクリア") {
                    columnViewModel.searchQuery = ""
                }
                .foregroundColor(.blue)
            }
        }
        .padding(40)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "yyyy年MM月dd日"
            formatter.locale = Locale(identifier: "ja_JP")
            return formatter.string(from: date)
        }
        
        return dateString
    }
}

/// MVVM対応のQRスキャナー画面
struct MVVMQRScannerViewImplementation: View {
    @StateObject private var qrScannerViewModel = QRScannerViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                if qrScannerViewModel.isScanning {
                    // QRスキャナーUI（実際の実装では、Camera Viewが必要）
                    ZStack {
                        Rectangle()
                            .fill(Color.black)
                        
                        VStack {
                            Text("QRコードをスキャン中...")
                                .font(.custom("GenJyuuGothicX-Bold", size: 18))
                                .foregroundColor(.white)
                            
                            // 仮のスキャンエリア表示
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: 3)
                                .frame(width: 250, height: 250)
                            
                            Button("テスト用: サンプルQRコード") {
                                qrScannerViewModel.handleScannedCode("https://example.com/sample-qr")
                            }
                            .foregroundColor(.blue)
                            .padding()
                        }
                    }
                } else {
                    VStack(spacing: 30) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text("QRコードスキャナー")
                            .font(.custom("GenJyuuGothicX-Bold", size: 24))
                        
                        Text("QRコードをカメラに向けてスキャンしてください")
                            .font(.custom("GenJyuuGothicX-Bold", size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        if let errorMessage = qrScannerViewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button {
                            qrScannerViewModel.startScanning()
                        } label: {
                            Text("スキャン開始")
                                .font(.custom("GenJyuuGothicX-Bold", size: 18))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(15)
                        }
                        .padding(.horizontal, 40)
                    }
                    .padding()
                }
            }
            .navigationTitle("QRスキャナー")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        qrScannerViewModel.stopScanning()
                        dismiss()
                    }
                }
            }
            .alert("QRコード読み取り完了", isPresented: $qrScannerViewModel.showResult) {
                Button("OK") {
                    qrScannerViewModel.clearResult()
                    dismiss()
                }
            } message: {
                Text("読み取り結果: \(qrScannerViewModel.scannedCode ?? "")")
            }
        }
    }
}

#Preview {
    MVVMColumnListViewImplementation()
}