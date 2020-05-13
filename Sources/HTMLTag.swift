//
//  HTMLTag.swift
//  StringEx
//
//  Created by Andrey Golovchak on 21/04/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation

enum HTMLTagType {
    case startTag
    case endTag
    case selfClosingTag
}

struct HTMLTag {
    let type: HTMLTagType
    let tagName: String
    
    let attributes: HTMLAttributes?
    
    var depth: Int?
    var rawRange: Range<Int>?
    var position: Int?
    
    init(type: HTMLTagType, tagName: String, attributes: HTMLAttributes? = nil) {
        self.type = type
        self.tagName = tagName.lowercased()
        self.attributes = attributes
    }
}

extension HTMLTag: Equatable {
    
    static func == (lhs: HTMLTag, rhs: HTMLTag) -> Bool {
        return lhs.tagName == rhs.tagName
    }
}

extension HTMLTag: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(tagName)
    }
}

extension HTMLTag: CustomStringConvertible {
    
    var description: String {
        var str = "<"
        
        if type == .endTag {
            str += "/"
        }
        
        str += tagName
        
        if let attributes = attributes {
            for (name, value) in attributes {
                str += " \(name)=\"\(value)\""
            }
        }
        
        if type == .selfClosingTag {
            str += " /"
        }
        
        str += ">"
        
        return str
    }
}

extension HTMLTag: CustomDebugStringConvertible {
    
    var debugDescription: String {
        var str = ""
        
        if let depth = depth, depth >= 0 {
            str += String(repeating: ". ", count: depth)
        } else {
            str += "? "
        }
        
        str += self.description
        
        if let rawRange = rawRange {
            str += " [\(rawRange)]"
        } else {
            str += " [nil]"
        }
        
        if let position = position {
            str += ":\(position)"
        } else {
            str += ":nil"
        }
        
        return str
    }
}
