//
//  UIViewTransition.swift
//  Pods-RickSwiftLib_Example
//
//  Created by Rick on 2019/11/18.
//

import UIKit

@objc extension UIView {
    
    public func addTranslate() {
        
        if let gestures = self.gestureRecognizers {
            for gesture in gestures {
                if gesture is UIPanGestureRecognizer {
                    self.removeGestureRecognizer(gesture)
                }
            }
        }
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        self.addGestureRecognizer(pan)
    }
    
    public func removeTranslate() {
        if let gestures = self.gestureRecognizers {
            for gesture in gestures {
                if gesture is UIPanGestureRecognizer {
                    self.removeGestureRecognizer(gesture)
                }
            }
        }
    }
    
    @objc private func panAction(_ sender: UIPanGestureRecognizer) {
        
        guard let panView = sender.view else { return }
        let currentPoint = sender.translation(in: panView)
        panView.transform = panView.transform.translatedBy(x: currentPoint.x, y: currentPoint.y)

        if sender.state == .ended {
            
            let viewCenterX: CGFloat = panView.frame.origin.x + panView.frame.width * 0.5
            var transPointX = viewCenterX > UIScreen.main.bounds.width * 0.5 ? (panView.frame.maxX > UIScreen.main.bounds.width ? UIScreen.main.bounds.width - panView.frame.width : panView.frame.origin.x) : (panView.frame.origin.x <= 0 ? 0 : panView.frame.origin.x)
            
            var transPointY = panView.frame.origin.y
            
            if panView.frame.maxY >= UIScreen.main.bounds.height - 44 {
                
                transPointY = (transPointX - (panView.frame.maxY - (UIScreen.main.bounds.height - 44))) > 0 ? UIScreen.main.bounds.height - panView.frame.height : (panView.frame.maxY >= UIScreen.main.bounds.height ? UIScreen.main.bounds.height - panView.frame.height : panView.frame.origin.y)
                
                transPointX = (transPointX - (panView.frame.maxY - (UIScreen.main.bounds.height - 44))) > 0 ? transPointX : (viewCenterX >= UIScreen.main.bounds.width * 0.5 ? UIScreen.main.bounds.width - panView.frame.width : 0)
                view(panView, transformPoint: transPointX, y: transPointY)
                
            }else if panView.frame.origin.y <= 44{
                
                transPointY = (transPointX - panView.frame.origin.y) > 0 ? UIApplication.shared.statusBarFrame.height : (panView.frame.origin.y < UIApplication.shared.statusBarFrame.height) ? UIApplication.shared.statusBarFrame.height : panView.frame.origin.y
                transPointX = (transPointX - panView.frame.origin.y) > 0 ? transPointX : (viewCenterX >= UIScreen.main.bounds.width * 0.5 ? UIScreen.main.bounds.width - panView.frame.width : 0)
            }else{
                
                transPointX = viewCenterX > UIScreen.main.bounds.width * 0.5 ? UIScreen.main.bounds.width - panView.frame.width : 0
            }
            view(panView, transformPoint: transPointX, y: transPointY)
        }
        sender.setTranslation(.zero, in: panView.superview)
    }
    
    private func view(_ panView: UIView, transformPoint x: CGFloat, y: CGFloat) {
        UIView.animateKeyframes(withDuration: 0.25, delay: 0.1, options: .calculationModeCubic, animations: {
            panView.frame.origin.x = x
            panView.frame.origin.y = y
        }) { (finished) in
            
        }
    }
}
