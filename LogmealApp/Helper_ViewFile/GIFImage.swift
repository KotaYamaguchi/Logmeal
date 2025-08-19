//
//  GIFImage.swift
//  LogmealApp
//
//  Created by Kota Yamaguchi on 2025/08/19.
//

import Foundation
import UIKit
import SwiftUI
import SwiftyGif

struct GIFImage: UIViewRepresentable {
    private let data: Data?
    private let name: String?
    private let loopCount: Int?
    @Binding var playGif: Bool
    var onFinished: (() -> Void)?
    
    init(data: Data, loopCount: Int = -1, playGif: Binding<Bool> = .constant(true), onFinished: (() -> Void)? = nil) {
        self.data = data
        self.name = nil
        self.loopCount = loopCount
        self._playGif = playGif
        self.onFinished = onFinished
    }
    
    init(name: String, loopCount: Int = -1, playGif: Binding<Bool> = .constant(true), onFinished: (() -> Void)? = nil) {
        self.data = nil
        self.name = name
        self.loopCount = loopCount
        self._playGif = playGif
        self.onFinished = onFinished
    }
    
    func makeUIView(context: Context) -> UIGIFImageView {
        var gifImageView: UIGIFImageView
        if let data = data {
            gifImageView = UIGIFImageView(data: data, loopCount: loopCount!, playGif: playGif)
        } else {
            gifImageView = UIGIFImageView(name: name!, loopCount: loopCount!, playGif: playGif)
        }
        gifImageView.onFinished = onFinished
        return gifImageView
    }
    
    func updateUIView(_ gifImageView: UIGIFImageView, context: Context) {
        gifImageView.updateGIF(name: name ?? "", data: data, loopCount: loopCount!)
        gifImageView.onFinished = onFinished
        
        if playGif {
            gifImageView.imageView.startAnimatingGif()
        } else {
            gifImageView.imageView.stopAnimatingGif()
        }
    }
}
