//
//  HTMLParserTests.swift
//  StringExTests
//
//  Created by Andrey Golovchak on 13/05/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import XCTest
@testable import StringEx

class HTMLParserTests: XCTestCase {

    func testParsingEmptyString() {
        let parser = HTMLParser(source: "")
        parser.parse()
        XCTAssertEqual("", parser.resultString)
    }

    func testParsingStringWithNoTags() {
        let parser = HTMLParser(source: "Hello, world!")
        parser.parse()
        XCTAssertEqual("Hello, world!", parser.resultString)
    }

    func testRemovalTags() {
        let parser = HTMLParser(source: "<div>Hello</div>, <span>world</span>!")
        parser.parse()
        XCTAssertEqual("Hello, world!", parser.resultString)
    }

    func testInsertingMissingEndTagsAtTheEnd() {
        let parser = HTMLParser(source: "<div>Hello, <span>world<b>!")
        parser.parse()
        XCTAssertEqual("<div>Hello, <span>world<b>!</b></span></div>", parser.rawString)
    }

    func testInsertingMissingEndTagsInTheMiddle() {
        let parser = HTMLParser(source: "<div>Hello, <span>world</div>!")
        parser.parse()
        XCTAssertEqual("<div>Hello, <span>world</span></div>!", parser.rawString)
    }

    func testInsertingMissingStartTags() {
        let parser = HTMLParser(source: "Hello</div>, world!")
        parser.parse()
        XCTAssertEqual("Hello<div></div>, world!", parser.rawString)
    }

    func testCountingTags() {
        let parser = HTMLParser(source: "<div>Hello</div>, <br /><span>world</span>!")
        parser.parse()
        XCTAssertEqual(6, parser.storage.count) // <div> </div> <br> <br /> <span> </span>
    }

}
