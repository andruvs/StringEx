//
//  HTMLTag.swift
//  StringEx
//
//  Created by Andrey Golovchak on 21/04/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation

class HTMLTag: CustomStringConvertible {
    let tagName: String
    
    var depth: Int?
    var rawRange: Range<Int>?
    var position: Int?
    
    weak var parent: HTMLTagPair?
    
    var length: Int {
        return rawRange?.count ?? 0
    }
    
    var siblingTag: HTMLTag? {
        if self is HTMLStartTag {
            return parent?.endTag
        } else if self is HTMLEndTag {
            return parent?.startTag
        }
        return nil
    }
    
    init(tagName: String) {
        self.tagName = tagName.lowercased()
    }
    
    var description: String {
        return ""
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

class HTMLEndTag: HTMLTag {
    
    override var description: String {
        return "</\(tagName)>"
    }
}

class HTMLStartTag: HTMLTag {
    let attributes: HTMLAttributes?
    
    init(tagName: String, attributes: HTMLAttributes? = nil) {
        self.attributes = attributes
        super.init(tagName: tagName)
    }
    
    override var description: String {
        var str = "<\(tagName)"
        
        if let attributes = attributes {
            for (name, value) in attributes {
                str += " \(name)=\"\(value)\""
            }
        }
        
        str += ">"
        
        return str
    }
}

class HTMLSelfClosingTag: HTMLStartTag {
    
    var startTag: HTMLStartTag {
        return HTMLStartTag(tagName: tagName, attributes: attributes)
    }
    
    var endTag: HTMLEndTag {
        return HTMLEndTag(tagName: tagName)
    }
    
    override var description: String {
        var str = super.description
        str.insert("/", at: str.index(before: str.endIndex))
        return str
    }
}
