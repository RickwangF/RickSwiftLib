//
//  BaseTypeExt.swift
//  Pods-RickSwiftLib_Example
//
//  Created by Rick on 2019/12/17.
//

import Foundation

// MARK: - NSObject扩展
@objc public extension NSObject {
    
    var jsonString: String? {
        if let string: String = self as? String {
            return string
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: [])
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
    
    class func isNilorEmpty(_ object: Any?) -> Bool {
        
        guard object != nil else { return true }
        
        if let _: NSNull = object as? NSNull {
            return true
        }
        
        if let array: NSArray = object as? NSArray {
            return array.count == 0
        }
        
        if let dictionary: NSDictionary = object as? NSDictionary {
            return dictionary.count == 0
        }
        
        if let set: NSSet = object as? NSSet {
            return set.count == 0
        }
        
        if let string: NSString = object as? NSString {
            return string.length == 0
        }
        
        return false
    }
    
    class func paramsValue(_ object: Any?) -> Any {
        
        guard object != nil else { return NSNull() }
        
        return object!
    }
}


// MARK: - String扩展
public extension String {
    
    func positionOf(sub: String, backwards: Bool = false) -> Int {
        var pos = NSNotFound
        if let range = range(of:sub, options: backwards ? .backwards : .literal ) {
            if !range.isEmpty {
                pos = self.distance(from:startIndex, to:range.lowerBound)
            }
        }
        return pos
    }
    
    func size(font: UIFont, textMaxSize: CGSize) -> CGSize {
        return self.boundingRect(with: textMaxSize, options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil).size
    }
    
    func add(font: UIFont,
                textMaxSize: CGSize = CGSize.zero,
                attributes: Dictionary<NSAttributedString.Key, Any>? = nil,
                alignment: NSTextAlignment = .left,
                lineHeight: CGFloat = 0,
                headIndent: CGFloat = 0,
                tailIndent: CGFloat = 0,
                isAutoLineBreak: Bool = false) -> NSAttributedString {
        
        let paraStyle = NSMutableParagraphStyle()
        
        let textH = size(font: font, textMaxSize: textMaxSize).height
        
        let isAddLineSpace = textH > font.lineHeight
        
        var _lineHeight_ = lineHeight - font.lineHeight
        
        _lineHeight_ = _lineHeight_ <= 0 ? lineHeight : _lineHeight_
        
        paraStyle.lineSpacing = isAddLineSpace ? _lineHeight_ : 0
        
        if !isAutoLineBreak {
            paraStyle.lineBreakMode = .byTruncatingTail
        }
        
        paraStyle.alignment = alignment
        paraStyle.firstLineHeadIndent = headIndent
        paraStyle.headIndent = headIndent
        paraStyle.tailIndent = tailIndent
        
        var tempAttribute = attributes
        
        tempAttribute?[.font] = font
        tempAttribute?[.paragraphStyle] = paraStyle
        
        return NSAttributedString(string: self, attributes: tempAttribute)
    }
    
