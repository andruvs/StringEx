//
//  ViewController.swift
//  StringExExamples
//
//  Created by Andrey Golovchak on 29/11/2019.
//  Copyright © 2019 Andrew Golovchak. All rights reserved.
//

import UIKit
import StringEx

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let string = "<title /><address class=\"line\">Address: Cupertino, CA 95014</address><phone class=\"line\">Phone: (408) 996–1010</phone><site class=\"line\">Site: https://apple.com</site>"

        // Create StringEx instance
        let ex = string.ex

        // Apply default styles to whole string
        ex.style([
            .font(.systemFont(ofSize: 17.0)),
            .color(.black)
        ])

        // Insert company name and style it
        ex[.tag("title")]
            .insert("Apple")
            .style(.font(.boldSystemFont(ofSize: 24.0)))

        // Add new lines to each tag with `line` class
        ex[.class("line")].prepend("\n")

        // Add some space before each paragraph and set text aligment
        ex[.all].style([
            .paragraphSpacingBefore(10.0),
            .aligment(.center)
        ])

        // Get site url
        let selector = .tag("site") => .regex("(?i)https?://(?:www\\.)?\\S+(?:/|\\b)")
        let url = ex[selector].selectedString

        // Attach url to site link and style it
        ex[selector].style([
            .linkString(url),
            .color(.blue),
            .underlineStyle(.single, color: .blue)
        ])

        // Apply gray color to contacts captions
        ex[.string("address:") + .string("phone:") + .string("site:")].style(.color(.gray))

        // Get result attributed string
        let attributedString = ex.attributedString

        // and display it in TextView
        textView.attributedText = attributedString
        textView.dataDetectorTypes = .link
    }


}

