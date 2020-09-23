//
//  HTMLAttributeTests.swift
//  StringExTests
//
//  Created by Andrey Golovchak on 11/05/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import XCTest
@testable import StringEx

class HTMLAttributeTests: XCTestCase {
    
    func testAttributeNameCaseInsensitiveInitialization() {
        XCTAssertEqual(.class, HTMLAttributeName(rawValue: "Class"))
        XCTAssertEqual(.id, HTMLAttributeName(rawValue: "ID"))
    }

    func testAttributeNameDescription() {
        XCTAssertEqual("class", "\(HTMLAttributeName.class)")
        XCTAssertEqual("id", "\(HTMLAttributeName.id)")
    }

}
