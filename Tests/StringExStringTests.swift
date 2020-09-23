//
//  StringExTests.swift
//  StringExTests
//
//  Created by Andrey Golovchak on 29/11/2019.
//  Copyright © 2019 Andrew Golovchak. All rights reserved.
//

import XCTest
@testable import StringEx

class StringExStringTests: XCTestCase {

    func getString(_ str: String, _ sel: StringSelector) -> String {
        return str.ex[sel].selectedString
    }

    func getReplacedRawString(_ str: String, _ sel: StringSelector, _ mode: RangeConversionMode) -> String {
        return str.ex[sel].replace(with: "_", mode: mode).rawString
    }
    
    func testSelectAll() {
        XCTAssertEqual("1234567890", getString("1234567890", .all))
        XCTAssertEqual("12345", getString("<a>12345</a>67890", .tag("a") => .all))
        XCTAssertEqual("12🐶34567890", getString("12🐶34567890", .all))
        XCTAssertEqual("45", getString("12🐶3<a>45</a>67890", .tag("a") => .all))
    }
    
    func testSelectTag() {
        XCTAssertEqual("5", getString("1234<a>5</a>67890", .tag("a")))
        XCTAssertEqual("5", getString("<a>1234<b>5</b></a>67890", .tag("b")))
        XCTAssertEqual("5", getString("1234<a><b>5</b></a>67890", .tag("a")))
        XCTAssertEqual("", getString("12345678<a/>90", .tag("a")))
        XCTAssertEqual("150", getString("<a>1</a>234<a>5</a>6789<a>0</a>", .tag("a")))
        XCTAssertEqual("345", getString("12<a>34<a>5</a></a>67890", .tag("a")))
        XCTAssertEqual("34🐶5🐶", getString("12🐶<a>34🐶<a>5🐶</a></a>67890", .tag("a")))
    }
    
    func testSelectTagByClass() {
        XCTAssertEqual("5", getString("1234<a class=\"test\">5</a>67890", .class("test")))
        XCTAssertEqual("5", getString("<a>1234<b class=\"test\">5</b></a>67890", .class("test")))
        XCTAssertEqual("5", getString("1234<a class=\"test\"><b>5</b></a>67890", .class("test")))
        XCTAssertEqual("", getString("12345678<a class=\"test\" />90", .class("test")))
        XCTAssertEqual("150", getString("<a class=\"test\">1</a>234<a class=\"test\">5</a>6789<a class=\"test\">0</a>", .class("test")))
        XCTAssertEqual("345", getString("12<a class=\"test\">34<a class=\"test\">5</a></a>67890", .class("test")))
        XCTAssertEqual("34🐶5🐶", getString("12🐶<a class=\"test\">34🐶<a class=\"test\">5🐶</a></a>67890", .class("test")))
    }
    
    func testSelectTagById() {
        XCTAssertEqual("5", getString("1234<a id=\"test\">5</a>67890", .id("test")))
        XCTAssertEqual("5", getString("<a>1234<b id=\"test\">5</b></a>67890", .id("test")))
        XCTAssertEqual("5", getString("1234<a id=\"test\"><b>5</b></a>67890", .id("test")))
        XCTAssertEqual("", getString("12345678<a id=\"test\" />90", .id("test")))
        XCTAssertEqual("150", getString("<a id=\"test\">1</a>234<a id=\"test\">5</a>6789<a id=\"test\">0</a>", .id("test")))
        XCTAssertEqual("345", getString("12<a id=\"test\">34<a id=\"test\">5</a></a>67890", .id("test")))
        XCTAssertEqual("34🐶5🐶", getString("12🐶<a id=\"test\">34🐶<a id=\"test\">5🐶</a></a>67890", .id("test")))
    }
    
    func testSelectStringCaseInsensitive() {
        XCTAssertEqual("HellohelloHELLOhello", getString("Hello, World! hello, world!HELLOhello", .string("HeLLo")))
        XCTAssertEqual("aAaA", getString("aAaA", .string("a")))
        XCTAssertEqual("🐶🐶", getString("1🐶2345🐶67890", .string("🐶")))
        XCTAssertEqual("Hello, World!", getString("text text <span>text🐶 Hello, World!</span> text hello, world! text", .tag("span") => .string("hello, world!")))
    }
    
    func testSelectStringCaseSensitive() {
        XCTAssertEqual("hellohello", getString("Hello, World! hello, world!HELLOhello", .string("hello", caseInsensitive: false)))
        XCTAssertEqual("aa", getString("aAaA", .string("a", caseInsensitive: false)))
    }
    
    func testSelectRegex() {
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        XCTAssertEqual("test@domain.com", getString("🐶Test E-mail: test@domain.com!", .regex(emailPattern)))
        XCTAssertEqual("test@domain.comtest2@domain.ru", getString("🐶Test E-mail: test@domain.com and test2@domain.ru", .regex(emailPattern)))
        XCTAssertEqual("test@domain.com", getString("🐶<span>The first E-mail🐶: test@domain.com</span>, the second Email: test2@domain.ru", .tag("span") => .regex(emailPattern)))
    }
    
    func testSelectRange() {
        XCTAssertEqual("456", getString("1234567890", .range(3..<6)))
        XCTAssertEqual("456", getString("1234<a>5</a>67890", .range(3..<6)))
        XCTAssertEqual("67890", getString("1234567890", .range(5..<Int.max)))
        XCTAssertEqual("45🐶", getString("12345🐶67890", .range(3..<6)))
        XCTAssertEqual("45🐶", getString("1🐶2345🐶67890", .range(4..<7)))
    }
    
