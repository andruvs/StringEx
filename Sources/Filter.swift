//
//  Filter.swift
//  StringEx
//
//  Created by Andrey Golovchak on 13/05/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation

/**
 The list of available filters.
 
 - Tag: Filter
*/
public enum Filter: Hashable {
    
    /// Reduces the set of the selector results to the first in the set.
    case first
        
    /// Reduces the set of the selector results to the last in the set.
    case last
        
    /// Reduces the set of the selector results to the one at the specified index.
    case eq(_ index: Int)
        
    /// Reduces the set of the selector results to even ones in the set.
    case even
        
    /// Reduces the set of the selector results to odd ones in the set.
    case odd
    
    /// Select all selector results at the index greater than index within the set.
    case gt(_ index: Int)
    
    /// Select all selector results at the index less than index within the set.
    case lt(_ index: Int)
}
