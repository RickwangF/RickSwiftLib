//
//  TimerExt.swift
//  Pods-RickSwiftLib_Example
//
//  Created by Rick on 2019/12/16.
//

import Foundation

@objc public extension Timer {
    
    class func supportiOS_10EarlierTimer(_ interval: TimeInterval, repeats: Bool, block: @escaping (_ timer: Timer) -> Void) -> Timer {
        
        if #available(iOS 10.0, *) {
            return Timer.init(timeInterval: interval, repeats: repeats, block: block)
        } else {
            return Timer.init(timeInterval: interval, target: self, selector: #selector(runTimer(_:)), userInfo: block, repeats: repeats)
        }
    }
    
    @objc private class func runTimer(_ timer: Timer) -> Void {
        
        guard let block: ((Timer) -> Void) = timer.userInfo as? ((Timer) -> Void) else { return }
        
        block(timer)
    }
}



@objc public class DisplayLink: NSObject {
    
    private var userInfo: ((_ displayLink: CADisplayLink) -> Void)?
    private var displayLink: CADisplayLink?
    
    /// 初始化CADisplayLink
    /// - Parameters:
    ///   - fps: 刷新频率，表示一秒钟刷新多少次，默认是60次
    ///   - block: 回调
    public class func displayLink(_ fps: Int = 60,
                              block: @escaping (_ displayLink: CADisplayLink) -> Void) -> DisplayLink {
        
        let weak_displayLink = DisplayLink()
        weak_displayLink.userInfo = block
        
        weak_displayLink.displayLink = CADisplayLink(target: weak_displayLink, selector: #selector(runDisplayLink(_:)))
        
        guard fps > 0 else { return weak_displayLink }
        
        if #available(iOS 10.0, *) {
            weak_displayLink.displayLink?.preferredFramesPerSecond = fps
        } else {
            weak_displayLink.displayLink?.frameInterval = fps
        }
        weak_displayLink.displayLink?.add(to: RunLoop.current, forMode: .default)
        
        return weak_displayLink
    }
    
    @objc private func runDisplayLink(_ displayLink: CADisplayLink) -> Void {
        
        guard userInfo != nil else { return }
        userInfo!(displayLink)
    }
    
    public func invalidate() {
        displayLink?.remove(from: RunLoop.current, forMode: .default)
        displayLink?.invalidate()
        displayLink = nil
        userInfo = nil
    }
}




@objc public class RickTimer: NSObject {
    
    var timerQueue: DispatchQueue?
    
    var timer: DispatchSourceTimer?
    
    public convenience init(interval: TimeInterval,
                     repeats: Bool = true,
                     block: @escaping () -> Void) {
        self.init()
        
        self.timerQueue = DispatchQueue(label: "com.Timer.rick", qos: .userInitiated)
        
        let repeating: DispatchTimeInterval = repeats ? .nanoseconds(Int(interval * pow(10, 9))) : .never
        
        self.timer = DispatchSource.makeTimerSource(queue: self.timerQueue)
        timer?.schedule(deadline: .now() + interval, repeating: repeating)
        timer?.setEventHandler(handler: block)
    }
    
    override init() {
        super.init()
    }
    
    public func resume() {
        timer?.resume()
    }
    
    public func invalidate() {
        timer?.cancel()
        timer = nil
    }
}
