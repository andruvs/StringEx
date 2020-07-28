//
//  Style.swift
//  StringEx
//
//  Created by Andrey Golovchak on 22/07/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation
import UIKit

public enum Style {
    
    // The font of the selected text
    case font(_ font: UIFont)
    
    // The color of the selected text
    case color(_ color: UIColor)
    
    // The color of the background area behind the selected text
    case backgroundColor(_ color: UIColor)
    
    // The number of points by which to adjust kern-pair characters
    case kern(_ value: Double)
    
    // The link of the selected text
    case linkUrl(_ url: URL?)
    case linkString(_ string: String?)
    
    // The shadow of the selected text
    case shadow(_ shadow: NSShadow?)
    
    // The line through style
    case lineThroughStyle(_ style: NSUnderlineStyle, color: UIColor?)
    case lineThroughStyles(_ styles: [NSUnderlineStyle], color: UIColor?)
    
    // The underline style
    case underlineStyle(_ style: NSUnderlineStyle, color: UIColor?)
    case underlineStyles(_ styles: [NSUnderlineStyle], color: UIColor?)
    
    // The stroke of the selected text
    case strokeWidth(_ width: Double, color: UIColor?)
    
    // The character’s offset from the baseline, in points
    case baselineOffset(_ value: Double)
    
    // The paragraph attributes
    case paragraphStyle(_ value: NSParagraphStyle)
    
    // The text alignment
    case aligment(_ value: NSTextAlignment)
    
    // The indentation of the first line
    case firstLineHeadIndent(_ value: Double)
    
    // The indentation of the lines other than the first
    case headIndent(_ value: Double)
    
    // The trailing indentation
    case tailIndent(_ value: Double)
    
    // The line height multiple
    case lineHeightMultiple(_ value: Double)
    
    // The distance in points between the bottom of one line fragment and the top of the next
    case lineSpacing(_ value: Double)
    
    // The space after the end of the paragraph
    case paragraphSpacing(_ value: Double)
    
    // The distance between the paragraph’s top and the beginning of its text content
    case paragraphSpacingBefore(_ value: Double)
}
