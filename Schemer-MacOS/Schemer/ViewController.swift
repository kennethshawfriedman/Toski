//
//  ViewController.swift
//  Schemer
//
//  Created by Kenneth Friedman on 5/2/17.
//  Copyright © 2017 Kenneth Friedman. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextViewDelegate, NSTextStorageDelegate {

	let cfOLD = CodeField()
	
	@IBOutlet var cf: CodeField!
	@IBOutlet var scrollView: NSScrollView!
	
	override func viewDidLoad() {
		super.viewDidLoad()

		//sets font to sourcecodepro and sets
		cf.font = NSFont(descriptor: NSFontDescriptor.init(name: "SourceCodePro-Regular", size: 16) , size: 16)
		//Setting Delegates
		cf.delegate = self
		cf.textStorage?.delegate = self
		
		//watch for keydown
		NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
			self.keyDown(with: $0)
			return $0
		}
		
		//watch for flag changed
		NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) {
			self.flagsChanged(with: $0)
			return $0
		}
		
		

	}
	
//	override func keyDown(with event: NSEvent) {
//	
//	}
	
	override func keyDown(with event: NSEvent) {
		print("wwworking bro")
	}
	
	override func flagsChanged(with event: NSEvent) {
		print("ok now")
	}
	
}

class CodeField : NSTextView {
	
	
}

extension ViewController {
	
	func textViewDidChangeSelection(_ notification: Notification) {
		//Swift.print("at least it's something")
	}
	
	func textView(_ textView: NSTextView, shouldChangeTextInRanges affectedRanges: [NSValue], replacementStrings: [String]?) -> Bool {
		Swift.print("sign of life")
		print(replacementStrings)
		return true
	}
}
