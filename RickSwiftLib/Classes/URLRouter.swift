//
//  URLRouter.swift
//  Pods-RickSwiftLib_Example
//
//  Created by Rick on 2019/12/20.
//

import Foundation

import UIKit

public enum URLRouterMode {
    case push
    case present
    case pop
}

public enum URLRouterError: Error {
    /// 路由解析失败
    case routeResolveFail
    /// 路由参数获取失败
    case routeForParamsFail
    /// 路由链接为nil
    case routeLinkEmpty
    /// 路由链接非法
    case routeLinkError
    /// 路由目标未找到
    case routeTargetNotFound
}

@objc public protocol URLRouter {
    
    /// 用于重写，定义路由需要忽略的特殊参数key
    @objc optional static func ignoreRouteParamsKey() -> [String]
    
    /// 用于重写，定义需要替换 value 的参数，与 ignore 可同时使用，会替换 ignore 里面的value
    @objc optional static func replaceRouteParamsKey() -> [String : String]
    
    /// 用于重写，定义路由规则，找到target controller
    /// - Parameter scheme: 标准url的scheme
    /// - Parameter host: 标准url的host
    /// - Parameter path: 标准url的path，包含特殊符号，例如#
    /// - Parameter query: 路由解析后的ignore query，为""时表示没有特殊参数
    /// - Parameter params: 路由解析后的params，为nil时表示没有query
    @objc optional static func didFinishRoute(scheme: String?,
                                                 host: String?,
                                                 path: String?,
                                                 ignore query: String,
                                                 params: [String : String]?)
        -> UIViewController.Type?
    
    /// 用于重写，监听路由失败的原因
    /// - Parameter link: 失败的路由地址
    /// - Parameter error: 错误信息
    @objc optional static func didRouteFail(link: String, error: Error)
    
    /// 路由target实例接收到的指定者传递的信息
    /// - Parameter normal link: 标准link，不包含params，包含ignore query
    /// - Parameter params: 路由解析后的params，为nil时表示没有query
    func didRouteTargetReceive(normal link: String,
                                  params: [String: String]?)
}

public extension URLRouter {
    
    /// 路由到指定目标
    /// - Parameter link: 指定目标link
    /// - Parameter mode: 模式
    /// - Parameter isCheckTabbar: 是否验证是tabbar controller
    /// - Parameter isAnimation: 是否开启动画
    /// - Parameter complete: 动画完成的回调，只有present有效
    static func route(to link: String,
                         mode: URLRouterMode = .push,
                         isCheckTabbar: Bool = true,
                         isAnimation: Bool = true,
                         complete: (() -> Void)? = nil) -> Self.Type {
        
        do {
            let target = try URLRoute(to: link, isCheckTabbar: isCheckTabbar)
            route(to: target, mode: mode, isAnimation: isAnimation, complete: complete)
        } catch {
            didRouteFail?(link: link, error: error)
        }
        
        return self
    }
    
    /// URL路由解析，返回可用的target controller
    /// - Parameter link: 路由链接
    /// - Parameter isCheckTabbar: 是否验证是tabbar controller
    static func URLRoute(to link: String?,
                            isCheckTabbar: Bool = true) throws -> UIViewController {
        
        guard var _link_ = link else { throw URLRouterError.routeLinkEmpty }
        
        _link_ = _link_.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        _link_ = _link_.replacingOccurrences(of: " ", with: "")
        _link_ = _link_.replacingOccurrences(of: " ", with: "")
        _link_ = _link_.replacingOccurrences(of: " ", with: "")
        
        var _normalLink_ = _link_
        
        var query: String = ""
        var querys: [String] = []
        
        var params: [String : String]?
        
        if let index = _link_.firstIndex(of: "?") {
            // 除参数以外的link
            _normalLink_ = String(_link_[..<index])
            
            // 参数
            let normalQueryIndex = _link_.index(index, offsetBy: 1)
            let normalQuery = String(_link_[normalQueryIndex..<_link_.endIndex])
            
            var _params_ = parmasFromRoute(query: normalQuery)
            
            // 需要替换的参数
            if let replaces = replaceRouteParamsKey?() {
                
                for (rekey, revalue) in replaces {
                    _params_[rekey] = revalue
                }
            }
            
            // 过滤特殊参数
            if let ignoreKeys = ignoreRouteParamsKey?() {
                
                for ignoreKey in ignoreKeys {
                    
                    let key = ignoreKey.addingPercentEncoding(withAllowedCharacters:
                        .urlQueryAllowed) ?? ignoreKey
                    
                    let val = _params_[ignoreKey]? .addingPercentEncoding(withAllowedCharacters:
                        .urlQueryAllowed)
                    
                    if val != nil {
                        querys.append("\(key)=\(val!)")
                    }
                    
                    _params_[ignoreKey] = nil
                }
            }
            
            params = _params_
            query = querys.map{ String($0) }.joined(separator: "&")
        }
        
        let normalLink = _normalLink_ .addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed) ?? _normalLink_
        
