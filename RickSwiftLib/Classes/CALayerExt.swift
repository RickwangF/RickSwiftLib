//
//  CALayerExt.swift
//  Pods-RickSwiftLib_Example
//
//  Created by Rick on 2019/12/18.
//

import Foundation

@objc public extension CALayer {
    
    @objc func animationScale(values: [Float],
                           duration: TimeInterval) {
        
        let keyAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        keyAnimation.duration = duration
        keyAnimation.values = values
        keyAnimation.isCumulative = false
        keyAnimation.isRemovedOnCompletion = false
        add(keyAnimation, forKey: "Scale")
    }
    
    @objc func animationRevole() {
        
        let basicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        basicAnimation.toValue = -.pi * 2.0
        basicAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        basicAnimation.duration = 2
        basicAnimation.repeatCount = MAXFLOAT//你可以设置到最大的整数值
        basicAnimation.isCumulative = false
        basicAnimation.isRemovedOnCompletion = false
        basicAnimation.fillMode = .forwards
        add(basicAnimation, forKey: "Rotation")
    }
    
    @objc func animationMove(to endPoint: CGPoint,
                          duration: TimeInterval,
                          delay: TimeInterval,
                          repeat: Int,
                          option: UIView.AnimationOptions) {
        
        let basicAnimation = CABasicAnimation(keyPath: "position")
        // 1秒后执行
        basicAnimation.beginTime = CACurrentMediaTime() + delay
        // 持续时间
        basicAnimation.duration = duration
        // 重复次数
        basicAnimation.repeatCount = repeatCount
        basicAnimation.isRemovedOnCompletion = false
        // 起始位置
        basicAnimation.fromValue = position
        // 终止位置
        basicAnimation.toValue = CGPoint(x: position.x + endPoint.x, y: position.y + endPoint.y)
        // 添加动画
        add(basicAnimation, forKey: "move")
    }
    
    @objc func animationShake(for frame: CGRect) {
        
        let keyAnimation = CAKeyframeAnimation(keyPath: "position")
        
        let path = CGMutablePath()
        
        let startPoint = CGPoint(x: frame.origin.x + frame.width * 0.5, y: frame.origin.y + frame.height * 0.5)
        path.move(to: startPoint)
        
        for index in 3...0 {
            path.addLine(to: CGPoint(x: startPoint.x - frame.width * 0.02 * CGFloat(index), y: startPoint.y))
            path.addLine(to: CGPoint(x: startPoint.x - frame.width * 0.02 * CGFloat(index), y: startPoint.y))
        }
        
        path.closeSubpath()
        
        keyAnimation.path = path
        keyAnimation.duration = 0.5
        keyAnimation.isRemovedOnCompletion = true
        
        add(keyAnimation, forKey: nil)
    }
}
