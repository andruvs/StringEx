//
//  HTMLTagTests.swift
//  StringExTests
//
//  Created by Andrey Golovchak on 08/05/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import XCTest
@testable import StringEx

class HTMLTagTests: XCTestCase {

    func testEquality() {
        XCTAssertEqual(HTMLTag(type: .startTag, tagName: "a"), HTMLTag(type: .startTag, tagName: "a"))
        XCTAssertEqual(HTMLTag(type: .startTag, tagName: "a"), HTMLTag(type: .startTag, tagName: "A"))
        XCTAssertNotEqual(HTMLTag(type: .startTag, tagName: "a"), HTMLTag(type: .startTag, tagName: "b"))
    }

}
