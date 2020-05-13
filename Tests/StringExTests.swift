//
//  StringExTests.swift
//  StringExTests
//
//  Created by Andrey Golovchak on 29/11/2019.
//  Copyright © 2019 Andrew Golovchak. All rights reserved.
//

import XCTest
@testable import StringEx

class StringExTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        let bundle = Bundle(for: type(of: self))
        guard let fileURL = bundle.url(forResource:"example", withExtension: "htm"), let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            return
        }
        
        self.measure {
            _ = StringEx(string: content)
        }
    }

}