    func testSelectUnion() {
        XCTAssertEqual("1390", getString("1234567890", .range(0..<1) + .range(2..<3) + .range(8..<Int.max)))
        XCTAssertEqual("13", getString("1234567890", .range(2..<3) + .range(0..<1)))
        XCTAssertEqual("1234567", getString("1234567890", .range(0..<5) + .range(3..<7)))
    }
    
    func testSelectChain() {
        XCTAssertEqual("4", getString("1234567890", .range(2..<6) => .range(1..<2)))
        XCTAssertEqual("56", getString("1234567890", .range(2..<6) => .all => .range(2..<Int.max)))
        XCTAssertEqual("56", getString("12<a>3456</a>7890", .tag("a") => .range(2..<Int.max)))
        XCTAssertEqual("6", getString("1<a>2</a>345<a>6</a>7890", .range(3..<Int.max) => .tag("a")))
        XCTAssertEqual("", getString("<span>Hello</span>, <em>World</em>!", .range(5..<Int.max) => .tag("span")))
    }
    
    func testSelectOrder() {
        XCTAssertEqual("125", getString("1234567890", .range(0..<2) + .range(3..<6) => .range(1..<2)))
        XCTAssertEqual("25", getString("1234567890", (.range(0..<2) + .range(3..<6)) => .range(1..<2)))
        XCTAssertEqual("HelloW", getString("<span><b>Hello</b></span>, <em><b>World</b></em>!", .tag("span") + .tag("em") => .range(0..<1)))
        XCTAssertEqual("HW", getString("<span><b>Hello</b></span>, <em><b>World</b></em>!", (.tag("span") + .tag("em")) => .range(0..<1)))
        XCTAssertEqual("Hello", getString("<span><b>Hello</b></span>, <em><b>World</b></em>!", .tag("span") => .tag("b") % .last))
        XCTAssertEqual("", getString("<span><b>Hello</b></span>, <em><b>World</b></em>!", .tag("span") => (.tag("b") % .last)))
        XCTAssertEqual("Hello", getString("<span><b>Hello</b></span>, <em><b>World</b></em>!", .tag("span") => (.tag("b") % .first)))
    }
    
    func testReplaceNoTags() {
        XCTAssertEqual("_", getReplacedRawString("", .all, .outer))
        XCTAssertEqual("_", getReplacedRawString("1234567890", .all, .outer))
        XCTAssertEqual("_", getReplacedRawString("1234567890", .range(0..<Int.max), .outer))
        XCTAssertEqual("_1234567890", getReplacedRawString("1234567890", .range(0..<0), .outer))
        XCTAssertEqual("1234567890_", getReplacedRawString("1234567890", .range(Int.max..<Int.max), .outer))
        XCTAssertEqual("_34567890", getReplacedRawString("1234567890", .range(0..<2), .outer))
        XCTAssertEqual("12345678_", getReplacedRawString("1234567890", .range(8..<Int.max), .outer))
        XCTAssertEqual("123_67890", getReplacedRawString("1234567890", .range(3..<5), .outer))
        XCTAssertEqual("1234567890", getReplacedRawString("1234567890", .tag("a"), .outer))
    }
    
    func testReplaceEmptyTagSelection() {
        let sel: StringSelector = .tag("a")
        
        XCTAssertEqual("<a>_</a>", getReplacedRawString("<a/>", sel, .outer))
        XCTAssertEqual("<a>_</a>", getReplacedRawString("<a/>", sel, .inner))
        XCTAssertEqual("<a>_</a>", getReplacedRawString("<a><b/></a>", sel, .outer))
        XCTAssertEqual("<a><b>_</b></a>", getReplacedRawString("<a><b/></a>", sel, .inner))
        XCTAssertEqual("<a>_</a>", getReplacedRawString("<a><b><c/><d/></b></a>", sel, .outer))
        XCTAssertEqual("<a><b>_</b></a>", getReplacedRawString("<a><b><c/><d/></b></a>", sel, .inner))
        XCTAssertEqual("1234<a>_</a>67890", getReplacedRawString("1234<a/>67890", sel, .outer))
    }
    
    func testReplaceEntireTagSelection() {
        let sel: StringSelector = .tag("a")
        
        XCTAssertEqual("<a>_</a>", getReplacedRawString("<a>1234567890</a>", sel, .outer))
        XCTAssertEqual("<a>_</a>", getReplacedRawString("<a>1234567890</a>", sel, .inner))
        XCTAssertEqual("<a>_</a>", getReplacedRawString("<a><b>1234567890</b></a>", sel, .outer))
        XCTAssertEqual("<a><b>_</b></a>", getReplacedRawString("<a><b>1234567890</b></a>", sel, .inner))
        XCTAssertEqual("<a>_</a>", getReplacedRawString("<a><b/>1234567890<c/></a>", sel, .outer))
        XCTAssertEqual("<a><b></b>_<c></c></a>", getReplacedRawString("<a><b/>1234567890<c/></a>", sel, .inner))
        XCTAssertEqual("<a>_</a>", getReplacedRawString("<a><b>1</b>23456789<c>0</c></a>", sel, .outer))
        XCTAssertEqual("<a>_</a>", getReplacedRawString("<a><b>1</b>23456789<c>0</c></a>", sel, .inner))
        XCTAssertEqual("<a>_</a>", getReplacedRawString("<a><b>1234567890<c/></b></a>", sel, .outer))
        XCTAssertEqual("<a><b>_<c></c></b></a>", getReplacedRawString("<a><b>1234567890<c/></b></a>", sel, .inner))
    }
    
