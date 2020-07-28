//
//  StringExOperatorsTests.swift
//  StringExTests
//
//  Created by Andrey Golovchak on 21/07/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import XCTest
@testable import StringEx

class StringExOperatorsTests: XCTestCase {

    func testAdditive() {
        XCTAssertEqual("1234567890", ("12345".ex() + "67890".ex()).string)
        XCTAssertEqual("1234567890", ("12345" + "67890".ex()).string)
        XCTAssertEqual("1234567890", ("12345".ex() + "67890").string)
        XCTAssertEqual("1234567890", (NSAttributedString(string: "12345") + "67890".ex()).string)
        XCTAssertEqual("1234567890", ("12345".ex() + NSAttributedString(string: "67890")).string)
    }

}
