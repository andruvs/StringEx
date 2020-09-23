//
//  String+StringEx.swift
//  StringEx
//
//  Created by Andrey Golovchak on 03/07/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation

public extension String {
    
    /// Shorthand method for creating `StringEx` object from string
    var ex: StringEx {
        return StringEx(string: self)
    }
    
}
