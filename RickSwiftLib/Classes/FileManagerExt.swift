//
//  FileManagerExt.swift
//  Pods-RickSwiftLib_Example
//
//  Created by Rick on 2019/11/18.
//

import Foundation

// MARK: - 常用沙盒路径
public extension FileManager {
    
    struct Directory {
        
        public static var Home: String {
            
            return NSHomeDirectory()
        }
        
        public static var Temp: String {
            
            return NSTemporaryDirectory()
        }
        
        /// 若为 404 Not Found 则为没找到
        public static var Document: String {
            
            return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? "404 Not Found"
        }
        
        /// 若为 404 Not Found 则为没找到
        public static var Library: String {
            
            return NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first ?? "404 Not Found"
        }
        
        /// 若为 404 Not Found 则为没找到
        public static var Cache: String {
            
            return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first ?? "404 Not Found"
        }
        
        /// 若为 404 Not Found/Preferences 则为没找到
        public static var Preferences: String {
            
            return Library + "/Preferences"
        }
    }
}




// MARK: - 文件遍历
@objc public extension FileManager {
    
    /// 文件遍历
    /// - Parameters:
    ///   - path: 目录的绝对路径
    ///   - isDeep: 是否深遍历 (1. 浅遍历：返回当前目录下的所有文件和文件夹；
    ///                       2. 深遍历：返回当前目录下及子目录下的所有文件和文件夹)
    ///   - extensions: 需要遍历的文件扩展，默认为全部遍历
    class func listFilesInDirectory(at path: String, isDeep: Bool = false) -> [String] {
        
        return self.default.listFilesInDirectory(at: path, isDeep: isDeep)
    }
    
    /// 文件遍历
    /// - Parameters:
    ///   - path: 目录的绝对路径
    ///   - isDeep: 是否深遍历 (1. 浅遍历：返回当前目录下的所有文件和文件夹；
    ///                       2. 深遍历：返回当前目录下及子目录下的所有文件和文件夹)
    ///   - extensions: 需要遍历的文件扩展，默认为全部遍历
    func listFilesInDirectory(at path: String,
                              isDeep: Bool = false,
                              pathsMatching extensions: [String] = []) -> [String] {
        
        var files: [String] = []
        
        if isDeep {
            do {
                files = try subpathsOfDirectory(atPath: path)
            } catch {
                print("----------- deepListInDirectory Error Begin ------------")
                print(error)
                print("----------- deepListInDirectory Error end ------------")
            }
            return files
        }
        
        do {
            files = try contentsOfDirectory(atPath: path)
        } catch {
            print("----------- shallListInDirectory Error Begin ------------")
            print(error)
            print("----------- shallListInDirectory Error end ------------")
        }
        
        if extensions.count > 0 {
            return (files as NSArray).pathsMatchingExtensions(extensions)
        }
        
        return files
    }
}




// MARK: - 文件写入
@objc public extension FileManager {
    
    /// 写入文件内容
    /// - Parameters:
    ///   - path: 绝对路径
    ///   - content: 写入内容，目前支持 String、Data、Array、Dictionary、UIImage
    class func write(to path: String, for content: Any) -> Bool {
        
        return self.default.write(to: path, for: content)
    }
    
    /// 写入文件内容
    /// - Parameters:
    ///   - path: 绝对路径
    ///   - content: 写入内容，目前支持 String、Data、Array、Dictionary、UIImage
    func write(to path: String, for content: Any) -> Bool {
        
        guard isExist(at: path) else {
            print("----------- write Error Begin ------------")
            print("path: \(path)")
            print("content: \(content)")
            print("文件目录不存在，404 Not Found")
            print("----------- write Error end ------------")
            return false
        }
        
        var contentType: String = ""
        var writeError: Error?
        
        let fileUrl = URL(fileURLWithPath: path)
        
        if let string = content as? String  {
            
            do {
                try string.write(to: fileUrl, atomically: true, encoding: .utf8)
                return true
            } catch {
                contentType = "String"
                writeError = error
            }
        }
        else if let data = content as? Data {
            
            do {
                try data.write(to: fileUrl)
                return true
            } catch {
                contentType = "Data"
                writeError = error
            }
        }
        else if let image = content as? UIImage {
            
            if let imgData = image.pngData() {
                return write(to: path, for: imgData)
            }
            contentType = "image"
        }
        else if let array = content as? NSArray {
            
            return array.write(toFile: path, atomically: true)
        }
        else if let dict = content as? NSDictionary {
            
            return dict.write(toFile: path, atomically: true)
        }
        
        print("----------- write Error Begin ------------")
        print("path: \(path)")
        print("content: \(content)")
        print("content-type: \(contentType)")
        print(writeError ?? "null")
        print("----------- write Error end ------------")
        return false
    }
}




