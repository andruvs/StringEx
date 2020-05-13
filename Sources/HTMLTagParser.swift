//
//  HTMLTagParser.swift
//  StringEx
//
//  Created by Andrey Golovchak on 20/04/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation

fileprivate enum CodePoint {
    typealias CodeUnit = UTF32.CodeUnit
    
    case tagStart
    case tagEnd
    case tagClosing
    case tagName
    case attributeName
    case unquotedAttributeValue
    case singleQuotedAttributeValue
    case doubleQuotedAttributeValue
    case anyWhitespace
    case equals
    case singleQuote
    case doubleQuote
}

extension CodePoint.CodeUnit {
    static let whitespace = 0x20
    static let lineFeed = 0x0A // LF (\n)
    static let formFeed = 0x0C // FF (\f)
    static let tab = 0x09 // TAB (\t)
    static let carriageReturn = 0x0D // CR (\r)
    static let lessThanSign = 0x3C // LESS-THAN SIGN (<)
    static let greaterThanSign = 0x3E // GREATER-THAN SIGN (>)
    static let solidus = 0x2F // SOLIDUS (/)
    static let singleQuote = 0x27 // APOSTROPHE (')
    static let doubleQuote = 0x22 // QUOTATION MARK (")
    static let graveAccent = 0x60 // GRAVE ACCENT (`)
    static let equals = 0x3D // EQUALS SIGN (=)
    static let lowerAlpha: ClosedRange<Self> = 0x61...0x7A // a...z
    static let upperAlpha: ClosedRange<Self> = 0x41...0x5A // A...Z
    static let digit: ClosedRange<Self> = 0x30...0x39 // 0...9
    static let c0: ClosedRange<Self> = 0x00...0x1F // NULL...INFORMATION SEPARATOR ONE
    static let control: ClosedRange<Self> = 0x7F...0x9F // DELETE...APPLICATION PROGRAM COMMAND
    static let noncharacter: Set<Self> = Set(0xFDD0...0xFDEF).union([0xFFFE, 0xFFFF, 0x1FFFE, 0x1FFFF, 0x2FFFE, 0x2FFFF, 0x3FFFE, 0x3FFFF, 0x4FFFE, 0x4FFFF, 0x5FFFE, 0x5FFFF, 0x6FFFE, 0x6FFFF, 0x7FFFE, 0x7FFFF, 0x8FFFE, 0x8FFFF, 0x9FFFE, 0x9FFFF, 0xAFFFE, 0xAFFFF, 0xBFFFE, 0xBFFFF, 0xCFFFE, 0xCFFFF, 0xDFFFE, 0xDFFFF, 0xEFFFE, 0xEFFFF, 0xFFFFE, 0xFFFFF, 0x10FFFE, 0x10FFFF])
}

extension CodePoint: Equatable {

    static func == (lhs: CodePoint, rhs: CodeUnit) -> Bool {
        switch lhs {
        case .tagStart:
            return rhs == CodeUnit.lessThanSign
        case .tagEnd:
            return rhs == CodeUnit.greaterThanSign
        case .tagClosing:
            return rhs == CodeUnit.solidus
        case .tagName:
            return CodeUnit.lowerAlpha.contains(rhs) || CodeUnit.upperAlpha.contains(rhs) || CodeUnit.digit.contains(rhs)
        case .attributeName:
            return !CodeUnit.c0.contains(rhs)
                && !CodeUnit.control.contains(rhs)
                && !CodeUnit.noncharacter.contains(rhs)
                && rhs != CodeUnit.whitespace
                && rhs != CodeUnit.doubleQuote
                && rhs != CodeUnit.singleQuote
                && rhs != CodeUnit.greaterThanSign
                && rhs != CodeUnit.solidus
                && rhs != CodeUnit.equals
        case .unquotedAttributeValue:
            return rhs != .anyWhitespace
                && rhs != CodeUnit.doubleQuote
                && rhs != CodeUnit.singleQuote
                && rhs != CodeUnit.equals
                && rhs != CodeUnit.lessThanSign
                && rhs != CodeUnit.greaterThanSign
                && rhs != CodeUnit.graveAccent
        case .singleQuotedAttributeValue:
            return rhs != CodeUnit.singleQuote
        case .doubleQuotedAttributeValue:
            return rhs != CodeUnit.doubleQuote
        case .anyWhitespace:
            return rhs == CodeUnit.whitespace
                || rhs == CodeUnit.lineFeed
                || rhs == CodeUnit.formFeed
                || rhs == CodeUnit.tab
                || rhs == CodeUnit.carriageReturn
        case .equals:
            return rhs == CodeUnit.equals
        case .singleQuote:
            return rhs == CodeUnit.singleQuote
        case .doubleQuote:
            return rhs == CodeUnit.doubleQuote
        }
    }

    static func == (lhs: CodeUnit, rhs: CodePoint) -> Bool {
        return rhs == lhs
    }
    
    static func != (lhs: CodeUnit, rhs: CodePoint) -> Bool {
        return !(rhs == lhs)
    }

}

class HTMLTagParser {
    typealias Source = String.UnicodeScalarView
    
    private let source: Source
    private var index: Source.Index
    private var startIndex: Source.Index
    private var endIndex: Source.Index
    
    private var currentCodeUnit: UTF32.CodeUnit {
        return source[index].value
    }
    
