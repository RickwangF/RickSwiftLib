//
//  JSTool.swift
//  Pods-RickSwiftLib_Example
//
//  Created by Rick on 2019/12/30.
//

import WebKit

@objc public protocol JSToolDelegate {
    func userContentController(_ function: String, params: [String: Any])
    func userContentController(_ function: String, array: [Any])
    func userContentController(_ function: String, content: String)
    func userContentController(_ function: String, number: NSNumber)
    func userContentController(_ function: String)
    @objc optional func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage)
}

@objcMembers public class JSTool: NSObject, WKScriptMessageHandler {
    
    public class func evaluateJavaScriptFunction(_ function: String, webView: WKWebView?, params: String) {
        
        webView?.evaluateJavaScript(function + "(" + params + ")") { (obj, error) in
            print("-----------evaluateJavaScript Begin-------------")
            print("function: \(function)")
            print("params:  \(params)")
            print(obj ?? "null")
            print(error ?? "无错误信息")
            print("-----------evaluateJavaScript End-------------")
        }
    }
    
    public weak var delegate: JSToolDelegate?
    
    public var isHaveAdded: Bool = false
    
    public func addScriptMessageHandler(_ webView: WKWebView, funcNames: [String]) {
        
        isHaveAdded = true
        
        let userContentController = webView.configuration.userContentController
        
        for funcName in funcNames {
            userContentController.add(self, name: funcName)
        }
    }
    
    public func removeScriptMessageHandler(_ webView: WKWebView, funcNames: [String]) {
        
        isHaveAdded = false
        
        let userContentController = webView.configuration.userContentController
        
        for funcName in funcNames {
            userContentController.removeScriptMessageHandler(forName: funcName)
        }
    }
    
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController?(userContentController, didReceive: message)
        
        if let array = message.body as? [Any] {
            delegate?.userContentController(message.name, array: array)
            return
        }
        
        if let params = message.body as? [String: Any] {
            delegate?.userContentController(message.name, params: params)
            return
        }
        
        if let number = message.body as? NSNumber {
            delegate?.userContentController(message.name, number: number)
            return
        }
        
        if let content = message.body as? String {
            
            let data = Data(content.utf8)
            
            if let object = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) {
                
                if let params = object as? [String : Any] {
                    delegate?.userContentController(message.name, params: params)
                    return
                }
                
                if let array = object as? [Any] {
                    delegate?.userContentController(message.name, array: array)
                    return
                }
            }
            delegate?.userContentController(message.name, content: content)
            return
        }
        
        delegate?.userContentController(message.name)
    }
}

public extension JSTool {
    
    struct DefaultScriptMessage {
        
        public static let route = "App_Route"
        public static let share = "App_Share"
        public static let copy  = "App_Copy"
        public static let setStatusMode = "App_SetStatusMode"
        public static let getUserInfo = "App_GetUserInfo"
        public static let syncUserInfo = "App_SaveUserInfo"
        public static let connectSever = "App_ConnectSever"
        public static let previewMedia = "App_PreviewMedia"
        public static let mediaPick = "App_MediaPick"
        public static let cameraPick = "App_TakePhoto"
        public static let popToRootController = "App_PopToRootController"
        
        fileprivate static let functions: [String] =
            [DefaultScriptMessage.route,
             DefaultScriptMessage.share,
             DefaultScriptMessage.copy,
             DefaultScriptMessage.setStatusMode,
             DefaultScriptMessage.getUserInfo,
             DefaultScriptMessage.syncUserInfo,
             DefaultScriptMessage.connectSever,
             DefaultScriptMessage.previewMedia,
             DefaultScriptMessage.mediaPick,
             DefaultScriptMessage.cameraPick,
             DefaultScriptMessage.popToRootController]
    }
    
    struct JavascriptFunc {
        
    }
    
    func addDefultScriptMessageHandler(_ webView: WKWebView, other funcNames: [String]? = nil) {
        
        if isHaveAdded {
            removeDefultScriptMessageHandler(webView)
        }
        
        var funcs = Array(DefaultScriptMessage.functions)
        
        if funcNames != nil {
            funcs += funcNames!
        }
        addScriptMessageHandler(webView, funcNames: funcs)
    }
    
    func removeDefultScriptMessageHandler(_ webView: WKWebView, other funcNames: [String]? = nil) {
        
        var funcs = Array(DefaultScriptMessage.functions)
        
        if funcNames != nil {
            funcs += funcNames!
        }
        removeScriptMessageHandler(webView, funcNames: funcs)
    }
}
