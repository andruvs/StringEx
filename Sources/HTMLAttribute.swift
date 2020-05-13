//
//  HTMLAttribute.swift
//  StringEx
//
//  Created by Andrey Golovchak on 28/04/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation

enum HTMLAttributeName {
    case `class`
    case id
    
    init?(rawValue: String) {
        switch rawValue.lowercased() {
        case "class":
            self = .class
        case "id":
            self = .id
        default:
            return nil
        }
    }
}

extension HTMLAttributeName: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .class:
            return "class"
        case .id:
            return "id"
        }
    }
}

protocol AnyHTMLAttribute: CustomStringConvertible {}

protocol HTMLAttribute: AnyHTMLAttribute {
    associatedtype ValueType
    
    var value: ValueType { get }
    
    init(value: ValueType?)
}

typealias HTMLAttributes = [HTMLAttributeName: AnyHTMLAttribute]

struct HTMLAttributeSingle: HTMLAttribute {
    
    private(set) var value: String
    
    init(value: String?) {
        if let value = value {
            self.value = value
        } else {
            self.value = ""
        }
    }
    
    var description: String {
        return self.value
    }
}

struct HTMLAttributeMultiple: HTMLAttribute {
    private(set) var value: Set<String>
    
    init(value: Set<String>?) {
        if let value = value {
            self.value = value
        } else {
            self.value = []
        }
    }
    
    var description: String {
        return self.value.joined(separator: " ")
    }
}
