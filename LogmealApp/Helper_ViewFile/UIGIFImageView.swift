import Foundation
import UIKit
import SwiftUI
import SwiftyGif

class UIGIFImageView: UIView,SwiftyGifDelegate {
    private var image = UIImage()
    var imageView = UIImageView()
    private var data: Data?
    private var name: String?
    private var loopCount: Int?
    private var playGif: Bool?
    var onFinished: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(name: String, loopCount: Int, playGif: Bool) {
        self.init()
        self.name = name
        self.loopCount = loopCount
        self.playGif = playGif
        self.layoutSubviews()
    }
    
    convenience init(data: Data, loopCount: Int, playGif: Bool) {
        self.init()
        self.data = data
        self.loopCount = loopCount
        self.playGif = playGif
        self.layoutSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        self.addSubview(imageView)
    }
    
    func updateGIF(name: String, data: Data?, loopCount: Int) {
            do {
                if let data = data {
                    image = try UIImage(gifData: data)
                } else {
                    print(name)
                    image = try UIImage(gifName: name)
                }
            } catch {
                print(error)
            }
            
            if let subview = self.subviews.first as? UIImageView {
                if image.imageData != subview.gifImage?.imageData {
                    imageView = UIImageView(gifImage: image, loopCount: loopCount)
                    imageView.contentMode = .scaleAspectFit
                    
                    imageView.delegate = self  // デリゲートを設定
                    subview.removeFromSuperview()
                }
            } else {
                print("error: no existing subview")
            }
        }
        
        // SwiftyGifDelegate メソッド
        func gifDidStop(sender: UIImageView) {
            onFinished?()
        }
}