    // TODO: -根据当前时间转为时间戳
    func timeToTimeStamp(time: String) -> Double {
        let dfmatter = DateFormatter()
        dfmatter.dateFormat="yyyy年MM月dd日 HH:mm:ss"
        let last = dfmatter.date(from: time)
        let timeStamp = last?.timeIntervalSince1970
        return timeStamp!
    }
    
    
    static var deviceVersion: String {
        
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let plat = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch plat {
            
        case "i386",
             "x86_64": return "iPhone Simulator"
            
        case "iPhone1,1":   return "iPhone 2G"
        case "iPhone1,2":   return "iPhone 3G"
        case "iPhone2,1":   return "iPhone 3GS"
            
        case "iPhone3,1",
             "iPhone3,2",
             "iPhone3,3":   return "iPhone 4"
            
        case "iPhone4,1":   return "iPhone 4S"
            
        case "iPhone5,1",
             "iPhone5,2":   return "iPhone 5"
            
        case "iPhone5,3",
             "iPhone5,4":   return "iPhone 5c"
            
        case "iPhone6,1",
             "iPhone6,2":   return "iPhone 5s"
            
        case "iPhone7,1",
             "iPhone7,2":   return "iPhone 6"
            
        case "iPhone8,1",
             "iPhone8,2":   return "iPhone 6s"
            
        case "iPhone8,3",
             "iPhone8,4":   return "iPhone SE"
            
        case "iPhone9,1",
             "iPhone9,3":   return "iPhone 7"
            
        case "iPhone9,2",
             "iPhone9,4":   return "iPhone 7Plus"
            
        case "iPhone10,1",
             "iPhone10,4":  return "iPhone 8"
            
        case "iPhone10,2",
             "iPhone10,5":  return "iPhone 8Plus"
            
        case "iPhone10,3",
             "iPhone10,6":  return "iPhone X"
            
        case "iPhone11,2":  return "iPhone XS"
        case "iPhone11,8":  return "iPhone XR"
            
        case "iPhone11,4",
             "iPhone11,6":  return "iPhone XS Max"
            
            
        case "iPod1,1":     return "iPodTouch"
        case "iPod2,1":     return "iPodTouch 2"
        case "iPod3,1":     return "iPodTouch 3"
        case "iPod4,1":     return "iPodTouch 4"
        case "iPod5,1":     return "iPodTouch 5"
        case "iPod7,1":     return "iPodTouch 6"
            
            
        case "iPad1,1":     return "iPad"
        case "iPad2,1":     return "iPad 2 (WiFi)"
        case "iPad2,2":     return "iPad 2 (GSM)"
        case "iPad2,3":     return "iPad 2 (CDMA)"
        case "iPad2,4":     return "iPad 2 (32nm)"
        case "iPad3,1":     return "iPad 3 (WiFi)"
        case "iPad3,2":     return "iPad 3 (CDMA)"
        case "iPad3,3":     return "iPad 3 (4G)"
        case "iPad3,4":     return "iPad 4 (WiFi)"
        case "iPad3,5":     return "iPad 4 (4G)"
        case "iPad3,6":     return "iPad 4 (CDMA)"
            
        case "iPad6,12",
             "iPad6,11":    return "iPad 9.7"
            
        case "iPad7,5",
             "iPad7,6":     return "iPad (2018) 9.7"
            
        case "iPad4,1",
             "iPad4,2",
             "iPad4,3":     return "iPad Air"
            
        case "iPad5,3",
             "iPad5,4":     return "iPad Air2"
            
        case "iPad2,5":     return "iPad mini (WiFi)"
        case "iPad2,6":     return "iPad mini (GSM)"
        case "iPad2,7":     return "iPad mini (CDMA)"
            
        case "iPad4,4",
             "iPad4,5",
             "iPad4,6":     return "iPad mini2"
            
        case "iPad4,7",
             "iPad4,8",
             "iPad4,9":     return "iPad mini3"
            
        case "iPad5,1",
             "iPad5,2":     return "iPad mini4"
            
        case "iPad6,3",
             "iPad6,4":     return "iPad Pro 9.7"
            
        case "iPad6,7",
             "iPad6,8":     return "iPad Pro 12.9"
            
        case "iPad7,1",
             "iPad7,2":     return "iPad Pro2 12.9"
            
        case "iPad7,3",
             "iPad7,4":     return "iPad Pro2 10.5"
            
        case "iPad8,1",
             "iPad8,2",
             "iPad8,3",
             "iPad8,4":     return "iPad Pro3 11"
            
        case "iPad8,5",
             "iPad8,6":     return "iPad Pro3 9.7"
            
        case "iPad8,7",
             "iPad8,8":     return "iPad Pro3 12.9"
            
        default: return plat
        }
    }
}


public extension String {
    var isInt: Bool {
        let scan = Scanner(string: self)
        var val: Int = 0
        return scan.scanInt(&val) && scan.isAtEnd
    }
    
