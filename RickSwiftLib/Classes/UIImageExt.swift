//
//  UIImageExt.swift
//  Pods-RickSwiftLib_Example
//
//  Created by Rick on 2019/12/27.
//

import UIKit

public extension UIImage {
    
    var fixOrientationImage: UIImage {

        guard imageOrientation != .up else { return self }

        var transform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -.pi / 2)
        default:break
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:break
        }
        
        guard let _cgImage_ = cgImage else { return self }
        
        guard let space = _cgImage_.colorSpace else { return self }
        
        guard let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: _cgImage_.bitsPerComponent, bytesPerRow: 0, space: space, bitmapInfo: _cgImage_.bitmapInfo.rawValue) else { return self }
        ctx.concatenate(transform)
        
        ctx.draw(cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        
        guard let cgimg: CGImage = ctx.makeImage() else { return self }
        let img = UIImage(cgImage: cgimg)
        
        return img
    }
    
    func scaledImage(_ newSize: CGSize) -> UIImage {
        
        guard newSize != .zero else { return self }
        
        let clipW = size.width >= newSize.width ? newSize.width : size.width
        let clipH = size.height >= newSize.height ? newSize.height : size.height
        
        guard let sourceImageRef = cgImage else { return self }
        
        guard let newImageRef = sourceImageRef.cropping(to: CGRect(x: (size.width - clipW) * 0.5, y: (size.height - clipH) * 0.5, width: clipW, height: clipH)) else { return self }
        
        return UIImage(cgImage: newImageRef)
    }
    
    func cornerRounded(radius: CGFloat) -> UIImage {
        
        let width = size.width * scale
        let height = size.height * scale
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 1.0)
        UIBezierPath(roundedRect: rect, cornerRadius: radius).addClip()
        draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? self
    }
    
    func mask(withImage image: UIImage) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        draw(in: rect)
        image.draw(in: rect, blendMode: .destinationIn, alpha: 1)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? self
    }
    
    class func image(withColor color: UIColor) -> UIImage? {
        
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    class func screenShot(view: UIView) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let complexViewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return complexViewImage
    }
}


