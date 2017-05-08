//
//  Syntaxr.swift
//  Schemer
//
//  Created by Kenneth Friedman on 5/7/17.
//  Copyright © 2017 Kenneth Friedman. All rights reserved.
//

import Cocoa

//Static class for syntax highlighting
class Syntaxr {
	
	//for a given line (as a string), return a string formatter with proper highlighting
	static func highlightLine(_ line:String) -> NSAttributedString {
		
		let result:NSMutableAttributedString = NSMutableAttributedString()
		var insideAQuote = false
		var locOfSemi = line.characters.indices.endIndex
		for i in line.characters.indices {
			let char = line[i]
			if (char == "\"") {
				insideAQuote = !insideAQuote
			} else if (char == ";" && !insideAQuote) {
				locOfSemi = i
				break
			}
		}
		
		if locOfSemi != line.characters.indices.endIndex {
			let firstSubtring = line.substring(to: locOfSemi)
			let secondSubstring = line.substring(from: locOfSemi)
			let aFirst = NSAttributedString.init(string: firstSubtring, attributes: CodeField.standardAtrributes())
			let aSecond = NSAttributedString.init(string: secondSubstring, attributes: [NSFontAttributeName: CodeField.standardFont(), NSForegroundColorAttributeName: NSColor.gray])
			result.append(aFirst)
			result.append(aSecond)
		} else {
			let aLine = NSAttributedString(string: line, attributes: CodeField.standardAtrributes())
			result.append(aLine)
		}
		return result
	}
	
	//take all text from textview, seperate by line, and syntax highlight at the per line level
	static func highlightAllText(_ text:String) -> NSAttributedString {
		let lines = text.components(separatedBy: "\n")
		let formattedText = NSMutableAttributedString()
		for i in 0..<lines.count {
			let line = lines[i]
			let formattedLine = Syntaxr.highlightLine(line)
			formattedText.append(formattedLine)
			if (i != lines.count-1) { //append new line char, unless it's the last line
				let aNewLine = NSAttributedString(string: "\n", attributes: CodeField.standardAtrributes())
				formattedText.append(aNewLine)
			}
		}
		return formattedText
	}
}
