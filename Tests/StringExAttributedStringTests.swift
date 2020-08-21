//
//  StringExAttributedStringTests.swift
//  StringExTests
//
//  Created by Andrey Golovchak on 17/07/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import XCTest
@testable import StringEx

class StringExAttributedStringTests: XCTestCase {

    func getString(_ str: String, _ sel: StringSelector) -> String {
        return str.ex[sel].selectedAttributedString.string
    }

    func getReplacedString(_ str: String, _ sel: StringSelector) -> String {
        return str.ex[sel].replace(with: "_").attributedString.string
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
    }
    
    func testSelectOrder() {
        XCTAssertEqual("125", getString("1234567890", .range(0..<2) + .range(3..<6) => .range(1..<2)))
        XCTAssertEqual("25", getString("1234567890", (.range(0..<2) + .range(3..<6)) => .range(1..<2)))
    }
    
    func testReplaceNoTags() {
        XCTAssertEqual("_", getReplacedString("", .all))
        XCTAssertEqual("_", getReplacedString("1234567890", .all))
        XCTAssertEqual("_", getReplacedString("1234567890", .range(0..<Int.max)))
        XCTAssertEqual("_1234567890", getReplacedString("1234567890", .range(0..<0)))
        XCTAssertEqual("1234567890_", getReplacedString("1234567890", .range(Int.max..<Int.max)))
        XCTAssertEqual("_34567890", getReplacedString("1234567890", .range(0..<2)))
        XCTAssertEqual("12345678_", getReplacedString("1234567890", .range(8..<Int.max)))
        XCTAssertEqual("123_67890", getReplacedString("1234567890", .range(3..<5)))
        XCTAssertEqual("1234567890", getReplacedString("1234567890", .tag("a")))
    }
    
    func testReplaceEmptyTagSelection() {
        let sel: StringSelector = .tag("a")
        
        XCTAssertEqual("_", getReplacedString("<a/>", sel))
        XCTAssertEqual("_", getReplacedString("<a><b/></a>", sel))
        XCTAssertEqual("_", getReplacedString("<a><b><c/><d/></b></a>", sel))
        XCTAssertEqual("1234_67890", getReplacedString("1234<a/>67890", sel))
        XCTAssertEqual("1234_67890", getReplacedString("1234<a><b><c/><d/></b></a>67890", sel))
    }
    
    func testReplaceEntireTagSelection() {
        let sel: StringSelector = .tag("a")
        
        XCTAssertEqual("_", getReplacedString("<a>1234567890</a>", sel))
        XCTAssertEqual("_", getReplacedString("<a><b>1234567890</b></a>", sel))
        XCTAssertEqual("_", getReplacedString("<a><b/>1234567890<c/></a>", sel))
        XCTAssertEqual("_", getReplacedString("<a><b>1</b>23456789<c>0</c></a>", sel))
        XCTAssertEqual("_", getReplacedString("<a><b>1234567890<c/></b></a>", sel))
        XCTAssertEqual("123_890", getReplacedString("123<a>4567</a>890", sel))
        XCTAssertEqual("123_890", getReplacedString("123<a><b>4567</b></a>890", sel))
        XCTAssertEqual("123_", getReplacedString("123<a>4567890</a>", sel))
        XCTAssertEqual("_890", getReplacedString("<a>1234567</a>890", sel))
    }
    
    func testReplacePrependToTag() {
        let sel: StringSelector = .tag("a") => .range(0..<0)
        
        XCTAssertEqual("_1234567890", getReplacedString("<a>1234567890</a>", sel))
        XCTAssertEqual("_1234567890", getReplacedString("<a><b>1234567890</b></a>", sel))
        XCTAssertEqual("_1234567890", getReplacedString("<a><b/><c/>1234567890</a>", sel))
        XCTAssertEqual("_1234567890", getReplacedString("<a><b><c/>1234567890</b></a>", sel))
        XCTAssertEqual("123_4567890", getReplacedString("123<a>4567</a>890", sel))
        XCTAssertEqual("123_4567890", getReplacedString("123<a><b>4567</b></a>890", sel))
        XCTAssertEqual("123_4567890", getReplacedString("123<a>4567890</a>", sel))
        XCTAssertEqual("_1234567890", getReplacedString("<a>1234567</a>890", sel))
    }
    
