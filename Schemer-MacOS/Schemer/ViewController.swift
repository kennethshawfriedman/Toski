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
		//InterfaceBuilder Connected
	@IBOutlet var cf: CodeField!
	@IBOutlet var scrollView: NSScrollView!
		//non-UI
	let task = SchemeProcess.shared
	let pipeIn = Pipe()
	var handleIn = FileHandle()
	let pipeOut = Pipe()
	
	var warmingUp = true
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		

		//set up coding field #todo [these eventually should become part of the class CodeField class]
		cf.font = NSFont(descriptor: NSFontDescriptor.init(name: "SourceCodePro-Regular", size: 16) , size: 16)
		cf.isContinuousSpellCheckingEnabled = false
		cf.isAutomaticSpellingCorrectionEnabled = false
		cf.toggleContinuousSpellChecking(nil) //bizzare, but needed to prevent spell checking
		cf.isAutomaticQuoteSubstitutionEnabled = false
		
		//Setting Delegates
		cf.delegate = self
		cf.textStorage?.delegate = self
		
		//watch for keydown
		NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
			self.keyDown(with: $0)
			return $0
		}
		
		task.launchPath = "/usr/local/bin/mit-scheme"	//this should eventually be detirmined per-machine (which is working in one of the playgrounds)
		
		//task set up
		task.standardOutput = pipeOut
		task.standardInput = pipeIn
		
		handleIn = pipeIn.fileHandleForWriting
		let outHandle = pipeOut.fileHandleForReading
		
		//this reads in new info from pipe when available
		outHandle.readabilityHandler = { pipe in
			if let line = String(data: pipe.availableData, encoding: String.Encoding.utf8) {
				print(line, terminator: "")
				
				if self.warmingUp {
					return
				}
				
				DispatchQueue.main.sync {
					
					let fontAttribute = [NSFontAttributeName: NSFont(descriptor: NSFontDescriptor.init(name: "SourceCodePro-Regular", size: 16) , size: 16)!]
					let atString = NSAttributedString(string: line, attributes: fontAttribute)
					self.cf.textStorage?.append(atString)
					
				}
			} else {
				pipe.closeFile()
				print("Error decoding data: \(pipe.availableData)")
			}
		}
		
		
	}
	
	override func viewDidAppear() {
		task.launch()
	}
	
	//called on every key-stroke of non-modifier keys
	override func keyDown(with event: NSEvent) {
		
		//If Command is Being Held, check for more things
		if (event.modifierFlags.contains(.command)) {
			
			//Cmd+Enter
			if (event.characters == "\r") {
				executeCommand()
			}
		
		}
	}
	
	func executeCommand() {
		
		warmingUp = false
		
		let nothingHereMessage = "(pp \"nothing here\")"
		let excText:String = cf.textStorage?.string ?? nothingHereMessage
		
		let excData:Data = excText.data(using: String.Encoding.utf8)!
		handleIn.write(excData)
	}
	
	@IBAction func ExitNow(sender: AnyObject) {
		NSApplication.shared().terminate(self)
	}
	
}

//Extension Contains the Delegate Methods
extension ViewController: NSTextViewDelegate, NSTextStorageDelegate {
	
	func textViewDidChangeSelection(_ notification: Notification) {
		//Swift.print("at least it's something")
	}
	
	func textView(_ textView: NSTextView, shouldChangeTextInRanges affectedRanges: [NSValue], replacementStrings: [String]?) -> Bool {
		return true
	}
}

class CodeField : NSTextView {
	
	override func performKeyEquivalent(with event: NSEvent) -> Bool {
		return true
	}
	
}