        guard let normalURL = URL(string: normalLink) else { throw URLRouterError.routeLinkError }

        guard let targetClass = didFinishRoute?(scheme: normalURL.scheme, host: normalURL.host, path: normalURL.path.removingPercentEncoding, ignore: query, params: params) else { throw URLRouterError.routeTargetNotFound }
        
        let target = routeTarget(targetClass, isCheckTabbar: isCheckTabbar)
        
        if let _target_ = target as? URLRouter {
            _target_.didRouteTargetReceive(normal: _normalLink_ + (query.isEmpty ? "" : "?\(query)"), params: params)
        }
        
        return target
    }
    
    /// 获取路由的参数
    /// - Parameter query: URL的query
    static func parmasFromRoute(query: String) -> [String: String] {
        
        let querys = query.components(separatedBy: "&")
        
        var params: [String: String] = [:]
        
        for element in querys {
            
            guard let elementIndx = element.firstIndex(of: "=") else { continue }
            
            let key = String(element[..<elementIndx])
            
            let valIndex = element.index(elementIndx, offsetBy: 1)
            let val = String(element[valIndex..<element.endIndex]) .removingPercentEncoding ?? ""
            
            params[key] = val
        }
        
        return params
    }
    
    /// 获取路由指定的target controller，主要目的在于查找tabbar controller
    /// - Parameter targetClass: 当前的targetClass
    /// - Parameter isCheckTabbar: 是否验证tabbar controller
    static func routeTarget(_ targetClass: UIViewController.Type,
                               isCheckTabbar: Bool) -> UIViewController {
        
        if !isCheckTabbar {
            return targetClass.init()
        }
        
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        
        guard let tabbarController = rootViewController as? UITabBarController else { return targetClass.init() }
        
        guard let viewControllers = tabbarController.viewControllers else { return targetClass.init() }
        
        for controller in viewControllers {
            
            if let navigation = controller as? UINavigationController {
                
                guard let subController = navigation.viewControllers.first else { return targetClass.init() }
                
                if subController.isMember(of: targetClass) {
                    return subController
                }
            }
            
            if controller.isMember(of: targetClass) {
                return controller
            }
        }
        return targetClass.init()
    }
    
    /// 路由到 target controller
    /// - Parameter controller: target
    /// - Parameter mode: mode
    /// - Parameter isAnimation: 是否开启动画
    /// - Parameter complete: 动画完成的回调，只有present有效
    static func route(to controller: UIViewController,
                         mode: URLRouterMode = .push,
                         isAnimation: Bool = true,
                         complete: (() -> Void)? = nil) {
        
        if let tabIdx = controller.tabBarController?.viewControllers?.firstIndex(of: controller) {
            
            controller.dismiss(animated: false, completion: nil)
            controller.navigationController?.popToRootViewController(animated: false)
            controller.tabBarController?.selectedIndex = tabIdx
            return
        }
        
        switch mode {
        case .push:
            
            currentNavigation?.pushViewController(controller, animated: isAnimation)
            break
        case .pop:
            
            let isContains = currentNavigation?.navigationController?.viewControllers.contains(controller) ?? false
            guard isContains == true else { return }
            currentNavigation?.popToViewController(controller, animated: isAnimation)
            break
        case .present:
            
            controller.modalPresentationStyle = .fullScreen
            
            var currentController: UIViewController?
            
            guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else { return }
            
            if let tabBarController = rootViewController as? UITabBarController {
                
                currentController = tabBarController.selectedViewController
            }
            
            while (currentController?.presentedViewController != nil) {
                currentController = currentController?.presentedViewController!
            }
            
            currentController?.present(controller, animated: isAnimation, completion: complete)
            break
        }
    }
    
    /// 当前的 navigation controller
    static var currentNavigation: UINavigationController? {
        
        var currentController: UIViewController?
        
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else { return nil }
        
        if let tabBarController = rootViewController as? UITabBarController {
            
            currentController = tabBarController.selectedViewController
        }
        
        while (currentController?.presentedViewController != nil) {
            currentController = currentController?.presentedViewController!
        }
        
        return currentController as? UINavigationController
    }
    
}
