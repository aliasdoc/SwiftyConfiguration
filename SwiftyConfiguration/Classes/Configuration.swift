//
//  Configuration.swift
//  SwiftyConfiguration
//
//  Created by kyo__hei on 2016/07/05.
//  Copyright © 2016年 kyo__hei. All rights reserved.
//

import Foundation

public protocol PlistValueType {}

extension String: PlistValueType {}
extension NSURL: PlistValueType {}
extension NSNumber: PlistValueType {}
extension Int: PlistValueType {}
extension Float: PlistValueType {}
extension Double: PlistValueType {}
extension Bool: PlistValueType {}
extension NSDate: PlistValueType {}
extension NSData: PlistValueType {}
extension Array: PlistValueType {}
extension Dictionary: PlistValueType {}

/// Extend this class and add your plist keys as static constants
/// so you can use the shortcut dot notation (e.g. ` configuration.get(.yourKey)`)

public class Keys {}

public final class Key<ValueType: PlistValueType>: Keys {
    
    public let key: String
    
    internal var separatedKeys: [String] {
        return key.componentsSeparatedByString(".")
    }
    
    public init(_ key: String) {
        self.key = key
    }
    
}


public struct Configuration {
    
    private let dictionary: NSDictionary
    
    public init?(plistPath: String) {
        guard let plist = NSDictionary(contentsOfFile: plistPath) else {
            assertionFailure("could not read plist file.")
            return nil
        }
        dictionary = plist
    }
    
    public func get<T>(key: Key<T>) -> T? {
        var object: AnyObject = dictionary
        
        key.separatedKeys.enumerate().forEach { idx, separatedKey in
            if let index = Int(separatedKey) {
                let array = object as! Array<AnyObject>
                object = array[index]
            } else {
                let dictionary = object as! NSDictionary
                object = dictionary[separatedKey]!
            }
        }
        
        let optionalValue: T?
        
        switch T.self {
        case is Int.Type:    optionalValue = object.integerValue as? T
        case is Float.Type:  optionalValue = object.floatValue as? T
        case is Double.Type: optionalValue = object.doubleValue as? T
        case is NSURL.Type:  optionalValue = NSURL(string: (object as? String) ?? "") as? T
        default:             optionalValue = object as? T
        }
        
        guard let value = optionalValue else {
            assertionFailure("Could not cast value of type \(object.dynamicType) to \(T.self)")
            return nil
        }
        
        return value
    }
    
}
