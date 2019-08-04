//
//  CodeField.swift
//  Toski
//
//  Created by Kenneth Friedman on 6/19/19.
//  Copyright © 2019 Kenneth Friedman. All rights reserved.
//

import Cocoa

class CodeField : NSTextView {

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		//this forces a light mode... should support dark mode eventually
		self.backgroundColor = .white
		self.insertionPointColor = .black
		self.font = CodeField.standardFont()
		self.isContinuousSpellCheckingEnabled = false
		self.isAutomaticQuoteSubstitutionEnabled = false
		self.isAutomaticQuoteSubstitutionEnabled = false
		self.isEditable = false //don't edit until scheme launches
		self.textContainer?.containerSize = NSSize.init(width: CGFloat.infinity, height: CGFloat.infinity)		
	}
	
	static func standardFont() -> NSFont {
		
		//tries to find source-code-pro (this *should* find the bundled font now)
		let fontDescriptor = NSFontDescriptor(name: "SourceCodePro-Regular", size: CodeField.stdFontSize())
		let font = NSFont(descriptor: fontDescriptor, size: CodeField.stdFontSize())
		if let f = font {
			return f
		}
		
		//if it can't find it, it uses Monaco (which *should* be default installed)
		let fontDescriptorBackup = NSFontDescriptor(name: "Monaco", size: CodeField.stdFontSize())
		let fontBackup = NSFont(descriptor: fontDescriptorBackup, size: CodeField.stdFontSize())
		if let fBackup = fontBackup {
			return fBackup
		}
		
		//if all else fails, it returns the system font
		return NSFont.systemFont(ofSize: CodeField.stdFontSize())
	}
	
	static func stdAtrributes() -> [NSAttributedString.Key : Any] {
		return [NSAttributedString.Key.font : CodeField.standardFont()]
	}
	
	static func stdFontSize() -> CGFloat {
		return 16
	}
	
	func NSRangeFromRange(range r: Range<String.Index>) -> NSRange {
		let text = self.textStorage!.string
		let start = text.distance(from: text.startIndex, to: r.lowerBound)
		let length = text.distance(from: r.lowerBound, to: r.upperBound)
		return NSMakeRange(start, length)
	}
	
	//This function prevents the "error bell" sound from occuring on every keystroke
	//This was first noticed in Toksi issue #4: https://github.com/kennethshawfriedman/Toski/issues/4
	override func performKeyEquivalent(with event: NSEvent) -> Bool {
		return true
	}
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
