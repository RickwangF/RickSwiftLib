//
//  RickWebView.swift
//  Pods-RickSwiftLib_Example
//
//  Created by Rick on 2019/12/29.
//

import WebKit
import JavaScriptCore

@objc public protocol RickWebViewDelegate {
    
    /// html 是否允许跳转 link
    /// - Parameter webView: 当前的web
    /// - Parameter navigationAction: 跳转事件
    @objc optional func rick_webView(_ webView: WKWebView, isDecidePolicy navigationAction: WKNavigationAction) -> Bool
    
    /// html open new window, 返回 nil 则不跳转
    /// - Parameter webView: 当前的web
    /// - Parameter configuration: 当前的web的 configuration
    /// - Parameter navigationAction: 跳转事件
    /// - Parameter windowFeatures: 当前的web的 windowFeatures
    @objc optional func rick_webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView?
    
    /// html alert
    /// - Parameter webView: 当前的web
    /// - Parameter message: 当前的 web alert 的 message
    @objc optional func rick_webView(_ webView: WKWebView, alert message: String)
    
    /// html 加载完毕
    /// - Parameter webView: 当前的web
    @objc optional func rick_webViewDidLoad(_ webView: WKWebView)
    
    /// html 加载失败
    /// - Parameter webView: 当前的web
    /// - Parameter error: 错误信息
    @objc optional func rick_webView(_ webView: WKWebView, loadFail error: Error)
    
    /// html 开始加载
    /// - Parameter webView: 当前的web
    @objc optional func rick_webViewBeginLoad(_ webView: WKWebView)
    
    /// webView 滑动回调
    /// - Parameter scrollView: 当前的 web scrollView
    @objc optional func rick_webViewDidScroll(_ scrollView: UIScrollView)
    
    /// html 加载进度
    /// - Parameter webView: 当前的 web
    /// - Parameter progress: 进度
    @objc optional func rick_webView(_ webView: WKWebView, loadFor progress : Float)
    
    /// html title
    /// - Parameter webView: 当前的 web
    /// - Parameter title: 标题
    @objc optional func rick_webView(_ webView: WKWebView, title: String)
    
    /// html 当前页面是否Root路径
    /// - Parameter webView: 当前的 web
    /// - Parameter isRootWeb: 是否Root路径
    @objc optional func rick_webView(_ webView: WKWebView, isRootWeb: Bool)
}

@objcMembers public class RickWebView: UIView, UIScrollViewDelegate, UIGestureRecognizerDelegate, WKUIDelegate, WKNavigationDelegate {
    
    private var canGoBack: Bool = false
    
    @objc private lazy var webView: WKWebView = {
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = WKUserContentController()
        configuration.selectionGranularity = .character
        configuration.allowsInlineMediaPlayback = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.delegate = self
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "canGoBack", options: .new, context: nil)
        
//        let longPress = UILongPressGestureRecognizer(target: self, action: nil)
//        longPress.minimumPressDuration = 0.2
//        longPress.delegate = self
//
//        webView.addGestureRecognizer(longPress)
        webView.scrollView.decelerationRate = .normal
        
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        addSubview(webView)
        return webView
    }()
    
    public weak var delegate: RickWebViewDelegate?
    
    public var contentView: WKWebView {
        return webView
    }
    
    public var isClearBackgroundColor: Bool = false {
        willSet {
            backgroundColor = .clear
            webView.isOpaque = !newValue
            webView.backgroundColor = UIColor.clear.withAlphaComponent(0)
        }
    }
    
    public var isAllowZoom: Bool = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        webView.frame = bounds
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "title")
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.uiDelegate = nil
        webView.navigationDelegate = nil
    }
    
    // TODO: 加载页面
    public func load(url: URL?) {
        
        guard let _url_ = url else { return }
        
        webView.load(URLRequest(url: _url_))
    }
    
    public func loadHTMLString(_ string: String?, baseURL: URL?) {
        
        guard let _string_ = string else { return }
        
        webView.loadHTMLString(_string_, baseURL: baseURL)
    }
    
    public func loadFileURL(_ url: URL?, baseURL: URL?) {
        
        guard let _url_ = url else { return }
        
        guard let _baseURL_ = baseURL else { return }
        
        if #available(iOS 9.0, *) {
            webView.loadFileURL(_url_, allowingReadAccessTo: _baseURL_)
        }
    }
    
    // TODO: observe
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard object as? WKWebView == webView else { return }
        
        if keyPath == "title" {
            delegate?.rick_webView?(webView, title: webView.title ?? "unknow")
            return
        }
        
        if keyPath == "estimatedProgress" {
            let progress: NSNumber = change?[.newKey] as? NSNumber ?? NSNumber(value: 0)
            delegate?.rick_webView?(webView, loadFor: progress.floatValue)
            return
        }
        
        if keyPath == "canGoBack" {
            canGoBack = change?[.newKey] as! Bool
            delegate?.rick_webView?(webView, isRootWeb: !canGoBack)
        }
    }
    
    // TODO: UIGestureRecognizerDelegate
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        next?.touchesBegan([touch], with: nil)
        return false
    }
    
    // TODO: UIScrollViewDelegate
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return isAllowZoom ? webView.scrollView.subviews.first : nil
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.rick_webViewDidScroll?(scrollView)
    }
    
    // TODO: WKNavigationDelegate
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        delegate?.rick_webViewBeginLoad?(webView)
    }
    
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        delegate?.rick_webViewDidLoad?(webView)
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        guard (error as NSError).code == URLError.cancelled.rawValue else { return }
        delegate?.rick_webView?(webView, loadFail: error)
    }
    
    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationAction: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if delegate?.rick_webView?(webView, isDecidePolicy: navigationAction) ?? true {
            decisionHandler(.allow)
            return
        }
        
        decisionHandler(.cancel)
    }
    
    public func webView(_ webView: WKWebView,
                        createWebViewWith configuration: WKWebViewConfiguration,
                        for navigationAction: WKNavigationAction,
                        windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        return delegate?.rick_webView?(webView, createWebViewWith: configuration, for: navigationAction, windowFeatures: windowFeatures)
    }
    
    // TODO: WKUIDelegate
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        // Alert
        delegate?.rick_webView?(webView, alert: message)
        completionHandler()
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        // Alert
        delegate?.rick_webView?(webView, alert: prompt)
        completionHandler(nil)
    }
}

