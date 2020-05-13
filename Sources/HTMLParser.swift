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
    private var offset: Int = 0 // Distance from the beginning of the source to the current cursor position (symbols count)
    private var offsetCorrection: Int = 0 // Offset correction due to missing tags
    
    private var depth = 0 // Current tag depth
    private var counter = [HTMLTag: Int]() // Start tags count
    private var queue = [HTMLTag]() // Queue of the start tags
    
    private var resultStringLength: Int = 0
    
    init(source: String) {
        self.source = source
        rawString = source
        resultString = ""
        
        index = source.startIndex
    }
    
    func parse() {
        if source.count == 0 {
            return
        }
        
        // Find all substrings that begin with "<" and end with ">" and then try to parse html tags..
        guard let regex = try? NSRegularExpression(pattern: "<[^>]+>", options: []) else {
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
            appendResultString(to: source.endIndex)
        }
        
        // Close all missing end tags
        if queue.count > 0 {
            for startTag in queue.reversed() {
                depth -= 1
                
                var missingTag = HTMLTag(type: .endTag, tagName: startTag.tagName)
                insert(tag: &missingTag)
                storage.add(startTag: startTag, endTag: missingTag)
            }
        }
    }
    
    private func process(tag: HTMLTag, in range: Range<String.Index>) {
        var tag = tag
        
        // Determine the offset of the range
        let startOffset = source.distance(from: index, to: range.lowerBound) + offset
        let endOffset = source.distance(from: index, to: range.upperBound) + offset
        
        // Append the part of the source between two tags to the result string
        appendResultString(to: range.lowerBound)
        
        // Update the current index and offset
        index = range.upperBound
        offset = endOffset
        
        if tag.type == .startTag {
            configure(tag: &tag, startOffset: startOffset, endOffset: endOffset)
            depth += 1
            queue.append(tag)
            counter[tag] = (counter[tag] ?? 0) + 1
        } else if tag.type == .endTag {
            if (counter[tag] ?? 0) > 0 { // If there is the same start tag in the queue
                var closedCount = 0
                
                // Close start tags until we meet the same tag
                for startTag in queue.reversed() {
                    depth -= 1
                    counter[startTag] = (counter[startTag] ?? 0) - 1
                    closedCount += 1
                    
                    if startTag == tag {
                        configure(tag: &tag, startOffset: startOffset, endOffset: endOffset)
                        storage.add(startTag: startTag, endTag: tag)
                        break
                    } else {
                        // Insert missing end tag to the raw string
                        var missingTag = HTMLTag(type: .endTag, tagName: startTag.tagName)
                        insert(tag: &missingTag, offsetBy: startOffset)
                        storage.add(startTag: startTag, endTag: missingTag)
                    }
                }
                
                // Remove closed start tags from the queue
                queue.removeLast(closedCount)
            } else {
                // If there is no same start tag then insert missing start tag to rhe raw string
                var missingTag = HTMLTag(type: .startTag, tagName: tag.tagName)
                insert(tag: &missingTag, offsetBy: startOffset)
                configure(tag: &tag, startOffset: startOffset, endOffset: endOffset)
                storage.add(startTag: missingTag, endTag: tag)
            }
        } else if tag.type == .selfClosingTag {
            configure(tag: &tag, startOffset: startOffset, endOffset: endOffset)
            storage.add(selfClosingTag: tag)
        }
    }
    
    private func appendResultString(to upperBound: String.Index) {
        resultString.append(contentsOf: source[index..<upperBound])
        resultStringLength = resultString.count
    }
    
    private func insert(tag: inout HTMLTag, offsetBy: Int? = nil) {
        let tagString = "\(tag)"
        let tagStringLength = tagString.count
        
        if let offsetBy = offsetBy {
            rawString.insert(contentsOf: tagString, at: rawString.index(rawString.startIndex, offsetBy: offsetBy + offsetCorrection))
            configure(tag: &tag, startOffset: offsetBy, endOffset: offsetBy + tagStringLength)
        } else {
            let rawStringLength = rawString.count
            
            rawString.append(tagString)
            configure(tag: &tag, startOffset: rawStringLength, endOffset: rawStringLength + tagStringLength)
        }
        
        offsetCorrection += tagStringLength
    }
    
    private func configure(tag: inout HTMLTag, startOffset: Int, endOffset: Int) {
        tag.depth = depth
        tag.rawRange = startOffset + offsetCorrection..<endOffset + offsetCorrection
        tag.position = resultStringLength
    }
}
