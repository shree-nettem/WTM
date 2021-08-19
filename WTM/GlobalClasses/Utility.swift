//
//  Utility.swift
//  Copped
//
//  Created by Tarun Sachdeva on 05/12/17.
//  Copyright © 2017 Tsss. All rights reserved.
//

import UIKit
import Foundation
import NVActivityIndicatorView
import SystemConfiguration
import SwiftMessages
import CoreData


class Utility: NSObject {
    
    
    static func createGradientLayer(_ view : UIView) {
        var gradientLayer: CAGradientLayer!
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor(red: 33/255, green: 147/255, blue: 176/255, alpha: 1.0).cgColor, UIColor(red: 109/255, green: 213/255, blue: 237/255, alpha: 1.0).cgColor]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    
    
     static  func hexStringToUIColor (hex:String) -> UIColor {
            var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

            if (cString.hasPrefix("#")) {
                cString.remove(at: cString.startIndex)
            }

            if ((cString.count) != 6) {
                return UIColor.gray
            }

            var rgbValue:UInt64 = 0
            Scanner(string: cString).scanHexInt64(&rgbValue)

            return UIColor(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0)
            )
     }
    
    static func convertDateFormater(_ date: String) -> String
    {
        print(date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "dd/MM/YYYY"
        return  dateFormatter.string(from: date!)
    }
    static func getTodayDateString() -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY"
        return  dateFormatter.string(from: Date())
    }
    static func getTodayDateMonthString() -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-YYYY"
        return  dateFormatter.string(from: Date())
    }
    
    static  func convertToJSONArray(moArray: [NSManagedObject]) -> Any {
        var jsonArray: [[String: Any]] = []
        for item in moArray {
            var dict: [String: Any] = [:]
            for attribute in item.entity.attributesByName {
                //check if value is present, then add key to dictionary so as to avoid the nil value crash
                if let value = item.value(forKey: attribute.key) {
                    dict[attribute.key] = value
                }
            }
            jsonArray.append(dict)
        }
        return jsonArray
    }
    
    
    static func displaySwiftAlert(_ message: String, _ title: String , type : Int) -> UIView
    {
        let view = MessageView.viewFromNib(layout: .cardView)
        var iconImg = UIImage(named: "CrossIcon")
        if type == 0 {
            view.configureTheme(.success)
            iconImg = UIImage(named: "RightTickIcon")
        }
        else if type == 1 {
            view.configureTheme(.warning)
            iconImg = UIImage(named: "CrossIcon")
        }
        else if type == 2 {
            view.configureTheme(.error)
            iconImg = UIImage(named: "CrossIcon")
        }
        view.configureDropShadow()
        view.configureContent(title: title, body: message, iconImage: iconImg!)
        view.button?.isHidden = true
        return view
    }
    
    static func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    static func hideActivityIndicator(){
        let window = UIApplication.shared.keyWindow!
        if let view = window.viewWithTag(Tag.indicatorTag){
            view.removeFromSuperview()
        }
        if let view = window.viewWithTag(Tag.blurviewTag){
            view.removeFromSuperview()
        }
    }
    static func showAlertWithMessage(title: String, message: String,buttonTitle: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertAction.Style.default, handler: nil))
        return alert
    }
    static func showActivityIndicator(){
        NVActivityIndicatorView.DEFAULT_COLOR = Color.logoColor
        let navigationControler = UINavigationController()
        let navigationBarHeight: CGFloat = navigationControler.navigationBar.frame.height
        let window = UIApplication.shared.keyWindow!
        print(window.frame.origin.x)
        let blurView = UIView(frame: CGRect(x: window.frame.origin.x, y: window.frame.origin.y+navigationBarHeight, width: window.frame.width, height: window.frame.height-navigationBarHeight*2))
            window.addSubview(blurView);
            blurView.backgroundColor = UIColor.clear
        let indicatorView = NVActivityIndicatorView(frame: CGRect(x: 50, y: 50, width: 50, height: 50))
        indicatorView.center = CGPoint(x: (window.frame.width)/2, y: (window.frame.height)/2)//blurView.center
            indicatorView.backgroundColor = UIColor.clear
            indicatorView.startAnimating()
        window.addSubview(indicatorView)
            indicatorView.tag = Tag.indicatorTag
        blurView.tag = Tag.blurviewTag

    }
    static func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    
}

extension UIImage {
    
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRect(x:0, y:0, width:size.width, height:size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func toBase64() -> String? {
        guard let imageData = self.pngData() else { return nil }
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
    
    
}

extension UIView {
    
    private static let lineDashPattern: [NSNumber] = [2, 2]
    private static let lineDashWidth: CGFloat = 1.0
    
    func makeDashedBorderLine() {
            let path = CGMutablePath()
            let shapeLayer = CAShapeLayer()
            shapeLayer.lineWidth = UIView.lineDashWidth
            shapeLayer.strokeColor = UIColor.lightGray.cgColor
            shapeLayer.lineDashPattern = UIView.lineDashPattern
            path.addLines(between: [CGPoint(x: bounds.minX, y: bounds.height/2),
                                    CGPoint(x: bounds.maxX, y: bounds.height/2)])
            shapeLayer.path = path
            layer.addSublayer(shapeLayer)
        }
    
    
    func shake() {
            let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            animation.duration = 0.6
            animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
            layer.add(animation, forKey: "shake")
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
         let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
         let mask = CAShapeLayer()
         mask.path = path.cgPath
         self.layer.mask = mask
    }
    
    func setView(_ view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.4, options: .transitionCrossDissolve, animations: {() -> Void in
            view.isHidden = hidden
        }) {(_ : Bool) -> Void in }
    }
    func dropShadow(scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 1
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func addBottomBorderWithColor(color: UIColor) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - 5, width: self.frame.size.width-5, height: 1)
        self.layer.addSublayer(border)
    }
    
