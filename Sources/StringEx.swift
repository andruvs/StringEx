//
//  StringEx.swift
//  StringEx
//
//  Created by Andrey Golovchak on 20/04/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation

public class StringEx {
    
    public private(set) var rawString: String
    public private(set) var resultString: String
    public private(set) var selector: StringSelector = .all
    
    private var storage: HTMLTagStorage
    private var selectorResults: [SelectorResult]?
    
    public init(string: String) {
        let parser = HTMLParser(source: string)
        parser.parse()
        
        rawString = parser.rawString
        resultString = parser.resultString
        storage = parser.storage
    }
    
}

// Mark: Getters

extension StringEx {
    
    var count: Int {
        return selectorResults?.count ?? 0
    }
    
    var string: String {
        switch selector {
        case .all:
            return resultString
        default:
            return string(separator: "")
        }
    }
    
    public func string(separator: String) -> String {
        guard let results = selectorResults else {
            return ""
        }
        
        let ranges = results.map { $0.range }
        let combinedRanges = ranges.combinedRanges()
        
        var parts = [String]()
        var index = resultString.startIndex
        var offset = 0
        
        for range in combinedRanges {
            let lowerBound = resultString.index(index, offsetBy: range.lowerBound - offset)
            let upperBound = resultString.index(lowerBound, offsetBy: range.upperBound - range.lowerBound)
            
            index = upperBound
            offset = range.upperBound
            
            parts.append(String(resultString[lowerBound..<upperBound]))
        }
        
        return parts.joined(separator: separator)
    }
    
}

// Mark: Modifiers

extension StringEx {
    
    @discardableResult
    public func replace(with replace: String, mode: RangeConversionMode = .outer) -> Self {
        if count == 0 {
            return self
        }
        
        guard let results = selectorResults else {
            return self
        }
        
        var ranges = [Range<Int>]()
        
        let rangeConverter = RangeConverter(storage: storage, resultStringCount: resultString.count, rawStringCount: rawString.count)
        
        for result in results {
            if let rawRange = rangeConverter.convert(result, mode: mode) {
                ranges.append(rawRange)
            }
        }
        
        let combinedRanges = ranges.combinedRanges()
        
        var parts = [String]()
        var index = rawString.startIndex
        var offset = 0
        
        for range in combinedRanges {
            let lowerBound = rawString.index(index, offsetBy: range.lowerBound - offset)
            let upperBound = rawString.index(lowerBound, offsetBy: range.upperBound - range.lowerBound)
            
            parts.append(String(rawString[index..<lowerBound]))
            
            index = upperBound
            offset = range.upperBound
        }
        
        parts.append(String(rawString[index..<rawString.endIndex]))
        
        let string = parts.joined(separator: replace)
        
        let parser = HTMLParser(source: string)
        parser.parse()
        
        rawString = parser.rawString
        resultString = parser.resultString
        storage = parser.storage
        
        return self
    }
}

// Mark: Selectors

extension StringEx {
    
    subscript(selector: StringSelector) -> StringEx {
        get {
            self.select(selector)
        }
    }
    
    public func select(_ selector: StringSelector) -> Self {
        self.selector = selector
        var results = execute(selector)
        results.sort { $0.range.lowerBound < $1.range.lowerBound }
        selectorResults = results
        return self
    }
    
    private func execute(_ selector: StringSelector, in parent: SelectorResult? = nil) -> [SelectorResult] {
        var results = [SelectorResult]()
        
        switch selector {
        case .all:
            if let parent = parent {
                results.append(parent)
            } else {
                results.append(SelectorResult(range: 0..<resultString.count, tag: nil))
            }
        case .tag(let tagName):
            storage.forEach(tagName: tagName) { (tagPair) in
                if let parent = parent, !parent.contains(tagPair) {
                    return
                }
                if let range = tagPair.range {
                    results.append(SelectorResult(range: range, tag: tagPair))
                }
            }
        case .class(let `class`):
            storage.forEach(class: `class`) { (tagPair) in
                if let parent = parent, !parent.contains(tagPair) {
                    return
                }
                if let range = tagPair.range {
                    results.append(SelectorResult(range: range, tag: tagPair))
                }
            }
        case .id(let id):
            storage.forEach(id: id) { (tagPair) in
                if let parent = parent, !parent.contains(tagPair) {
                    return
                }
                if let range = tagPair.range {
                    results.append(SelectorResult(range: range, tag: tagPair))
                }
            }
        case .range(let range):
            let resultRange: Range<Int>
            let tagPair: HTMLTagPair?
            if let parent = parent {
                let lowerBound = parent.range.lowerBound.addingReportingOverflow(range.lowerBound)
                let upperBound = parent.range.lowerBound.addingReportingOverflow(range.upperBound)
                resultRange = min(parent.range.upperBound, max(parent.range.lowerBound, lowerBound.overflow ? Int.max : lowerBound.partialValue))..<max(parent.range.lowerBound, min(parent.range.upperBound, upperBound.overflow ? Int.max : upperBound.partialValue))
                tagPair = parent.tag
            } else {
                resultRange = min(resultString.count, max(0, range.lowerBound))..<max(0, min(resultString.count, range.upperBound))
                tagPair = nil
            }
            results.append(SelectorResult(range: resultRange, tag: tagPair))
        case .select(let selector, let parentSelector):
            let parentResults = execute(parentSelector)
            for parentResult in parentResults {
                results.append(contentsOf: execute(selector, in: parentResult))
            }
        case .union(let selectors):
            for selector in selectors {
                results.append(contentsOf: execute(selector))
            }
        case .filter(let selectors, let filter):
            print(selectors, filter)
        }
        
        return results
    }
}
