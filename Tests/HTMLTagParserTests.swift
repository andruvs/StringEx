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
        XCTAssertEqual(.startTag, parseTag(from: "<a>")?.type)
        XCTAssertEqual(.startTag, parseTag(from: "<a >")?.type)
        XCTAssertEqual(.startTag, parseTag(from: "<a   >")?.type)
        XCTAssertEqual(.startTag, parseTag(from: "<a href=\"javascript:void(0);\">")?.type)
        XCTAssertEqual(.startTag, parseTag(from: "<a href=\"javascript:void(0);\" class=\"link\" >")?.type)
        XCTAssertNil(parseTag(from: "< a>"))
    }
    
    func testEndTagParsing() {
        XCTAssertEqual(.endTag, parseTag(from: "</a>")?.type)
        XCTAssertEqual(.endTag, parseTag(from: "</a >")?.type)
        XCTAssertEqual(.endTag, parseTag(from: "</a   >")?.type)
        XCTAssertNil(parseTag(from: "</ a>"))
        XCTAssertNil(parseTag(from: "< /a>"))
    }

    func testSelfClosingTagParsing() {
        XCTAssertEqual(.selfClosingTag, parseTag(from: "<a/>")?.type)
        XCTAssertEqual(.selfClosingTag, parseTag(from: "<a />")?.type)
        XCTAssertEqual(.selfClosingTag, parseTag(from: "<a   />")?.type)
        XCTAssertEqual(.selfClosingTag, parseTag(from: "<a href=\"javascript:void(0);\"/>")?.type)
        XCTAssertEqual(.selfClosingTag, parseTag(from: "<a href=\"javascript:void(0);\" class=\"link\" />")?.type)
        XCTAssertNotEqual(.selfClosingTag, parseTag(from: "<a / >")?.type)
        XCTAssertNil(parseTag(from: "<a/ >"))
        XCTAssertNil(parseTag(from: "< a/>"))
    }
    
    func testTagNameParsing() {
        XCTAssertEqual("button", parseTag(from: "<button>")?.tagName)
        XCTAssertEqual("button123", parseTag(from: "<button123>")?.tagName)
        XCTAssertEqual("button", parseTag(from: "<BUTTON>")?.tagName)
        XCTAssertNil(parseTag(from: "<button!>"))
        XCTAssertNil(parseTag(from: "<but!ton>"))
        XCTAssertNil(parseTag(from: "<кнопка>"))
    }
    
    func testClassAttributeParsing() {
        guard let tag = parseTag(from: "<div class=\"Bold color-red    text\">") else {
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
        guard let tag = parseTag(from: "<div id=\"awesomeTag\">") else {
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
        guard let tag = parseTag(from: "<div id='awesomeTag'>") else {
            XCTFail("Expected a HTMLTag at this point")
            return
        }
        
        XCTAssertEqual("awesomeTag", (tag.attributes?[.id] as? HTMLAttributeSingle)?.value)
    }
    
    func testUnquotedAttributeParsing() {
        guard let tag = parseTag(from: "<div id=awesomeTag>") else {
            XCTFail("Expected a HTMLTag at this point")
            return
        }
        
        XCTAssertEqual("awesomeTag", (tag.attributes?[.id] as? HTMLAttributeSingle)?.value)
    }
    
    func testUnquotedAttributeParsingInSelfClosingTag() {
        guard let tag = parseTag(from: "<div id=awesomeTag/>") else {
            XCTFail("Expected a HTMLTag at this point")
            return
        }
        
        XCTAssertEqual("awesomeTag", (tag.attributes?[.id] as? HTMLAttributeSingle)?.value)
    }
    
    func testAttributeParsingWithoutValue() {
        guard let tag = parseTag(from: "<input type=\"checkbox\" disabled id=\"awesomeTag\" />") else {
            XCTFail("Expected a HTMLTag at this point")
            return
        }
        
        XCTAssertEqual("awesomeTag", (tag.attributes?[.id] as? HTMLAttributeSingle)?.value)
    }

}
