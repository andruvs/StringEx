//
//  RangeConverter.swift
//  StringEx
//
//  Created by Andrey Golovchak on 01/07/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation

public enum RangeConversionMode {
    case inner
    case outer
}

class RangeConverter {
    
    private var storage: HTMLTagStorage
    private var resultStringCount: Int
    private var rawStringCount: Int
    
    private var lowerBound = 0
    private var upperBound = 0
    
    private var lowerBoundFound = false
    private var upperBoundFound = false
    
    private var result: SelectorResult!
    private var resultTagPair: HTMLTagPair!
    private var startTagPosition: Int!
    private var endTagPosition: Int!
    private var rawRange: Range<Int>!
    
    private var mode: RangeConversionMode = .outer
    
    var range: Range<Int>? {
        if lowerBound <= upperBound {
            return lowerBound..<upperBound
        }
        return nil
    }
    
    init(storage: HTMLTagStorage, resultStringCount: Int, rawStringCount: Int) {
        self.storage = storage
        self.resultStringCount = resultStringCount
        self.rawStringCount = rawStringCount
    }
    
    func convert(_ result: SelectorResult, mode: RangeConversionMode) -> Range<Int>? {
        
        self.result = result
        self.mode = mode
        
        if storage.count == 0 {
            return convertExactRange()
        }
        
        lowerBoundFound = false
        upperBoundFound = false
        
        if let resultTagPair = result.tag, let startTagPosition = resultTagPair.startTag.position, let endTagPosition = resultTagPair.endTag.position, let rawRange = resultTagPair.rawRange {
            
            self.resultTagPair = resultTagPair
            self.startTagPosition = startTagPosition
            self.endTagPosition = endTagPosition
            self.rawRange = rawRange
            
            // Empty tag selection <span />: .tag("span")
            if result.range.lowerBound == startTagPosition && result.range.upperBound == endTagPosition && startTagPosition == endTagPosition {
                return convertEmptyTagSelection()
            }
            
            // Entire tag selection: .tag("span")
            if result.range.lowerBound == startTagPosition && result.range.upperBound == endTagPosition {
                return convertEntireSelection(tagPair: resultTagPair)
            }
            
            // Prepend to tag: .tag("span") => .range(0..<0)
            if result.range.lowerBound == startTagPosition && result.range.upperBound == startTagPosition {
                return convertPrepend(tagPair: resultTagPair)
            }
            
            // Append to tag: .tag("span") => .range(Int.max..<Int.max)
            if result.range.lowerBound == endTagPosition && result.range.upperBound == endTagPosition {
                return convertAppend(tagPair: resultTagPair)
            }
            
            // Left side selection: .tag("span") => .range(0..<5)
            if result.range.lowerBound == startTagPosition && result.range.upperBound < endTagPosition {
                return convertLeftSideSelection(tagPair: resultTagPair)
            }
            
            // Right side selection: .tag("span") => .range(5..<Int.max)
            if result.range.lowerBound > startTagPosition && result.range.upperBound == endTagPosition {
                return convertRightSideSelection(tagPair: resultTagPair)
            }
            
            // Insert to tag: .tag("span") => .range(5..<5)
            if result.range.lowerBound > startTagPosition && result.range.upperBound < endTagPosition && result.range.lowerBound == result.range.upperBound {
                return convertInsertion(tagPair: resultTagPair)
            }
            
            // Inner selection: .tag("span") => .range(5..<6)
            if result.range.lowerBound > startTagPosition && result.range.upperBound < endTagPosition {
                return convertSelection(tagPair: resultTagPair)
            }
            
        } else {
            
            // Entire selection
            if result.range.lowerBound == 0 && result.range.upperBound == resultStringCount {
                return convertEntireSelection()
            }
            
            // Prepend
            if result.range.lowerBound == 0 && result.range.upperBound == 0 {
                return convertPrepend()
            }
            
            // Append
            if result.range.lowerBound == resultStringCount && result.range.upperBound == resultStringCount {
                return convertAppend()
            }
            
            // Left side selection
            if result.range.lowerBound == 0 && result.range.upperBound < resultStringCount {
                return convertLeftSideSelection()
            }
            
            // Right side selection
            if result.range.lowerBound > 0 && result.range.upperBound == resultStringCount {
                return convertRightSideSelection()
            }
            
            // Insertion
            if result.range.lowerBound == result.range.upperBound {
                return convertInsertion()
            }
            
            // Inner selection
            return convertSelection()
        }
        
        return nil
    }
}

extension RangeConverter {
    
    private func convertExactRange() -> Range<Int>? {
        return result.range
    }
    
