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
        XCTAssertEqual(HTMLTag(tagName: "a"), HTMLTag(tagName: "a"))
        XCTAssertEqual(HTMLTag(tagName: "a"), HTMLTag(tagName: "A"))
        XCTAssertNotEqual(HTMLTag(tagName: "a"), HTMLTag(tagName: "b"))
    }

}
