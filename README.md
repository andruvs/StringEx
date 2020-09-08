# StringEx

StringEx makes it easy to create `NSAttributedString` and manipulate `String`.

## Quick Example

This simple example allows you to understand what the library actually does.

```swift
let string = "Hello, <user />!"
let ex = string.ex

ex.style(.color(.blue))

ex[.tag("user")]
    .replace(with: "UserName")
    .style([
        .font(.boldSystemFont(ofSize: 17.0)),
        .color(.red),
        .underlineStyles([.single, .patternDot], color: .green)
    ])

let attributedString = ex.attributedString

let label = UILabel()
label.attributedText = attributedString
```
As a result, we get something like:

<span style="color: blue;">Hello, <span style="border-bottom: 2px dashed #75f94c;"><span style="font-weight: bold; color: #eb3223;">UserName</span></span>!</span>