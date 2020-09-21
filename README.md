# StringEx

StringEx makes it easy to create `NSAttributedString` and manipulate `String`.

## Table of contents

* [Quick Example](#quick-example)
* [Initialization](#initialization)
* [String selectors](#string-selectors)
	* [HTML tags](#html-tags)
	* [Substrings](#substrings)
	* [Regular expressions](#regular-expressions)
	* [Ranges](#ranges)
	* [Nested selectors](#nested-selectors)
	* [Selectors union](#selectors-union)
	* [Filtering selectors](#filtering-selectors)
	* [Priority](#priority)

## Quick Example

This simple example allows you to understand what the library actually does.

```swift
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
```
As a result, we get something like:

![Example](Documentation/images/example.gif)

## Initialization

First of all include the library in code:

```swift
import StringEx
```

Creating `StringEx` instance:

```swift
// Creating with an initializer from a string
var ex = StringEx(string: "Hello, World!")

// Creating with an initializer from a NSAttributedString
ex = StringEx(attributedString: NSAttributedString(string: "Hello, World!"))

// Shorthand method for strings
ex = "Hello, World!".ex

// Shorthand method for NSAttributedString
ex = NSAttributedString(string: "Hello, World!").ex
```

## String selectors

String selectors are the :heart: &nbsp;of the library. With selectors, you can select sub-ranges of a string in different ways and in a uniform manner. Various manipulations can be performed on the selected substrings, such as deleting, replacing, adding other strings, and applying styles.

There are two ways to execute selectors:

```swift
let ex = "Hello, World!".ex

// Using select method
ex.select(.string("world")).style(.color(.red))

// or using subscript on StringEx instance
ex[.string("world")].style(.color(.red))
```

These methods set an internal pointer to the passed selector and return the same object. This allows you to chain other methods (on the same instance) within a single statement.

> The result of executing the selector is an array of ranges sorted by their lower bound. If there are overlapping ranges as a result, they are combined into one range.

The following types of selectors are available:

### HTML tags

`StringEx` can process HTML strings, allowing you to select substrings within HTML tags by tag name, class or identifier. HTML tags syntax must conform to the specification available at [https://html.spec.whatwg.org/multipage/syntax.html](https://html.spec.whatwg.org/multipage/syntax.html)

```swift
let ex = "Example: <p id="example"><span class="word1">Hello</span>, <span class="word2">World</span>!</p>".ex

// Select by tag name
let str1 = ex[.tag("span")].selectedString
print(str1) // HelloWorld

// Select by tag class
let str2 = ex[.class("word1")].selectedString
print(str2) // Hello

// Select by tag identifier
let str3 = ex[.id("example")].selectedString
print(str3) // Hello, World!
```

You can also use self-closing tags:

```swift
let ex = "Hello, <name />!".ex
let str = ex[.tag("name")].insert("World").string
print(str) // Hello, World!
```

### Substrings

```swift
let ex = "Hello, World!".ex

// Case insensitive search
let str1 = ex[.string("hello")].selectedString
print(str1) // Hello

// Case sensitive search
let str2 = ex[.string("World", caseInsensitive: false)].selectedString
print(str2) // World

let str3 = ex[.string("world", caseInsensitive: false)].selectedString
print(str3.isEmpty) // true
```

### Regular expressions

```swift
let ex = "Hello, World!".ex

// Select only latin symbols
let str1 = ex[.regex("[a-zA-Z]")].selectedString
print(str1) // HelloWorld

// Using NSRegularExpression.Options
let str2 = ex[.regex("[a-z]", options: [.caseInsensitive])].selectedString
print(str2) // HelloWorld
```

### Ranges

`StringEx` uses a `Range<Int>` to work with ranges. The index corresponds to each displayed character in the string, where the first character is at index`0`, the last is at index `str.count - 1`

> In HTML strings, indices correspond to characters in a string without tags

```swift
let ex = "Hello, World!".ex

// Select first 5 symbols
let str1 = ex[.range(0..<5)].selectedString
print(str1) // Hello

// It is safe to pass a range that is out of range
let str2 = ex[.range(-Int.max..<Int.max)].selectedString
print(str2) // Hello, World!
```

### Nested selectors

You can use nested selectors to search within the parent selector.

```swift
// Select first character of each span tag
let selector1: StringSelector = .tag("span").select(.range(0..<1))

// or do the same using the shorthand operator =>
let selector2: StringSelector = .tag("span") => .range(0..<1)

print(selector1 == selector2) // true
```

```swift
let ex = "<b><span>Hello</span></b>, <span><b>World</b></span>!".ex
let str = ex[.tag("span") => .tag("b") => .range(0..<1)].selectedString
print(str) // W
```

### Selectors union

You can combine multiple selectors into one to perform searches within a single statement.

```swift
// Select inner contents of each span and em tags
let selector1: StringSelector = .tag("span").add(.tag("em"))

// or do the same using the shorthand operator +
let selector2: StringSelector = .tag("span") + .tag("em")

print(selector1 == selector2) // true
```

```swift
let ex = "<span>Hello</span>, <em>World</em>!".ex
let str = ex[.tag("span") + .tag("em")].selectedString
print(str) // HelloWorld
```

### Filtering selectors

You can filter the results of the selectors to get the desired result subset.

```swift
// Get the first result of the selector
let selector1: StringSelector = .tag("span").filter(.first)

// or do the same using the shorthand operator %
let selector2: StringSelector = .tag("span") % .first

print(selector1 == selector2) // true
```

```swift
let ex = "<b>H</b><b>e</b><b>l</b><b>l</b><b>o</b>, <b>W</b><b>o</b><b>r</b><b>l</b><b>d</b>!".ex

// Reduces the set of the selector results to the first in the set
let str1 = ex[.tag("b") % .first].selectedString
print(str1) // H

// Reduces the set of the selector results to the last in the set
let str2 = ex[.tag("b") % .last].selectedString
print(str2) // d

// Reduces the set of the selector results to the one at the specified index
let str3 = ex[.tag("b") % .eq(5)].selectedString
print(str3) // W

// Reduces the set of the selector results to even ones in the set
let str4 = ex[.tag("b") % .even].selectedString
print(str4) // Hlool

// Reduces the set of the selector results to odd ones in the set
let str5 = ex[.tag("b") % .odd].selectedString
print(str5) // elWrd

// Select all selector results at the index greater than index within the set
let str6 = ex[.tag("b") % .gt(4)].selectedString
print(str6) // World

// Select all selector results at the index less than index within the set
let str7 = ex[.tag("b") % .lt(5)].selectedString
print(str7) // Hello
```

### Priority

You can change the order of the operators using parentheses similar to the conventional arithmetic expressions.

```swift
let ex = "<span><b>Hello</b></span>, <em><b>World</b></em>!".ex

let selector1: StringSelector = .tag("span") + .tag("em") => .range(0..<1)
print(ex[selector1].selectedString) // HelloW

let selector2: StringSelector = (.tag("span") + .tag("em")) => .range(0..<1)
print(ex[selector2].selectedString) // HW

let selector3: StringSelector = .tag("span") => .tag("b") % .last
print(ex[selector3].selectedString) // Hello

let selector4: StringSelector = .tag("span") => (.tag("b") % .last)
print(ex[selector4].selectedString.isEmpty) // true
```