    func testReplacePrependToTag() {
        let sel: StringSelector = .tag("a") => .range(0..<0)
        
        XCTAssertEqual("<a>_1234567890</a>", getReplacedRawString("<a>1234567890</a>", sel, .outer))
        XCTAssertEqual("<a>_1234567890</a>", getReplacedRawString("<a>1234567890</a>", sel, .inner))
        XCTAssertEqual("<a>_<b>1234567890</b></a>", getReplacedRawString("<a><b>1234567890</b></a>", sel, .outer))
        XCTAssertEqual("<a><b>_1234567890</b></a>", getReplacedRawString("<a><b>1234567890</b></a>", sel, .inner))
        XCTAssertEqual("<a>_<b></b><c></c>1234567890</a>", getReplacedRawString("<a><b/><c/>1234567890</a>", sel, .outer))
        XCTAssertEqual("<a><b></b><c></c>_1234567890</a>", getReplacedRawString("<a><b/><c/>1234567890</a>", sel, .inner))
        XCTAssertEqual("<a>_<b><c></c>1234567890</b></a>", getReplacedRawString("<a><b><c/>1234567890</b></a>", sel, .outer))
        XCTAssertEqual("<a><b><c></c>_1234567890</b></a>", getReplacedRawString("<a><b><c/>1234567890</b></a>", sel, .inner))
    }
    
    func testReplaceAppendToTag() {
        let sel: StringSelector = .tag("a") => .range(Int.max..<Int.max)
        
        XCTAssertEqual("<a>1234567890_</a>", getReplacedRawString("<a>1234567890</a>", sel, .outer))
        XCTAssertEqual("<a>1234567890_</a>", getReplacedRawString("<a>1234567890</a>", sel, .inner))
        XCTAssertEqual("<a><b>1234567890</b>_</a>", getReplacedRawString("<a><b>1234567890</b></a>", sel, .outer))
        XCTAssertEqual("<a><b>1234567890_</b></a>", getReplacedRawString("<a><b>1234567890</b></a>", sel, .inner))
        XCTAssertEqual("<a>1234567890<b></b><c></c>_</a>", getReplacedRawString("<a>1234567890<b/><c/></a>", sel, .outer))
        XCTAssertEqual("<a>1234567890_<b></b><c></c></a>", getReplacedRawString("<a>1234567890<b/><c/></a>", sel, .inner))
        XCTAssertEqual("<a><b>1234567890<c></c></b>_</a>", getReplacedRawString("<a><b>1234567890<c/></b></a>", sel, .outer))
        XCTAssertEqual("<a><b>1234567890_<c></c></b></a>", getReplacedRawString("<a><b>1234567890<c/></b></a>", sel, .inner))
    }
    
    func testReplaceLeftSideTagSelection() {
        let sel: StringSelector = .tag("a") => .range(0..<5)
        
        XCTAssertEqual("<a>_67890</a>", getReplacedRawString("<a>1234567890</a>", sel, .outer))
        XCTAssertEqual("<a>_67890</a>", getReplacedRawString("<a>1234567890</a>", sel, .inner))
        XCTAssertEqual("<a><b>_67890</b></a>", getReplacedRawString("<a><b>1234567890</b></a>", sel, .outer))
        XCTAssertEqual("<a><b>_67890</b></a>", getReplacedRawString("<a><b>1234567890</b></a>", sel, .inner))
        XCTAssertEqual("<a><b>_67890</b></a>", getReplacedRawString("<a><b><c/>1234567890</b></a>", sel, .outer))
        XCTAssertEqual("<a><b><c></c>_67890</b></a>", getReplacedRawString("<a><b><c/>1234567890</b></a>", sel, .inner))
        XCTAssertEqual("<a>_67890</a>", getReplacedRawString("<a><b>12345</b>67890</a>", sel, .outer))
        XCTAssertEqual("<a><b>_</b>67890</a>", getReplacedRawString("<a><b>12345</b>67890</a>", sel, .inner))
        XCTAssertEqual("<a>_67890</a>", getReplacedRawString("<a><b>12345</b><c/>67890</a>", sel, .outer))
        XCTAssertEqual("<a><b>_</b><c></c>67890</a>", getReplacedRawString("<a><b>12345</b><c/>67890</a>", sel, .inner))
        XCTAssertEqual("<a>_<c>6</c>7890</a>", getReplacedRawString("<a><b>12345</b><c>6</c>7890</a>", sel, .outer))
        XCTAssertEqual("<a><b>_</b><c>6</c>7890</a>", getReplacedRawString("<a><b>12345</b><c>6</c>7890</a>", sel, .inner))
        XCTAssertEqual("<a>_67890</a>", getReplacedRawString("<a><b><c>123</c>45</b>67890</a>", sel, .outer))
        XCTAssertEqual("<a><b>_</b>67890</a>", getReplacedRawString("<a><b><c>123</c>45</b>67890</a>", sel, .inner))
        XCTAssertEqual("<a>_67890</a>", getReplacedRawString("<a><b>123</b>4567890</a>", sel, .outer))
        XCTAssertEqual("<a>_67890</a>", getReplacedRawString("<a><b>123</b>4567890</a>", sel, .inner))
        XCTAssertEqual("<a>_<b>6</b>7890</a>", getReplacedRawString("<a>12345<b>6</b>7890</a>", sel, .outer))
        XCTAssertEqual("<a>_<b>6</b>7890</a>", getReplacedRawString("<a>12345<b>6</b>7890</a>", sel, .inner))
        XCTAssertEqual("<a><b>_6</b>7890</a>", getReplacedRawString("<a><b>123456</b>7890</a>", sel, .outer))
        XCTAssertEqual("<a><b>_6</b>7890</a>", getReplacedRawString("<a><b>123456</b>7890</a>", sel, .inner))
    }
    
