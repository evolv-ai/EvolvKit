//
//  EvolvRawAllocationNode.swift
//
//  Copyright (c) 2019 Evolv Technology Solutions
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

// swiftlint:disable type_name
public typealias __N = EvolvRawAllocationNode

// TODO: add doc for property
public final class EvolvRawAllocationNode: NSObject {
    
    /// Raw allocation node's type definitions.
    @objc public enum NodeType: Int, CustomStringConvertible {
        case unknown
        case null
        case number
        case string
        case bool
        case array
        case dictionary
        
        public var description: String {
            switch self {
            case .unknown: return "unknown"
            case .null: return "null"
            case .number: return "number"
            case .string: return "string"
            case .bool: return "bool"
            case .array: return "array"
            case .dictionary: return "dictionary"
            }
        }
        
    }
    
    enum Error: LocalizedError, Equatable {
        case emptyKey
        case notDictionaryType
        case incorrectKey(key: String)
        
        var errorDescription: String? {
            switch self {
            case .emptyKey:
                return "Key provided was empty."
            case .notDictionaryType:
                return "Type of node is not equal to .dictionary."
            case .incorrectKey(let key):
                return "Could not find node for key: \(key)"
            }
        }
    }
    
    /// The static null EvolvRawAllocationNode
    public static var null: EvolvRawAllocationNode {
        return EvolvRawAllocationNode(NSNull())
    }
    
    /// EvolvRawAllocationNode type, private setter
    @objc public private(set) var type: NodeType = .unknown
    
    /// Private raw objects
    private var rawNull: NSNull = NSNull()
    private var rawNumber: NSNumber = 0
    private var rawString: String = ""
    private var rawBool: Bool = false
    private var rawArray: [Any] = []
    private var rawDictionary: [String: Any] = [:]
    
    /// Value in EvolvRawAllocationNode
    @objc public var value: Any {
        get {
            switch type {
            case .number: return rawNumber
            case .string: return rawString
            case .bool: return rawBool
            case .array: return rawArray
            case .dictionary: return rawDictionary
            default: return rawNull
            }
        }
        set {
            switch unwrap(newValue) {
            case let bool as Bool:
                type = .bool
                rawBool = bool
            case let number as NSNumber:
                type = .number
                rawNumber = number
            case let string as String:
                type = .string
                rawString = string
            case let array as [Any]:
                type = .array
                rawArray = array
            case let dictionary as [String: Any]:
                type = .dictionary
                rawDictionary = dictionary
            case _ as NSNull:
                type = .null
            case nil:
                type = .null
            default:
                type = .unknown
            }
        }
    }
    
    /// Creates a EvolvRawAllocationNode object
    ///
    /// - Parameter value: the value
    @objc public required init(_ value: Any) {
        super.init()
        self.value = value
    }
    
    /// Private method to unwrap a node (recursively)
    ///
    /// - Parameter node: a node
    /// - Returns: a value in node
    private func unwrap(_ node: Any) -> Any {
        switch node {
        case let singleNode as EvolvRawAllocationNode:
            return unwrap(singleNode.value)
        case let array as [Any]:
            return array.map(unwrap)
        case let dictionary as [String: Any]:
            var childDictionary = dictionary
            dictionary.forEach { keyValuePair in
                childDictionary[keyValuePair.key] = unwrap(keyValuePair.value)
            }
            return childDictionary
        default:
            return node
        }
    }
    
    // MARK: - Printable, DebugPrintable
    
    override public var description: String {
        let superDescription = super.description
        
        var value: Any = rawNull
        switch type {
            
        case .number: value = rawNumber
        case .string: value = rawString
        case .bool: value = rawBool
        case .array: value = rawArray
        case .dictionary: value = rawDictionary
        default: value = rawNull
        }
        
        return "\(superDescription) (type: \(type), value: \(value))"
    }
    
    override public var debugDescription: String {
        return description
    }
    
}

// MARK: - Decodable

extension EvolvRawAllocationNode: Decodable {
    
