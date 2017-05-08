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
	static func highlight(line:String) -> NSAttributedString {
		let result:NSMutableAttributedString = NSMutableAttributedString()
		let semiColonLoc = line.range(of: ";")
		if let scLoc = semiColonLoc {
			let lowerBound = scLoc.lowerBound
			let firstSubtring = line.substring(to: lowerBound)
			let secondSubstring = line.substring(from: lowerBound)
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
	
}