    var isFloat: Bool {
        let scan = Scanner(string: self)
        var val: Float = 0
        return scan.scanFloat(&val) && scan.isAtEnd
    }
    
    var isNumber: Bool {
        return isInt || isFloat
    }
    
    var isValidHttpURL: Bool {
        let predcate: NSPredicate = NSPredicate(format: "SELF MATCHES%@", #"http[s]{0,1}://[^\s]*"#)
        return predcate.evaluate(with: self)
    }
    
    var removeWhitespaceAndLineBreak: String {
        var sub = trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        sub = sub.replacingOccurrences(of: "\n", with: "")
        sub = sub.replacingOccurrences(of: "\r", with: "")
        return sub
    }
    
    // TODO: URL处理
    var url: URL? {
        return URL(string: self)
    }
    
    var URLEncoded: String {
        return addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed) ?? self
    }
    
    var URLDecoded: String {
        return removingPercentEncoding ?? self
    }
}


// MARK: - NSString扩展
@objc public extension NSString {
    
    class var deviceVersion: String {
        return String.deviceVersion
    }
}



// MARK: - NSAttributedString扩展
@objc public extension NSAttributedString {
    
    class func imageAttribute(_ image: UIImage,
                              textFont: UIFont,
                              imageFont: UIFont? = nil) -> NSAttributedString {
        
        let attchment = NSTextAttachment()
        attchment.image = image
        
        let height = (imageFont == nil ? textFont.lineHeight : imageFont?.lineHeight) ?? 0
        let width = (image.size.width / image.size.height) * height
        let y = (imageFont == nil ? textFont.descender : (textFont.lineHeight - height) * 0.5 + textFont.descender - (imageFont?.descender ?? 0))

        
        attchment.bounds = CGRect(x: 0, y: y, width: width, height: height)
        
        return NSAttributedString(attachment: attchment)
    }
    
    func add(font: UIFont,
                textMaxSize: CGSize = CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)),
                attributes: Dictionary<NSAttributedString.Key, Any>? = nil,
                alignment: NSTextAlignment = .left,
                lineHeight: CGFloat = 0,
                headIndent: CGFloat = 0,
                tailIndent: CGFloat = 0,
                isAutoLineBreak: Bool = false) -> NSAttributedString {
        
        let paraStyle = NSMutableParagraphStyle()
        
        let textH = size(textMaxSize: textMaxSize).height
        
        let isAddLineSpace = textH > font.lineHeight
        
        var _lineHeight_ = lineHeight - font.lineHeight
        
        _lineHeight_ = _lineHeight_ <= 0 ? lineHeight : _lineHeight_
        
        paraStyle.lineSpacing = isAddLineSpace ? _lineHeight_ : 0
        
        if !isAutoLineBreak {
            paraStyle.lineBreakMode = .byTruncatingTail
        }
        
        paraStyle.alignment = alignment
        paraStyle.firstLineHeadIndent = headIndent
        paraStyle.headIndent = headIndent
        paraStyle.tailIndent = tailIndent
        
        guard let mutable: NSMutableAttributedString = self.mutableCopy() as? NSMutableAttributedString else { return self }
        
        guard var tempAttribute = attributes else { return self }
        
        tempAttribute[.font] = font
        tempAttribute[.paragraphStyle] = paraStyle
        
        mutable.addAttributes(tempAttribute, range: NSMakeRange(0, self.length))
        return mutable.copy() as! NSAttributedString
    }
    
    func size(textMaxSize: CGSize) -> CGSize {
        return self.boundingRect(with: textMaxSize, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).size
    }
    
}


// MARK: - Dictiony扩展
public extension Dictionary {
    
    var queryURLEncodedString: String {
        
        var querys: [String] = []
        
        for (key, value) in self {
            
            if let val = value as? String {
                querys.append("\(key)=\(val.URLEncoded)")
                continue
            }
            
            querys.append("\(key)=\(value)")
        }
        return querys.map{ String($0) }.joined(separator: "&")
    }
}
