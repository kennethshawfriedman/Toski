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
	
	static func stdAtrributes() -> [String : Any] {
		return [convertFromNSAttributedStringKey(NSAttributedString.Key.font): CodeField.standardFont()]
	}
	
	static func stdFontSize() -> CGFloat {
		return 16
	}
	
	// command+drag to slide numerical values
	// inspiration from https://github.com/Shopify/superdb/blob/develop/SuperDebug/Super%20Debug/SuperDraggableShellView.m#L129
	override func mouseDown(with event: NSEvent) {
		if !event.modifierFlags.contains(.command) {
			return super.mouseDown(with: event)
		}
		
		let start_location = event.locationInWindow
		
		let initial_string = self.textStorage!.string
		var hit_char_index = initial_string.index(initial_string.startIndex, offsetBy:
			// for who-knows-why reasons, .charachterIndex() takes mouse in global coordinates,
			// so we use NSEvent.mouseLocation() to get it
			self.characterIndex(for: NSEvent.mouseLocation))
		
		// make sure we're not passed the end of the chars
		if hit_char_index == initial_string.endIndex {
			hit_char_index = initial_string.index(before: hit_char_index)
		}
		
		Swift.print(initial_string[hit_char_index])
		
		// scan left for start of number token
		var start_index = hit_char_index
		while start_index != initial_string.startIndex {
			let next_index = initial_string.index(before: start_index)
			
			if !["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].contains(initial_string[next_index]) {
				// number doesn't continue left
				break;
			}
			
			start_index = next_index
		}
		
		// scan right for end of number token
		var end_index = hit_char_index
		while end_index != initial_string.endIndex {
			if !["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].contains(initial_string[end_index]) {
				// number doesn't continue left
				break;
			}
			
			end_index = initial_string.index(after: end_index)
		}
		
		if initial_string.distance(from: start_index, to: end_index) == 0 {
			// there's no number token here
			return
		}
		
		//let initial_text_range = Range.init(uncheckedBounds: (lower: start_index, upper: end_index))
		//let initial_number = Int(initial_string.substring(with: initial_text_range))!
		let initial_text_range = start_index ..< end_index
		let init_substring = initial_string[initial_text_range]
		let init_regular_str = String(init_substring)
		let initial_number = Int(init_regular_str)
		
		
		
		var range = NSRangeFromRange(range: initial_text_range)
		self.setSelectedRange(range)
		
		// technique from https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/EventOverview/HandlingMouseEvents/HandlingMouseEvents.html#//apple_ref/doc/uid/10000060i-CH6-SW4
		while true {
			let next_event = self.window!.nextEvent(matching: NSEvent.EventTypeMask.leftMouseUp.union(.leftMouseDragged))!
			switch next_event.type {
				
			case .leftMouseDragged:
				let deltaX = next_event.locationInWindow.x - start_location.x
				let new_value = (initial_number ?? 0) + Int(deltaX / 10)
				let strval = String(new_value)
				self.insertText(strval, replacementRange: range)
				
				range.length = strval.count
				self.setSelectedRange(range)
				
			case .leftMouseUp:
				// mouse is up, so the drag is over, and we should break out of the drag loop
				Swift.print("mouse up")
				return
				
			default:
				// we should never get any eevents other than mouse up or dragged
				Swift.print("mouse dragging code got a wrong event")
				break
			}
			
		}
	}
	
	func NSRangeFromRange(range r: Range<String.Index>) -> NSRange {
		let text = self.textStorage!.string
		let start = text.distance(from: text.startIndex, to: r.lowerBound)
		let length = text.distance(from: r.lowerBound, to: r.upperBound)
		return NSMakeRange(start, length)
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
