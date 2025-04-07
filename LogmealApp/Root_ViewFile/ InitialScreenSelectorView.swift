import SwiftUI

struct InitialScreenSelectorView: View {
    @EnvironmentObject var user: UserData
    var body: some View {
        if user.isLogined{
            NewContentView()
        }else{
            FirstLoginView()
        }
    }
}
