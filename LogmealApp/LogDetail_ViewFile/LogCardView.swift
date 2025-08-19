//
//  LogCardView.swift
//  LogmealApp
//
//  Created by Kota Yamaguchi on 2025/08/19.
//

import SwiftUI
import SwiftData
import PhotosUI

struct LogCardlView: View {
    
    @Environment(\.modelContext) private var context
    @EnvironmentObject var user: UserData
    
    @State private var isEditing = false
    
    let dataIndex: Int
    @Query private var allData: [AjiwaiCardData]
    
    private let senseIcons = ["mt_Eye_icon", "mt_Ear_icon", "mt_Nose_icon", "mt_Tongue_icon", "mt_Hand_Icon"]
    
    var body: some View {
        ZStack{
            if isEditing{
                LogEditView(isEditing: $isEditing, dataIndex: dataIndex)
            }else{
                LogDetailView(dataIndex: dataIndex)
            }
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    if !isEditing{
                        Button{
                            isEditing.toggle()
                        }label: {
                            Text("書き直す")
                                .font(.custom("GenJyuuGothicX-Bold",size:15))
                                .frame(width: 180, height: 50)
                                .background(Color.white)
                                .foregroundStyle(Color.cyan)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .overlay{
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.cyan ,lineWidth: 4)
                                }
                        }
                        .padding()
                    }
                }
            }
        }
    }
}
