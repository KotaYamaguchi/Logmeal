import SwiftUI

// MARK: - MVVM Enhanced SettingsView

struct MVVMEnhancedSettingsView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var userData: UserData
    @StateObject private var settingsViewModel: SettingsViewModel
    @StateObject private var bridge: UserDataBridge
    
    init(userData: UserData) {
        self._settingsViewModel = StateObject(wrappedValue: SettingsViewModel())
        let bridge = UserDataBridgeFactory.createBridge(for: userData)
        self._bridge = StateObject(wrappedValue: bridge)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Section
                    profileSection
                    
                    // Preferences Section
                    preferencesSection
                    
                    // Data Management Section
                    dataManagementSection
                    
                    // Information Section
                    informationSection
                    
                    // App Information
                    appInfoSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
        .sheet(isPresented: $settingsViewModel.showProfileEditor) {
            MVVMProfileEditorView()
        }
        .sheet(isPresented: $settingsViewModel.showDataExport) {
            MVVMDataExportView()
        }
        .sheet(isPresented: $settingsViewModel.showAboutApp) {
            AboutAppView()
        }
        .sheet(isPresented: $settingsViewModel.showPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $settingsViewModel.showTermsOfService) {
            TermsOfServiceView()
        }
        .alert("データリセット", isPresented: $settingsViewModel.showResetConfirmation) {
            Button("キャンセル", role: .cancel) {
                settingsViewModel.hideResetConfirmation()
            }
            Button("リセット", role: .destructive) {
                settingsViewModel.resetAllData()
            }
        } message: {
            Text("全てのデータが削除されます。この操作は取り消せません。")
        }
        .alert("リセット完了", isPresented: $settingsViewModel.showResetResult) {
            Button("OK") {
                settingsViewModel.dismissResetResult()
            }
        } message: {
            Text(settingsViewModel.resetMessage)
        }
        .onAppear {
            bridge.syncUserDataToServices()
        }
    }
    
    // MARK: - Profile Section
    @ViewBuilder
    private var profileSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("プロフィール")
                    .font(.custom("GenJyuuGothicX-Bold", size: 20))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            HStack(spacing: 15) {
                // Profile image placeholder
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.gray)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(settingsViewModel.userDisplayName)
                        .font(.custom("GenJyuuGothicX-Bold", size: 18))
                        .foregroundColor(.primary)
                    
                    Text(settingsViewModel.profileCompletionText)
                        .font(.custom("GenJyuuGothicX-Bold", size: 14))
                        .foregroundColor(.secondary)
                    
                    ProgressView(value: settingsViewModel.profileCompletionPercentage)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .frame(width: 150)
                }
                
                Spacer()
                
                Button(action: {
                    settingsViewModel.showProfileEditor()
                }) {
                    Text("編集")
                        .font(.custom("GenJyuuGothicX-Bold", size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.blue)
                        )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
    }
    
    // MARK: - Preferences Section
    @ViewBuilder
    private var preferencesSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("アプリ設定")
                    .font(.custom("GenJyuuGothicX-Bold", size: 20))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            VStack(spacing: 12) {
                // BGM Toggle
                HStack {
                    Image(systemName: "music.note")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    Text("BGM")
                        .font(.custom("GenJyuuGothicX-Bold", size: 16))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Toggle("", isOn: Binding(
                        get: { settingsViewModel.userPreferences.isBGMOn },
                        set: { _ in settingsViewModel.toggleBGM() }
                    ))
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                
                Divider()
                
                // Sound Effects Toggle
                HStack {
                    Image(systemName: "speaker.wave.2")
                        .foregroundColor(.green)
                        .frame(width: 24)
                    
                    Text("効果音")
                        .font(.custom("GenJyuuGothicX-Bold", size: 16))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Toggle("", isOn: Binding(
                        get: { settingsViewModel.userPreferences.isSoundEffectOn },
                        set: { _ in settingsViewModel.toggleSoundEffect() }
                    ))
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                }
                
                Divider()
                
                // Notifications Toggle
                HStack {
                    Image(systemName: "bell")
                        .foregroundColor(.orange)
                        .frame(width: 24)
                    
                    Text("通知")
                        .font(.custom("GenJyuuGothicX-Bold", size: 16))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Toggle("", isOn: Binding(
                        get: { settingsViewModel.userPreferences.isNotificationEnabled },
                        set: { _ in settingsViewModel.toggleNotification() }
                    ))
                    .toggleStyle(SwitchToggleStyle(tint: .orange))
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
    }
    
    // MARK: - Data Management Section
    @ViewBuilder
    private var dataManagementSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("データ管理")
                    .font(.custom("GenJyuuGothicX-Bold", size: 20))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            VStack(spacing: 12) {
                // Export Data
                Button(action: {
                    settingsViewModel.showDataExportView()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("データのエクスポート")
                            .font(.custom("GenJyuuGothicX-Bold", size: 16))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
                
                Divider()
                
                // Reset Data
                Button(action: {
                    settingsViewModel.showResetConfirmation()
                }) {
                    HStack {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .frame(width: 24)
                        
                        Text("全データリセット")
                            .font(.custom("GenJyuuGothicX-Bold", size: 16))
                            .foregroundColor(.red)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
    }
    
    // MARK: - Information Section
    @ViewBuilder
    private var informationSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("情報")
                    .font(.custom("GenJyuuGothicX-Bold", size: 20))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            VStack(spacing: 12) {
                // About App
                Button(action: {
                    settingsViewModel.showAboutAppView()
                }) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("アプリについて")
                            .font(.custom("GenJyuuGothicX-Bold", size: 16))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
                
                Divider()
                
                // Privacy Policy
                Button(action: {
                    settingsViewModel.showPrivacyPolicyView()
                }) {
                    HStack {
                        Image(systemName: "hand.raised")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        
                        Text("プライバシーポリシー")
                            .font(.custom("GenJyuuGothicX-Bold", size: 16))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
                
                Divider()
                
                // Terms of Service
                Button(action: {
                    settingsViewModel.showTermsOfServiceView()
                }) {
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        
                        Text("利用規約")
                            .font(.custom("GenJyuuGothicX-Bold", size: 16))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
    }
    
    // MARK: - App Info Section
    @ViewBuilder
    private var appInfoSection: some View {
        VStack(spacing: 8) {
            Text("Logmeal")
                .font(.custom("GenJyuuGothicX-Bold", size: 24))
                .foregroundColor(.primary)
            
            Text(settingsViewModel.appDisplayVersion)
                .font(.custom("GenJyuuGothicX-Bold", size: 14))
                .foregroundColor(.secondary)
            
            Text("© 2024 Iimura Laboratory")
                .font(.custom("GenJyuuGothicX-Bold", size: 12))
                .foregroundColor(.secondary)
                .padding(.top, 5)
        }
        .padding(.vertical, 20)
    }
}

// MARK: - Placeholder Views

struct MVVMProfileEditorView: View {
    var body: some View {
        NavigationView {
            Text("プロフィール編集画面（MVVM）")
                .navigationTitle("プロフィール編集")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MVVMDataExportView: View {
    var body: some View {
        NavigationView {
            Text("データエクスポート画面（MVVM）")
                .navigationTitle("データエクスポート")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Preview

struct MVVMEnhancedSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MVVMEnhancedSettingsView(userData: UserData())
            .environmentObject(AppCoordinator())
            .environmentObject(UserData())
    }
}