    func testReplaceAppendToTag() {
        let sel: StringSelector = .tag("a") => .range(Int.max..<Int.max)
        
        XCTAssertEqual("1234567890_", getReplacedString("<a>1234567890</a>", sel))
        XCTAssertEqual("1234567890_", getReplacedString("<a><b>1234567890</b></a>", sel))
        XCTAssertEqual("1234567890_", getReplacedString("<a>1234567890<b/><c/></a>", sel))
        XCTAssertEqual("1234567890_", getReplacedString("<a><b>1234567890<c/></b></a>", sel))
        XCTAssertEqual("1234567_890", getReplacedString("123<a>4567</a>890", sel))
        XCTAssertEqual("1234567_890", getReplacedString("123<a><b>4567<c/></b></a>890", sel))
    }
    
    func testReplaceLeftSideTagSelection() {
        let sel: StringSelector = .tag("a") => .range(0..<5)
        
        XCTAssertEqual("_67890", getReplacedString("<a>1234567890</a>", sel))
        XCTAssertEqual("_67890", getReplacedString("<a><b>1234567890</b></a>", sel))
        XCTAssertEqual("_67890", getReplacedString("<a><b><c/>1234567890</b></a>", sel))
        XCTAssertEqual("_67890", getReplacedString("<a><b>12345</b>67890</a>", sel))
        XCTAssertEqual("_67890", getReplacedString("<a><b>12345</b><c/>67890</a>", sel))
        XCTAssertEqual("_67890", getReplacedString("<a><b>12345</b><c>6</c>7890</a>", sel))
        XCTAssertEqual("_67890", getReplacedString("<a><b><c>123</c>45</b>67890</a>", sel))
        XCTAssertEqual("_67890", getReplacedString("<a><b>123</b>4567890</a>", sel))
        XCTAssertEqual("_67890", getReplacedString("<a>12345<b>6</b>7890</a>", sel))
        XCTAssertEqual("_67890", getReplacedString("<a><b>123456</b>7890</a>", sel))
    }
    
    func testReplaceRightSideTagSelection() {
        let sel: StringSelector = .tag("a") => .range(5..<Int.max)
        
        XCTAssertEqual("12345_", getReplacedString("<a>1234567890</a>", sel))
        XCTAssertEqual("12345_", getReplacedString("<a><b>1234567890</b></a>", sel))
        XCTAssertEqual("12345_", getReplacedString("<a><b>1234567890<c/></b></a>", sel))
        XCTAssertEqual("12345_", getReplacedString("<a>12345<b>67890</b></a>", sel))
        XCTAssertEqual("12345_", getReplacedString("<a>12345<c/><b>67890</b></a>", sel))
        XCTAssertEqual("12345_", getReplacedString("<a>1234<c>5</c><b>67890</b></a>", sel))
        XCTAssertEqual("12345_", getReplacedString("<a>12345<b>67<c>890</c></b></a>", sel))
        XCTAssertEqual("12345_", getReplacedString("<a>1234567<b>890</b></a>", sel))
        XCTAssertEqual("12345_", getReplacedString("<a>1234<b>5</b>67890</a>", sel))
        XCTAssertEqual("12345_", getReplacedString("<a>1234<b>567890</b></a>", sel))
        XCTAssertEqual("12345_", getReplacedString("<a><b>12345<c/></b><d>67890</d></a>", sel))
    }
    
    func testReplaceInsertToTag() {
        let sel: StringSelector = .tag("a") => .range(5..<5)
        
        XCTAssertEqual("12345_67890", getReplacedString("<a>1234567890</a>", sel))
        XCTAssertEqual("12345_67890", getReplacedString("<a><b>12345</b>67890</a>", sel))
        XCTAssertEqual("12345_67890", getReplacedString("<a>12345<b>67890</b></a>", sel))
        XCTAssertEqual("12345_67890", getReplacedString("<a><b>12345<c/></b>67890</a>", sel))
        XCTAssertEqual("12345_67890", getReplacedString("<a>12345<b><c/>67890</b></a>", sel))
        XCTAssertEqual("12345_67890", getReplacedString("<a><b>12345</b><c>67890</c></a>", sel))
        XCTAssertEqual("12345_67890", getReplacedString("<a><b>12345<d/></b><c><e/>67890</c></a>", sel))
        XCTAssertEqual("12345_67890", getReplacedString("<a><b><d>12345</d></b><c><e>67890</e></c></a>", sel))
        XCTAssertEqual("12345_67890", getReplacedString("<a>12345<b/>67890</a>", sel))
        XCTAssertEqual("12345_67890", getReplacedString("<a><b>12345</b><c/>67890</a>", sel))
        XCTAssertEqual("12345_67890", getReplacedString("<a>12345<c/><b>67890</b></a>", sel))
        XCTAssertEqual("12345_67890", getReplacedString("<a><b>12345</b><d><e/><f/></d><c>67890</c></a>", sel))
    }
    
