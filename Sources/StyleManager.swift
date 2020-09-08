//
//  StyleManager.swift
//  StringEx
//
//  Created by Andrey Golovchak on 11/08/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation

public protocol StyleManagerAcceptable {}

extension Stylesheet: StyleManagerAcceptable {}
extension String: StyleManagerAcceptable {}

public class StyleManager {
    
    public static let shared = StyleManager()
    
    private init() {}
    
    private var themes = [String: [StyleManagerAcceptable]]()
    
    private(set) var theme: String?
    
    public var styles: [Stylesheet]? {
        guard let theme = theme else {
            return nil
        }
        return getStyles(for: theme)
    }
    
    public func set(_ theme: String, styles: [StyleManagerAcceptable]?) {
        themes[theme] = styles
    }
    
    public func clear() {
        themes.removeAll()
    }
    
    public func use(_ theme: String) {
        self.theme = theme
    }
}

extension StyleManager {
    
    private func getStyles(for theme: String, processedThemes: [String: Bool]? = nil) -> [Stylesheet]? {
        var processedThemes = processedThemes != nil ? processedThemes! : [String: Bool]()
       
        if processedThemes[theme] != nil {
            return nil
        }
       
        processedThemes[theme] = true
       
        guard let items = themes[theme] else {
            return nil
        }
       
        var styles = [Stylesheet]()
       
        for item in items {
            if let stylesheet = item as? Stylesheet {
                styles.append(stylesheet)
            } else if let theme = item as? String {
                if let stylesheet = getStyles(for: theme, processedThemes: processedThemes) {
                    styles.append(contentsOf: stylesheet)
                }
            }
        }
       
        return styles
    }
}

extension StyleManager {

    public subscript(theme: String) -> [StyleManagerAcceptable]? {
        get {
            themes[theme]
        }
        set {
            set(theme, styles: newValue)
        }
    }
}
