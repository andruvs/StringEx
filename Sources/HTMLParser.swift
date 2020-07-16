//
//  HTMLParser.swift
//  StringEx
//
//  Created by Andrey Golovchak on 20/04/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation

class HTMLParser {
    
    private let source: String // Initial string for parsing
    
    private(set) var rawString: String // String with missing tags
    private(set) var resultString: String // String without tags
    private(set) var storage = HTMLTagStorage()
    
    private var index: String.Index // Current cursor position
    private var rawStringLength: Int = 0 // Raw string symbols count
    private var resultStringLength: Int = 0 // Result string symbols count
    
    private var depth = 0 // Current tag depth
    private var counter = [String: Int]() // Start tags count
    private var queue = [HTMLStartTag]() // Queue of the start tags
    
    //private var resultStringLength: Int = 0
    
    init(source: String) {
        self.source = source
        
        index = source.startIndex
        
        rawString = ""
        resultString = ""
    }
    
    func parse() {
        if source.count == 0 {
            return
        }
        
        // Find all substrings that begin with "<" and end with ">" and then try to parse html tags..
        guard let regex = try? NSRegularExpression(pattern: "<[^>]+>", options: []) else {
            resultString = source
            return
        }
        
        // The enumerateMatches method works internally with NSString that matches UTF16View elements of the String
        regex.enumerateMatches(in: source, options: [], range: NSMakeRange(0, source.utf16.count)) { result, _, _ in
            if let result = result, let range = Range(result.range, in: source) {
                let parser = HTMLTagParser(source: String(source[range]))
                if let tag = parser.parse() {
                    process(tag: tag, in: range)
                }
            }
        }
        
        // Append the last part of the source without tags
        if index < source.endIndex {
            appendString(to: source.endIndex)
        }
        
        // Close all missing end tags
        if queue.count > 0 {
            for startTag in queue.reversed() {
                depth -= 1
                
                let missingTag = HTMLEndTag(tagName: startTag.tagName)
                appendHTMLTag(missingTag)
                storage.append(HTMLTagPair(startTag: startTag, endTag: missingTag))
            }
        }
    }
    
    private func process(tag: HTMLTag, in range: Range<String.Index>) {
        
        // Append the part of the source string from cursor position to the current tag
        appendString(to: range.lowerBound)
        
        // Update the current cursor position
        index = range.upperBound
        
        if let tag = tag as? HTMLSelfClosingTag {
            let startTag = tag.startTag
            let endTag = tag.endTag
            appendHTMLTag(startTag)
            appendHTMLTag(endTag)
            storage.append(HTMLTagPair(startTag: startTag, endTag: endTag))
        } else if let tag = tag as? HTMLStartTag {
            appendHTMLTag(tag)
            depth += 1
            queue.append(tag)
            counter[tag.tagName] = (counter[tag.tagName] ?? 0) + 1
        } else if let tag = tag as? HTMLEndTag {
            if (counter[tag.tagName] ?? 0) > 0 { // If there is the same start tag in the queue
                var closedCount = 0
                
                // Close start tags until we meet the same tag
                for startTag in queue.reversed() {
                    depth -= 1
                    counter[startTag.tagName] = (counter[startTag.tagName] ?? 0) - 1
                    closedCount += 1
                    
                    if startTag == tag {
                        appendHTMLTag(tag)
                        storage.append(HTMLTagPair(startTag: startTag, endTag: tag))
                        break
                    } else {
                        // Insert missing end tag to the raw string
                        let missingTag = HTMLEndTag(tagName: startTag.tagName)
                        appendHTMLTag(missingTag)
                        storage.append(HTMLTagPair(startTag: startTag, endTag: missingTag))
                    }
                }
                
                // Remove closed start tags from the queue
                queue.removeLast(closedCount)
            } else {
                // If there is no same start tag then insert missing start tag to rhe raw string
                let missingTag = HTMLStartTag(tagName: tag.tagName)
                appendHTMLTag(missingTag)
                appendHTMLTag(tag)
                storage.append(HTMLTagPair(startTag: missingTag, endTag: tag))
            }
        }
    }
    
    private func appendString(to upperBound: String.Index) {
        let str = source[index..<upperBound]
        let strLength = str.count
        
        rawString.append(contentsOf: str)
        resultString.append(contentsOf: str)
        
        rawStringLength += strLength
        resultStringLength += strLength
    }
    
    private func appendHTMLTag(_ tag: HTMLTag) {
        let str: String = "\(tag)"
        let strLength = str.count
        
        tag.depth = depth
        tag.rawRange = rawStringLength..<rawStringLength + strLength
        tag.position = resultStringLength
        
        rawString.append(contentsOf: str)
        
        rawStringLength += strLength
    }
}
