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

    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let string = "Hello, <user />!"
        let ex = string.ex

        ex[.tag("user")]
            .replace(with: "UserName")
            .style([
                .font(.boldSystemFont(ofSize: 20.0)),
                .color(.red),
                .underlineStyles([.single, .patternDot], color: .green)
            ])

        let attributedString = ex.attributedString

        label.attributedText = attributedString
        
        print("!!!")
    }


}

