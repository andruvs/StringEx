//
//  StringExStylingTests.swift
//  StringExTests
//
//  Created by Andrey Golovchak on 23/07/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import XCTest
@testable import StringEx

class StringExStylingTests: XCTestCase {
    
    private func getAppliedAttributes(for style: Style) -> [NSAttributedString.Key : Any] {
        let attributedString = "1234567890".ex[.range(4..<5)].style(style).attributedString
        return attributedString.attributes(at: 4, effectiveRange: nil)
    }

    func testStylingFont() {
        let attributes = getAppliedAttributes(for: .font(UIFont.boldSystemFont(ofSize: 12.0)))
        XCTAssertNotNil(attributes[.font])
        XCTAssertEqual(attributes[.font] as? UIFont, UIFont.boldSystemFont(ofSize: 12.0))
    }

    func testStylingColor() {
        let attributes = getAppliedAttributes(for: .color(UIColor.red))
        XCTAssertNotNil(attributes[.foregroundColor])
        XCTAssertEqual(attributes[.foregroundColor] as? UIColor, UIColor.red)
    }

    func testStylingBackgroundColor() {
        let attributes = getAppliedAttributes(for: .backgroundColor(UIColor.green))
        XCTAssertNotNil(attributes[.backgroundColor])
        XCTAssertEqual(attributes[.backgroundColor] as? UIColor, UIColor.green)
    }

    func testStylingKern() {
        let attributes = getAppliedAttributes(for: .kern(0.5))
        XCTAssertNotNil(attributes[.kern])
        XCTAssertEqual(attributes[.kern] as? Double, 0.5)
    }

    func testStylingLinkUrl() {
        let attributes = getAppliedAttributes(for: .linkUrl(URL(string: "https://github.com/andruvs/stringex")))
        XCTAssertNotNil(attributes[.link])
        XCTAssertEqual((attributes[.link] as? URL)?.absoluteString, "https://github.com/andruvs/stringex")
    }

    func testStylingLinkString() {
        let attributes = getAppliedAttributes(for: .linkString("https://github.com/andruvs/stringex"))
        XCTAssertNotNil(attributes[.link])
        XCTAssertEqual((attributes[.link] as? URL)?.absoluteString, "https://github.com/andruvs/stringex")
    }

    func testStylingShadow() {
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.yellow
        shadow.shadowOffset = CGSize(width: 1.0, height: 2.0)
        
        let attributes = getAppliedAttributes(for: .shadow(shadow))
        XCTAssertNotNil(attributes[.shadow])
        XCTAssertEqual((attributes[.shadow] as? NSShadow)?.shadowColor as? UIColor, UIColor.yellow)
        XCTAssertEqual((attributes[.shadow] as? NSShadow)?.shadowOffset, CGSize(width: 1.0, height: 2.0))
    }

    func testStylingLineThroughStyle() {
        let attributes = getAppliedAttributes(for: .lineThroughStyle(.double, color: UIColor.blue))
        XCTAssertNotNil(attributes[.strikethroughStyle])
        XCTAssertEqual(attributes[.strikethroughStyle] as? Int, NSUnderlineStyle.double.rawValue)
        XCTAssertNotNil(attributes[.strikethroughColor])
        XCTAssertEqual(attributes[.strikethroughColor] as? UIColor, UIColor.blue)
    }

    func testStylingLineThroughStyles() {
        let attributes = getAppliedAttributes(for: .lineThroughStyles([.double, .thick, .patternDot], color: UIColor.gray))
        XCTAssertNotNil(attributes[.strikethroughStyle])
        XCTAssertEqual(attributes[.strikethroughStyle] as? Int, NSUnderlineStyle.double.rawValue | NSUnderlineStyle.thick.rawValue | NSUnderlineStyle.patternDot.rawValue)
        XCTAssertNotNil(attributes[.strikethroughColor])
        XCTAssertEqual(attributes[.strikethroughColor] as? UIColor, UIColor.gray)
    }

    func testStylingUnderlineStyle() {
        let attributes = getAppliedAttributes(for: .underlineStyle(.patternDash, color: UIColor.magenta))
        XCTAssertNotNil(attributes[.underlineStyle])
        XCTAssertEqual(attributes[.underlineStyle] as? Int, NSUnderlineStyle.patternDash.rawValue)
        XCTAssertNotNil(attributes[.underlineColor])
        XCTAssertEqual(attributes[.underlineColor] as? UIColor, UIColor.magenta)
    }

    func testStylingUnderlineStyles() {
        let attributes = getAppliedAttributes(for: .underlineStyles([.double, .thick, .patternDot], color: UIColor.brown))
        XCTAssertNotNil(attributes[.underlineStyle])
        XCTAssertEqual(attributes[.underlineStyle] as? Int, NSUnderlineStyle.double.rawValue | NSUnderlineStyle.thick.rawValue | NSUnderlineStyle.patternDot.rawValue)
        XCTAssertNotNil(attributes[.underlineColor])
        XCTAssertEqual(attributes[.underlineColor] as? UIColor, UIColor.brown)
    }

