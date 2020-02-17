//
//  UIBaseExt.swift
//  Pods-RickSwiftLib_Example
//
//  Created by Rick on 2019/12/17.
//

import UIKit

// MARK: - UITableView扩展
@objc extension UITableView {
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        self.estimatedRowHeight = 0
        self.estimatedSectionFooterHeight = 0
        self.estimatedSectionHeaderHeight = 0
    }
}


// MARK: - UILabel扩展
@objc extension UILabel {
    
    public var attributedTextTail: NSAttributedString? {
        set {
            attributedText = newValue
            lineBreakMode = .byTruncatingTail
        }
        get {
            return attributedText
        }
    }
}


// MARK: - UITextView扩展
@objc extension UITextView {
    
    public var attributedTextTail: NSAttributedString? {
        set {
            attributedText = newValue
            textContainer.lineBreakMode = .byTruncatingTail
        }
        get {
            return attributedText
        }
    }
}


// MARK: - UIViewController扩展
@objc extension UIViewController {
    
    public func presentRootController(animated: Bool = false,
                                      complete: (()->Void)? = nil) {
        
        if let presentedViewController = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController {
            presentedViewController.present(self, animated: animated, completion: complete)
        }else{
            UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: animated, completion: complete)
        }
    }
    
    public func presentViewController(_ controller: UIViewController,
                                      animated: Bool = true,
                                      modalPresentationStyle: UIModalPresentationStyle = .fullScreen,
                                      completion: (() -> Void)? = nil) {
        
        controller.modalPresentationStyle = modalPresentationStyle
        self.present(controller, animated: animated, completion: completion)
        
    }
}


// MARK: - UIView扩展
@objc public extension UIView {
    
    var originX: CGFloat {
        set{
            self.frame.origin.x = newValue
        }
        get{
            return self.frame.minX
        }
    }
    
    var originY: CGFloat {
        set{
            self.frame.origin.y = newValue
        }
        get{
            return self.frame.minY
        }
    }
    
    var width: CGFloat {
        set{
            self.frame.size.width = newValue
        }
        get{
            return self.frame.width
        }
    }
    
    var height: CGFloat {
        set{
            self.frame.size.height = newValue
        }
        get{
            return self.frame.height
        }
    }
    
    var maxX: CGFloat {
        get {
            return self.frame.maxX
        }
    }
    
    var maxY: CGFloat {
        get {
            return self.frame.maxY
        }
    }
    
    class var currentControllerView: UIView? {
        get {
            var controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
            
            while (controller?.presentedViewController != nil && !(controller?.presentedViewController is UIAlertController)) {
                controller = controller?.presentedViewController
            }
            return controller?.view
        }
    }
    
    func addSubviewToControllerView() {
        UIView.currentControllerView?.addSubview(self)
    }
    
    func addSubviewToRootControllerView() {
        UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(self)
    }
}




// MARK: - UIColor扩展
@objc extension UIColor {
 
    public convenience init(hexCode: String) {
        
        var cString: String = hexCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            self.init()
            return
        }
            
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: 1)
    }
    
    public func dark(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor {
        return dark(UIColor.init(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha))
    }
    
    public func dark(_ color: UIColor) -> UIColor {
        
        if #available(iOS 13.0, *) {
            return UIColor { (traitCollection) -> UIColor in
                
                switch traitCollection.userInterfaceStyle {
                case .light:
                    return self
                case .dark:
                    return color
                default:
                    fatalError()
                }
            }
        } else {
            return self
        }
    }
}
