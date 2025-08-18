import SwiftUI
import PhotosUI

/// MVVM対応の味わいカード作成画面
struct MVVMAjiwaiCardCreateViewImplementation: View {
    @StateObject private var ajiwaiCardViewModel = AjiwaiCardViewModel()
    @StateObject private var characterViewModel = CharacterViewModel()
    @StateObject private var menuViewModel = MenuService(modelContext: DIContainer.shared.resolve(ModelContext.self))
    @Binding var showWritingView: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景
                Image(characterViewModel.backgroundImageName)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // ヘッダー
                        headerView(geometry: geometry)
                        
                        // 日付選択
                        dateSelectionView(geometry: geometry)
                        
                        // 写真選択
                        photoSelectionView(geometry: geometry)
                        
                        // 五感入力
                        senseInputView(geometry: geometry)
                        
                        // メニュー選択
                        menuSelectionView(geometry: geometry)
                        
                        // 保存ボタン
                        saveButton(geometry: geometry)
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            characterViewModel.initCharacterData()
            ajiwaiCardViewModel.resetForm()
        }
        .photosPicker(
            isPresented: .constant(false),
            selection: $ajiwaiCardViewModel.selectedPhotoItem,
            matching: .images
        )
        .onChange(of: ajiwaiCardViewModel.selectedPhotoItem) { _, newItem in
            ajiwaiCardViewModel.handlePhotoPicker(newItem: newItem)
        }
        .overlay(
            // バリデーションオーバーレイ
            validationOverlay(geometry: geometry)
        )
        .alert("エラー", isPresented: .constant(ajiwaiCardViewModel.errorMessage != nil)) {
            Button("OK") {
                ajiwaiCardViewModel.clearErrorMessage()
            }
        } message: {
            Text(ajiwaiCardViewModel.errorMessage ?? "")
        }
        .onChange(of: ajiwaiCardViewModel.showAnimation) { _, showAnimation in
            if !showAnimation {
                // アニメーション終了後にビューを閉じる
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showWritingView = false
                }
            }
        }
    }
    
    private func headerView(geometry: GeometryProxy) -> some View {
        HStack {
            Button("キャンセル") {
                showWritingView = false
            }
            .font(.custom("GenJyuuGothicX-Bold", size: 16))
            .foregroundColor(.white)
            .padding()
            .background(Color.red.opacity(0.7))
            .cornerRadius(10)
            
            Spacer()
            
            Text("味わいカード作成")
                .font(.custom("GenJyuuGothicX-Bold", size: 20))
                .foregroundColor(.white)
            
            Spacer()
            
            // プレースホルダー（左右対称にするため）
            Color.clear
                .frame(width: 100, height: 40)
        }
    }
    
    private func dateSelectionView(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("日付")
                .font(.custom("GenJyuuGothicX-Bold", size: 18))
                .foregroundColor(.white)
            
            DatePicker("", selection: $ajiwaiCardViewModel.currentDate, displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
                .background(Color.white.opacity(0.9))
                .cornerRadius(10)
        }
    }
    
    private func photoSelectionView(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("写真")
                .font(.custom("GenJyuuGothicX-Bold", size: 18))
                .foregroundColor(.white)
            
            if let image = ajiwaiCardViewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(15)
                    .onTapGesture {
                        // 写真を再選択
                    }
            } else {
                Button {
                    // PhotosPicker を表示
                } label: {
                    VStack(spacing: 10) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 40))
                        Text("写真を選択")
                            .font(.custom("GenJyuuGothicX-Bold", size: 16))
                    }
                    .foregroundColor(.gray)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray, style: StrokeStyle(lineWidth: 2, dash: [10]))
                    )
                }
            }
        }
    }
    
    private func senseInputView(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("五感で味わおう")
                .font(.custom("GenJyuuGothicX-Bold", size: 18))
                .foregroundColor(.white)
            
            ForEach(0..<ajiwaiCardViewModel.senseTitles.count, id: \.self) { index in
                senseInputField(
                    title: ajiwaiCardViewModel.senseTitles[index],
                    placeholder: ajiwaiCardViewModel.sensePlaceholders[index],
                    text: bindingForSenseText(index: index),
                    color: ajiwaiCardViewModel.senseColors[index],
                    icon: ajiwaiCardViewModel.senseIcons[index]
                )
            }
        }
    }
    
    private func senseInputField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        color: Color,
        icon: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.custom("GenJyuuGothicX-Bold", size: 16))
                    .foregroundColor(.white)
            }
            
            TextField(placeholder, text: text, axis: .vertical)
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color, lineWidth: 2)
                )
        }
    }
    
    private func menuSelectionView(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("食事の時間")
                .font(.custom("GenJyuuGothicX-Bold", size: 18))
                .foregroundColor(.white)
            
            Picker("時間", selection: $ajiwaiCardViewModel.selectedTime) {
                Text("朝食").tag(TimeStamp.morning)
                Text("昼食").tag(TimeStamp.lunch)
                Text("夕食").tag(TimeStamp.dinner)
            }
            .pickerStyle(SegmentedPickerStyle())
            .background(Color.white.opacity(0.9))
            .cornerRadius(10)
            
            Text("メニュー")
                .font(.custom("GenJyuuGothicX-Bold", size: 16))
                .foregroundColor(.white)
                .padding(.top, 10)
            
            ForEach(0..<ajiwaiCardViewModel.selectedMenu.count, id: \.self) { index in
                TextField("メニュー \(index + 1)", text: bindingForMenu(index: index))
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
            }
        }
    }
    
    private func saveButton(geometry: GeometryProxy) -> some View {
        Button {
            ajiwaiCardViewModel.attemptToSave()
        } label: {
            HStack {
                if ajiwaiCardViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                }
                
                Text(ajiwaiCardViewModel.isLoading ? "保存中..." : "保存する")
                    .font(.custom("GenJyuuGothicX-Bold", size: 18))
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(ajiwaiCardViewModel.isLoading ? Color.gray : Color.green)
            .cornerRadius(15)
        }
        .disabled(ajiwaiCardViewModel.isLoading)
        .padding(.top, 20)
    }
    
    @ViewBuilder
    private func validationOverlay(geometry: GeometryProxy) -> some View {
        if ajiwaiCardViewModel.showValidationOverlay {
            ZStack {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Text("入力不備")
                        .font(.custom("GenJyuuGothicX-Bold", size: 20))
                        .foregroundColor(.white)
                    
                    Text(ajiwaiCardViewModel.validationMessage)
                        .font(.custom("GenJyuuGothicX-Bold", size: 16))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Button("OK") {
                        ajiwaiCardViewModel.clearValidationMessage()
                    }
                    .font(.custom("GenJyuuGothicX-Bold", size: 16))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding(30)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                .padding(.horizontal, 40)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func bindingForSenseText(index: Int) -> Binding<String> {
        Binding<String>(
            get: {
                guard index < ajiwaiCardViewModel.editedSenseText.count else { return "" }
                return ajiwaiCardViewModel.editedSenseText[index]
            },
            set: { newValue in
                guard index < ajiwaiCardViewModel.editedSenseText.count else { return }
                ajiwaiCardViewModel.editedSenseText[index] = newValue
                
                // 対応するプロパティを更新
                switch index {
                case 0: ajiwaiCardViewModel.sight = newValue
                case 1: ajiwaiCardViewModel.hearing = newValue
                case 2: ajiwaiCardViewModel.smell = newValue
                case 3: ajiwaiCardViewModel.taste = newValue
                case 4: ajiwaiCardViewModel.tactile = newValue
                default: break
                }
            }
        )
    }
    
    private func bindingForMenu(index: Int) -> Binding<String> {
        Binding<String>(
            get: {
                guard index < ajiwaiCardViewModel.selectedMenu.count else { return "" }
                return ajiwaiCardViewModel.selectedMenu[index]
            },
            set: { newValue in
                if ajiwaiCardViewModel.selectedMenu.count <= index {
                    ajiwaiCardViewModel.selectedMenu.append(newValue)
                } else {
                    ajiwaiCardViewModel.selectedMenu[index] = newValue
                }
            }
        )
    }
}

#Preview {
    MVVMAjiwaiCardCreateViewImplementation(showWritingView: .constant(true))
}