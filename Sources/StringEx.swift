//
//  StringEx.swift
//  StringEx
//
//  Created by Andrey Golovchak on 20/04/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation
import UIKit

public class StringEx {
    
    public private(set) var rawString: String
    private var resultString: String
    public private(set) var selector: StringSelector = .all
    
    private var storage: HTMLTagStorage
    private var selectorResults: [SelectorResult]?
    private var restoreSelectorResults: Bool = true
    
    private var resultAttributedString: NSMutableAttributedString
    
    public var useStyleManager = false
    
    public init(string: String) {
        let parser = HTMLParser(source: string)
        parser.parse()
        
        rawString = parser.rawString
        resultString = parser.resultString
        storage = parser.storage
        
        resultAttributedString = NSMutableAttributedString(string: resultString)
    }
    
    public init(attributedString: NSAttributedString) {
        let parser = HTMLParser(source: attributedString.string)
        parser.parse()
        
        rawString = parser.rawString
        resultString = parser.resultString
        storage = parser.storage
        
        resultAttributedString = NSMutableAttributedString(attributedString: attributedString)
    }
    
}

// Mark: Getters

extension StringEx {
    
    var count: Int {
        return selectorResults?.count ?? 0
    }
    
    var string: String {
        return resultString
    }
    
    var selectedString: String {
        switch selector {
        case .all:
            return resultString
        default:
            return selectedString(separator: "")
        }
    }
    
    public func selectedString(separator: String) -> String {
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
    
    var attributedString: NSAttributedString {
        applyManagerStyles()
        return NSAttributedString(attributedString: resultAttributedString)
    }
    
    var selectedAttributedString: NSAttributedString {
        switch selector {
        case .all:
            return attributedString
        default:
            return selectedAttributedString(separator: "")
        }
    }
    
    public func selectedAttributedString(separator: String) -> NSAttributedString {
        guard let ranges = selectedNSRanges() else {
            return NSAttributedString()
        }
        
        applyManagerStyles()
        
        var parts = [NSAttributedString]()
        
        for range in ranges {
            parts.append(resultAttributedString.attributedSubstring(from: range))
        }
        
        let attributedString = NSMutableAttributedString()
        let attributedSeparator = NSAttributedString(string: separator)
        var first = true
        
        for part in parts {
            if first {
                first = false
            } else {
                attributedString.append(attributedSeparator)
            }
            attributedString.append(part)
        }
        
        return attributedString
    }
    
}

// Mark: Utils

extension StringEx {
    
    private func selectedNSRanges() -> [NSRange]? {
        
        guard let results = selectorResults else {
            return nil
        }
        
        var resultRanges = [NSRange]()
        
        let ranges = results.map { $0.range }
        let combinedRanges = ranges.combinedRanges()
        
        var index = resultString.startIndex
        var offset = 0
        
        let utf16 = resultString.utf16
        var indexUTF16 = utf16.startIndex
        var offsetUTF16 = 0
        
        for range in combinedRanges {
            let lowerBound = resultString.index(index, offsetBy: range.lowerBound - offset)
            let upperBound = resultString.index(lowerBound, offsetBy: range.upperBound - range.lowerBound)
            
            index = upperBound
            offset = range.upperBound
            
            if let lowerBoundUTF16 = lowerBound.samePosition(in: utf16), let upperBoundUTF16 = upperBound.samePosition(in: utf16) {
                let location = utf16.distance(from: indexUTF16, to: lowerBoundUTF16) + offsetUTF16
                let length = utf16.distance(from: lowerBoundUTF16, to: upperBoundUTF16)
                
                indexUTF16 = upperBoundUTF16
                offsetUTF16 = location + length
                
                resultRanges.append(NSRange(location: location, length: length))
            }
        }
        
        return resultRanges
    }
    
    private func applyManagerStyles() {
        if useStyleManager {
            select(.all).clearStyles()
            if let styles = StyleManager.shared.styles {
                style(styles)
            }
        }
    }
}

// Mark: Modifiers

extension StringEx {
    
    @discardableResult
    public func replace(with replace: String, mode: RangeConversionMode = .outer) -> Self {
        return self.replace(with: replace.ex, mode: mode)
    }
    
    @discardableResult
    public func replace(with replace: NSAttributedString, mode: RangeConversionMode = .outer) -> Self {
        return self.replace(with: replace.ex, mode: mode)
    }
    
