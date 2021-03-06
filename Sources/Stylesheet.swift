//
//  Stylesheet.swift
//  StringEx
//
//  Created by Andrey Golovchak on 11/08/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation

/**
 An object describing a set of styles to apply to a string based on a given selector.
 
 - Tag: Stylesheet
*/
public struct Stylesheet {
    let selector: StringSelector
    let styles: [Style]
    
    public init(selector: StringSelector, styles: [Style]) {
        self.selector = selector
        self.styles = styles
    }
    
    public init(selector: StringSelector, style: Style) {
        self.init(selector: selector, styles: [style])
    }
}
