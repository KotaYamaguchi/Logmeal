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
  
    
    var selectedData: AjiwaiCardData
    @Query private var allData: [AjiwaiCardData]
    
    private let senseIcons = ["mt_Eye_icon", "mt_Ear_icon", "mt_Nose_icon", "mt_Tongue_icon", "mt_Hand_Icon"]
    
    var body: some View {
        ZStack{
            if isEditing{
                LogEditView(isEditing: $isEditing, selectedData: selectedData)
            }else{
                LogDetailView(isEditing: $isEditing, selectedData: selectedData)
            }

        }
    }
}
