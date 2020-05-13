//
//  HTMLTagStorage.swift
//  StringEx
//
//  Created by Andrey Golovchak on 06/05/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation

public struct HTMLTagStorage {
    typealias Index = (startTagIndex: Int, endTagIndex: Int)
    
    private(set) var count = 0
    
    private var tags = [HTMLTag]()
    
    private var tagsByName = [String: [Index]]()
    private var tagsByClass = [String: [Index]]()
    private var tagsById = [String: [Index]]()
    
    mutating func add(startTag: HTMLTag, endTag: HTMLTag) {
        if startTag.type == .startTag && endTag.type == .endTag {
            tags.append(startTag)
            tags.append(endTag)
            
            register(tag: startTag, with: (count, count + 1))
            
            count += 2
        }
    }
    
    mutating func add(selfClosingTag tag: HTMLTag) {
        if tag.type == .selfClosingTag {
            tags.append(tag)
            
            register(tag: tag, with: (count, count))
            
            count += 1
        }
    }
    
    private mutating func register(tag: HTMLTag, with index: Index) {
        
        if tagsByName[tag.tagName] == nil {
            tagsByName[tag.tagName] = [Index]()
        }
        tagsByName[tag.tagName]?.append(index)
        
        if tag.attributes?[.id] != nil {
            if let value = (tag.attributes?[.id] as? HTMLAttributeSingle)?.value {
                if tagsById[value] == nil {
                    tagsById[value] = [Index]()
                }
                tagsByName[value]?.append(index)
            }
        }
        
        if tag.attributes?[.class] != nil {
            if let values = (tag.attributes?[.class] as? HTMLAttributeMultiple)?.value {
                for value in values {
                    if tagsByClass[value] == nil {
                        tagsByClass[value] = [Index]()
                    }
                    tagsByClass[value]?.append(index)
                }
            }
        }
    }
}

extension HTMLTagStorage: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        let t = tags.sorted { (t1, t2) -> Bool in
            if let r1 = t1.rawRange?.lowerBound, let r2 = t2.rawRange?.lowerBound {
                if r1 == r2 {
                    if let d1 = t1.depth, let d2 = t2.depth {
                        return d1 < d2
                    }
                    return false
                }
                return r1 < r2
            }
            return false
        }
        let a = t.map{ $0.debugDescription }
        return a.joined(separator: "\n")
    }
}
