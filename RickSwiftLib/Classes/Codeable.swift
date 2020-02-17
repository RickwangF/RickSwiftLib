//
//  Codeable.swift
//  Pods-RickSwiftLib_Example
//
//  Created by Rick on 2019/12/20.
//

import Foundation

public enum CodeableError: Error {
    /// json转model失败
    case jsonToModelFail
    /// json转data失败
    case jsonToDataFail
    /// json转数组失败
    case jsonToArrayFail
    /// 字典转json失败
    case dictToJsonFail
    /// model转json失败
    case modelToJsonFail
}

public protocol Codeable: Codable {
    
    func modelCodableFinished()
    mutating func structCodableFinish()
}

public extension Codeable {
    
    func modelCodableFinished() {}
    
    mutating func structCodableFinish() {}
    
    // TODO: 字典转模型
    static func modelFromDict(_ dict: [String : Any]?) throws -> Self {
        
        guard let JSONString = dict?.json else {
            throw CodeableError.dictToJsonFail
        }
        
        guard let obj = try? modelFromJSON(JSONString) else {
            throw CodeableError.dictToJsonFail
        }
        
        return obj
    }
    
    // TODO: JSON转模型
    static func modelFromJSON(_ JSONString: String?) throws -> Self {

        guard let jsonData = JSONString?.data(using: .utf8) else {
            throw CodeableError.jsonToDataFail
        }
        
        let decoder = JSONDecoder()
        
        guard let obj = try? decoder.decode(self, from: jsonData) else {
            throw CodeableError.jsonToModelFail
        }

        var vobj = obj
        let mirro = Mirror(reflecting: vobj)
        
        if mirro.displayStyle == .struct {
            vobj.structCodableFinish()
        }
        
        if mirro.displayStyle == .class {
            vobj.modelCodableFinished()
        }
        
        return vobj
    }
    
    // TODO: 模型转字典
    var dictionary: [String : Any] {
        
        let mirro = Mirror(reflecting: self)
        var dict = [String : Any]()
        for case let (key?, value) in mirro.children {
            dict[key] = value
        }
        return dict
    }
    
    // TODO: 模型转JSON字符串
    func toJSONString() throws -> String {
        
        guard let string = self.dictionary.json else {
            throw CodeableError.modelToJsonFail
        }
        
        return string
    }
}


public extension Dictionary {
    
    var json: String? {
        
        guard JSONSerialization.isValidJSONObject(self) else { return nil }
        
        guard let newData: Data = try? JSONSerialization.data(withJSONObject: self, options: []) else { return nil }
        
        return String(data: newData, encoding: .utf8)
    }
}

public extension Array {
    
    var json: String? {
    
        guard JSONSerialization.isValidJSONObject(self) else { return nil }
        
        guard let newData: Data = try? JSONSerialization.data(withJSONObject: self, options: []) else { return nil }
        
        return String(data: newData, encoding: .utf8)
    }
    
    func modelFromJson<T: Decodable>(_ type: [T].Type) throws -> Array<T> {
        
        guard let JSONString = json else {
            throw CodeableError.dictToJsonFail
        }
        
        guard let jsonData = JSONString.data(using: .utf8) else {
            throw CodeableError.jsonToDataFail
        }
        
        let decoder = JSONDecoder()
        
        guard let obj = try? decoder.decode(type, from: jsonData) else {
            throw CodeableError.jsonToArrayFail
        }
        
        return obj
    }
}


public extension String {
    
    var dictionary: [String : Any]? {
        return Data(utf8).dictionary
    }
    
    var array: [Any]? {
        return Data(utf8).array
    }
}


public extension Data {
    
    var dictionary: [String : Any]? {
        
        guard let dict = try? JSONSerialization.jsonObject(with: self, options: .mutableContainers) else {
            
            return nil
        }
        
        return dict as? [String : Any]
    }
    
    var array: [Any]? {
        
        guard let dict = try? JSONSerialization.jsonObject(with: self, options: .mutableContainers) else {
            
            return nil
        }
        
        return dict as? [Any]
    }
}




public extension KeyedDecodingContainer {
    
    /// 防止Bool类型数据在JSON中是Int的类型
    func decodeIfPresent(_ type: Bool.Type, forKey key: K) throws -> Bool? {
        
        if let value = try? decode(type, forKey: key) {
            return value
        }
        
        if let value = try? decode(String.self, forKey: key) {
            return Bool(value)
        }
        
        if let value = try? decode(Int.self, forKey: key) {
            return value > 0
        }
        
        return nil
    }
    
    
    /// 防止Int类型数据在JSON中是String的类型
    func decodeIfPresent(_ type: Int.Type, forKey key: K) throws -> Int? {
        
        if let value = try? decode(type, forKey: key) {
            return value
        }
        
        if let value = try? decode(String.self, forKey: key) {
            return Int(value)
        }
        
        return nil
    }
    
    
    /// 防止String类型数据在JSON中是Int的类型
    func decodeIfPresent(_ type: String.Type, forKey key: K) throws -> String? {
        
        if let value = try? decode(type, forKey: key) {
            return value
        }
        
        if let value = try? decode(Int.self, forKey: key) {
            return String(value)
        }
        
        return nil
    }
    
    
    /// 防止 Dictionary, Array, SubModel 解析失败
    func decodeIfPresent<T>(_ type: T.Type, forKey key: K) throws -> T? where T : Decodable {

        if let value = try? decode(String.self, forKey: key) {
            
            guard let jsonData = value.data(using: .utf8) else {
                return try? decode(type, forKey: key)
            }
            
            let decoder = JSONDecoder()
            
            guard let obj = try? decoder.decode(type, from: jsonData) else {
                return try? decode(type, forKey: key)
            }
            
            return obj
        }
        
        return try? decode(type, forKey: key)
    }
}
