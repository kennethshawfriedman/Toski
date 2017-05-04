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
		
		//watch for flag changed [we don't need this now because the keydown can check what modifiers are working
//		NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) {
//			self.flagsChanged(with: $0)
//			return $0
//		}
		
	}
	
	//called on every key-stroke of non-modifier keys
	override func keyDown(with event: NSEvent) {
		super.keyDown(with: event)
		print("wwworking bro")
		print("KEY PRESSED: \(event.keyCode)")
		print("MODS: \(event.modifierFlags)")
	}
	
	//called on every modifier change, no longer need this since keyDown will be able to check for modifiers
//	override func flagsChanged(with event: NSEvent) {
//		
//		print(event.modifierFlags)
//		
//		if (event.modifierFlags.contains([.command])) {
//			//print(event.characters ?? "shit")
////			if (event.characters == "\n") {
////				print("command enter!")
////			}
//		}
//	}
	
}

class CodeField : NSTextView {
	
	
}

extension ViewController {
	
	func textViewDidChangeSelection(_ notification: Notification) {
		//Swift.print("at least it's something")
	}
	
	func textView(_ textView: NSTextView, shouldChangeTextInRanges affectedRanges: [NSValue], replacementStrings: [String]?) -> Bool {
		print(replacementStrings ?? "rut roh!")
		return true
	}
}
