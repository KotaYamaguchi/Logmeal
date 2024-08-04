//
//  LaunchScreen.swift
//  AjiwaiCardApp
//
//  Created by 山口昂大 on 2024/07/24.
//

import SwiftUI

struct LaunchScreen: View {
    @State private var isLoading = true
    var body: some View {
        GeometryReader{ geometry in
            if isLoading{
                ZStack{
                    Image("logmeal_icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width:geometry.size.width*0.5,height: geometry.size.height*0.5)
                        .position(x:geometry.size.width*0.5,y: geometry.size.height*0.5)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            isLoading = false
                        }
                    }
                }
            }else{
                ContentView()
            }
        }
    }
}

#Preview {
    LaunchScreen()
}
