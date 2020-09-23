//
//  HTMLTagParserTests.swift
//  StringExTests
//
//  Created by Andrey Golovchak on 08/05/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import XCTest
@testable import StringEx

class HTMLTagParserTests: XCTestCase {
    
    private func parseTag(from source: String) -> HTMLTag? {
        let parser = HTMLTagParser(source: source)
        return parser.parse()
    }
    
    func testMin3SymbolsForTag() {
        XCTAssertNil(parseTag(from: "<a"))
    }
    
    func testOnlyAngleBracketsAtTheEnds() {
        XCTAssertNil(parseTag(from: "span"))
        XCTAssertNil(parseTag(from: "<span"))
        XCTAssertNil(parseTag(from: "<span/"))
        XCTAssertNil(parseTag(from: "</span"))
        XCTAssertNil(parseTag(from: "span>"))
        XCTAssertNil(parseTag(from: " <span>"))
        XCTAssertNil(parseTag(from: "</span> "))
        XCTAssertNotNil(parseTag(from: "<span>"))
    }

    func testStartTagParsing() {
        XCTAssert(parseTag(from: "<a>") is HTMLStartTag)
        XCTAssert(parseTag(from: "<a >") is HTMLStartTag)
        XCTAssert(parseTag(from: "<a   >") is HTMLStartTag)
        XCTAssert(parseTag(from: "<a href=\"javascript:void(0);\">") is HTMLStartTag)
        XCTAssert(parseTag(from: "<a href=\"javascript:void(0);\" class=\"link\" >") is HTMLStartTag)
        XCTAssertNil(parseTag(from: "< a>"))
    }
    
    func testEndTagParsing() {
        XCTAssert(parseTag(from: "</a>") is HTMLEndTag)
        XCTAssert(parseTag(from: "</a >") is HTMLEndTag)
        XCTAssert(parseTag(from: "</a   >") is HTMLEndTag)
        XCTAssertNil(parseTag(from: "</ a>"))
        XCTAssertNil(parseTag(from: "< /a>"))
    }

    func testSelfClosingTagParsing() {
        XCTAssert(parseTag(from: "<a/>") is HTMLSelfClosingTag)
        XCTAssert(parseTag(from: "<a />") is HTMLSelfClosingTag)
        XCTAssert(parseTag(from: "<a   />") is HTMLSelfClosingTag)
        XCTAssert(parseTag(from: "<a href=\"javascript:void(0);\"/>") is HTMLSelfClosingTag)
        XCTAssert(parseTag(from: "<a href=\"javascript:void(0);\" class=\"link\" />") is HTMLSelfClosingTag)
        XCTAssert(!(parseTag(from: "<a / >") is HTMLSelfClosingTag))
        XCTAssertNil(parseTag(from: "<a/ >"))
        XCTAssertNil(parseTag(from: "< a/>"))
    }
    
    func testTagNameParsing() {
        XCTAssertEqual("button", parseTag(from: "<button>")?.tagName ?? "")
        XCTAssertEqual("button123", parseTag(from: "<button123>")?.tagName ?? "")
        XCTAssertEqual("button", parseTag(from: "<BUTTON>")?.tagName ?? "")
        XCTAssertNil(parseTag(from: "<button!>"))
        XCTAssertNil(parseTag(from: "<but!ton>"))
        XCTAssertNil(parseTag(from: "<кнопка>"))
    }
    
    func testClassAttributeParsing() {
        guard let tag = parseTag(from: "<div class=\"Bold color-red    text\">") as? HTMLStartTag else {
            XCTFail("Expected a HTMLTag at this point")
            return
        }

        XCTAssertNotNil(tag.attributes?[.class])
        
        if let attribute = tag.attributes?[.class] as? HTMLAttributeMultiple {
            XCTAssertEqual(3, attribute.value.count)
            XCTAssertTrue(attribute.value.contains("Bold"))
            XCTAssertTrue(attribute.value.contains("color-red"))
            XCTAssertTrue(attribute.value.contains("text"))
        } else {
            XCTFail("Tag attribute `class` is not HTMLAttributeMultiple")
        }
    }
    
    func testIdAttributeParsing() {
        guard let tag = parseTag(from: "<div id=\"awesomeTag\">") as? HTMLStartTag else {
            XCTFail("Expected a HTMLTag at this point")
            return
        }

        XCTAssertNotNil(tag.attributes?[.id])
        
        if let attribute = tag.attributes?[.id] as? HTMLAttributeSingle {
            XCTAssertEqual("awesomeTag", attribute.value)
        } else {
            XCTFail("Tag attribute `id` is not HTMLAttributeSingle")
        }
    }
    
    func testSingleQuotedAttributeParsing() {
        guard let tag = parseTag(from: "<div id='awesomeTag'>") as? HTMLStartTag else {
            XCTFail("Expected a HTMLStartTag at this point")
            return
        }
        
        XCTAssertEqual("awesomeTag", (tag.attributes?[.id] as? HTMLAttributeSingle)?.value)
    }
    
    func testUnquotedAttributeParsing() {
        guard let tag = parseTag(from: "<div id=awesomeTag>") as? HTMLStartTag else {
            XCTFail("Expected a HTMLStartTag at this point")
            return
        }
        
        XCTAssertEqual("awesomeTag", (tag.attributes?[.id] as? HTMLAttributeSingle)?.value)
    }
    
    func testUnquotedAttributeParsingInSelfClosingTag() {
        guard let tag = parseTag(from: "<div id=awesomeTag/>") as? HTMLSelfClosingTag else {
            XCTFail("Expected a HTMLSelfClosingTag at this point")
            return
        }
        
        XCTAssertEqual("awesomeTag", (tag.attributes?[.id] as? HTMLAttributeSingle)?.value)
    }
    
    func testAttributeParsingWithoutValue() {
        guard let tag = parseTag(from: "<input type=\"checkbox\" disabled id=\"awesomeTag\" />") as? HTMLSelfClosingTag else {
            XCTFail("Expected a HTMLSelfClosingTag at this point")
            return
        }
        
        XCTAssertEqual("awesomeTag", (tag.attributes?[.id] as? HTMLAttributeSingle)?.value)
    }

}
