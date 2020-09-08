//
//  StringSelector.swift
//  StringEx
//
//  Created by Andrey Golovchak on 13/05/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation

extension NSRegularExpression.Options: Hashable {}

public enum StringSelector: Hashable {
    case all
    case tag(_ tagName: String)
    case `class`(_ class: String)
    case id(_ id: String)
    case string(_ string: String, caseInsensitive: Bool = true)
    case regex(_ pattern: String, options: NSRegularExpression.Options = [])
    case range(_ range: Range<Int>)
    
    indirect case filter(_ selector: Self, filter: Filter)
    indirect case select(_ selector: Self, in: Self)
    indirect case union(_ selectors: [Self])
    
    func filter(with filter: Filter) -> Self {
        switch self {
        case .filter(let selector, _):
            return .filter(selector, filter: filter)
        default:
            return .filter(self, filter: filter)
        }
    }
    
    func select(_ selector: Self) -> Self {
        return .select(selector, in: self)
    }
    
    func add(_ selector: Self) -> Self {
        switch (self, selector) {
        case (.union(var sel), .union(let sel2)):
            sel.append(contentsOf: sel2)
            return .union(sel)
        case (.union(var sel), _):
            sel.append(selector)
            return .union(sel)
        case (_, .union(var sel)):
            sel.append(selector)
            return .union(sel)
        default:
            return .union([self, selector])
        }
    }
}

infix operator =>: MultiplicationPrecedence

public extension StringSelector {
    
    static func +(lhs: Self, rhs: Self) -> Self {
        return lhs.add(rhs)
    }

    static func =>(lhs: Self, rhs: Self) -> Self {
        return lhs.select(rhs)
    }

    static func %(lhs: Self, rhs: Filter) -> Self {
        return lhs.filter(with: rhs)
    }
}
