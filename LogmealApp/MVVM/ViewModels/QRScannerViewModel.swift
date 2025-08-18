import Foundation
import SwiftUI
import AVFoundation
import Combine

// MARK: - QRScanner ViewModel

@MainActor
class QRScannerViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isScanning: Bool = false
    @Published var scannedCode: String = ""
    @Published var showScannerView: Bool = false
    @Published var showResult: Bool = false
    @Published var scanResult: ScanResult?
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    @Published var hasPermission: Bool = false
    @Published var isProcessing: Bool = false
    
    // MARK: - Services
    private let columnService: ColumnServiceProtocol
    private let menuService: MenuServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        let container = DIContainer.shared
        self.columnService = container.columnService
        self.menuService = container.menuService
        
        checkCameraPermission()
    }
    
    // MARK: - Camera Permission
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            hasPermission = true
        case .notDetermined:
            requestCameraPermission()
        case .denied, .restricted:
            hasPermission = false
            handleError("カメラのアクセス許可が必要です。設定アプリから許可してください。")
        @unknown default:
            hasPermission = false
        }
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.hasPermission = granted
                if !granted {
                    self?.handleError("カメラのアクセス許可が拒否されました。")
                }
            }
        }
    }
    
    // MARK: - QR Scanning
    func startScanning() {
        guard hasPermission else {
            checkCameraPermission()
            return
        }
        
        showScannerView = true
        isScanning = true
        print("✅ QRスキャンを開始しました")
    }
    
    func stopScanning() {
        showScannerView = false
        isScanning = false
        print("✅ QRスキャンを停止しました")
    }
    
    func handleScannedCode(_ code: String) {
        guard !isProcessing else { return }
        
        isProcessing = true
        scannedCode = code
        
        // Process the scanned QR code
        processQRCode(code)
        
        // Stop scanning
        stopScanning()
        
        isProcessing = false
    }
    
    // MARK: - QR Code Processing
    private func processQRCode(_ code: String) {
        // Try to parse the QR code as JSON
        guard let data = code.data(using: .utf8) else {
            handleInvalidQRCode(code)
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                processQRData(json)
            } else {
                handleInvalidQRCode(code)
            }
        } catch {
            handleInvalidQRCode(code)
        }
    }
    
    private func processQRData(_ data: [String: Any]) {
        // Check if it's a column data
        if let columnTitle = data["columnTitle"] as? String,
           let columnCaption = data["columnCaption"] as? String,
           let date = data["date"] as? String {
            
            addColumn(title: columnTitle, caption: columnCaption, date: date)
            
        } else if let menuItems = data["menuItems"] as? [String],
                  let date = data["date"] as? String {
            
            addMenu(items: menuItems, date: date)
            
        } else {
            handleInvalidQRCode(String(data: try! JSONSerialization.data(withJSONObject: data), encoding: .utf8) ?? "")
        }
    }
    
    private func addColumn(title: String, caption: String, date: String) {
        do {
            try columnService.addMonthlyColumn(title: title, caption: caption, for: date)
            
            scanResult = ScanResult(
                type: .column,
                title: "コラムを追加しました",
                message: "「\(title)」を\(date)に追加しました。",
                success: true
            )
            
            showResult = true
            print("✅ QRコードからコラムを追加しました: \(title)")
            
        } catch {
            handleError("コラムの追加に失敗しました: \(error.localizedDescription)")
        }
    }
    
    private func addMenu(items: [String], date: String) {
        do {
            try menuService.addMenuForDate(items, for: date)
            
            scanResult = ScanResult(
                type: .menu,
                title: "メニューを追加しました",
                message: "\(date)のメニューを追加しました。",
                success: true
            )
            
            showResult = true
            print("✅ QRコードからメニューを追加しました: \(date)")
            
        } catch {
            handleError("メニューの追加に失敗しました: \(error.localizedDescription)")
        }
    }
    
    private func handleInvalidQRCode(_ code: String) {
        scanResult = ScanResult(
            type: .unknown,
            title: "無効なQRコード",
            message: "読み取ったQRコードは対応していません。",
            success: false
        )
        
        showResult = true
        print("⚠️ 無効なQRコードです: \(code)")
    }
    
    // MARK: - Result Handling
    func dismissResult() {
        showResult = false
        scanResult = nil
        scannedCode = ""
    }
    
    func dismissError() {
        showError = false
        errorMessage = ""
    }
    
    // MARK: - Computed Properties
    var canStartScanning: Bool {
        return hasPermission && !isScanning
    }
    
    var scanningStatus: String {
        if !hasPermission {
            return "カメラのアクセス許可が必要です"
        } else if isScanning {
            return "QRコードをスキャン中..."
        } else {
            return "QRコードをスキャンする準備ができています"
        }
    }
    
    // MARK: - Private Methods
    private func handleError(_ message: String) {
        errorMessage = message
        showError = true
        print("❌ \(message)")
    }
}

// MARK: - Scan Result Model

struct ScanResult {
    enum ResultType {
        case column
        case menu
        case unknown
    }
    
    let type: ResultType
    let title: String
    let message: String
    let success: Bool
}