    private func convertEmptyTagSelection() -> Range<Int>? {
        
        lowerBound = rawRange.lowerBound
        upperBound = rawRange.upperBound
        
        if mode == .inner {

            var innerTags = [HTMLTag]()
            
            storage.forEachTag(in: resultTagPair) { (tag, _, _) -> Bool in
                innerTags.append(tag)
                return true
            }
            
            let count = innerTags.count
            if count > 0 {
                for (index, tag) in innerTags.enumerated() {
                    if tag is HTMLStartTag {
                        if let siblingTag = tag.siblingTag, let lowerBound = tag.rawRange?.upperBound, let upperBound = siblingTag.rawRange?.lowerBound {
                            if siblingTag === innerTags[count - index - 1] {
                                self.lowerBound = lowerBound
                                self.upperBound = upperBound
                            } else {
                                break
                            }
                        }
                    } else {
                        break
                    }
                }
            }
        }
        
        return range
    }
    
    private func convertEntireSelection(tagPair: HTMLTagPair? = nil) -> Range<Int>? {
        
        switch mode {
        case .outer:
            
            if tagPair == nil {
                lowerBound = 0
                upperBound = rawStringCount
            } else {
                lowerBound = rawRange.lowerBound
                upperBound = rawRange.upperBound
            }
            
        case .inner:
            
            if tagPair == nil {
                lowerBound = 0
                upperBound = result.range.upperBound
            } else {
                lowerBound = rawRange.lowerBound
                upperBound = lowerBound + result.range.count
            }
            
            storage.forEachTag(in: tagPair) { (tag, position, _) -> Bool in
                
                // Lower bound
                if position == result.range.lowerBound {
                    if let siblingPosition = tag.siblingTag?.position {
                        if siblingPosition > result.range.lowerBound && siblingPosition < result.range.upperBound {
                            lowerBoundFound = true
                        }
                    }
                } else {
                    lowerBoundFound = true
                }

                if !lowerBoundFound {
                    lowerBound += tag.length
                }
                
                // Upper bound
                if position == result.range.upperBound {
                    if let siblingPosition = tag.siblingTag?.position {
                        if siblingPosition == result.range.lowerBound || siblingPosition == result.range.upperBound {
                            upperBoundFound = true
                        }
                    }
                }
                
                if !upperBoundFound {
                    upperBound += tag.length
                }
                
                return !lowerBoundFound || !upperBoundFound
            }
        }
        
        return range
    }
    
    private func convertPrepend(tagPair: HTMLTagPair? = nil) -> Range<Int>? {
        
        if tagPair == nil {
            lowerBound = 0
        } else {
            lowerBound = rawRange.lowerBound
        }
        
        if mode == .inner {
            storage.forEachTag(in: tagPair) { (tag, position, _) -> Bool in
                
                if position == result.range.lowerBound {
                    lowerBound += tag.length
                    return true
                }
                
                return false
            }
        }
        
        upperBound = lowerBound
        
        return range
    }
    
    private func convertAppend(tagPair: HTMLTagPair? = nil) -> Range<Int>? {
        
        if tagPair == nil {
            upperBound = rawStringCount
        } else {
            upperBound = rawRange.upperBound
        }
        
        if mode == .inner {
            storage.forEachTag(in: tagPair) { (tag, position, _) -> Bool in
                
                if position == result.range.upperBound {
                    upperBound -= tag.length
                }

                return true
            }
        }
        
        lowerBound = upperBound
        
        return range
    }
    
    private func convertLeftSideSelection(tagPair: HTMLTagPair? = nil) -> Range<Int>? {
        
        if tagPair == nil {
            lowerBound = 0
            upperBound = result.range.upperBound
        } else {
            lowerBound = rawRange.lowerBound
            upperBound = lowerBound + result.range.count
        }
        
        storage.forEachTag(in: tagPair) { (tag, position, _) -> Bool in
            
            switch mode {
            case .outer:
                
                // Lower bound
                if position == result.range.lowerBound {
                    if let siblingPosition = tag.siblingTag?.position {
                        if siblingPosition >= result.range.lowerBound && siblingPosition <= result.range.upperBound {
                            lowerBoundFound = true
                        }
                    }
                } else {
                    lowerBoundFound = true
                }

                if !lowerBoundFound {
                    lowerBound += tag.length
                }

                // Upper bound
                if position > result.range.upperBound {
                    upperBoundFound = true
                } else if position == result.range.upperBound {
                    if let siblingPosition = tag.siblingTag?.position {
                        if siblingPosition > result.range.upperBound {
                            upperBoundFound = true
                        }
                    }
                }
                if !upperBoundFound {
                    upperBound += tag.length
                }
                
            case .inner:
                
                // Lower bound
                if position == result.range.lowerBound {
                    if let siblingPosition = tag.siblingTag?.position {
                        if siblingPosition > result.range.lowerBound && siblingPosition < result.range.upperBound {
                            lowerBoundFound = true
                        }
                    }
                } else {
                    lowerBoundFound = true
                }

                if !lowerBoundFound {
                    lowerBound += tag.length
                }
                
                // Upper bound
                if position == result.range.upperBound {
                    if let siblingPosition = tag.siblingTag?.position {
                        if siblingPosition <= result.range.lowerBound || siblingPosition >= result.range.upperBound {
                            upperBoundFound = true
                        }
                    }
                } else if position > result.range.upperBound {
                    upperBoundFound = true
                }
                if !upperBoundFound {
                    upperBound += tag.length
                }
                
            }
            
            return !lowerBoundFound || !upperBoundFound
        }
        return range
    }
    
