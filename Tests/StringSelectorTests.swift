//
//  StringSelectorTests.swift
//  StringExTests
//
//  Created by Andrey Golovchak on 06/08/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import XCTest
@testable import StringEx

class StringSelectorTests: XCTestCase {

    func testHashableUnique() {
        XCTAssertNotEqual(StringSelector.tag("span"), StringSelector.tag("a"))
        XCTAssertEqual(StringSelector.tag("span"), StringSelector.tag("span"))
        XCTAssertNotEqual(StringSelector.tag("span") => .id("1"), StringSelector.tag("span") => .id("2"))
        XCTAssertEqual(StringSelector.tag("span") => .id("1"), StringSelector.tag("span") => .id("1"))
    }

}
