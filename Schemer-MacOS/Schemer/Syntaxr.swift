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
		
		var insideAQuote = false //are you inside a quote right now?
		for i in line.characters.indices { //loop through each character
			let char = line[i]
			if (char == "\"") { //if it's a quote, flip the boolean
				insideAQuote = !insideAQuote
			} else if (char == ";" && !insideAQuote) {
				//we found the semicolon! Rest of line doesn't matter
				let firstSubtring = line.substring(to: i)
				let secondSubstring = line.substring(from: i)
				let aFirst = NSAttributedString.init(string: firstSubtring, attributes: CodeField.stdAtrributes())
				let aSecond = NSAttributedString.init(string: secondSubstring, attributes: [NSFontAttributeName: CodeField.standardFont(), NSForegroundColorAttributeName: NSColor.gray])
				let result:NSMutableAttributedString = NSMutableAttributedString()
				result.append(aFirst)
				result.append(aSecond)
				return result
			}
		}
		let aLine = NSAttributedString(string: line, attributes: CodeField.stdAtrributes())
		return aLine
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
				let aNewLine = NSAttributedString(string: "\n", attributes: CodeField.stdAtrributes())
				formattedText.append(aNewLine)
			}
		}
		return formattedText
	}
}