    @discardableResult
    public func replace(with replace: StringEx, mode: RangeConversionMode = .outer) -> Self {
        if count == 0 {
            return self
        }
        
        guard let results = selectorResults else {
            return self
        }
        
        var ranges = [Range<Int>]()
        var rawRanges = [Range<Int>]()
        
        let rangeConverter = RangeConverter(storage: storage, resultStringCount: resultString.count, rawStringCount: rawString.count)
        
        for result in results {
            ranges.append(result.range)
            
            if let rawRange = rangeConverter.convert(result, mode: mode) {
                rawRanges.append(rawRange)
            }
        }
        
        // Replace attributed string
        
        var attributedStringParts = [NSAttributedString]()
        
        var index = resultString.startIndex
        var offset = 0
        
        let utf16 = resultString.utf16
        var indexUTF16 = utf16.startIndex
        var location = 0
        
        for range in ranges.combinedRanges() {
            let lowerBound = resultString.index(index, offsetBy: range.lowerBound - offset)
            let upperBound = resultString.index(lowerBound, offsetBy: range.upperBound - range.lowerBound)
            
            index = upperBound
            offset = range.upperBound
            
            if let lowerBoundUTF16 = lowerBound.samePosition(in: utf16), let upperBoundUTF16 = upperBound.samePosition(in: utf16) {
                let length = utf16.distance(from: indexUTF16, to: lowerBoundUTF16)
                
                attributedStringParts.append(resultAttributedString.attributedSubstring(from: NSRange(location: location, length: length)))
                
                indexUTF16 = upperBoundUTF16
                location += length + utf16.distance(from: lowerBoundUTF16, to: upperBoundUTF16)
            }
        }
        
        let length = utf16.distance(from: indexUTF16, to: utf16.endIndex)
        attributedStringParts.append(resultAttributedString.attributedSubstring(from: NSRange(location: location, length: length)))
        
        let attributedString = NSMutableAttributedString()
        let attributedSeparator = NSAttributedString(attributedString: replace.attributedString)
        var first = true
        
        for part in attributedStringParts {
            if first {
                first = false
            } else {
                attributedString.append(attributedSeparator)
            }
            attributedString.append(part)
        }
        
        resultAttributedString = attributedString
        
        // Replace string
        
        var parts = [String]()
        
        index = rawString.startIndex
        offset = 0
        
        for range in rawRanges.combinedRanges() {
            let lowerBound = rawString.index(index, offsetBy: range.lowerBound - offset)
            let upperBound = rawString.index(lowerBound, offsetBy: range.upperBound - range.lowerBound)
            
            parts.append(String(rawString[index..<lowerBound]))
            
            index = upperBound
            offset = range.upperBound
        }
        
        parts.append(String(rawString[index..<rawString.endIndex]))
        
        let string = parts.joined(separator: replace.rawString)
        
        let parser = HTMLParser(source: string)
        parser.parse()
        
        rawString = parser.rawString
        resultString = parser.resultString
        storage = parser.storage
        
        // Restore selector results
        if restoreSelectorResults {
            _ = select(selector)
        } else {
            restoreSelectorResults = true
        }
        
        return self
    }
    
    @discardableResult
    public func prepend(_ value: String) -> Self {
        return prepend(value.ex)
    }
    
    @discardableResult
    public func prepend(_ value: NSAttributedString) -> Self {
        return prepend(value.ex)
    }
    
    @discardableResult
    public func prepend(_ value: StringEx) -> Self {
        let currentSelector = selector
        _ = select(selector.select(.range(0..<0)))
        restoreSelectorResults = false
        self.replace(with: value)
        _ = select(currentSelector)
        return self
    }
    
    @discardableResult
    public func append(_ value: String) -> Self {
        return append(value.ex)
    }
    
    @discardableResult
    public func append(_ value: NSAttributedString) -> Self {
        return append(value.ex)
    }
    
    @discardableResult
    public func append(_ value: StringEx) -> Self {
        let currentSelector = selector
        _ = select(selector.select(.range(Int.max..<Int.max)))
        restoreSelectorResults = false
        self.replace(with: value)
        _ = select(currentSelector)
        return self
    }
    
    @discardableResult
    public func insert(_ value: String, at index: Int) -> Self {
        return insert(value.ex, at: index)
    }
    
    @discardableResult
    public func insert(_ value: NSAttributedString, at index: Int) -> Self {
        return insert(value.ex, at: index)
    }
    
    @discardableResult
    public func insert(_ value: StringEx, at index: Int) -> Self {
        let currentSelector = selector
        _ = select(selector.select(.range(index..<index)))
        restoreSelectorResults = false
        self.replace(with: value)
        _ = select(currentSelector)
        return self
    }
}

// Mark: Styling

extension StringEx {
    
    @discardableResult
    public func style(_ stylesheet: Stylesheet) -> Self {
        return self.style([stylesheet])
    }
    