    func testReplaceTagSelection() {
        let sel: StringSelector = .tag("a") => .range(4..<6)
        
        XCTAssertEqual("1234_7890", getReplacedString("<a>1234567890</a>", sel))
        XCTAssertEqual("1234_7890", getReplacedString("<a>1234<b>56</b>7890</a>", sel))
        XCTAssertEqual("1234_7890", getReplacedString("<a>1234<b>5<c/>6</b>7890</a>", sel))
        XCTAssertEqual("1234_7890", getReplacedString("<a>1234<b><c>56</c>78</b>90</a>", sel))
        XCTAssertEqual("1234_7890", getReplacedString("<a>1234<b>5678</b>90</a>", sel))
        XCTAssertEqual("1234_7890", getReplacedString("<a>12<b>3456</b>7890</a>", sel))
        XCTAssertEqual("1234_7890", getReplacedString("<a>12<b>345678</b>90</a>", sel))
        XCTAssertEqual("1234_7890", getReplacedString("<a>12345<b>678</b>90</a>", sel))
        XCTAssertEqual("1234_7890", getReplacedString("<a>12<b>345</b>67890</a>", sel))
        XCTAssertEqual("1234_7890", getReplacedString("<a>1234<b/><c>5678</c>90</a>", sel))
        XCTAssertEqual("1234_7890", getReplacedString("<a>1234<b/><c><d>56</d>78</c>90</a>", sel))
    }
    
    func testReplaceEntireSelection() {
        let sel: StringSelector = .range(0..<Int.max)
        
        XCTAssertEqual("_", getReplacedString("1234567890", sel))
        XCTAssertEqual("_", getReplacedString("<b>1234567890</b>", sel))
        XCTAssertEqual("_", getReplacedString("<b/>1234567890<c/>", sel))
        XCTAssertEqual("_", getReplacedString("<b>1</b>23456789<c>0</c>", sel))
        XCTAssertEqual("_", getReplacedString("<b>1234567890<c/></b>", sel))
    }
    
    func testReplacePrepend() {
        let sel: StringSelector = .range(0..<0)
        
        XCTAssertEqual("_1234567890", getReplacedString("1234567890", sel))
        XCTAssertEqual("_1234567890", getReplacedString("<b>1234567890</b>", sel))
        XCTAssertEqual("_1234567890", getReplacedString("<b/><c/>1234567890", sel))
        XCTAssertEqual("_1234567890", getReplacedString("<b><c/>1234567890</b>", sel))
    }
    
    func testReplaceAppend() {
        let sel: StringSelector = .range(Int.max..<Int.max)
        
        XCTAssertEqual("1234567890_", getReplacedString("1234567890", sel))
        XCTAssertEqual("1234567890_", getReplacedString("<b>1234567890</b>", sel))
        XCTAssertEqual("1234567890_", getReplacedString("1234567890<b/><c/>", sel))
        XCTAssertEqual("1234567890_", getReplacedString("<b>1234567890<c/></b>", sel))
    }
    
    func testReplaceLeftSideSelection() {
        let sel: StringSelector = .range(0..<5)
        
        XCTAssertEqual("_67890", getReplacedString("1234567890", sel))
        XCTAssertEqual("_67890", getReplacedString("<b>1234567890</b>", sel))
        XCTAssertEqual("_67890", getReplacedString("<b><c/>1234567890</b>", sel))
        XCTAssertEqual("_67890", getReplacedString("<b>12345</b>67890", sel))
        XCTAssertEqual("_67890", getReplacedString("<b>12345</b><c/>67890", sel))
        XCTAssertEqual("_67890", getReplacedString("<b>12345</b><c>6</c>7890", sel))
        XCTAssertEqual("_67890", getReplacedString("<b><c>123</c>45</b>67890", sel))
        XCTAssertEqual("_67890", getReplacedString("<b>123</b>4567890", sel))
        XCTAssertEqual("_67890", getReplacedString("12345<b>6</b>7890", sel))
        XCTAssertEqual("_67890", getReplacedString("<b>123456</b>7890", sel))
    }
    
