//
//  EvolvAudienceQuery.swift
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

public struct Rule: Decodable {
    
    enum Operator: String, Decodable {
        case exists
        case equal = "kv_equal"
        case notEqual = "kv_not_equal"
        case contains = "kv_contains"
        case notContains = "kv_not_contains"
    }
    
    enum Field: String, Decodable {
        case userAttributes = "user_attributes"
    }
    
    let id: String
    let field: Field
    let `operator`: Operator
    let value: Any
    
    enum CodingKey: String, Swift.CodingKey {
        case id
        case field
        case `operator`
        case value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKey.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.field = try container.decode(Field.self, forKey: .field)
        self.operator = try container.decode(Operator.self, forKey: .`operator`)
        
        if let value = try? container.decode(String.self, forKey: .value) {
            self.value = value
        } else if let values = try? container.decode([String].self, forKey: .value) {
            self.value = values
        } else {
            throw DecodingError.dataCorruptedError(forKey: .value, in: container, debugDescription: "Invalid format for value")
        }
    }
    
}

public struct CompoundRule: Decodable {
    enum Combinator: String, Decodable {
        case and
        case or
    }
    
    let id: String
    let combinator: Combinator
    let rules: [EvolvQuery]
}

public enum EvolvQuery: Decodable {
    
    case rule(Rule)
    case compoundRule(CompoundRule)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let rule = try? container.decode(Rule.self) {
            self = .rule(rule)
        } else if let compoundRule = try? container.decode(CompoundRule.self) {
            self = .compoundRule(compoundRule)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Mismatched Types")
        }
    }
    
    /// Recursive handling of the query to check if a certain rule will work
    /// for the current userAttributes
    ///
    /// - Parameters:
    ///   - expression: Query the specific audience filter defined by project
    ///   - userAttributes: map representing attributes that represent the participant
    /// - Returns: Returns true if rule is matched with userAttributes
    static func evaluate(_ expression: EvolvQuery, userAttributes: [String: String]) -> Bool {
        switch expression {
        case .rule(let rule):
            switch (rule.operator, rule.value) {
            case (.exists, let value as String):
                return userAttributes.keys.contains(where: { $0 == value })
            case (.equal, let values as [String]) where values.count > 1:
                return userAttributes.keys.contains(where: { $0 == values[0] }) && userAttributes[values[0]] == values[1]
            case (.notEqual, let values as [String]) where values.count > 1:
                return userAttributes.keys.contains(where: { $0 == values[0] }) && userAttributes[values[0]] != values[1]
            case (.contains, let values as [String]) where values.count > 1:
                return userAttributes.contains(where: { $0.key == values[0] && $0.value.contains(values[1]) })
            case (.notContains, let values as [String]) where values.count > 1:
                return userAttributes.contains(where: { $0.key == values[0] && $0.value.contains(values[1]) == false })
            default:
                return true
            }
        case .compoundRule(let compoundRule):
            guard compoundRule.rules.isEmpty == false else {
                return true
            }
            
            let results = compoundRule.rules.map({ evaluate($0, userAttributes: userAttributes) })
            
            switch compoundRule.combinator {
            case .and:
                return !results.contains(false)
            case .or:
                return results.contains(true)
            }
        }
    }
    
}
