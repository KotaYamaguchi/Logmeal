import SwiftUI

// MARK: - Complete MVVM ContentView

struct CompleteContentView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var userData: UserData
    @StateObject private var bridge: UserDataBridge
    
    // Tab selection
    @State private var selectedTab: Int = 0
    
    init(userData: UserData) {
        let bridge = UserDataBridgeFactory.createBridge(for: userData)
        self._bridge = StateObject(wrappedValue: bridge)
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            MVVMEnhancedHomeView(userData: userData)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }
                .tag(0)
            
            // Column Tab
            MVVMColumnListView(userData: userData)
                .tabItem {
                    Image(systemName: "doc.text.fill")
                    Text("コラム")
                }
                .tag(1)
            
            // Settings Tab
            MVVMEnhancedSettingsView(userData: userData)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("設定")
                }
                .tag(2)
        }
        .accentColor(.blue)
        .onAppear {
            setupInitialState()
        }
    }
    
    private func setupInitialState() {
        // Sync data between legacy and MVVM systems
        bridge.syncUserDataToServices()
        
        // Initialize coordinator if needed
        if !coordinator.isInitialized {
            coordinator.initializeApp()
        }
    }
}

// MARK: - MVVM Column List View

struct MVVMColumnListView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var userData: UserData
    @StateObject private var columnViewModel: ColumnViewModel
    @StateObject private var qrScannerViewModel: QRScannerViewModel
    @StateObject private var bridge: UserDataBridge
    
    init(userData: UserData) {
        self._columnViewModel = StateObject(wrappedValue: ColumnViewModel())
        self._qrScannerViewModel = StateObject(wrappedValue: QRScannerViewModel())
        let bridge = UserDataBridgeFactory.createBridge(for: userData)
        self._bridge = StateObject(wrappedValue: bridge)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if columnViewModel.isLoading {
                    ProgressView("読み込み中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if columnViewModel.hasColumns {
                    columnListView
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("コラム")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        qrScannerViewModel.startScanning()
                    }) {
                        Image(systemName: "qrcode.viewfinder")
                    }
                }
            }
        }
        .sheet(isPresented: $qrScannerViewModel.showScannerView) {
            QRScannerView(viewModel: qrScannerViewModel)
        }
        .alert("QRスキャン結果", isPresented: $qrScannerViewModel.showResult) {
            Button("OK") {
                qrScannerViewModel.dismissResult()
            }
        } message: {
            if let result = qrScannerViewModel.scanResult {
                Text(result.message)
            }
        }
        .onAppear {
            columnViewModel.fetchColumns()
            bridge.syncUserDataToServices()
        }
    }
    
    // MARK: - Column List
    @ViewBuilder
    private var columnListView: some View {
        List {
            // Unread columns section
            if columnViewModel.hasUnreadColumns {
                Section("未読コラム") {
                    ForEach(columnViewModel.getUnreadColumns(), id: \.columnDay) { column in
                        ColumnRowView(column: column, viewModel: columnViewModel)
                    }
                }
            }
            
            // Read columns section
            if !columnViewModel.getReadColumns().isEmpty {
                Section("既読コラム") {
                    ForEach(columnViewModel.getReadColumns(), id: \.columnDay) { column in
                        ColumnRowView(column: column, viewModel: columnViewModel)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    // MARK: - Empty State
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("コラムがありません")
                .font(.custom("GenJyuuGothicX-Bold", size: 24))
                .foregroundColor(.primary)
            
            Text("QRコードをスキャンして\nコラムを追加してください")
                .font(.custom("GenJyuuGothicX-Bold", size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                qrScannerViewModel.startScanning()
            }) {
                HStack {
                    Image(systemName: "qrcode.viewfinder")
                    Text("QRコードをスキャン")
                }
                .font(.custom("GenJyuuGothicX-Bold", size: 18))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.blue)
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Column Row View

struct ColumnRowView: View {
    let column: ColumnData
    @ObservedObject var viewModel: ColumnViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(column.title)
                    .font(.custom("GenJyuuGothicX-Bold", size: 16))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Spacer()
                
                if !column.isRead {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                }
            }
            
            Text(column.columnDay)
                .font(.custom("GenJyuuGothicX-Bold", size: 12))
                .foregroundColor(.secondary)
            
            if column.isExpanded {
                Text(column.caption)
                    .font(.custom("GenJyuuGothicX-Bold", size: 14))
                    .foregroundColor(.primary)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            // Toggle expanded state and mark as read
            if !column.isRead {
                viewModel.markColumnAsRead(column)
            }
            viewModel.toggleColumnExpanded(column)
        }
    }
}

// MARK: - QR Scanner View

struct QRScannerView: View {
    @ObservedObject var viewModel: QRScannerViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Button("キャンセル") {
                        viewModel.stopScanning()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("QRコードをスキャン")
                        .foregroundColor(.white)
                        .font(.custom("GenJyuuGothicX-Bold", size: 18))
                    
                    Spacer()
                    
                    // Placeholder for balance
                    Button("") { }
                        .disabled(true)
                        .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // Scanner area placeholder
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: 250, height: 250)
                    .overlay(
                        VStack {
                            Image(systemName: "qrcode.viewfinder")
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                            
                            Text("QRコードを枠内に合わせてください")
                                .foregroundColor(.white)
                                .font(.custom("GenJyuuGothicX-Bold", size: 14))
                                .multilineTextAlignment(.center)
                                .padding(.top, 10)
                        }
                    )
                
                Spacer()
                
                // Status text
                Text(viewModel.scanningStatus)
                    .foregroundColor(.white)
                    .font(.custom("GenJyuuGothicX-Bold", size: 16))
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            if viewModel.hasPermission {
                // Start actual scanning logic here
                viewModel.isScanning = true
            }
        }
        .onDisappear {
            viewModel.stopScanning()
        }
    }
}

// MARK: - Preview

struct CompleteContentView_Previews: PreviewProvider {
    static var previews: some View {
        CompleteContentView(userData: UserData())
            .environmentObject(AppCoordinator())
            .environmentObject(UserData())
    }
}