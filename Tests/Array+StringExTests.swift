//
//  Array+StringExTests.swift
//  StringExTests
//
//  Created by Andrey Golovchak on 07/06/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import XCTest
@testable import StringEx

class Array_StringExTests: XCTestCase {

    func testRangesCombine() {
        XCTAssertEqual([], [].combinedRanges())
        XCTAssertEqual([0..<0], [0..<0].combinedRanges())
        XCTAssertEqual([0..<5], [0..<0, 0..<5].combinedRanges())
        XCTAssertEqual([0..<5], [1..<5, 0..<5].combinedRanges())
        XCTAssertEqual([0..<0, 6..<11], [0..<0, 6..<7, 7..<11].combinedRanges())
        XCTAssertEqual([1..<6, 7..<11], [1..<6, 7..<11].combinedRanges())
        XCTAssertEqual([1..<6, 7..<11], [1..<3, 2..<6, 8..<10, 7..<11].combinedRanges())
    }

}