    func testReplaceRightSideTagSelection() {
        let sel: StringSelector = .tag("a") => .range(5..<Int.max)
        
        XCTAssertEqual("<a>12345_</a>", getReplacedRawString("<a>1234567890</a>", sel, .outer))
        XCTAssertEqual("<a>12345_</a>", getReplacedRawString("<a>1234567890</a>", sel, .inner))
        XCTAssertEqual("<a><b>12345_</b></a>", getReplacedRawString("<a><b>1234567890</b></a>", sel, .outer))
        XCTAssertEqual("<a><b>12345_</b></a>", getReplacedRawString("<a><b>1234567890</b></a>", sel, .inner))
        XCTAssertEqual("<a><b>12345_</b></a>", getReplacedRawString("<a><b>1234567890<c/></b></a>", sel, .outer))
        XCTAssertEqual("<a><b>12345_<c></c></b></a>", getReplacedRawString("<a><b>1234567890<c/></b></a>", sel, .inner))
        XCTAssertEqual("<a>12345_</a>", getReplacedRawString("<a>12345<b>67890</b></a>", sel, .outer))
        XCTAssertEqual("<a>12345<b>_</b></a>", getReplacedRawString("<a>12345<b>67890</b></a>", sel, .inner))
        XCTAssertEqual("<a>12345_</a>", getReplacedRawString("<a>12345<c/><b>67890</b></a>", sel, .outer))
        XCTAssertEqual("<a>12345<c></c><b>_</b></a>", getReplacedRawString("<a>12345<c/><b>67890</b></a>", sel, .inner))
        XCTAssertEqual("<a>1234<c>5</c>_</a>", getReplacedRawString("<a>1234<c>5</c><b>67890</b></a>", sel, .outer))
        XCTAssertEqual("<a>1234<c>5</c><b>_</b></a>", getReplacedRawString("<a>1234<c>5</c><b>67890</b></a>", sel, .inner))
        XCTAssertEqual("<a>12345_</a>", getReplacedRawString("<a>12345<b>67<c>890</c></b></a>", sel, .outer))
        XCTAssertEqual("<a>12345<b>_</b></a>", getReplacedRawString("<a>12345<b>67<c>890</c></b></a>", sel, .inner))
        XCTAssertEqual("<a>12345_</a>", getReplacedRawString("<a>1234567<b>890</b></a>", sel, .outer))
        XCTAssertEqual("<a>12345_</a>", getReplacedRawString("<a>1234567<b>890</b></a>", sel, .inner))
        XCTAssertEqual("<a>1234<b>5</b>_</a>", getReplacedRawString("<a>1234<b>5</b>67890</a>", sel, .outer))
        XCTAssertEqual("<a>1234<b>5</b>_</a>", getReplacedRawString("<a>1234<b>5</b>67890</a>", sel, .inner))
        XCTAssertEqual("<a>1234<b>5_</b></a>", getReplacedRawString("<a>1234<b>567890</b></a>", sel, .outer))
        XCTAssertEqual("<a>1234<b>5_</b></a>", getReplacedRawString("<a>1234<b>567890</b></a>", sel, .inner))
        XCTAssertEqual("<a><b>12345<c></c></b>_</a>", getReplacedRawString("<a><b>12345<c/></b><d>67890</d></a>", sel, .outer))
        XCTAssertEqual("<a><b>12345<c></c></b><d>_</d></a>", getReplacedRawString("<a><b>12345<c/></b><d>67890</d></a>", sel, .inner))
    }
    
    func testReplaceInsertToTag() {
        let sel: StringSelector = .tag("a") => .range(5..<5)
        
        XCTAssertEqual("<a>12345_67890</a>", getReplacedRawString("<a>1234567890</a>", sel, .outer))
        XCTAssertEqual("<a>12345_67890</a>", getReplacedRawString("<a>1234567890</a>", sel, .inner))
        XCTAssertEqual("<a><b>12345</b>_67890</a>", getReplacedRawString("<a><b>12345</b>67890</a>", sel, .outer))
        XCTAssertEqual("<a><b>12345_</b>67890</a>", getReplacedRawString("<a><b>12345</b>67890</a>", sel, .inner))
        XCTAssertEqual("<a>12345_<b>67890</b></a>", getReplacedRawString("<a>12345<b>67890</b></a>", sel, .outer))
        XCTAssertEqual("<a>12345<b>_67890</b></a>", getReplacedRawString("<a>12345<b>67890</b></a>", sel, .inner))
        XCTAssertEqual("<a><b>12345<c></c></b>_67890</a>", getReplacedRawString("<a><b>12345<c/></b>67890</a>", sel, .outer))
        XCTAssertEqual("<a><b>12345<c>_</c></b>67890</a>", getReplacedRawString("<a><b>12345<c/></b>67890</a>", sel, .inner))
        XCTAssertEqual("<a>12345_<b><c></c>67890</b></a>", getReplacedRawString("<a>12345<b><c/>67890</b></a>", sel, .outer))
        XCTAssertEqual("<a>12345<b><c>_</c>67890</b></a>", getReplacedRawString("<a>12345<b><c/>67890</b></a>", sel, .inner))
        XCTAssertEqual("<a><b>12345</b>_<c>67890</c></a>", getReplacedRawString("<a><b>12345</b><c>67890</c></a>", sel, .outer))
        XCTAssertEqual("<a><b>12345</b>_<c>67890</c></a>", getReplacedRawString("<a><b>12345</b><c>67890</c></a>", sel, .inner))
        XCTAssertEqual("<a><b>12345<d></d></b>_<c><e></e>67890</c></a>", getReplacedRawString("<a><b>12345<d/></b><c><e/>67890</c></a>", sel, .outer))
        XCTAssertEqual("<a><b>12345<d></d></b>_<c><e></e>67890</c></a>", getReplacedRawString("<a><b>12345<d/></b><c><e/>67890</c></a>", sel, .inner))
        XCTAssertEqual("<a><b><d>12345</d></b>_<c><e>67890</e></c></a>", getReplacedRawString("<a><b><d>12345</d></b><c><e>67890</e></c></a>", sel, .outer))
        XCTAssertEqual("<a><b><d>12345</d></b>_<c><e>67890</e></c></a>", getReplacedRawString("<a><b><d>12345</d></b><c><e>67890</e></c></a>", sel, .inner))
        XCTAssertEqual("<a>12345_67890</a>", getReplacedRawString("<a>12345<b/>67890</a>", sel, .outer))
        XCTAssertEqual("<a>12345<b>_</b>67890</a>", getReplacedRawString("<a>12345<b/>67890</a>", sel, .inner))
        XCTAssertEqual("<a><b>12345</b>_67890</a>", getReplacedRawString("<a><b>12345</b><c/>67890</a>", sel, .outer))
        XCTAssertEqual("<a><b>12345</b><c>_</c>67890</a>", getReplacedRawString("<a><b>12345</b><c/>67890</a>", sel, .inner))
        XCTAssertEqual("<a>12345_<b>67890</b></a>", getReplacedRawString("<a>12345<c/><b>67890</b></a>", sel, .outer))
        XCTAssertEqual("<a>12345<c>_</c><b>67890</b></a>", getReplacedRawString("<a>12345<c/><b>67890</b></a>", sel, .inner))
        XCTAssertEqual("<a><b>12345</b>_<c>67890</c></a>", getReplacedRawString("<a><b>12345</b><d><e/><f/></d><c>67890</c></a>", sel, .outer))
        XCTAssertEqual("<a><b>12345</b><d>_</d><c>67890</c></a>", getReplacedRawString("<a><b>12345</b><d><e/><f/></d><c>67890</c></a>", sel, .inner))
    }
    
