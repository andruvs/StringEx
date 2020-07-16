//
//  Array+StringEx.swift
//  StringEx
//
//  Created by Andrey Golovchak on 07/06/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation

extension Array where Element == Range<Int> {
    
    func combinedRanges() -> [Range<Int>] {
        var combined = [Range<Int>]()
        var accumulator: Range<Int>?
        
        let ranges = self.sorted { $0.lowerBound < $1.lowerBound }
        
        for range in ranges {
            if accumulator == nil {
                accumulator = range
            } else if accumulator!.upperBound >= range.lowerBound && accumulator!.upperBound < range.upperBound {
                accumulator = accumulator!.lowerBound..<range.upperBound
            } else if accumulator!.upperBound < range.lowerBound {
                combined.append(accumulator!)
                accumulator = range
            }
        }
        
        if accumulator != nil {
            combined.append(accumulator!)
        }
        
        return combined
    }
}
