//
//  SelectorResult.swift
//  StringEx
//
//  Created by Andrey Golovchak on 18/05/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation

struct SelectorResult {
    let range: Range<Int>
    let tag: HTMLTagPair?
    
    func contains(_ tagPair: HTMLTagPair) -> Bool {
        if let depth = tag?.depth, let checkDepth = tagPair.depth {
            if checkDepth <= depth {
                return false
            }
        }
        if let checkRange = tagPair.range {
            if checkRange.lowerBound >= range.lowerBound && checkRange.upperBound <= range.upperBound {
                return true
            }
        }
        return false
    }
}