    private static var decodableTypes: [Decodable.Type] {
        return [
            Bool.self,
            Int.self,
            Int8.self,
            Int16.self,
            Int32.self,
            Int64.self,
            UInt.self,
            UInt8.self,
            UInt16.self,
            UInt32.self,
            UInt64.self,
            Double.self,
            String.self,
            [EvolvRawAllocationNode].self,
            [String: EvolvRawAllocationNode].self
        ]
    }
    
    public convenience init(from decoder: Decoder) throws {
        var node: Any?
        
        if let container = try? decoder.singleValueContainer(), container.decodeNil() == false {
            for type in EvolvRawAllocationNode.decodableTypes {
                guard node == nil else {
                    break
                }
                
                switch type {
                case let boolType as Bool.Type:
                    node = try? container.decode(boolType)
                case let intType as Int.Type:
                    node = try? container.decode(intType)
                case let int8Type as Int8.Type:
                    node = try? container.decode(int8Type)
                case let int32Type as Int32.Type:
                    node = try? container.decode(int32Type)
                case let int64Type as Int64.Type:
                    node = try? container.decode(int64Type)
                case let uintType as UInt.Type:
                    node = try? container.decode(uintType)
                case let uint8Type as UInt8.Type:
                    node = try? container.decode(uint8Type)
                case let uint16Type as UInt16.Type:
                    node = try? container.decode(uint16Type)
                case let uint32Type as UInt32.Type:
                    node = try? container.decode(uint32Type)
                case let uint64Type as UInt64.Type:
                    node = try? container.decode(uint64Type)
                case let doubleType as Double.Type:
                    node = try? container.decode(doubleType)
                case let stringType as String.Type:
                    node = try? container.decode(stringType)
                case let jsonValueArrayType as [EvolvRawAllocationNode].Type:
                    node = try? container.decode(jsonValueArrayType)
                case let jsonValueDictType as [String: EvolvRawAllocationNode].Type:
                    node = try? container.decode(jsonValueDictType)
                default:
                    break
                }
            }
        }
        
        self.init(node ?? NSNull())
    }
    
    // MARK: - Equatable
    
    override public func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? EvolvRawAllocationNode else {
            return false
        }
        
        guard object.type == type else {
            return false
        }
        
        switch type {
        case .number:
            return object.rawNumber == rawNumber
        case .string:
            return object.rawString == rawString
        case .bool:
            return object.rawBool == rawBool
        case .array:
            return object.rawArray as NSArray == rawArray as NSArray
        case .dictionary:
            return object.rawDictionary as NSDictionary == rawDictionary as NSDictionary
        case .null:
            return true
        default:
            return false
        }
    }
    
}

// MARK: - Comparable

extension EvolvRawAllocationNode: Comparable {
    
    public static func < (lhs: EvolvRawAllocationNode, rhs: EvolvRawAllocationNode) -> Bool {
        switch (lhs.type, rhs.type) {
        case (.number, .number): return lhs.rawNumber < rhs.rawNumber
        case (.string, .string): return lhs.rawString < rhs.rawString
        default: return false
        }
    }
    
}

// MARK: - NSNumber Comparable

func < (lhs: NSNumber, rhs: NSNumber) -> Bool {
    return lhs.compare(rhs) == .orderedAscending
}

// MARK: - LiteralConvertible

extension EvolvRawAllocationNode: ExpressibleByStringLiteral {
    
    public convenience init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
    
    public convenience init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self.init(value)
    }
    
    public convenience init(unicodeScalarLiteral value: StringLiteralType) {
        self.init(value)
    }
    
}

extension EvolvRawAllocationNode: ExpressibleByIntegerLiteral {
    
    public convenience init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
    
}

extension EvolvRawAllocationNode: ExpressibleByBooleanLiteral {
    
    public convenience init(booleanLiteral value: BooleanLiteralType) {
        self.init(value)
    }
    
}

extension EvolvRawAllocationNode: ExpressibleByFloatLiteral {
    
    public convenience init(floatLiteral value: FloatLiteralType) {
        self.init(value)
    }
    
}

extension EvolvRawAllocationNode: ExpressibleByDictionaryLiteral {
    