    func testReplaceTagSelection() {
        let sel: StringSelector = .tag("a") => .range(4..<6)
        
        XCTAssertEqual("<a>1234_7890</a>", getReplacedRawString("<a>1234567890</a>", sel, .outer))
        XCTAssertEqual("<a>1234_7890</a>", getReplacedRawString("<a>1234567890</a>", sel, .inner))
        XCTAssertEqual("<a>1234_7890</a>", getReplacedRawString("<a>1234<b>56</b>7890</a>", sel, .outer))
        XCTAssertEqual("<a>1234<b>_</b>7890</a>", getReplacedRawString("<a>1234<b>56</b>7890</a>", sel, .inner))
        XCTAssertEqual("<a>1234_7890</a>", getReplacedRawString("<a>1234<b>5<c/>6</b>7890</a>", sel, .outer))
        XCTAssertEqual("<a>1234<b>_</b>7890</a>", getReplacedRawString("<a>1234<b>5<c/>6</b>7890</a>", sel, .inner))
        XCTAssertEqual("<a>1234<b>_78</b>90</a>", getReplacedRawString("<a>1234<b><c>56</c>78</b>90</a>", sel, .outer))
        XCTAssertEqual("<a>1234<b><c>_</c>78</b>90</a>", getReplacedRawString("<a>1234<b><c>56</c>78</b>90</a>", sel, .inner))
        XCTAssertEqual("<a>1234<b>_78</b>90</a>", getReplacedRawString("<a>1234<b>5678</b>90</a>", sel, .outer))
        XCTAssertEqual("<a>1234<b>_78</b>90</a>", getReplacedRawString("<a>1234<b>5678</b>90</a>", sel, .inner))
        XCTAssertEqual("<a>12<b>34_</b>7890</a>", getReplacedRawString("<a>12<b>3456</b>7890</a>", sel, .outer))
        XCTAssertEqual("<a>12<b>34_</b>7890</a>", getReplacedRawString("<a>12<b>3456</b>7890</a>", sel, .inner))
        XCTAssertEqual("<a>12<b>34_78</b>90</a>", getReplacedRawString("<a>12<b>345678</b>90</a>", sel, .outer))
        XCTAssertEqual("<a>12<b>34_78</b>90</a>", getReplacedRawString("<a>12<b>345678</b>90</a>", sel, .inner))
        XCTAssertEqual("<a>1234_78<b></b>90</a>", getReplacedRawString("<a>12345<b>678</b>90</a>", sel, .outer))
        XCTAssertEqual("<a>1234_78<b></b>90</a>", getReplacedRawString("<a>12345<b>678</b>90</a>", sel, .inner))
        XCTAssertEqual("<a>12<b>34_7890</b></a>", getReplacedRawString("<a>12<b>345</b>67890</a>", sel, .outer))
        XCTAssertEqual("<a>12<b>34_7890</b></a>", getReplacedRawString("<a>12<b>345</b>67890</a>", sel, .inner))
        XCTAssertEqual("<a>1234<b></b><c>_78</c>90</a>", getReplacedRawString("<a>1234<b/><c>5678</c>90</a>", sel, .outer))
        XCTAssertEqual("<a>1234<b></b><c>_78</c>90</a>", getReplacedRawString("<a>1234<b/><c>5678</c>90</a>", sel, .inner))
        XCTAssertEqual("<a>1234<b></b><c>_78</c>90</a>", getReplacedRawString("<a>1234<b/><c><d>56</d>78</c>90</a>", sel, .outer))
        XCTAssertEqual("<a>1234<b></b><c><d>_</d>78</c>90</a>", getReplacedRawString("<a>1234<b/><c><d>56</d>78</c>90</a>", sel, .inner))
    }
    
