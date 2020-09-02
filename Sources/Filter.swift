//
//  Filter.swift
//  StringEx
//
//  Created by Andrey Golovchak on 13/05/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation

/// Filtering options for selector results.
public enum Filter: Hashable {
    
    /// Reduces the set of matched elements to the first in the set.
    case first
        
    /// Reduces the set of matched elements to the last in the set.
    case last
        
    /// Reduces the set of matched elements to the one at the specified index.
    case eq(_ index: Int)
        
    /// Reduces the set of matching items to even ones in the set.
    case even
        
    /// Reduces the set of matching items to odd ones in the set.
    case odd
}