    private func convertRightSideSelection(tagPair: HTMLTagPair? = nil) -> Range<Int>? {
        
        if tagPair == nil {
            lowerBound = result.range.lowerBound
            upperBound = result.range.upperBound
        } else {
            lowerBound = rawRange.lowerBound - startTagPosition + result.range.lowerBound
            upperBound = lowerBound + result.range.count
        }
        
        storage.forEachTag(in: tagPair) { (tag, position, tagRange) -> Bool in

            switch mode {
            case .outer:

                // Lower bound
                if position > result.range.lowerBound {
                    lowerBoundFound = true
                } else if position < result.range.lowerBound {
                    lowerBound += tag.length
                } else if position == result.range.lowerBound {
                    if let siblingPosition = tag.siblingTag?.position {
                        if siblingPosition < result.range.lowerBound {
                            lowerBound = tagRange.upperBound
                        }
                    }
                }

                // Upper bound
                if position == result.range.upperBound {
                    if let siblingPosition = tag.siblingTag?.position {
                        if siblingPosition < result.range.lowerBound {
                            upperBoundFound = true
                        }
                    }
                }
                if !upperBoundFound {
                    upperBound += tag.length
                }
                
            case .inner:
                
                // Lower bound
                if position > result.range.lowerBound {
                    lowerBoundFound = true
                } else if position == result.range.lowerBound {
                    if let siblingPosition = tag.siblingTag?.position {
                        if siblingPosition > result.range.lowerBound && siblingPosition < result.range.upperBound {
                            lowerBoundFound = true
                        }
                    }
                }
                if !lowerBoundFound {
                    lowerBound += tag.length
                }

                // Upper bound
                if position == result.range.upperBound {
                    if let siblingPosition = tag.siblingTag?.position {
                        if siblingPosition == result.range.lowerBound || siblingPosition == result.range.upperBound {
                            upperBoundFound = true
                        }
                    }
                }
                if !upperBoundFound {
                    upperBound += tag.length
                }
            }

            return !lowerBoundFound || !upperBoundFound
        }
        return range
    }
    
