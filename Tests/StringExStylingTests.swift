//
//  StringExStylingTests.swift
//  StringExTests
//
//  Created by Andrey Golovchak on 23/07/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import XCTest

class StringExStylingTests: XCTestCase {

    func testExample() {
        let str = NSMutableAttributedString(string: "1234567890")
        
        let p1 = NSMutableParagraphStyle()
        p1.alignment = .natural
        let attr1: [NSAttributedString.Key: Any] = [
            .paragraphStyle: p1
        ]
        
        str.addAttributes(attr1, range: NSRange(location: 4, length: 1))
        
        let p2 = NSMutableParagraphStyle()
        p2.lineSpacing = 2.0
        let attr2: [NSAttributedString.Key: Any] = [
            .paragraphStyle: p2
        ]
        
        //str.addAttributes(attr2, range: NSRange(location: 4, length: 1))
        
        let a = str.attributes(at: 4, effectiveRange: nil)
        print(a)
    }

}
