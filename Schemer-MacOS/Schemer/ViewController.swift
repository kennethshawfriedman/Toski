//
//  ViewController.swift
//  Schemer
//
//  Created by Kenneth Friedman on 5/2/17.
//  Copyright © 2017 Kenneth Friedman. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
	
	//Class Variables
	@IBOutlet var cf: CodeField!
	@IBOutlet var scrollView: NSScrollView!
	
	override func viewDidLoad() {
		super.viewDidLoad()

		//set up coding field #todo [these eventually should become part of the class CodeField class]
		cf.font = NSFont(descriptor: NSFontDescriptor.init(name: "SourceCodePro-Regular", size: 16) , size: 16)
		cf.isContinuousSpellCheckingEnabled = false
		cf.isAutomaticSpellingCorrectionEnabled = false
		cf.toggleContinuousSpellChecking(nil) //bizzare, but needed to prevent spell checking
		
		//Setting Delegates
		cf.delegate = self
		cf.textStorage?.delegate = self
		
		//watch for keydown
		NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
			self.keyDown(with: $0)
			return $0
		}
		
	}
	
	//called on every key-stroke of non-modifier keys
	override func keyDown(with event: NSEvent) {
		super.keyDown(with: event)
		
		//If Command is Being Held, check for more things
		if (event.modifierFlags.contains(.command)) {
			
			//Cmd+Enter
			if (event.characters == "\r") {
				print("LET'S GO!")
			}
		}
	}
}

//Extension Contains the Delegate Methods
extension ViewController: NSTextViewDelegate, NSTextStorageDelegate {
	
	func textViewDidChangeSelection(_ notification: Notification) {
		//Swift.print("at least it's something")
	}
	
	func textView(_ textView: NSTextView, shouldChangeTextInRanges affectedRanges: [NSValue], replacementStrings: [String]?) -> Bool {
		print(replacementStrings ?? "rut roh!")
		return true
	}
}

class CodeField : NSTextView {
	
	
}
