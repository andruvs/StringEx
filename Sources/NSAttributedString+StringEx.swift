//
//  NSAttributedString+StringEx.swift
//  StringEx
//
//  Created by Andrey Golovchak on 21/07/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation

public extension NSAttributedString {
    
    var ex: StringEx {
        return StringEx(attributedString: self)
    }
    
}
