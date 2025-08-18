import SwiftUI

/// MVVM対応の設定画面
struct MVVMSettingsViewImplementation: View {
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var userProfileViewModel = UserProfileViewModel()
    @State private var showingResetAlert = false
    @State private var showingExportSheet = false
    
    var body: some View {
        NavigationView {
            Form {
                // ユーザー情報セクション
                Section("ユーザー情報") {
                    userInfoSection()
                }
                
                // アプリ設定セクション
                Section("アプリ設定") {
                    appSettingsSection()
                }
                
                // データ管理セクション
                Section("データ管理") {
                    dataManagementSection()
                }
                
                // アプリ情報セクション
                Section("アプリ情報") {
                    appInfoSection()
                }
                
                // デバッグセクション（開発用）
                Section("デバッグ情報") {
                    debugSection()
                }
            }
            .navigationTitle("設定")
            .alert("データリセット", isPresented: $showingResetAlert) {
                Button("キャンセル", role: .cancel) { }
                Button("リセット", role: .destructive) {
                    settingsViewModel.resetAllData()
                }
            } message: {
                Text("すべてのデータが削除されます。この操作は元に戻せません。")
            }
            .sheet(isPresented: $showingExportSheet) {
                MVVMDataExportView()
            }
            .alert("エラー", isPresented: .constant(settingsViewModel.errorMessage != nil)) {
                Button("OK") {
                    settingsViewModel.clearMessages()
                }
            } message: {
                Text(settingsViewModel.errorMessage ?? "")
            }
            .alert("成功", isPresented: .constant(settingsViewModel.successMessage != nil)) {
                Button("OK") {
                    settingsViewModel.clearMessages()
                }
            } message: {
                Text(settingsViewModel.successMessage ?? "")
            }
        }
    }
    
    private func userInfoSection() -> some View {
        Group {
            HStack {
                Text("名前")
                Spacer()
                Text(userProfileViewModel.userProfile.name.isEmpty ? "未設定" : userProfileViewModel.userProfile.name)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("学年")
                Spacer()
                Text(userProfileViewModel.userProfile.grade.isEmpty ? "未設定" : userProfileViewModel.userProfile.grade)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("クラス")
                Spacer()
                Text(userProfileViewModel.userProfile.yourClass.isEmpty ? "未設定" : userProfileViewModel.userProfile.yourClass)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("年齢")
                Spacer()
                Text("\(userProfileViewModel.userProfile.age)歳")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("ポイント")
                Spacer()
                Text("\(userProfileViewModel.userProfile.point) pt")
                    .foregroundColor(.secondary)
            }
            
            NavigationLink {
                MVVMProfileEditView()
            } label: {
                Text("プロフィール編集")
            }
        }
    }
    
    private func appSettingsSection() -> some View {
        Group {
            Toggle("先生モード", isOn: .constant(userProfileViewModel.userProfile.isTeacher))
                .onChange(of: userProfileViewModel.userProfile.isTeacher) { _, newValue in
                    settingsViewModel.toggleTeacherMode()
                }
            
            Toggle("記録モード", isOn: .constant(userProfileViewModel.userProfile.onRecord))
                .onChange(of: userProfileViewModel.userProfile.onRecord) { _, newValue in
                    settingsViewModel.toggleRecordingMode()
                }
        }
    }
    
    private func dataManagementSection() -> some View {
        Group {
            Button {
                showingExportSheet = true
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("データエクスポート")
                }
            }
            
            Button {
                showingResetAlert = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                    Text("全データリセット")
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    private func appInfoSection() -> some View {
        Group {
            HStack {
                Text("バージョン")
                Spacer()
                Text(settingsViewModel.getAppVersion())
                    .foregroundColor(.secondary)
            }
            
            Link("プライバシーポリシー", destination: URL(string: "https://example.com/privacy")!)
            Link("利用規約", destination: URL(string: "https://example.com/terms")!)
            Link("お問い合わせ", destination: URL(string: "mailto:support@example.com")!)
        }
    }
    
    private func debugSection() -> some View {
        Group {
            DisclosureGroup("デバッグ情報") {
                Text(settingsViewModel.getDebugInfo())
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
            }
        }
    }
}

/// MVVM対応のプロフィール編集画面
struct MVVMProfileEditViewImplementation: View {
    @StateObject private var userProfileViewModel = UserProfileViewModel()
    @State private var name: String = ""
    @State private var grade: String = ""
    @State private var yourClass: String = ""
    @State private var age: Int = 6
    @State private var gender: String = ""
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("基本情報") {
                    TextField("名前", text: $name)
                    TextField("学年", text: $grade)
                    TextField("クラス", text: $yourClass)
                    
                    Picker("年齢", selection: $age) {
                        ForEach(6...12, id: \.self) { age in
                            Text("\(age)歳").tag(age)
                        }
                    }
                    
                    Picker("性別", selection: $gender) {
                        Text("選択してください").tag("")
                        Text("男").tag("男")
                        Text("女").tag("女")
                        Text("その他").tag("その他")
                    }
                }
            }
            .navigationTitle("プロフィール編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        userProfileViewModel.updateProfile(
                            name: name,
                            grade: grade,
                            yourClass: yourClass,
                            age: age,
                            gender: gender
                        )
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadCurrentProfile()
            }
        }
    }
    
    private func loadCurrentProfile() {
        let profile = userProfileViewModel.userProfile
        name = profile.name
        grade = profile.grade
        yourClass = profile.yourClass
        age = profile.age
        gender = profile.gender
    }
}

/// MVVM対応のデータエクスポート画面
struct MVVMDataExportViewImplementation: View {
    @StateObject private var exportViewModel = ExportViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if exportViewModel.isExporting {
                    VStack(spacing: 15) {
                        ProgressView()
                            .scaleEffect(1.5)
                        
                        Text("データをエクスポート中...")
                            .font(.custom("GenJyuuGothicX-Bold", size: 18))
                        
                        ProgressView(value: exportViewModel.exportProgress)
                            .frame(width: 200)
                        
                        Text("\(Int(exportViewModel.exportProgress * 100))%")
                            .font(.custom("GenJyuuGothicX-Bold", size: 16))
                            .foregroundColor(.secondary)
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "square.and.arrow.up.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("データエクスポート")
                            .font(.custom("GenJyuuGothicX-Bold", size: 24))
                        
                        Text("ユーザーデータ、キャラクター情報、味わいカードをJSONファイルとしてエクスポートします。")
                            .font(.custom("GenJyuuGothicX-Bold", size: 16))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        if let errorMessage = exportViewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                        
                        if let successMessage = exportViewModel.successMessage {
                            VStack(spacing: 10) {
                                Text(successMessage)
                                    .foregroundColor(.green)
                                    .multilineTextAlignment(.center)
                                
                                if let fileURL = exportViewModel.exportedFileURL {
                                    ShareLink(item: fileURL) {
                                        Label("ファイルを共有", systemImage: "square.and.arrow.up")
                                            .padding()
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        
                        Button {
                            exportViewModel.exportAllData()
                        } label: {
                            Text("エクスポート開始")
                                .font(.custom("GenJyuuGothicX-Bold", size: 18))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(15)
                        }
                        .disabled(exportViewModel.isExporting)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("データエクスポート")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    MVVMSettingsViewImplementation()
}