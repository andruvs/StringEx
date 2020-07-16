//
//  HTMLTagStorage.swift
//  StringEx
//
//  Created by Andrey Golovchak on 06/05/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation

class HTMLTagStorage {
    typealias Iterator = (HTMLTagPair) -> Void
    
    private var tags = [HTMLTag]()
    
    private var tagsByName = [String: [HTMLTagPair]]()
    private var tagsByClass = [String: [HTMLTagPair]]()
    private var tagsById = [String: [HTMLTagPair]]()
    
    private var sorted = false
    
    var count: Int {
        return tags.count
    }
    
    func append(_ tagPair: HTMLTagPair) {
        
        sorted = false
        
        let tag = tagPair.startTag
        
        tags.append(tag)
        tags.append(tagPair.endTag)
        
        if tagsByName[tag.tagName] == nil {
            tagsByName[tag.tagName] = [HTMLTagPair]()
        }
        tagsByName[tag.tagName]?.append(tagPair)
        
        if tag.attributes?[.id] != nil {
            if let value = (tag.attributes?[.id] as? HTMLAttributeSingle)?.value {
                if tagsById[value] == nil {
                    tagsById[value] = [HTMLTagPair]()
                }
                tagsById[value]?.append(tagPair)
            }
        }
        
        if tag.attributes?[.class] != nil {
            if let values = (tag.attributes?[.class] as? HTMLAttributeMultiple)?.value {
                for value in values {
                    if tagsByClass[value] == nil {
                        tagsByClass[value] = [HTMLTagPair]()
                    }
                    tagsByClass[value]?.append(tagPair)
                }
            }
        }
    }
    
    func forEachTag(in tagPair: HTMLTagPair? = nil, closure: ((HTMLTag, Int, Range<Int>) -> Bool)) {
        if !sorted {
            sorted = true
            tags.sort { (tag1, tag2) -> Bool in
                if let offset1 = tag1.rawRange?.lowerBound, let offset2 = tag2.rawRange?.lowerBound {
                    return offset1 < offset2
                }
                return false
            }
        }
        
        if let tagPair = tagPair {
            var fireClosure = false
            for tag in tags {
                if tag === tagPair.endTag {
                    return
                }
                if fireClosure {
                    if let position = tag.position, let range = tag.rawRange {
                        if !closure(tag, position, range) {
                            return
                        }
                    }
                }
                if tag === tagPair.startTag {
                    fireClosure = true
                }
            }
        } else {
            for tag in tags {
                if let position = tag.position, let range = tag.rawRange {
                    if !closure(tag, position, range) {
                        return
                    }
                }
            }
        }
    }
    
    func forEach(tagName: String, closure: Iterator) {
        forEach(tags: tagsByName[tagName], closure: closure)
    }
    
    func forEach(class: String, closure: Iterator) {
        forEach(tags: tagsByClass[`class`], closure: closure)
    }
    
    func forEach(id: String, closure: Iterator) {
        forEach(tags: tagsById[id], closure: closure)
    }
    
    private func forEach(tags: [HTMLTagPair]?, closure: Iterator) {
        if let tags = tags {
            for tagPair in tags {
                closure(tagPair)
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
