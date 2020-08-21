//
//  StyleManagerTests.swift
//  StringExTests
//
//  Created by Andrey Golovchak on 21/08/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import XCTest
@testable import StringEx

class StyleManagerTests: XCTestCase {
    
    var styleManager: StyleManager {
        return StyleManager.shared
    }
    
    func testCycleThemeHandling() {
        styleManager.clear()
        
        styleManager["font"] = [
            "color",
            Stylesheet(selector: .all, style: .font(.boldSystemFont(ofSize: 20.0)))
        ]
        
        styleManager["color"] = [
            "font",
            "color",
            Stylesheet(selector: .all, style: .color(UIColor.yellow))
        ]
        
        styleManager.use("color")
        
        guard let styles = styleManager.styles else {
            XCTFail("Expected a styles array at this point")
            return
        }
        
        XCTAssertEqual(styles.count, 2)
        
        let ex = "1234567890".ex
        ex.useStyleManager = true
        
        let attributes = ex.attributedString.attributes(at: 4, effectiveRange: nil)
        
        XCTAssertNotNil(attributes[.foregroundColor])
        XCTAssertEqual(attributes[.foregroundColor] as? UIColor, UIColor.yellow)
        
        XCTAssertNotNil(attributes[.font])
        XCTAssertEqual(attributes[.font] as? UIFont, .boldSystemFont(ofSize: 20.0))
    }
    
    func testGettingStyleByThemeName() {
        styleManager.clear()
        
        styleManager["color"] = [
            Stylesheet(selector: .all, style: .color(UIColor.green))
        ]
        styleManager["color-bold"] = [
            "color",
            Stylesheet(selector: .all, style: .font(.boldSystemFont(ofSize: 20.0)))
        ]
        styleManager["color-bold-background"] = [
            "color-bold",
            Stylesheet(selector: .all, style: .backgroundColor(UIColor.gray))
        ]
        
        styleManager.use("color-bold-background")
        
        guard let styles = styleManager.styles else {
            XCTFail("Expected a styles array at this point")
            return
        }
        
        XCTAssertEqual(styles.count, 3)
        
        let ex = "1234567890".ex
        ex.useStyleManager = true
        
        let attributes = ex.attributedString.attributes(at: 4, effectiveRange: nil)
        
        XCTAssertNotNil(attributes[.foregroundColor])
        XCTAssertEqual(attributes[.foregroundColor] as? UIColor, UIColor.green)
        
        XCTAssertNotNil(attributes[.font])
        XCTAssertEqual(attributes[.font] as? UIFont, .boldSystemFont(ofSize: 20.0))
        
        XCTAssertNotNil(attributes[.backgroundColor])
        XCTAssertEqual(attributes[.backgroundColor] as? UIColor, UIColor.gray)
    }

    func testStyleManagerChangingTheme() {
        styleManager.clear()
        styleManager["red"] = [
            Stylesheet(selector: .range(4..<5), style: .color(UIColor.red))
        ]
        styleManager["blue"] = [
            Stylesheet(selector: .range(3..<4), style: .color(UIColor.blue))
        ]
        
        let ex = "1234567890".ex
        ex.useStyleManager = true
        
        styleManager.use("red")
        
        var attributes = ex.attributedString.attributes(at: 4, effectiveRange: nil)
        XCTAssertNotNil(attributes[.foregroundColor])
        XCTAssertEqual(attributes[.foregroundColor] as? UIColor, UIColor.red)
        
        styleManager.use("blue")
        
        attributes = ex.attributedString.attributes(at: 4, effectiveRange: nil)
        XCTAssertNil(attributes[.foregroundColor])
        
        attributes = ex.attributedString.attributes(at: 3, effectiveRange: nil)
        XCTAssertNotNil(attributes[.foregroundColor])
        XCTAssertEqual(attributes[.foregroundColor] as? UIColor, UIColor.blue)
    }

}
