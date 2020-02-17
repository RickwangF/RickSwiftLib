//
//  NotificationManager.swift
//  Pods-RickSwiftLib_Example
//
//  Created by Rick on 2019/11/20.
//

import UIKit

@objc public protocol NotificationToolDelegate {
    
    @objc optional func enterBackground()
    @objc optional func enterForeground()
    @objc optional func keyboardWillShow(frame: CGRect)
    @objc optional func keyboardWillHide()
}


@objcMembers public class NotificationTool: NSObject {
    
    public weak var delegate: NotificationToolDelegate?
    
    public func addAllObservers() {
        addKeyboardObserver()
        addEnterBackForeObserver()
    }
    
    public func removeAllObservers() {
        removeKeyboardObserver()
        removeEnterBackForeObserver()
    }
    
    
    // MARK: - 进入前后台的通知
    public func addEnterBackForeObserver() {
        let notice: NotificationCenter = NotificationCenter.default
        
        notice.addObserver(self, selector: #selector(enterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notice.addObserver(self, selector: #selector(enterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    public func removeEnterBackForeObserver() {
        
        let notice: NotificationCenter = NotificationCenter.default
        
        notice.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        notice.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func enterBackground() {
        delegate?.enterBackground?()
    }
    
    @objc func enterForeground() {
        delegate?.enterForeground?()
    }
    
    
    // MARK: - 键盘的通知
    public func addKeyboardObserver() {
        let notice: NotificationCenter = NotificationCenter.default
        notice.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notice.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    public func removeKeyboardObserver() {
        let notice: NotificationCenter = NotificationCenter.default
        notice.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        notice.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notifiaction: Notification) {
        if let keyboardFrame: CGRect = notifiaction.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            delegate?.keyboardWillShow?(frame: keyboardFrame)
        }
    }
    
    @objc func keyboardWillHide(_ notifiaction: Notification) {
        delegate?.keyboardWillHide?()
    }
    
}
