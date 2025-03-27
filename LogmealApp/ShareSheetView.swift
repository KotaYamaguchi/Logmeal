//
//  ShareSheetView.swift
//  AjiwaiCardApp
//
//  Created by 山口昂大 on 2024/05/13.
//

import Foundation
import SwiftUI
import UIKit
//共有シートビュー
struct ActivityView: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]?
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {
    }
}