    func dropShadowToView(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offSet
        self.layer.shadowRadius = radius
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func addDashedLine() {
        let  path = UIBezierPath()

        let  p0 = CGPoint(x: self.bounds.minX, y: self.bounds.midY)
        path.move(to: p0)

        let  p1 = CGPoint(x: self.bounds.maxX, y: self.bounds.midY)
        path.addLine(to: p1)

        let  dashes: [ CGFloat ] = [ 16.0, 32.0 ]
        path.setLineDash(dashes, count: dashes.count, phase: 0.0)

        path.lineWidth = 8.0
        path.lineCapStyle = .butt
        UIColor.magenta.set()
        path.stroke()
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable
    public var borderWidth: CGFloat
    {
        set (borderWidth) {
            self.layer.borderWidth = borderWidth
        }
        get {
            return self.layer.borderWidth
        }
    }
    @IBInspectable
    public var borderColor:UIColor?
    {
        set (color) {
            self.layer.borderColor = color?.cgColor
        }
        get {
            if let color = self.layer.borderColor
            {
                return UIColor(cgColor: color)
            } else {
                return nil
            }
        }
    }
}



extension String {
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
    
    public func isImage() -> Bool {
        let imageFormats = ["jpg","jpeg", "png","gif","JPG","PNG","JPEG","bmp","BMP"]
        if let ext = self.getExtension() {
            return imageFormats.contains(ext)
        }
        return false
    }
    
    public func getExtension() -> String? {
        let ext = (self as NSString).pathExtension
        if ext.isEmpty {
            return nil
        }
        return ext
    }
    
    public func isURL() -> Bool {
        return URL(string: self) != nil
    }

    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(boundingBox.height)
    }
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(boundingBox.width)
    }
    
    var htmlToAttributedString: NSMutableAttributedString? {
            guard let data = data(using: .utf8) else { return NSMutableAttributedString() }
            do {
                return try NSMutableAttributedString(data: data, options: [.documentType: NSMutableAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
            } catch {
                return NSMutableAttributedString()
            }
        }
        var htmlToString: String {
            return htmlToAttributedString?.string ?? ""
        }
    
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    
    
}

extension NSMutableAttributedString {
    convenience init(htmlString html: String, font: UIFont? = nil, useDocumentFontSize: Bool = true) throws {
        let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        let data = html.data(using: .utf8, allowLossyConversion: true)
        guard (data != nil), let fontFamily = font?.familyName, let attr = try? NSMutableAttributedString(data: data!, options: options, documentAttributes: nil) else {
            try self.init(data: data ?? Data(html.utf8), options: options, documentAttributes: nil)
            return
        }
        
        let fontSize: CGFloat? = useDocumentFontSize ? nil : font!.pointSize
        let range = NSRange(location: 0, length: attr.length)
        attr.enumerateAttribute(.font, in: range, options: .longestEffectiveRangeNotRequired) { attrib, range, _ in
            if let htmlFont = attrib as? UIFont {
                let traits = htmlFont.fontDescriptor.symbolicTraits
                var descrip = htmlFont.fontDescriptor.withFamily(fontFamily)
                
                if (traits.rawValue & UIFontDescriptor.SymbolicTraits.traitBold.rawValue) != 0 {
                    descrip = descrip.withSymbolicTraits(.traitBold)!
                }

                if (traits.rawValue & UIFontDescriptor.SymbolicTraits.traitItalic.rawValue) != 0 {
                    descrip = descrip.withSymbolicTraits(.traitItalic)!
                }
                
                attr.addAttribute(.font, value: UIFont(descriptor: descrip, size: fontSize ?? htmlFont.pointSize), range: range)
            }
        }
        
        self.init(attributedString: attr)
    }
    
    
    public func trimWhiteSpace() -> NSAttributedString {
        let invertedSet = CharacterSet.whitespacesAndNewlines.inverted
        let startRange = string.utf16.description.rangeOfCharacter(from: invertedSet)
        let endRange = string.utf16.description.rangeOfCharacter(from: invertedSet, options: .backwards)
        guard let startLocation = startRange?.upperBound, let endLocation = endRange?.lowerBound else {
            return NSAttributedString(string: string)
        }
        
        let location = string.utf16.distance(from: string.startIndex, to: startLocation) - 1
        let length = string.utf16.distance(from: startLocation, to: endLocation) + 2
        let range = NSRange(location: location, length: length)
        return attributedSubstring(from: range)
    }
    
    
}


extension UITextView {
    
    func setLeftPaddingPoints(){
        self.contentInset = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10)
    }

}


extension UITextField {
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    func changePlaceholderColor(text : String)  {
        self.attributedPlaceholder = NSAttributedString(string: text,
                                                        attributes: [NSAttributedString.Key.foregroundColor: Color.logoColor])
        
    }
}




extension UITextView {
    
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
    
    
}


extension Notification.Name {
    static let didReceiveData = Notification.Name("didReceiveData")
    static let didCompleteTask = Notification.Name("didCompleteTask")
    static let completedLengthyDownload = Notification.Name("completedLengthyDownload")
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension UIPageViewController {

    func enableSwipeGesture() {
        for view in self.view.subviews {
            if let subView = view as? UIScrollView {
                subView.isScrollEnabled = true
            }
        }
    }

    func disableSwipeGesture() {
        for view in self.view.subviews {
            if let subView = view as? UIScrollView {
                subView.isScrollEnabled = false
            }
        }
    }
}



