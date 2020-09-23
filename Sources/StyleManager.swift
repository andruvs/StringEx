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

/// The Style Manager lets you manage your style sheets in one place and automatically apply them to `StringEx` objects.
public class StyleManager {
    
    /// The shared instance of the Style Manager.
    public static let shared = StyleManager()
    
    private init() {}
    
    private var themes = [String: [StyleManagerAcceptable]]()
    
    /// The current theme used in the Style manager.
    private(set) var theme: String?
    
    /// Returns array of the style sheets for the current theme.
    public var styles: [Stylesheet]? {
        guard let theme = theme else {
            return nil
        }
        return getStyles(for: theme)
    }
    
    /**
    Adds the style sheets for the given theme.
    
    # Example #
    ```
    StyleManager.shared.set("heading", [
        Stylesheet(selector: .tag("h1"), styles: [
            .font(.boldSystemFont(ofSize: 24.0)),
            .color(.black)
        ]),
        Stylesheet(selector: .tag("h2"), styles: [
            .font(.boldSystemFont(ofSize: 18.0)),
            .color(.gray)
        ])
    ])
     
    StyleManager.shared.set("text", [
        Stylesheet(selector: .tag("p"), styles: [
            .font(.systemFont(ofSize: 17.0)),
            .color(.black)
        ])
    ])
     
    StyleManager.shared.set("default", ["heading", "text"])
    ```
    
    - Parameters:
       - theme: Theme name.
       - styles: The array of the `Stylesheet` or another theme names.
    */
    public func set(_ theme: String, styles: [StyleManagerAcceptable]?) {
        themes[theme] = styles
    }
    
    /**
    Clears all current style sheets.
    */
    public func clear() {
        themes.removeAll()
    }
    
    /**
    Sets the current theme to use.
    */
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

    /**
    Subscript version of the `set` method.
    
    # Example #
    ```
    StyleManager.shared["heading"] = [
        Stylesheet(selector: .tag("h1"), styles: [
            .font(.boldSystemFont(ofSize: 24.0)),
            .color(.black)
        ]),
        Stylesheet(selector: .tag("h2"), styles: [
            .font(.boldSystemFont(ofSize: 18.0)),
            .color(.gray)
        ])
    ]
     
    StyleManager.shared["text"] = [
        Stylesheet(selector: .tag("p"), styles: [
            .font(.systemFont(ofSize: 17.0)),
            .color(.black)
        ])
    ]
     
    StyleManager.shared["default"] = ["heading", "text"]
    ```
    */
    public subscript(theme: String) -> [StyleManagerAcceptable]? {
        get {
            themes[theme]
        }
        set {
            set(theme, styles: newValue)
        }
    }
}
