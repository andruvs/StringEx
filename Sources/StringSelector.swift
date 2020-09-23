//
//  StringSelector.swift
//  StringEx
//
//  Created by Andrey Golovchak on 13/05/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation

extension NSRegularExpression.Options: Hashable {}

/**
 The list of available selectors.
 
 - Tag: StringSelector
*/
public enum StringSelector: Hashable {
    
    /// Selects whole string
    case all
    
    /// Selects the inner content of an html tag with a specific tag name.
    /// - tagName: Tag name.
    case tag(_ tagName: String)
    
    /// Selects the inner content of an html tag with a specific tag class.
    /// - class: Class name.
    case `class`(_ class: String)
    
    /// Selects the inner content of an html tag with a specific tag identifier.
    /// - id: Identifier of the html tag.
    case id(_ id: String)
    
    /// Selects ranges containing the search string. It is possible to search with or without case sensitive.
    /// - string: Search string.
    /// - caseInsensitive: A flag that determines whether the search is case sensitive or not. By default, the search is case insensitive.
    case string(_ string: String, caseInsensitive: Bool = true)
    
    /// Selects ranges using the passed regular expression.
    /// - pattern: The regular expression.
    /// - options: The regular expression options.
    case regex(_ pattern: String, options: NSRegularExpression.Options = [])
    
    /// Selects specific sub-range of the string. It is safe to pass a range that is out of range.
    /// - range: The range to select.
    case range(_ range: Range<Int>)
    
    indirect case filter(_ selector: Self, filter: Filter)
    indirect case select(_ selector: Self, in: Self)
    indirect case union(_ selectors: [Self])
    
    /**
    Filters the results of the current selector. You can also use a shorthand version of the method: `%`.

    # Example #
    ```
    // These selectors are identical
    let selector1: StringSelector = .tag("span").filter(.odd)
    let selector2: StringSelector = .tag("span") % .odd
    print(selector1 == selector2) // true
    ```

    - Parameters:
      - filter: The [Filter](x-source-tag://Filter) object.
    - Returns: Resulting selector.
    */
    func filter(with filter: Filter) -> Self {
        switch self {
        case .filter(let selector, _):
            return .filter(selector, filter: filter)
        default:
            return .filter(self, filter: filter)
        }
    }
    
    /**
    Executes a selector on each result of the previous selector. You can also use a shorthand version of the method: `=>`.

    # Example #
    ```
    // These selectors are identical
    let selector1: StringSelector = .tag("span").select(.range(0..<3))
    let selector2: StringSelector = .tag("span") => .range(0..<3)
    print(selector1 == selector2) // true
    ```

    - Parameters:
      - selector: The [StringSelector](x-source-tag://StringSelector) object.
    - Returns: Resulting selector.
    */
    func select(_ selector: Self) -> Self {
        return .select(selector, in: self)
    }
    
    /**
    Combines multiple selectors into one. You can also use a shorthand version of the method: `+`.

    # Example #
    ```
    // These selectors are identical
    let selector1: StringSelector = .tag("span").add(.range(0..<3))
    let selector2: StringSelector = .tag("span") + .range(0..<3)
    print(selector1 == selector2) // true
    ```

    - Parameters:
      - selector: The [StringSelector](x-source-tag://StringSelector) object.
    - Returns: Resulting selector.
    */
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
