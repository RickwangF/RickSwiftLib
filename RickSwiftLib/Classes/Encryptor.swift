//
//  Encryptor.swift
//  Pods-RickSwiftLib_Example
//
//  Created by Rick on 2019/12/17.
//

import Foundation
import CommonCrypto

public extension String {
    // TODO: md5
    private var md5Hash: [UInt8] {
        let data = Data(utf8)
        return data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
            
            var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &hash)
            return hash
        }
    }
    
    var md5: String {
        return md5Hash.map { String(format: "%02x", $0) }.joined()
    }
    
    var MD5: String {
        return md5Hash.map { String(format: "%02X", $0) }.joined()
    }
    
    // TODO: base64
    var base64Encoded: String {
        
        let data = Data(utf8)
        return data.base64EncodedString(options: .lineLength64Characters)
    }
    
    var base64Decoded: String {
        
        guard let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else { return self }
        return String(data: data, encoding: .utf8) ?? self
    }
    
    // TODO: hex 16进制转换
    var hexEncoded: String {
        let data = Data(utf8)
        
        return data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> String in
            
            return bytes.map { String(format: "%02x", ($0 & 0xff)) }.joined()
        }
    }
    
    var HEXEncoded: String {
        let data = Data(utf8)
        
        return data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> String in
            
            return bytes.map { String(format: "%02X", ($0 & 0xff)) }.joined()
        }
    }
    
    var hexDecoded: String {
        
        var raw: String = replacingOccurrences(of: "", with: ",").replacingOccurrences(of: "", with: "，")
        
        guard raw.count >= 2 else { return self }
        
        var pos = NSNotFound
        if let range = range(of:"0x", options: .literal ) {
            if !range.isEmpty {
                pos = self.distance(from:startIndex, to:range.lowerBound)
            }
        }
        
        if pos == 0 {
            raw.remove(at: raw.startIndex)
        }
        
        var startIndex: Index = raw.startIndex
        var endIndex: Index = raw.index(raw.startIndex, offsetBy: 1)
        if raw.count % 2 == 0 {
            endIndex = raw.index(raw.startIndex, offsetBy: 2)
        }
        
        var hexData = Data()
        
        for _ in stride(from: 0, to: raw.count, by: 2) {
            
            let hexSub = String(raw[startIndex..<endIndex])
            let scan = Scanner(string: hexSub)
            var val: UInt64 = 0
            scan.scanHexInt64(&val)
            hexData.append(Data.init(bytes: &val, count: 1))
            startIndex = endIndex
            endIndex = endIndex == raw.endIndex ? raw.endIndex : raw.index(startIndex, offsetBy: 2)
        }
        
        return String(data: hexData, encoding: .utf8) ?? self
    }
}




// MARK: - Data扩展
public extension Data {
    
    enum encryptType: Int {
        case aes128 = 1, aes256
    }
    
    var base64Encoded: String {
        return base64EncodedString(options: .lineLength64Characters)
    }
    
    func aesEncoded(is method: encryptType = .aes128,
                       key: String,
                       iv: String) -> Data? {
        return aes(operation: CCOperation(kCCEncrypt), is: method, key: key, iv: iv)
    }
    
    func aesDecoded(is method: encryptType = .aes128,
                       key: String,
                       iv: String) -> Data? {
        return aes(operation: CCOperation(kCCDecrypt), is: method, key: key, iv: iv)
    }
    
    private func aes(operation: CCOperation,
                        is method: encryptType = .aes128,
                        key: String,
                        iv: String) -> Data? {
        
        let keyData = Data(key.utf8) as NSData
        let keyPoniter = keyData.bytes
        
        let ivData = Data(iv.utf8) as NSData
        let ivPoniter = ivData.bytes
        
        let dataPoniter = (self as NSData).bytes
        
        let dataOutSize: Int = count + (method == .aes256 ? kCCKeySizeAES256 : kCCKeySizeAES128)
        
        let dataOut = UnsafeMutableRawPointer.allocate(byteCount: dataOutSize, alignment: 1)
        
        var bytesDecrypted: Int = 0
        
        let cryptorStatus = CCCrypt(operation,
                                    CCAlgorithm(kCCAlgorithmAES),
                                    CCOptions(kCCOptionPKCS7Padding),
                                    keyPoniter,
                                    keyData.count,
                                    ivPoniter,
                                    dataPoniter,
                                    count,
                                    dataOut,
                                    dataOutSize,
                                    &bytesDecrypted)
        
        
        guard cryptorStatus == kCCSuccess else {
            dataOut.deallocate()
            return nil
        }
        
        return Data(bytes: dataOut, count: bytesDecrypted)
    }
}
