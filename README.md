# StringEx

StringEx makes it easy to create `NSAttributedString` and manipulate `String`.

## Quick Example

This simple example allows you to understand what the library actually does.

```swift
let string = "Hello, <user />!"
let ex = string.ex

ex[.tag("user")]
    .replace(with: "UserName")
    .style([
        .font(.boldSystemFont(ofSize: 12.0)),
        .color(.red),
        .underlineStyles([.single, .patternDot], color: .green)
    ])

let attributedString = ex.attributedString

let label = UILabel()
label.attributedText = attributedString
```
As a result, we get something like:

![StringEx Example](Documentation/images/example.png)