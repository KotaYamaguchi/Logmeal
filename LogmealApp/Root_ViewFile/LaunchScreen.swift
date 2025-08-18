import SwiftUI
import SwiftData

struct LaunchScreen: View {
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var coordinator: AppCoordinator
    @Environment(\.modelContext) private var modelContext
    @Query private var allData: [AjiwaiCardData]
    
    @State private var isLoading = true
    @State private var isInitialized = false
    
    var body: some View {
        GeometryReader{ geometry in
            if isLoading{
                ZStack{
                    Image("logmeal_icon_view")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 50))
                        .frame(width:geometry.size.width*0.5,height: geometry.size.height*0.5)
                        .position(x:geometry.size.width*0.5,y: geometry.size.height*0.5)
                    Text("© 2024 Iimura Laboratory , Prefectural University of Kumamoto")
                        .font(.custom("GenJyuuGothicX-Bold", size: 18))
                        .position(x:geometry.size.width*0.5,y: geometry.size.height*0.9
                        )
                }
                .onAppear {
                    if !isInitialized {
                        setupMVVMArchitecture()
                        performDataMigration()
                        isInitialized = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation {
                            isLoading = false
                        }
                    }
                }
            }else{
                TitleView()
            }
        }
    }
    
    // MARK: - MVVM Setup
    private func setupMVVMArchitecture() {
        // Setup DI container with dependencies
        DIContainer.shared.setup(modelContext: modelContext, userData: userData)
        
        // Initialize coordinator
        coordinator.initializeApp()
        
        print("✅ MVVM architecture initialized in LaunchScreen")
    }
    
    // MARK: - Data Migration
    private func performDataMigration() {
        for card in allData {
            if card.uuid == nil {
                card.uuid = UUID()
                print("Migration: Added UUID to card")
            }
            if card.time == nil {
                card.time = .lunch
                print("Migration: Added default time to card")
            }
        }
        
        do {
            try modelContext.save()
            print("✅ Data migration completed successfully")
        } catch {
            print("❌ Data migration failed: \(error)")
        }
    }
}

#Preview {
    LaunchScreen()
        .environmentObject(UserData())
        .environmentObject(AppCoordinator())
}