    func testReplaceEntireSelection() {
        let sel: StringSelector = .range(0..<Int.max)
        
        XCTAssertEqual("_", getReplacedRawString("1234567890", sel, .outer))
        XCTAssertEqual("_", getReplacedRawString("1234567890", sel, .inner))
        XCTAssertEqual("_", getReplacedRawString("<b>1234567890</b>", sel, .outer))
        XCTAssertEqual("<b>_</b>", getReplacedRawString("<b>1234567890</b>", sel, .inner))
        XCTAssertEqual("_", getReplacedRawString("<b/>1234567890<c/>", sel, .outer))
        XCTAssertEqual("<b></b>_<c></c>", getReplacedRawString("<b/>1234567890<c/>", sel, .inner))
        XCTAssertEqual("_", getReplacedRawString("<b>1</b>23456789<c>0</c>", sel, .outer))
        XCTAssertEqual("_", getReplacedRawString("<b>1</b>23456789<c>0</c>", sel, .inner))
        XCTAssertEqual("_", getReplacedRawString("<b>1234567890<c/></b>", sel, .outer))
        XCTAssertEqual("<b>_<c></c></b>", getReplacedRawString("<b>1234567890<c/></b>", sel, .inner))
    }
    
    func testReplacePrepend() {
        let sel: StringSelector = .range(0..<0)
        
        XCTAssertEqual("_1234567890", getReplacedRawString("1234567890", sel, .outer))
        XCTAssertEqual("_1234567890", getReplacedRawString("1234567890", sel, .inner))
        XCTAssertEqual("_<b>1234567890</b>", getReplacedRawString("<b>1234567890</b>", sel, .outer))
        XCTAssertEqual("<b>_1234567890</b>", getReplacedRawString("<b>1234567890</b>", sel, .inner))
        XCTAssertEqual("_<b></b><c></c>1234567890", getReplacedRawString("<b/><c/>1234567890", sel, .outer))
        XCTAssertEqual("<b></b><c></c>_1234567890", getReplacedRawString("<b/><c/>1234567890", sel, .inner))
        XCTAssertEqual("_<b><c></c>1234567890</b>", getReplacedRawString("<b><c/>1234567890</b>", sel, .outer))
        XCTAssertEqual("<b><c></c>_1234567890</b>", getReplacedRawString("<b><c/>1234567890</b>", sel, .inner))
    }
    
    func testReplaceAppend() {
        let sel: StringSelector = .range(Int.max..<Int.max)
        
        XCTAssertEqual("1234567890_", getReplacedRawString("1234567890", sel, .outer))
        XCTAssertEqual("1234567890_", getReplacedRawString("1234567890", sel, .inner))
        XCTAssertEqual("<b>1234567890</b>_", getReplacedRawString("<b>1234567890</b>", sel, .outer))
        XCTAssertEqual("<b>1234567890_</b>", getReplacedRawString("<b>1234567890</b>", sel, .inner))
        XCTAssertEqual("1234567890<b></b><c></c>_", getReplacedRawString("1234567890<b/><c/>", sel, .outer))
        XCTAssertEqual("1234567890_<b></b><c></c>", getReplacedRawString("1234567890<b/><c/>", sel, .inner))
        XCTAssertEqual("<b>1234567890<c></c></b>_", getReplacedRawString("<b>1234567890<c/></b>", sel, .outer))
        XCTAssertEqual("<b>1234567890_<c></c></b>", getReplacedRawString("<b>1234567890<c/></b>", sel, .inner))
    }
    
    func testReplaceLeftSideSelection() {
        let sel: StringSelector = .range(0..<5)
        
        XCTAssertEqual("_67890", getReplacedRawString("1234567890", sel, .outer))
        XCTAssertEqual("_67890", getReplacedRawString("1234567890", sel, .inner))
        XCTAssertEqual("<b>_67890</b>", getReplacedRawString("<b>1234567890</b>", sel, .outer))
        XCTAssertEqual("<b>_67890</b>", getReplacedRawString("<b>1234567890</b>", sel, .inner))
        XCTAssertEqual("<b>_67890</b>", getReplacedRawString("<b><c/>1234567890</b>", sel, .outer))
        XCTAssertEqual("<b><c></c>_67890</b>", getReplacedRawString("<b><c/>1234567890</b>", sel, .inner))
        XCTAssertEqual("_67890", getReplacedRawString("<b>12345</b>67890", sel, .outer))
        XCTAssertEqual("<b>_</b>67890", getReplacedRawString("<b>12345</b>67890", sel, .inner))
        XCTAssertEqual("_67890", getReplacedRawString("<b>12345</b><c/>67890", sel, .outer))
        XCTAssertEqual("<b>_</b><c></c>67890", getReplacedRawString("<b>12345</b><c/>67890", sel, .inner))
        XCTAssertEqual("_<c>6</c>7890", getReplacedRawString("<b>12345</b><c>6</c>7890", sel, .outer))
        XCTAssertEqual("<b>_</b><c>6</c>7890", getReplacedRawString("<b>12345</b><c>6</c>7890", sel, .inner))
        XCTAssertEqual("_67890", getReplacedRawString("<b><c>123</c>45</b>67890", sel, .outer))
        XCTAssertEqual("<b>_</b>67890", getReplacedRawString("<b><c>123</c>45</b>67890", sel, .inner))
        XCTAssertEqual("_67890", getReplacedRawString("<b>123</b>4567890", sel, .outer))
        XCTAssertEqual("_67890", getReplacedRawString("<b>123</b>4567890", sel, .inner))
        XCTAssertEqual("_<b>6</b>7890", getReplacedRawString("12345<b>6</b>7890", sel, .outer))
        XCTAssertEqual("_<b>6</b>7890", getReplacedRawString("12345<b>6</b>7890", sel, .inner))
        XCTAssertEqual("<b>_6</b>7890", getReplacedRawString("<b>123456</b>7890", sel, .outer))
        XCTAssertEqual("<b>_6</b>7890", getReplacedRawString("<b>123456</b>7890", sel, .inner))
    }
    