    func testStylingStrokeWidth() {
        let attributes = getAppliedAttributes(for: .strokeWidth(2.0, color: UIColor.red))
        XCTAssertNotNil(attributes[.strokeWidth])
        XCTAssertEqual(attributes[.strokeWidth] as? Double, 2.0)
        XCTAssertNotNil(attributes[.strokeColor])
        XCTAssertEqual(attributes[.strokeColor] as? UIColor, UIColor.red)
    }

    func testStylingBaselineOffset() {
        let attributes = getAppliedAttributes(for: .baselineOffset(3.0))
        XCTAssertNotNil(attributes[.baselineOffset])
        XCTAssertEqual(attributes[.baselineOffset] as? Double, 3.0)
    }

    func testStylingParagraphStyle() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
        let attributes = getAppliedAttributes(for: .paragraphStyle(paragraphStyle))
        XCTAssertNotNil(attributes[.paragraphStyle])
        XCTAssertEqual((attributes[.paragraphStyle] as? NSMutableParagraphStyle)?.alignment, .right)
    }

    func testStylingAligment() {
        let attributes = getAppliedAttributes(for: .aligment(.center))
        XCTAssertNotNil(attributes[.paragraphStyle])
        XCTAssertEqual((attributes[.paragraphStyle] as? NSMutableParagraphStyle)?.alignment, .center)
    }

    func testStylingFirstLineHeadIndent() {
        let attributes = getAppliedAttributes(for: .firstLineHeadIndent(5.0))
        XCTAssertNotNil(attributes[.paragraphStyle])
        XCTAssertEqual((attributes[.paragraphStyle] as? NSMutableParagraphStyle)?.firstLineHeadIndent, 5.0)
    }

    func testStylingHeadIndent() {
        let attributes = getAppliedAttributes(for: .headIndent(6.0))
        XCTAssertNotNil(attributes[.paragraphStyle])
        XCTAssertEqual((attributes[.paragraphStyle] as? NSMutableParagraphStyle)?.headIndent, 6.0)
    }

    func testStylingTailIndent() {
        let attributes = getAppliedAttributes(for: .tailIndent(7.0))
        XCTAssertNotNil(attributes[.paragraphStyle])
        XCTAssertEqual((attributes[.paragraphStyle] as? NSMutableParagraphStyle)?.tailIndent, 7.0)
    }

    func testStylingLineHeightMultiple() {
        let attributes = getAppliedAttributes(for: .lineHeightMultiple(8.0))
        XCTAssertNotNil(attributes[.paragraphStyle])
        XCTAssertEqual((attributes[.paragraphStyle] as? NSMutableParagraphStyle)?.lineHeightMultiple, 8.0)
    }

    func testStylingLineSpacing() {
        let attributes = getAppliedAttributes(for: .lineSpacing(9.0))
        XCTAssertNotNil(attributes[.paragraphStyle])
        XCTAssertEqual((attributes[.paragraphStyle] as? NSMutableParagraphStyle)?.lineSpacing, 9.0)
    }

    func testStylingParagraphSpacing() {
        let attributes = getAppliedAttributes(for: .paragraphSpacing(10.0))
        XCTAssertNotNil(attributes[.paragraphStyle])
        XCTAssertEqual((attributes[.paragraphStyle] as? NSMutableParagraphStyle)?.paragraphSpacing, 10.0)
    }

    func testStylingParagraphSpacingBefore() {
        let attributes = getAppliedAttributes(for: .paragraphSpacingBefore(11.0))
        XCTAssertNotNil(attributes[.paragraphStyle])
        XCTAssertEqual((attributes[.paragraphStyle] as? NSMutableParagraphStyle)?.paragraphSpacingBefore, 11.0)
    }
    
    func testStylesheet() {
        let ex = "1234567890".ex
        let attributedString = ex.style(Stylesheet(selector: .range(4..<5), style: .color(UIColor.red))).attributedString
        let attributes = attributedString.attributes(at: 4, effectiveRange: nil)
        XCTAssertNotNil(attributes[.foregroundColor])
        XCTAssertEqual(attributes[.foregroundColor] as? UIColor, UIColor.red)
    }
    
    func testClearAllStyles() {
        let ex = "1234567890".ex
        var attributedString = ex[.range(4..<5)].style(.color(UIColor.red)).attributedString
        var attributes = attributedString.attributes(at: 4, effectiveRange: nil)
        XCTAssertNotNil(attributes[.foregroundColor])
        XCTAssertEqual(attributes[.foregroundColor] as? UIColor, UIColor.red)
        
        attributedString = ex[.all].clearStyles().attributedString
        attributes = attributedString.attributes(at: 4, effectiveRange: nil)
        XCTAssert(attributes.isEmpty)
    }
    
    func testClearSubrangeStyles() {
        let ex = "1234567890".ex
        var attributedString = ex[.range(4..<5)].style(.color(UIColor.red)).attributedString
        var attributes = attributedString.attributes(at: 4, effectiveRange: nil)
        XCTAssertNotNil(attributes[.foregroundColor])
        XCTAssertEqual(attributes[.foregroundColor] as? UIColor, UIColor.red)
        
        attributedString = ex[.range(4..<5)].clearStyles().attributedString
        attributes = attributedString.attributes(at: 4, effectiveRange: nil)
        XCTAssert(attributes.isEmpty)
    }

}