// MARK: - 创建文件（夹）
@objc public extension FileManager {
    
    /// 创建文件夹
    /// - Parameter path: 文件夹存放的绝对路径
    class func createDirectory(at path: String) -> Bool{
        
        return self.default.createDirectory(at: path)
    }
    
    /// 创建文件夹
    /// - Parameter path: 文件夹存放的绝对路径
    func createDirectory(at path: String) -> Bool{
        
        do {
            try createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            print("----------- createDirectory Error Begin ------------")
            print(error)
            print("----------- createDirectory Error end ------------")
        }
        return false
    }
    
    /// 创建文件
    /// - Parameters:
    ///   - path: 存放的绝对路径
    ///   - content: 文件内容，默认为 nil 表示空文件
    ///   - isOverwrite: 是否覆盖原有文件，默认是 true
    class func createFile(at path: String,
                          content: Any? = nil,
                          isOverwrite: Bool = true) -> Bool {
        
        return self.default.createFile(at: path, content: content, isOverwrite: isOverwrite)
    }
    
    /// 创建文件
    /// - Parameters:
    ///   - path: 存放的绝对路径
    ///   - content: 文件内容，默认为 nil 表示空文件
    ///   - isOverwrite: 是否覆盖原有文件，默认是 true
    func createFile(at path: String,
                    content: Any? = nil,
                    isOverwrite: Bool = true) -> Bool {
        
        let directoryPath = directoryFormPath(atFile: path)
        
        if !isExist(at: directoryPath) {
            if !createDirectory(at: directoryPath) {
                return false
            }
        }
        
        if !isOverwrite && isExist(at: directoryPath) {
            return true
        }
        
        guard createFile(atPath: path, contents: nil, attributes: nil) else { return false }
        
        guard content != nil else { return true }
        
        return write(to: path, for: content!)
    }
}




// MARK: - 删除文件（夹）
@objc public extension FileManager {
    
    /// 删除文件(夹)
    /// - Parameter path: 绝对路径
    class func remove(at path: String) -> Bool {
        
        return self.default.remove(at: path)
    }
    
    /// 删除文件(夹)
    /// - Parameter path: 绝对路径
    func remove(at path: String) -> Bool {
        
        guard isExist(at: path) else { return true }
        
        do {
            try removeItem(atPath: path)
            return true
        } catch {
            print("----------- remove Error Begin ------------")
            print(error)
            print("----------- remove Error end ------------")
        }
        
        return false
    }
    
    /// 清空文件夹
    /// - Parameter path: 文件夹的绝对路径
    class func clear(atDir path: String) -> Bool {
        
        return self.default.clear(atDir: path)
    }
    
    /// 清空文件夹
    /// - Parameter path: 文件夹的绝对路径
    func clear(atDir path: String) -> Bool {
        
        guard isDirectory(at: path) else {
            print("----------- clear Error Begin ------------")
            print("\(path)不是文件夹")
            print("----------- clear Error end ------------")
            return false
        }
        
        let list = listFilesInDirectory(at: path, isDeep: false)
        
        var isSuccess: Bool = true
        
        for item in list {
            isSuccess = isSuccess && remove(at: Directory.Cache + "/" + item)
        }
        
        return isSuccess
    }
}




// MARK: - 复制文件（夹）
@objc public extension FileManager {
    
    /// 复制文件（夹）
    /// - Parameters:
    ///   - path: 源绝对路径
    ///   - toPath: 目标绝对路径
    ///   - isOverwrite: 是否覆盖原有文件，默认是 true
    class func copy(at path: String,
                    toPath: String,
                    isOverwrite: Bool = true) -> Bool {
        
        return self.default.copy(at: path, toPath: toPath, isOverwrite: isOverwrite)
    }
    
    /// 复制文件（夹）
    /// - Parameters:
    ///   - path: 源路径
    ///   - toPath: 目标路径
    ///   - isOverwrite: 是否覆盖原有文件，默认是 true
    func copy(at path: String,
              toPath: String,
              isOverwrite: Bool = true) -> Bool {
        
        guard isExist(at: path) else {
            
            print("----------- copy Error Begin ------------")
            print("path: \(path)")
            print("源文件目录不存在，404 Not Found")
            print("----------- copy Error end ------------")
            return false
        }
        
        let toDirPath = directoryFormPath(atFile: toPath)
        
        if !isExist(at: toDirPath) {
            if createDirectory(at: toDirPath) {
                return false
            }
        }
        
        if isOverwrite && isExist(at: toPath) {
            let _ = remove(at: path)
        }
        
        do {
            try copyItem(atPath: path, toPath: toPath)
            return true
        } catch {
            print("----------- copy Error Begin ------------")
            print("path: \(path)")
            print("to path: \(toPath)")
            print(error)
            print("----------- copy Error end ------------")
        }
        
        return false
    }
}




