//
//  StringEx.swift
//  StringEx
//
//  Created by Andrey Golovchak on 20/04/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation

public struct StringEx {
    
    public private(set) var rawString: String
    public private(set) var string: String
    
    public private(set) var storage: HTMLTagStorage
    
    public init(string: String) {
        let parser = HTMLParser(source: string)
        parser.parse()
        
        rawString = parser.rawString
        self.string = parser.resultString
        storage = parser.storage
        
        //debugPrint(storage)
        
        //print(parser.resultString)
    }
}