    @discardableResult
    public func style(_ stylesheets: [Stylesheet]) -> Self {
        
        for stylesheet in stylesheets {
            self[stylesheet.selector].style(stylesheet.styles)
        }
        
        return self
    }
    
    @discardableResult
    public func style(_ style: Style) -> Self {
        return self.style([style])
    }
    
    @discardableResult
    public func style(_ styles: [Style]) -> Self {
        
        guard let ranges = selectedNSRanges() else {
            return self
        }
        
        var attributes = [NSAttributedString.Key: Any]()
        var paragraphStyle: NSMutableParagraphStyle?
        
        for style in styles {
            switch style {
            case .font(let font):
                attributes[.font] = font
            case .color(let color):
                attributes[.foregroundColor] = color
            case .backgroundColor(let color):
                attributes[.backgroundColor] = color
            case .kern(let value):
                attributes[.kern] = value
            case .linkString(let string):
                if let string = string {
                    attributes[.link] = URL(string: string)
                } else {
                    attributes[.link] = nil
                }
            case .linkUrl(let url):
                attributes[.link] = url
            case .shadow(let shadow):
                attributes[.shadow] = shadow
            case .lineThroughStyle(let style, let color):
                attributes[.strikethroughStyle] = style.rawValue
                attributes[.strikethroughColor] = color
            case .lineThroughStyles(let styles, let color):
                if styles.count > 0 {
                    var style = -1
                    for s in styles {
                        if style < 0 {
                            style = s.rawValue
                        } else {
                            style = style | s.rawValue
                        }
                    }
                    attributes[.strikethroughStyle] = style
                    attributes[.strikethroughColor] = color
                }
            case .underlineStyle(let style, let color):
                attributes[.underlineStyle] = style.rawValue
                attributes[.underlineColor] = color
            case .underlineStyles(let styles, let color):
                if styles.count > 0 {
                    var style = -1
                    for s in styles {
                        if style < 0 {
                            style = s.rawValue
                        } else {
                            style = style | s.rawValue
                        }
                    }
                    attributes[.underlineStyle] = style
                    attributes[.underlineColor] = color
                }
            case .strokeWidth(let width, let color):
                attributes[.strokeWidth] = width
                attributes[.strokeColor] = color
            case .baselineOffset(let value):
                attributes[.baselineOffset] = value
            case .paragraphStyle(let value):
                attributes[.paragraphStyle] = value
            case .aligment(let value):
                if paragraphStyle == nil {
                    paragraphStyle = NSMutableParagraphStyle()
                }
                paragraphStyle!.alignment = value
            case .firstLineHeadIndent(let value):
                if paragraphStyle == nil {
                    paragraphStyle = NSMutableParagraphStyle()
                }
                paragraphStyle!.firstLineHeadIndent = CGFloat(value)
            case .headIndent(let value):
                if paragraphStyle == nil {
                    paragraphStyle = NSMutableParagraphStyle()
                }
                paragraphStyle!.headIndent = CGFloat(value)
            case .tailIndent(let value):
                if paragraphStyle == nil {
                    paragraphStyle = NSMutableParagraphStyle()
                }
                paragraphStyle!.tailIndent = CGFloat(value)
            case .lineHeightMultiple(let value):
                if paragraphStyle == nil {
                    paragraphStyle = NSMutableParagraphStyle()
                }
                paragraphStyle!.lineHeightMultiple = CGFloat(value)
            case .lineSpacing(let value):
                if paragraphStyle == nil {
                    paragraphStyle = NSMutableParagraphStyle()
                }
                paragraphStyle!.lineSpacing = CGFloat(value)
            case .paragraphSpacing(let value):
                if paragraphStyle == nil {
                    paragraphStyle = NSMutableParagraphStyle()
                }
                paragraphStyle!.paragraphSpacing = CGFloat(value)
            case .paragraphSpacingBefore(let value):
                if paragraphStyle == nil {
                    paragraphStyle = NSMutableParagraphStyle()
                }
                paragraphStyle!.paragraphSpacingBefore = CGFloat(value)
            }
        }
        
        if let paragraphStyle = paragraphStyle {
            attributes[.paragraphStyle] = paragraphStyle
        }
        
        for range in ranges {
            resultAttributedString.addAttributes(attributes, range: range)
        }
        
        return self
    }
    