    public convenience init(dictionaryLiteral elements: (String, Any)...) {
        let dictionary = elements.reduce(into: [String: Any](), { $0[$1.0] = $1.1})
        self.init(dictionary)
    }
}

extension EvolvRawAllocationNode: ExpressibleByArrayLiteral {
    
    public convenience init(arrayLiteral elements: Any...) {
        self.init(elements)
    }
    
}

// MARK: - RawRepresentable

extension EvolvRawAllocationNode: RawRepresentable {

    public convenience init?(rawValue: Any) {
        if EvolvRawAllocationNode(rawValue).type == .unknown {
            return nil
        } else {
            self.init(rawValue)
        }
    }

    public var rawValue: Any {
        return value
    }

}

// MARK: - Bool, NSNumber, Int, Float, Double, String, Array, Dictionary

extension EvolvRawAllocationNode {
    
    public var bool: Bool? {
        return type == .bool ? rawBool : nil
    }
    
    @objc public var boolValue: Bool {
        return type == .bool ? rawBool : false
    }
    
    public var number: NSNumber? {
        return type == .number ? rawNumber : nil
    }
    
    @objc public var numberValue: NSNumber {
        return type == .number ? rawNumber : NSNumber.init(value: 0)
    }
    
    public var int: Int? {
        return type == .number ? number?.intValue : nil
    }
    
    @objc public var intValue: Int {
        return type == .number ? numberValue.intValue : 0
    }
    
    public var float: Float? {
        return type == .number ? number?.floatValue : nil
    }
    
    @objc public var floatValue: Float {
        return type == .number ? numberValue.floatValue : 0.0
    }
    
    public var double: Double? {
        return type == .number ? number?.doubleValue : nil
    }
    
    @objc public var doubleValue: Double {
        return type == .number ? numberValue.doubleValue : 0.0
    }
    
    public var string: String? {
        return type == .string ? rawString : nil
    }
    
    @objc public var stringValue: String {
        return type == .string ? rawString : ""
    }
    
    public var array: [EvolvRawAllocationNode]? {
        return type == .array ? rawArray.map { EvolvRawAllocationNode($0) } : nil
    }
    
    @objc public var arrayValue: [EvolvRawAllocationNode] {
        return type == .array ? array ?? [] : []
    }
    
    public var dictionary: [String: EvolvRawAllocationNode]? {
        if type == .dictionary {
            var dictionary = [String: EvolvRawAllocationNode](minimumCapacity: rawDictionary.count)
            
            rawDictionary.forEach { pair in
                dictionary[pair.key] = EvolvRawAllocationNode(pair.value)
            }
            
            return dictionary
        }
        
        return nil
    }
    
    @objc public var dictionaryValue: [String: EvolvRawAllocationNode] {
        return type == .dictionary ? dictionary ?? [:] : [:]
    }
    
}

// MARK: - Subscript (key path)

extension EvolvRawAllocationNode {
    
    subscript(index: Int) -> EvolvRawAllocationNode? {
        guard case .array = type, rawArray.indices.contains(index) else {
            return nil
        }
        
        return EvolvRawAllocationNode(rawArray[index])
    }
    
    private subscript(_ key: String) -> Any? {
        guard case .dictionary = type else {
            return nil
        }
        
        guard let node = rawDictionary[key] else {
            return nil
        }
        
        return node
    }
    
    func node(forKey key: String) throws -> EvolvRawAllocationNode? {
        guard case .dictionary = type else {
            throw Error.notDictionaryType
        }
        
        let keyPathKeys = key.components(separatedBy: ".").filter({ $0.isEmpty == false })
        
        if keyPathKeys.isEmpty {
            throw Error.emptyKey
        }
        
        var node = self
        var keyPath: [String] = []
        
        for key in keyPathKeys {
            keyPath.append(key)
            
            guard let childNode = node[key] else {
                throw Error.incorrectKey(key: keyPath.joined(separator: "."))
            }
            
            node = EvolvRawAllocationNode(childNode)
        }
        
        return node
    }
    
}
