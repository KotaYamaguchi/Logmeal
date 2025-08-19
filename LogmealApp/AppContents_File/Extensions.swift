import SwiftUI

extension Color{
    static let buttonColor = Color("buttonColor")
    static let textColor = Color("textColor")
    static let skipColor = Color("skipColor")
}
extension UIImage {
    func rotate(degrees: CGFloat) -> UIImage? {
        let radians = degrees * .pi / 180
        let newSize = CGSize(width: size.height, height: size.width)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        context.rotate(by: radians)
        draw(in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