    @discardableResult
    public func clearStyles() -> Self {
        switch selector {
        case .all:
            resultAttributedString = NSMutableAttributedString(string: resultString)
        default:
            guard let ranges = selectedNSRanges() else {
                return self
            }
            
            for range in ranges {
                resultAttributedString.setAttributes([:], range: range)
            }
        }
        
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
        case .string(let string, let caseInsensitive):
            if !string.isEmpty && !resultString.isEmpty {
                var tagPair: HTMLTagPair?
                var searchStartIndex = resultString.startIndex
                var searchEndIndex = resultString.endIndex
                if let parent = parent {
                    searchStartIndex = resultString.index(resultString.startIndex, offsetBy: parent.range.lowerBound)
                    searchEndIndex = resultString.index(searchStartIndex, offsetBy: parent.range.upperBound - parent.range.lowerBound)
                    tagPair = parent.tag
                }
                var index = resultString.startIndex
                var offset = 0
                while searchStartIndex < searchEndIndex, let range = resultString.range(of: string, options: caseInsensitive ? .caseInsensitive : [], range: searchStartIndex..<searchEndIndex, locale: nil), !range.isEmpty {
                    let lowerBound = resultString.distance(from: index, to: range.lowerBound) + offset
                    let upperBound = resultString.distance(from: range.lowerBound, to: range.upperBound) + lowerBound
                    index = range.upperBound
                    offset = upperBound
                    results.append(SelectorResult(range: lowerBound..<upperBound, tag: tagPair))
                    searchStartIndex = range.upperBound
                }
            }
        case .regex(let pattern, let options):
            if !pattern.isEmpty && !resultString.isEmpty {
                if let regex = try? NSRegularExpression(pattern: pattern, options: options) {
                    var tagPair: HTMLTagPair?
                    var searchStartIndex = resultString.startIndex
                    var searchEndIndex = resultString.endIndex
                    if let parent = parent {
                        searchStartIndex = resultString.index(resultString.startIndex, offsetBy: parent.range.lowerBound)
                        searchEndIndex = resultString.index(searchStartIndex, offsetBy: parent.range.upperBound - parent.range.lowerBound)
                        tagPair = parent.tag
                    }
                    let utf16 = resultString.utf16
                    if let startIndexUTF16 = searchStartIndex.samePosition(in: utf16), let endIndexUTF16 = searchEndIndex.samePosition(in: utf16) {
                        let searchRange = NSMakeRange(utf16.distance(from: utf16.startIndex, to: startIndexUTF16), utf16.distance(from: startIndexUTF16, to: endIndexUTF16))
                        var index = resultString.startIndex
                        var offset = 0
                        regex.enumerateMatches(in: resultString, options: [], range: searchRange) { result, _, _ in
                            if let result = result, let range = Range(result.range, in: resultString) {
                                let lowerBound = resultString.distance(from: index, to: range.lowerBound) + offset
                                let upperBound = resultString.distance(from: range.lowerBound, to: range.upperBound) + lowerBound
                                index = range.upperBound
                                offset = upperBound
                                results.append(SelectorResult(range: lowerBound..<upperBound, tag: tagPair))
                            }
                        }
                    }
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
        case .filter(let selector, let filter):
            var selectorResults = execute(selector)
            if !selectorResults.isEmpty {
                selectorResults.sort { $0.range.lowerBound < $1.range.lowerBound }
                switch filter {
                case .first:
                    results.append(selectorResults.first!)
                case .last:
                    results.append(selectorResults.last!)
                case .eq(let index):
                    if index >= 0 && index < selectorResults.count {
                        results.append(selectorResults[index])
                    }
                case .even:
                    results.append(contentsOf: selectorResults.enumerated().compactMap { $0 % 2 == 0 ? $1 : nil })
                case .odd:
                    results.append(contentsOf: selectorResults.enumerated().compactMap { $0 % 2 != 0 ? $1 : nil })
                }
            }
        }
        
        return results
    }
}

// Mark: Operators

extension StringEx {
    
    static func +(lhs: StringEx, rhs: StringEx) -> StringEx {
        return lhs[.range(Int.max..<Int.max)].replace(with: rhs).select(.all)
    }
    
    static func +(lhs: StringEx, rhs: String) -> StringEx {
        return lhs[.range(Int.max..<Int.max)].replace(with: rhs).select(.all)
    }
    
    static func +(lhs: String, rhs: StringEx) -> StringEx {
        return rhs[.range(0..<0)].replace(with: lhs).select(.all)
    }
    
    static func +(lhs: StringEx, rhs: NSAttributedString) -> StringEx {
        return lhs[.range(Int.max..<Int.max)].replace(with: rhs).select(.all)
    }
    
    static func +(lhs: NSAttributedString, rhs: StringEx) -> StringEx {
        return rhs[.range(0..<0)].replace(with: lhs).select(.all)
    }
}
