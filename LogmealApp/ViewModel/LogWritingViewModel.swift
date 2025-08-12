
import SwiftUI
import PhotosUI
import SwiftData

@MainActor
class LogWritingViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var timeStamp: TimeStamp? = nil
    @Published var currentDate: Date = Date()
    @Published var selectedPhotoItem: PhotosPickerItem? = nil
    @Published var uiImage: UIImage? = nil
    @Published var editedSenseText: [String] = Array(repeating: "", count: 5)
    @Published var editedMenu: [String] = ["", "", "", ""]
    
    @Published var showCameraPicker = false
    @Published var showDatePicker = false
    @Published var showSaveResultAlert = false
    @Published var saveResultMessage: String? = nil
    @Published var showValidationOverlay = false
    @Published var validationMessage: String = ""

    // MARK: - Dependencies
    private var modelContext: ModelContext
    private var userData: UserData

    // MARK: - Constants
    let senseIcons = ["mt_Eye_icon", "mt_Ear_icon", "mt_Nose_icon", "mt_Tongue_icon", "mt_Hand_Icon"]
    let senseTitles = ["みため", "おと", "におい", "あじ", "さわりごこち"]
    let sensePlaceholders = [
        "どんな色やかたちだったかな？",
        "どんな音がしたかな？",
        "どんなにおいがしたかな？",
        "どんな味がしたかな？",
        "さわってみてどうだった？"
    ]
    let senseColors: [Color] = [
        Color(red: 240 / 255, green: 145 / 255, blue: 144 / 255),
        Color(red: 243 / 255, green: 179 / 255, blue: 67 / 255),
        Color(red: 105 / 255, green: 192 / 255, blue: 160 / 255),
        Color(red: 139 / 255, green: 194 / 255, blue: 222 / 255),
        Color(red: 196 / 255, green: 160 / 255, blue: 193 / 255)
    ]

    init(modelContext: ModelContext, userData: UserData) {
        self.modelContext = modelContext
        self.userData = userData
    }
    
    // MARK: - Public Methods
    
    func onAppear(allMenu: [MenuData]) {
        let menuForDate = allMenu.first { $0.day == dateFormatter(date: currentDate) }?.menu
        self.editedMenu = menuForDate ?? []
    }
    
    func handlePhotoPicker(newItem: PhotosPickerItem?) {
        Task {
            if let data = try? await newItem?.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                self.uiImage = image
            }
        }
    }

    func attemptToSave() {
        let missing = missingFields
        if missing.isEmpty {
            saveCurrentData()
            userData.showAnimation = true
        } else {
            validationMessage = missing.joined(separator: "\n")
            showValidationOverlay = true
        }
    }
    
    func dateFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    func frameSize(for image: UIImage) -> CGSize {
        let aspectRatio = image.size.width / image.size.height
        let targetRatio: CGFloat = 3.0 / 4.0
        let tolerance: CGFloat = 0.01
        let width: CGFloat = abs(aspectRatio - targetRatio) < tolerance ? 300.0 : 400.0
        let height = width / aspectRatio
        return CGSize(width: width, height: height)
    }

    // MARK: - Private Methods
    
    private func saveCurrentData() {
        guard let selectedTimeStamp = timeStamp, let imageToSave = uiImage else { 
            saveResultMessage = "保存に必要な情報が不足しています。"
            showSaveResultAlert = true
            return
        }

        let fileName = generateUniqueImageFileName(saveDay: currentDate, timeStamp: selectedTimeStamp)
        
        guard let imagePath = getDocumentPath(saveData: imageToSave, fileName: fileName) else {
            saveResultMessage = "画像の保存に失敗しました…"
            showSaveResultAlert = true
            return
        }

        let newData = AjiwaiCardData(
            saveDay: currentDate,
            times: selectedTimeStamp,
            sight: editedSenseText[0],
            taste: editedSenseText[3],
            smell: editedSenseText[2],
            tactile: editedSenseText[4],
            hearing: editedSenseText[1],
            imagePath: imagePath,
            menu: editedMenu.filter { !$0.isEmpty }
        )
        
        modelContext.insert(newData)
        
        do {
            try modelContext.save()
            saveResultMessage = "保存に成功しました！"
            
            let totalCharacterCount = editedSenseText.map { $0.count }.reduce(0, +)
            updateUserExperience(by: totalCharacterCount)
            updateUserPoints(by: totalCharacterCount)
            
            if userData.currentCharacter.level >= 12 {
                userData.currentCharacter.growthStage = 3
                userData.isGrowthed = true
            } else if userData.currentCharacter.level >= 5 {
                userData.currentCharacter.growthStage = 2
                userData.isGrowthed = true
            }
        } catch {
            print("保存に失敗しました: \(error)")
            saveResultMessage = "保存に失敗しました…"
        }
        showSaveResultAlert = true
    }
    
    private var missingFields: [String] {
        var fields: [String] = []
        if timeStamp == nil {
            fields.append("「あさ」か「ひる」か「よる」を選んでね")
        }
        if uiImage == nil {
            fields.append("写真をとるかライブラリから選んでね")
        }
        return fields
    }

    private func updateUserExperience(by gainedExp: Int) {
        userData.initCharacterData()
        userData.currentCharacter.exp += gainedExp / 10
        
        var newLevel = 0
        for threshold in userData.levelThresholds {
            if userData.currentCharacter.exp >= threshold {
                newLevel += 1
            } else {
                break
            }
        }
        userData.currentCharacter.level = newLevel
        userData.isIncreasedLevel = true
        
        switch userData.selectedCharacter {
        case "Dog":
            userData.DogData = userData.currentCharacter
        case "Cat":
            userData.CatData = userData.currentCharacter
        case "Rabbit":
            userData.RabbitData = userData.currentCharacter
        default:
            break
        }
        userData.saveAllCharacter()
    }
    
    private func updateUserPoints(by gainedExp: Int) {
        let gainedPoints = gainedExp / 10
        userData.point += gainedPoints
    }

    private func generateUniqueImageFileName(saveDay: Date, timeStamp: TimeStamp) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString = dateFormatter.string(from: saveDay)
        let timeString = timeStamp.rawValue
        let uuidString = UUID().uuidString
        return "\(dateString)_\(timeString)_\(uuidString)"
    }

    private func getDocumentPath(saveData: UIImage, fileName: String) -> URL? {
        guard let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let fileURL = documentURL.appendingPathComponent(fileName + ".jpeg")
        do {
            try saveData.jpegData(compressionQuality: 1.0)?.write(to: fileURL)
            return fileURL
        } catch {
            print("画像の保存に失敗しました: \(error)")
            return nil
        }
    }
}
