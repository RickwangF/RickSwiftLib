//
//  DeviceSize.swift
//  Pods-RickSwiftLib_Example
//
//  Created by Rick on 2019/10/13.
//

import Foundation

public enum DeviceSize {
    
    // MARK: - 屏幕宽高、frame
    static public let width: CGFloat = UIScreen.main.bounds.width
    static public let height: CGFloat = UIScreen.main.bounds.height
    static public let frame: CGRect = UIScreen.main.bounds
    
    // MARK: - 屏幕16:9比例系数下的宽高
    static public let width16_9: CGFloat = DeviceSize.height * 9.0 / 16.0
    static public let height16_9: CGFloat = DeviceSize.width * 16.0 / 9.0
    
    // MARK: - 关于刘海屏幕适配
    static public let tabbarHeight: CGFloat = DeviceSize.aboveiPhoneX ? 83 : 49
    public static let homeHeight: CGFloat = DeviceSize.aboveiPhoneX ? 34 : 0
    static public let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
    
    // MARK: - 设备类型
    static public let isPhone: Bool = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone)
    static public let isPad: Bool = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad)
    static public let aboveiPhoneX: Bool = (Float(String(format: "%.2f", 9.0 / 19.5)) == Float(String(format: "%.2f", DeviceSize.width / DeviceSize.height)))
}


// MARK: - iPhone以375 * 667为基础机型的比例系数，iPad以768 * 1024为基础机型的比例系数
public let WidthUnit: CGFloat = DeviceSize.width / (DeviceSize.isPad ? 768.0 : 375.0)
public let HeightUnit: CGFloat = DeviceSize.isPad ? DeviceSize.height / 1024.0 : ( DeviceSize.aboveiPhoneX ? DeviceSize.height16_9 / 667.0 : DeviceSize.height / 667.0 )


// MARK: - 子试图16:9比例系数下的宽高
public func KSubViewWidth(_ subViewHeight: CGFloat) -> CGFloat {
    return DeviceSize.isPad ? subViewHeight * 3.0 / 4.0 : subViewHeight * 9.0 / 16.0
}

public func KSubViewHeight(_ subviewWidth: CGFloat) -> CGFloat {
    return DeviceSize.isPad ? subviewWidth * 4.0 / 3.0 : subviewWidth * 16.0 / 9.0
}


// MARK: - iPad适配
public func iPadWidth(_ viewWidth: CGFloat) -> CGFloat {
    return viewWidth / 375.0 * DeviceSize.width  // 以375宽度进行比例计算
}

public func iPadHeight(_ viewHeight: CGFloat) -> CGFloat {
    return viewHeight / 667.0 * DeviceSize.height  // 以667高度进行比例计算
}

public func iPadFullScreenWidthToHeight(_ viewHeight: CGFloat) -> CGFloat {
    return DeviceSize.isPad ? DeviceSize.width / 375.0 * viewHeight * HeightUnit : viewHeight * HeightUnit
}


// MARK: - 字体和颜色
public func fontUnit(_ font: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: font * HeightUnit)
}

public func colorDivide255(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor {
    return UIColor.init(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
}

public func color(light: UIColor, dark: UIColor) -> UIColor {
    
    if #available(iOS 13.0, *) {
        return UIColor { (traitCollection) -> UIColor in
            switch traitCollection.userInterfaceStyle {
            case .light:
                return light
            case .dark:
                return dark
            default:
                fatalError()
            }
        }
    } else {
        return light
    }
}