    private func convertInsertion(tagPair: HTMLTagPair? = nil) -> Range<Int>? {
        
        if tagPair == nil {
            lowerBound = result.range.lowerBound
        } else {
            lowerBound = rawRange.lowerBound - startTagPosition + result.range.lowerBound
        }
        
        var innerTags = [HTMLTag]()
        
        storage.forEachTag(in: tagPair) { (tag, position, _) -> Bool in
            
            if position == result.range.lowerBound {
                innerTags.append(tag)
            } else if position < result.range.lowerBound {
                lowerBound += tag.length
            } else if position > result.range.lowerBound {
                return false
            }
            
            return true
        }
        
        upperBound = lowerBound
        

        var count = innerTags.count
        if count > 0 {
            
            switch mode {
            case .outer:
                
                for tag in innerTags {
                    if let siblingTag = tag.siblingTag, let siblingPosition = siblingTag.position, let tagRange = tag.rawRange, let siblingRange = siblingTag.rawRange {
                        if siblingPosition < result.range.lowerBound {
                            lowerBound = tagRange.upperBound
                            upperBound = lowerBound
                        } else if siblingPosition > result.range.lowerBound {
                            upperBound = tagRange.lowerBound
                            break
                        } else if siblingPosition == result.range.lowerBound && tag is HTMLStartTag {
                            upperBound = siblingRange.upperBound
                        }
                    }
                }
                
            case .inner:
                
                var index1 = -1
                var index2 = -1
                var index3 = -1
                var index4 = -1
                
                for (index, tag) in innerTags.enumerated() {
                    if let siblingTag = tag.siblingTag, let siblingPosition = siblingTag.position {
                        if siblingPosition < result.range.lowerBound {
                            if index1 < 0 {
                                index1 = index
                            }
                            index2 = index
                        } else if siblingPosition > result.range.lowerBound {
                            if index3 < 0 {
                                index3 = index
                            }
                            index4 = index
                        }
                    }
                }
                
                if index1 == 0 && index2 == (count - 1) && index4 < 0 {
                    if let lowerBound = innerTags[index1].rawRange?.lowerBound {
                        self.lowerBound = lowerBound
                        self.upperBound = lowerBound
                    }
                } else if index4 == (count - 1) && index3 == 0 && index1 < 0 {
                    if let upperBound = innerTags[index4].rawRange?.upperBound {
                        self.lowerBound = upperBound
                        self.upperBound = upperBound
                    }
                } else if index2 >= 0 && index3 >= 0 && index2 == (index3 - 1) {
                    if let upperBound = innerTags[index2].rawRange?.upperBound {
                        self.lowerBound = upperBound
                        self.upperBound = upperBound
                    }
                } else {
                    
                    if index1 >= 0 && index4 < 0 {
                        if index2 == (count - 1) {
                            innerTags = Array(innerTags[0..<index1])
                        } else {
                            innerTags = Array(innerTags[(index2 + 1)..<count])
                        }
                    } else if index4 >= 0 && index1 < 0 {
                        if index3 == 0 {
                            innerTags = Array(innerTags[(index4 + 1)..<count])
                        } else {
                            innerTags = Array(innerTags[0..<index3])
                        }
                    } else if index2 >= 0 && index3 >= 0 {
                        innerTags = Array(innerTags[(index2 + 1)..<index3])
                    }
                    
                    count = innerTags.count
                    
                    for (index, tag) in innerTags.enumerated() {
                        if tag is HTMLStartTag {
                            if let siblingTag = tag.siblingTag, let lowerBound = tag.rawRange?.upperBound, let upperBound = siblingTag.rawRange?.lowerBound {
                                if siblingTag === innerTags[count - index - 1] {
                                    self.lowerBound = lowerBound
                                    self.upperBound = upperBound
                                } else {
                                    break
                                }
                            }
                        } else {
                            break
                        }
                    }
                    
                }
            }
        }
        
        return range
    }
    
    private func convertSelection(tagPair: HTMLTagPair? = nil) -> Range<Int>? {
        
        if tagPair == nil {
            lowerBound = result.range.lowerBound
            upperBound = result.range.upperBound
        } else {
            lowerBound = rawRange.lowerBound - startTagPosition + result.range.lowerBound
            upperBound = lowerBound + result.range.count
        }
        
        storage.forEachTag(in: tagPair) { (tag, position, tagRange) -> Bool in
            
            switch mode {
            case .outer:
                
                // Lower bound
                if position > result.range.lowerBound {
                    lowerBoundFound = true
                } else if position < result.range.lowerBound {
                    lowerBound += tag.length
                } else if position == result.range.lowerBound {
                    if let siblingPosition = tag.siblingTag?.position {
                        if siblingPosition < result.range.lowerBound || siblingPosition > result.range.upperBound {
                            lowerBound = tagRange.upperBound
                        }
                    }
                }

                // Upper bound
                if position > result.range.upperBound {
                    upperBoundFound = true
                } else if position == result.range.upperBound {
                    if let siblingPosition = tag.siblingTag?.position {
                        if siblingPosition < result.range.lowerBound || siblingPosition > result.range.upperBound {
                            upperBoundFound = true
                        }
                    }
                }
                if !upperBoundFound {
                    upperBound += tag.length
                }
                
            case .inner:
                
                // Lower bound
                if position > result.range.lowerBound {
                    lowerBoundFound = true
                } else if position == result.range.lowerBound {
                    if let siblingPosition = tag.siblingTag?.position {
                        if siblingPosition > result.range.lowerBound && siblingPosition < result.range.upperBound {
                            lowerBoundFound = true
                        }
                    }
                }
                if !lowerBoundFound {
                    lowerBound += tag.length
                }
                
                // Upper bound
                if position > result.range.upperBound {
                    upperBoundFound = true
                } else if position == result.range.upperBound {
                    if let siblingPosition = tag.siblingTag?.position {
                        if siblingPosition <= result.range.lowerBound || siblingPosition >= result.range.upperBound {
                            upperBoundFound = true
                        }
                    }
                }
                if !upperBoundFound {
                    upperBound += tag.length
                }
            }
            
            return !lowerBoundFound || !upperBoundFound
        }
        return range
    }
    
}
