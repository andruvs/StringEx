//
//  HTMLTagPair.swift
//  StringEx
//
//  Created by Andrey Golovchak on 31/05/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation

class HTMLTagPair {
    
    let startTag: HTMLStartTag
    let endTag: HTMLEndTag
    
    var rawRange: Range<Int>? {
        if let lowerBound = startTag.rawRange?.upperBound, let upperBound = endTag.rawRange?.lowerBound {
            return lowerBound..<upperBound
        }
        return nil
    }
    
    var range: Range<Int>? {
        if let startIndex = startTag.position, let endIndex = endTag.position {
            return startIndex..<endIndex
        }
        return nil
    }
    
    var depth: Int? {
        if let depth = startTag.depth {
            return depth
        }
        return nil
    }
    
    init(startTag: HTMLStartTag, endTag: HTMLEndTag) {
        self.startTag = startTag
        self.endTag = endTag
        
        self.startTag.parent = self
        self.endTag.parent = self
    }
}