    private var isLastIndex: Bool {
        return index == endIndex
    }
    
    private var isSecondLastIndex: Bool {
        return index == source.index(before: endIndex)
    }
    
    init(source: String) {
        self.source = source.unicodeScalars
        startIndex = source.startIndex
        endIndex = source.endIndex
        index = startIndex
    }
    
    // https://html.spec.whatwg.org/multipage/syntax.html
    func parse() -> HTMLTag? {
        
        // Min. 3 symbols per tag: <a>
        if source.count < 3 {
            return nil
        }
        
        if currentCodeUnit == .tagStart {
            nextIndex()
        } else {
            return nil
        }
        
        var tagType: HTMLTagType = .startTag
        var tagName: String?
        var tagAttributes: HTMLAttributes?
        
        if currentCodeUnit == .tagClosing {
            tagType = .endTag
            nextIndex()
        }
        
        if let range = nextRange(of: .tagName) {
            tagName = String(source[range])
        }
        
        if tagName == nil {
            return nil
        }
        
        if !isLastIndex {
            if currentCodeUnit != .anyWhitespace {
                if currentCodeUnit == .tagClosing {
                    nextIndex()
                    if !isLastIndex && currentCodeUnit == .tagEnd {
                        prevIndex()
                    } else {
                        return nil
                    }
                } else if currentCodeUnit != .tagEnd {
                    return nil
                }
            }
        }
        
        if tagType == .endTag {
            nextIndex(while: .anyWhitespace)
            
            if isLastIndex {
                return nil
            }
            
            if currentCodeUnit != .tagEnd || !isSecondLastIndex {
                return nil
            }
        } else {
            
            var attributes = HTMLAttributes()
            
            while index < endIndex {
                guard let _ = nextRange(of: .anyWhitespace), let attrNameRange = nextRange(of: .attributeName) else {
                    break
                }
                
                let attributeName = String(source[attrNameRange]).lowercased()
                var attributeValue: String?
                let mark = index
                
                nextIndex(while: .anyWhitespace)
                
                if currentCodeUnit == .equals {
                    
                    nextIndex()
                    nextIndex(while: .anyWhitespace)
                    
                    if currentCodeUnit == .singleQuote {
                        
                        nextIndex()
                        
                        if let attrValueRange = nextRange(of: .singleQuotedAttributeValue) {
                            attributeValue = String(source[attrValueRange])
                        }
                        
                        nextIndex()
                        
                    } else if currentCodeUnit == .doubleQuote {
                        
                        nextIndex()
                        
                        if let attrValueRange = nextRange(of: .doubleQuotedAttributeValue) {
                            attributeValue = String(source[attrValueRange])
                        }
                        
                        nextIndex()
                        
                    } else {
                        
                        if var attrValueRange = nextRange(of: .unquotedAttributeValue) {
                            if isSecondLastIndex {
                                let i = source.index(before: attrValueRange.upperBound)
                                if source[i].value == .tagClosing {
                                    attrValueRange = attrValueRange.lowerBound..<i
                                }
                            }
                            attributeValue = String(source[attrValueRange])
                        }
                        
                    }
                    
                } else {
                    index = mark
                }
                
                if let attributeValue = attributeValue, let attributeName = HTMLAttributeName(rawValue: attributeName), attributes[attributeName] == nil {
                    switch attributeName {
                    case .class:
                        attributes[attributeName] = HTMLAttributeMultiple(value: split(attributeValue, by: .anyWhitespace))
                    case .id:
                        attributes[attributeName] = HTMLAttributeSingle(value: attributeValue)
                    }
                }
            }
            
            tagAttributes = attributes
            
            nextIndex(until: .tagEnd)
            
            if !isSecondLastIndex {
                return nil
            }
            
            prevIndex()
            
            if currentCodeUnit == .tagClosing {
                tagType = .selfClosingTag
            }
        }
        
        return HTMLTag(type: tagType, tagName: tagName!, attributes: tagAttributes)
    }
    
    private func nextIndex() {
        if index < endIndex {
            index = source.index(after: index)
        }
    }
    
    private func nextIndex(until matching: CodePoint) {
        while index < endIndex {
            if currentCodeUnit == matching {
                break
            }
            index = source.index(after: index)
        }
    }
    
    private func nextIndex(while matching: CodePoint) {
        while index < endIndex {
            if currentCodeUnit != matching {
                break
            }
            index = source.index(after: index)
        }
    }
    
    private func prevIndex() {
        if index > startIndex {
            index = source.index(before: index)
        }
    }
    
    private func nextRange(of matching: CodePoint) -> Range<Source.Index>? {
        let from = index
        while index < endIndex {
            if currentCodeUnit != matching {
                break
            }
            index = source.index(after: index)
        }
        if from == index {
            return nil
        }
        return from..<index
    }
    
    private func split(_ value: String, by: CodePoint) -> Set<String> {
        let source = value.unicodeScalars
        var index = source.startIndex
        var from = index
        let endIndex = source.endIndex
        var components = Set<String>()
        
        while index < endIndex {
            if source[index].value == by {
                if index > from {
                    components.insert(String(source[from..<index]))
                }
                index = source.index(after: index)
                from = index
            } else {
                index = source.index(after: index)
            }
        }
        
        if index > from {
            components.insert(String(source[from..<index]))
        }
        
        return components
    }
}