// MARK: - 移动文件（夹）
@objc public extension FileManager {
    
    /// 移动文件（夹） 覆盖原有文件
    /// - Parameters:
    ///   - path: 源绝对路径
    ///   - toPath: 目标绝对路径
    class func move(at path: String,
                    toPath: String) -> Bool {
        
        return self.default.copy(at: path, toPath: toPath)
    }
    
    /// 移动文件（夹） 覆盖原有文件
    /// - Parameters:
    ///   - path: 源路径
    ///   - toPath: 目标路径
    func move(at path: String,
              toPath: String) -> Bool {
        
        guard isExist(at: path) else {
            
            print("----------- copy Error Begin ------------")
            print("path: \(path)")
            print("源文件目录不存在，404 Not Found")
            print("----------- copy Error end ------------")
            return false
        }
        
        let toDirPath = directoryFormPath(atFile: toPath)
        
        if !isExist(at: toDirPath) {
            if createDirectory(at: toDirPath) {
                return false
            }
        }
        
        if isExist(at: toPath) {
            let _ = remove(at: path)
        }
        
        do {
            try moveItem(atPath: path, toPath: toPath)
            return true
        } catch {
            print("----------- move Error Begin ------------")
            print("path: \(path)")
            print("to path: \(toPath)")
            print(error)
            print("----------- move Error end ------------")
        }
        
        return false
    }
}




// MARK: - 文件（夹）是否存在
@objc public extension FileManager {
    
    /// 文件路径是否存在
    /// - Parameter path: 绝对路径
    class func isExist(at path: String) -> Bool {
        
        return self.default.isExist(at: path)
    }
    
    /// 文件路径是否存在
    /// - Parameter path: 绝对路径
    func isExist(at path: String) -> Bool {
        
        return fileExists(atPath: path)
    }
    
    /// 文件路径是否为空(判空条件是文件大小为0，或者是文件夹下没有子文件)
    /// - Parameter path: 绝对路径
    class func isEmptyItem(at path: String) -> Bool {
        
        return self.default.isEmptyItem(at: path)
    }
    
    /// 文件路径是否为空(判空条件是文件大小为0，或者是文件夹下没有子文件)
    /// - Parameter path: 绝对路径
    func isEmptyItem(at path: String) -> Bool {
        
        if isFile(at: path) {
            return sizeOfFile(at: path) == 0
        }
        
        if isDirectory(at: path) {
            return sizeOfDirectory(at: path) == 0
        }
        
        return sizeOf(path: path) == 0
    }
}




// MARK: - 获取文件名 和 文件所在的文件夹的路径
@objc public extension FileManager {
    
    /// 根据文件路径获取文件名称
    /// - Parameters:
    ///   - path: 绝对路径
    ///   - isKeepExtension: 是否需要后缀
    class func fileName(at path: String, isKeepExtension: Bool) -> String {
        
        return self.default.fileName(at: path, isKeepExtension: isKeepExtension)
    }
    
    /// 根据文件路径获取文件名称
    /// - Parameters:
    ///   - path: 绝对路径
    ///   - isKeepExtension: 是否需要后缀
    func fileName(at path: String, isKeepExtension: Bool) -> String {
        
        let fileName = NSString(string: path).lastPathComponent
        
        guard isKeepExtension else { return NSString(string: fileName).deletingPathExtension }
        
        return fileName
    }
    
    /// 根据文件路径获取文件扩展
    /// - Parameter path: 绝对路径
    class func fileExtension(at path: String) -> String {
        
        return self.default.fileExtension(at: path)
    }
    
    /// 根据文件路径获取文件扩展
    /// - Parameter path: 绝对路径
    func fileExtension(at path: String) -> String {
        
        return NSString(string: path).pathExtension
    }
    
    /// 获取文件所在文件夹的路径
    /// - Parameter path: 绝对路径
    class func directoryFormPath(atFile path: String) -> String {
        
        return self.default.directoryFormPath(atFile: path)
    }
    