    func testReplaceRightSideSelection() {
        let sel: StringSelector = .range(5..<Int.max)
        
        XCTAssertEqual("12345_", getReplacedRawString("1234567890", sel, .outer))
        XCTAssertEqual("12345_", getReplacedRawString("1234567890", sel, .inner))
        XCTAssertEqual("<b>12345_</b>", getReplacedRawString("<b>1234567890</b>", sel, .outer))
        XCTAssertEqual("<b>12345_</b>", getReplacedRawString("<b>1234567890</b>", sel, .inner))
        XCTAssertEqual("<b>12345_</b>", getReplacedRawString("<b>1234567890<c/></b>", sel, .outer))
        XCTAssertEqual("<b>12345_<c></c></b>", getReplacedRawString("<b>1234567890<c/></b>", sel, .inner))
        XCTAssertEqual("12345_", getReplacedRawString("12345<b>67890</b>", sel, .outer))
        XCTAssertEqual("12345<b>_</b>", getReplacedRawString("12345<b>67890</b>", sel, .inner))
        XCTAssertEqual("12345_", getReplacedRawString("12345<c/><b>67890</b>", sel, .outer))
        XCTAssertEqual("12345<c></c><b>_</b>", getReplacedRawString("12345<c/><b>67890</b>", sel, .inner))
        XCTAssertEqual("1234<c>5</c>_", getReplacedRawString("1234<c>5</c><b>67890</b>", sel, .outer))
        XCTAssertEqual("1234<c>5</c><b>_</b>", getReplacedRawString("1234<c>5</c><b>67890</b>", sel, .inner))
        XCTAssertEqual("12345_", getReplacedRawString("12345<b>67<c>890</c></b>", sel, .outer))
        XCTAssertEqual("12345<b>_</b>", getReplacedRawString("12345<b>67<c>890</c></b>", sel, .inner))
        XCTAssertEqual("12345_", getReplacedRawString("1234567<b>890</b>", sel, .outer))
        XCTAssertEqual("12345_", getReplacedRawString("1234567<b>890</b>", sel, .inner))
        XCTAssertEqual("1234<b>5</b>_", getReplacedRawString("1234<b>5</b>67890", sel, .outer))
        XCTAssertEqual("1234<b>5</b>_", getReplacedRawString("1234<b>5</b>67890", sel, .inner))
        XCTAssertEqual("1234<b>5_</b>", getReplacedRawString("1234<b>567890</b>", sel, .outer))
        XCTAssertEqual("1234<b>5_</b>", getReplacedRawString("1234<b>567890</b>", sel, .inner))
        XCTAssertEqual("<b>12345<c></c></b>_", getReplacedRawString("<b>12345<c/></b><d>67890</d>", sel, .outer))
        XCTAssertEqual("<b>12345<c></c></b><d>_</d>", getReplacedRawString("<b>12345<c/></b><d>67890</d>", sel, .inner))
    }
    
    func testReplaceInsert() {
        let sel: StringSelector = .range(5..<5)
        
        XCTAssertEqual("12345_67890", getReplacedRawString("1234567890", sel, .outer))
        XCTAssertEqual("12345_67890", getReplacedRawString("1234567890", sel, .inner))
        XCTAssertEqual("<b>12345</b>_67890", getReplacedRawString("<b>12345</b>67890", sel, .outer))
        XCTAssertEqual("<b>12345_</b>67890", getReplacedRawString("<b>12345</b>67890", sel, .inner))
        XCTAssertEqual("12345_<b>67890</b>", getReplacedRawString("12345<b>67890</b>", sel, .outer))
        XCTAssertEqual("12345<b>_67890</b>", getReplacedRawString("12345<b>67890</b>", sel, .inner))
        XCTAssertEqual("<b>12345<c></c></b>_67890", getReplacedRawString("<b>12345<c/></b>67890", sel, .outer))
        XCTAssertEqual("<b>12345<c>_</c></b>67890", getReplacedRawString("<b>12345<c/></b>67890", sel, .inner))
        XCTAssertEqual("12345_<b><c></c>67890</b>", getReplacedRawString("12345<b><c/>67890</b>", sel, .outer))
        XCTAssertEqual("12345<b><c>_</c>67890</b>", getReplacedRawString("12345<b><c/>67890</b>", sel, .inner))
        XCTAssertEqual("<b>12345</b>_<c>67890</c>", getReplacedRawString("<b>12345</b><c>67890</c>", sel, .outer))
        XCTAssertEqual("<b>12345</b>_<c>67890</c>", getReplacedRawString("<b>12345</b><c>67890</c>", sel, .inner))
        XCTAssertEqual("<b>12345<d></d></b>_<c><e></e>67890</c>", getReplacedRawString("<b>12345<d/></b><c><e/>67890</c>", sel, .outer))
        XCTAssertEqual("<b>12345<d></d></b>_<c><e></e>67890</c>", getReplacedRawString("<b>12345<d/></b><c><e/>67890</c>", sel, .inner))
        XCTAssertEqual("<b><d>12345</d></b>_<c><e>67890</e></c>", getReplacedRawString("<b><d>12345</d></b><c><e>67890</e></c>", sel, .outer))
        XCTAssertEqual("<b><d>12345</d></b>_<c><e>67890</e></c>", getReplacedRawString("<b><d>12345</d></b><c><e>67890</e></c>", sel, .inner))
        XCTAssertEqual("12345_67890", getReplacedRawString("12345<b/>67890", sel, .outer))
        XCTAssertEqual("12345<b>_</b>67890", getReplacedRawString("12345<b/>67890", sel, .inner))
        XCTAssertEqual("<b>12345</b>_67890", getReplacedRawString("<b>12345</b><c/>67890", sel, .outer))
        XCTAssertEqual("<b>12345</b><c>_</c>67890", getReplacedRawString("<b>12345</b><c/>67890", sel, .inner))
        XCTAssertEqual("12345_<b>67890</b>", getReplacedRawString("12345<c/><b>67890</b>", sel, .outer))
        XCTAssertEqual("12345<c>_</c><b>67890</b>", getReplacedRawString("12345<c/><b>67890</b>", sel, .inner))
        XCTAssertEqual("<b>12345</b>_<c>67890</c>", getReplacedRawString("<b>12345</b><d><e/><f/></d><c>67890</c>", sel, .outer))
        XCTAssertEqual("<b>12345</b><d>_</d><c>67890</c>", getReplacedRawString("<b>12345</b><d><e/><f/></d><c>67890</c>", sel, .inner))
    }
    