    func testReplaceRightSideSelection() {
        let sel: StringSelector = .range(5..<Int.max)
        
        XCTAssertEqual("12345_", getReplacedString("1234567890", sel))
        XCTAssertEqual("12345_", getReplacedString("<b>1234567890</b>", sel))
        XCTAssertEqual("12345_", getReplacedString("<b>1234567890<c/></b>", sel))
        XCTAssertEqual("12345_", getReplacedString("12345<b>67890</b>", sel))
        XCTAssertEqual("12345_", getReplacedString("12345<c/><b>67890</b>", sel))
        XCTAssertEqual("12345_", getReplacedString("1234<c>5</c><b>67890</b>", sel))
        XCTAssertEqual("12345_", getReplacedString("12345<b>67<c>890</c></b>", sel))
        XCTAssertEqual("12345_", getReplacedString("1234567<b>890</b>", sel))
        XCTAssertEqual("12345_", getReplacedString("1234<b>5</b>67890", sel))
        XCTAssertEqual("12345_", getReplacedString("1234<b>567890</b>", sel))
        XCTAssertEqual("12345_", getReplacedString("<b>12345<c/></b><d>67890</d>", sel))
    }
    
    func testReplaceInsert() {
        let sel: StringSelector = .range(5..<5)
        
        XCTAssertEqual("12345_67890", getReplacedString("1234567890", sel))
        XCTAssertEqual("12345_67890", getReplacedString("<b>12345</b>67890", sel))
        XCTAssertEqual("12345_67890", getReplacedString("12345<b>67890</b>", sel))
        XCTAssertEqual("12345_67890", getReplacedString("<b>12345<c/></b>67890", sel))
        XCTAssertEqual("12345_67890", getReplacedString("12345<b><c/>67890</b>", sel))
        XCTAssertEqual("12345_67890", getReplacedString("<b>12345</b><c>67890</c>", sel))
        XCTAssertEqual("12345_67890", getReplacedString("<b>12345<d/></b><c><e/>67890</c>", sel))
        XCTAssertEqual("12345_67890", getReplacedString("<b><d>12345</d></b><c><e>67890</e></c>", sel))
        XCTAssertEqual("12345_67890", getReplacedString("12345<b/>67890", sel))
        XCTAssertEqual("12345_67890", getReplacedString("<b>12345</b><c/>67890", sel))
        XCTAssertEqual("12345_67890", getReplacedString("12345<c/><b>67890</b>", sel))
        XCTAssertEqual("12345_67890", getReplacedString("<b>12345</b><d><e/><f/></d><c>67890</c>", sel))
    }
    
    func testReplaceSelection() {
        let sel: StringSelector = .range(4..<6)
        
        XCTAssertEqual("1234_7890", getReplacedString("1234567890", sel))
        XCTAssertEqual("1234_7890", getReplacedString("1234<b>56</b>7890", sel))
        XCTAssertEqual("1234_7890", getReplacedString("1234<b>5<c/>6</b>7890", sel))
        XCTAssertEqual("1234_7890", getReplacedString("1234<b><c>56</c>78</b>90", sel))
        XCTAssertEqual("1234_7890", getReplacedString("1234<b>5678</b>90", sel))
        XCTAssertEqual("1234_7890", getReplacedString("12<b>3456</b>7890", sel))
        XCTAssertEqual("1234_7890", getReplacedString("12<b>345678</b>90", sel))
        XCTAssertEqual("1234_7890", getReplacedString("12345<b>678</b>90", sel))
        XCTAssertEqual("1234_7890", getReplacedString("12<b>345</b>67890", sel))
        XCTAssertEqual("1234_7890", getReplacedString("1234<b/><c>5678</c>90", sel))
        XCTAssertEqual("1234_7890", getReplacedString("1234<b/><c><d>56</d>78</c>90", sel))
    }

}