    /// 获取文件所在文件夹的路径
    /// - Parameter path: 绝对路径
    func directoryFormPath(atFile path: String) -> String {
        
        return NSString(string: path).deletingLastPathComponent
    }
}




// MARK: - 文件（夹）详细描述
@objc public extension FileManager {
    
    /// 获取目录详细描述
    /// - Parameter path: 绝对路径
    class func attributesOfItem(at path: String) -> [FileAttributeKey: Any] {
        
        return self.default.attributesOfItem(at: path)
    }
    
    /// 获取目录详细描述
    /// - Parameter path: 绝对路径
    func attributesOfItem(at path: String) -> [FileAttributeKey: Any] {
        do {
            return try attributesOfItem(atPath: path)
        } catch {
            print("----------- attributesOfItem Error Begin ------------")
            print(error)
            print("----------- attributesOfItem Error end ------------")
        }
        return [:]
    }
    
    /// 是否是文件夹
    /// - Parameter path: 绝对路径
    class func isDirectory(at path: String) -> Bool {
        
        return self.default.isDirectory(at: path)
    }
    
    /// 是否是文件夹
    /// - Parameter path: 绝对路径
    func isDirectory(at path: String) -> Bool {
        
        let type = attributesOfItem(at: path)[.type] as? FileAttributeType
        return type == .typeDirectory
    }
    
    /// 是否是文件
    /// - Parameter path: 绝对路径
    class func isFile(at path: String) -> Bool {
        
        return self.default.isFile(at: path)
    }
    
    /// 是否是文件
    /// - Parameter path: 绝对路径
    func isFile(at path: String) -> Bool {
        
        let type = attributesOfItem(at: path)[.type] as? FileAttributeType
        return type == .typeRegular
    }
}




// MARK: - 获取文件大小
@objc public extension FileManager {
    
    /// 目录大小转换为标准化字符串
    /// - Parameter size: 目录大小
    class func formattedFor(size: Int64) -> String {
        
        return self.default.formattedFor(size: size)
    }
    
    /// 目录大小转换为标准化字符串
    /// - Parameter size: 目录大小
    func formattedFor(size: Int64) -> String {
        
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
    
    /// 获取目录大小
    /// - Parameter path: 绝对路径
    class func sizeOf(path: String) -> Int64 {
        
        return self.default.sizeOfFile(at: path)
    }
    
    /// 获取目录大小
    /// - Parameter path: 绝对路径
    func sizeOf(path: String) -> Int64 {
        
        return (attributesOfItem(at: path)[.size] as? Int64) ?? 0
    }
    
    /// 获取文件夹大小
    /// - Parameter path: 绝对路径
    class func sizeOfDirectory(at path: String) -> Int64 {
        
        return self.default.sizeOfDirectory(at: path)
    }
    
    /// 获取文件夹大小
    /// - Parameter path: 绝对路径
    func sizeOfDirectory(at path: String) -> Int64 {
        
        guard isDirectory(at: path) else { return 0 }
        
        let list = listFilesInDirectory(at: path, isDeep: true)
        
        var folderSize: Int64 = 0
        
        for item in list {
            
            let size = (attributesOfItem(at: path + "/\(item)")[.size] as? Int64) ?? 0
            folderSize += size
        }
        
        return folderSize
    }
    
    /// 获取文件大小
    /// - Parameter path: 绝对路径
    class func sizeOfFile(at path: String) -> Int64 {
        
        return self.default.sizeOfFile(at: path)
    }
    
    /// 获取文件大小
    /// - Parameter path: 绝对路径
    func sizeOfFile(at path: String) -> Int64 {
        
        guard isFile(at: path) else { return 0 }
        
        return (attributesOfItem(at: path)[.size] as? Int64) ?? 0
    }
}




// MARK: - 获取文件日期
@objc public extension FileManager {
    
    /// 获取创建日期
    /// - Parameter path: 绝对路径
    class func creationDate(at path: String) -> Date? {
        
        return self.default.creationDate(at: path)
    }
    
    /// 获取创建日期
    /// - Parameter path: 绝对路径
    func creationDate(at path: String) -> Date? {
        
        return attributesOfItem(at: path)[.creationDate] as? Date
    }
    
    /// 获取修改日期
    /// - Parameter path: 绝对路径
    class func modificationDate(at path: String) -> Date? {
        
        return self.default.modificationDate(at: path)
    }
    
    /// 获取修改日期
    /// - Parameter path: 绝对路径
    func modificationDate(at path: String) -> Date? {
        
        return attributesOfItem(at: path)[.modificationDate] as? Date
    }
}
