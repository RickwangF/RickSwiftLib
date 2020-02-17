//
//  TimestampExt.swift
//  Pods-RickSwiftLib_Example
//
//  Created by Rick on 2019/11/10.
//

import Foundation

public extension Date {
    
    /// 获取时区为"Asia/Beijing"的DateFormatter
    /// - Parameter format: 格式，默认 "yyyy年MM月dd日 HH:mm:ss"
    static func dataFormatter(_ format: String = "yyyy年MM月dd日 HH:mm:ss") -> DateFormatter {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(identifier: "Asia/Beijing")
        return formatter
    }
    
    /// 获取未来时间戳
    /// - Parameter time: 现在时间往后多少秒，默认为0，表示获取当前时间戳
    static func timeStamp<ResultValue>(future time: TimeInterval = 0) -> ResultValue? {
        
        let date = Date(timeIntervalSinceNow: time)
        
        return date.timeIntervalSince1970 as? ResultValue
    }
    
    /// 返回未来日期
    /// - Parameter format: 格式，默认 "yyyy年MM月dd日 HH:mm:ss"
    /// - Parameter time: 现在时间往后多少秒，默认为0，表示获取当前日期
    static func dateString(format: String = "yyyy年MM月dd日 HH:mm:ss",
                              future time: TimeInterval = 0) -> String {
        
        let date = Date(timeIntervalSinceNow: time)
        
        let formatter = dataFormatter(format)
        
        return formatter.string(from: date)
    }
    
    
    /// 根据时间戳返回日期
    /// - Parameter format: 格式，默认 "yyyy年MM月dd日 HH:mm:ss"
    /// - Parameter stamp: 时间戳
    static func dateString(format: String = "yyyy年MM月dd日 HH:mm:ss",
                              time stamp: TimeInterval) -> String {
        
        let needStamp = String(stamp).count == 13 ? TimeInterval(stamp / 1000) : stamp
        
        let date = Date(timeIntervalSince1970: needStamp)
        
        let formatter = dataFormatter(format)
        
        return formatter.string(from: date)
    }
    
    /// 根据时间戳返回几分钟前，几小时前，几天前
    /// - Parameter format: 格式，默认 "yyyy年MM月dd日 HH:mm:ss"
    /// - Parameter stamp: 时间戳
    static func timeQuantum(format: String = "yyyy年MM月dd日 HH:mm:ss",
                               time stamp: TimeInterval) -> String {
        
        let currentTime: TimeInterval = timeStamp()!
        let needStamp = String(stamp).count == 13 ? TimeInterval(stamp / 1000) : stamp
        let reduceTime : TimeInterval = currentTime - needStamp
        

        if reduceTime < 60 {
            return "刚刚"
        }
        
        let mins = Int(reduceTime / 60)
        
        if mins < 60 {
            return "\(mins)分钟前"
        }

        let hours = Int(reduceTime / 3600)
        
        if hours < 24 {
            return "\(hours)小时前"
        }

        let days = Int(reduceTime / 3600 / 24)
        
        if days < 30 {
            return "\(days)天前"
        }
        
        return dateString(format: format, time: needStamp)
    }
}


@objc public extension NSDate {
    
    class func dataFormatter(_ format: String = "yyyy年MM月dd日 HH:mm:ss") -> DateFormatter {
        
        return Date.dataFormatter(format)
    }
    
    class func timeStamp(future time: TimeInterval = 0) -> Any? {
        
        return Date.timeStamp(future: time)
    }
    
    class func dateString(format: String = "yyyy年MM月dd日 HH:mm:ss",
                             future time: TimeInterval = 0) -> String {
        
        return Date.dateString(format: format, time: time)
    }
    
    class func dateString(format: String = "yyyy年MM月dd日 HH:mm:ss",
                             time stamp: TimeInterval) -> String {
        
        return Date.dateString(format: format, time: stamp)
    }
}