    func testReplaceSelection() {
        let sel: StringSelector = .range(4..<6)
        
        XCTAssertEqual("1234_7890", getReplacedRawString("1234567890", sel, .outer))
        XCTAssertEqual("1234_7890", getReplacedRawString("1234567890", sel, .inner))
        XCTAssertEqual("1234_7890", getReplacedRawString("1234<b>56</b>7890", sel, .outer))
        XCTAssertEqual("1234<b>_</b>7890", getReplacedRawString("1234<b>56</b>7890", sel, .inner))
        XCTAssertEqual("1234_7890", getReplacedRawString("1234<b>5<c/>6</b>7890", sel, .outer))
        XCTAssertEqual("1234<b>_</b>7890", getReplacedRawString("1234<b>5<c/>6</b>7890", sel, .inner))
        XCTAssertEqual("1234<b>_78</b>90", getReplacedRawString("1234<b><c>56</c>78</b>90", sel, .outer))
        XCTAssertEqual("1234<b><c>_</c>78</b>90", getReplacedRawString("1234<b><c>56</c>78</b>90", sel, .inner))
        XCTAssertEqual("1234<b>_78</b>90", getReplacedRawString("1234<b>5678</b>90", sel, .outer))
        XCTAssertEqual("1234<b>_78</b>90", getReplacedRawString("1234<b>5678</b>90", sel, .inner))
        XCTAssertEqual("12<b>34_</b>7890", getReplacedRawString("12<b>3456</b>7890", sel, .outer))
        XCTAssertEqual("12<b>34_</b>7890", getReplacedRawString("12<b>3456</b>7890", sel, .inner))
        XCTAssertEqual("12<b>34_78</b>90", getReplacedRawString("12<b>345678</b>90", sel, .outer))
        XCTAssertEqual("12<b>34_78</b>90", getReplacedRawString("12<b>345678</b>90", sel, .inner))
        XCTAssertEqual("1234_78<b></b>90", getReplacedRawString("12345<b>678</b>90", sel, .outer))
        XCTAssertEqual("1234_78<b></b>90", getReplacedRawString("12345<b>678</b>90", sel, .inner))
        XCTAssertEqual("12<b>34_7890</b>", getReplacedRawString("12<b>345</b>67890", sel, .outer))
        XCTAssertEqual("12<b>34_7890</b>", getReplacedRawString("12<b>345</b>67890", sel, .inner))
        XCTAssertEqual("1234<b></b><c>_78</c>90", getReplacedRawString("1234<b/><c>5678</c>90", sel, .outer))
        XCTAssertEqual("1234<b></b><c>_78</c>90", getReplacedRawString("1234<b/><c>5678</c>90", sel, .inner))
        XCTAssertEqual("1234<b></b><c>_78</c>90", getReplacedRawString("1234<b/><c><d>56</d>78</c>90", sel, .outer))
        XCTAssertEqual("1234<b></b><c><d>_</d>78</c>90", getReplacedRawString("1234<b/><c><d>56</d>78</c>90", sel, .inner))
    }
    
    func testFilter() {
        let string = "<b>1</b><b>2</b><b>3</b><b>4</b><b>5</b><b>6</b><b>7</b><b>8</b><b>9</b><b>0</b>"
        XCTAssertEqual("1", getString(string, .tag("b") % .first))
        XCTAssertEqual("0", getString(string, .tag("b") % .last))
        XCTAssertEqual("4", getString(string, .tag("b") % .eq(3)))
        XCTAssertEqual("13579", getString(string, .tag("b") % .even))
        XCTAssertEqual("24680", getString(string, .tag("b") % .odd))
    }
    
    func testPrepend() {
        XCTAssertEqual("123<span>!456</span>7890", "123<span>456</span>7890".ex[.tag("span")].prepend("!").rawString)
        XCTAssertEqual("!1234567890", "1234567890".ex.prepend("!").rawString)
        XCTAssertEqual("1234567890!", "1234567890".ex[.range(Int.max..<Int.max)].prepend("!").rawString)
    }
    
    func testAppend() {
        XCTAssertEqual("123<span>456!</span>7890", "123<span>456</span>7890".ex[.tag("span")].append("!").rawString)
        XCTAssertEqual("1234567890!", "1234567890".ex.append("!").rawString)
        XCTAssertEqual("!1234567890", "1234567890".ex[.range(0..<0)].append("!").rawString)
    }
    
    func testInsert() {
        XCTAssertEqual("123<span>4!56</span>7890", "123<span>456</span>7890".ex[.tag("span")].insert("!", at: 1).rawString)
        XCTAssertEqual("1!234567890", "1234567890".ex.insert("!", at: 1).rawString)
    }
    
    func testRestoreSelector() {
        XCTAssertEqual("123<span>!</span>7890", "123<span>456</span>7890".ex[.tag("span")].replace(with: "?").replace(with: "!").rawString)
        XCTAssertEqual("123<span>!?456</span>7890", "123<span>456</span>7890".ex[.tag("span")].prepend("?").prepend("!").rawString)
        XCTAssertEqual("123<span>456?!</span>7890", "123<span>456</span>7890".ex[.tag("span")].append("?").append("!").rawString)
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
