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
	////InterfaceBuilder Connected
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

		//cf.setupCodingField()
		cf.font = NSFont(descriptor: NSFontDescriptor.init(name: "SourceCodePro-Regular", size: 16) , size: 16)
		cf.isContinuousSpellCheckingEnabled = false
		cf.isAutomaticQuoteSubstitutionEnabled = false
		cf.toggleContinuousSpellChecking(nil)
		cf.isAutomaticQuoteSubstitutionEnabled = false
		
		
		//Setting Delegates
		cf.delegate = self
		cf.textStorage?.delegate = self
		
		//watch for keydown
		NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
			self.keyDown(with: $0)
			return $0
		}
		
		//task.launchPath = "/usr/local/bin/mit-scheme"	//this should eventually be detirmined per-machine (which is working in one of the playgrounds)
		//The launchpath on my machine is "/usr/local/bin/mit-scheme", but if this is different on someone else's computer, i
		task.launchPath = SchemeHelper.findSchemeLaunchPath()
		
		//task set up
		task.standardOutput = pipeOut
		task.standardInput = pipeIn
		
		handleIn = pipeIn.fileHandleForWriting
		let outHandle = pipeOut.fileHandleForReading
		
		//this reads in new info from pipe when available
		outHandle.readabilityHandler = { pipe in
			if let line = String(data: pipe.availableData, encoding: String.Encoding.utf8) {
				print("\(line)", terminator: "")
				
				//if no more changes happen to the checking to see if it's warmed up, it's not ncessary to have these double booleans,
				//// but there might be a case where more checking needs to be done. In which case, it can stay for now
				var shouldPrintLine = true
				
				let newLine = line.replacingOccurrences(of: "1 ]=> ", with: "")
				
				//if the user hasn't executed a command yet, no need to print whatever warm up text is happening
				if self.warmingUp {
					shouldPrintLine = false
				}
				
				//if the line should be printed
				if shouldPrintLine {
					//adding text back to the view requires you to be on the main thread, but this readabilityHandler is async
					DispatchQueue.main.sync {
						//add the proper font to the text, and append it to the codingfield (cf)
						let fontAttribute = [NSFontAttributeName: NSFont(descriptor: NSFontDescriptor.init(name: "SourceCodePro-Regular", size: 16) , size: 16)!]
						let atString = NSAttributedString(string: newLine, attributes: fontAttribute)
						self.cf.textStorage?.append(atString)
						
					}
				}
			}
		}
	}
	
	//When the
	override func viewDidAppear() {
		task.launch()
	}
	
	//called on every key-stroke of non-modifier keys
	override func keyDown(with event: NSEvent) {
		
		//Check if the command key is pressed, if it is: send to other function to handle
		let commandKey:Bool = event.modifierFlags.contains(.command)
		if (commandKey) {
			handleKeyPressWithCommand(from: event)
		}
	}
	
	func handleKeyPressWithCommand(from event:NSEvent) {
		
		let character:String = event.characters ?? ""
		
		switch character {
			case "\r":	//this handles Cmd+enter
				executeCommand()
				break
			default:
				break
		}
	}
	
	//This function is called on Cmd+Enter: it executes a call to Scheme Communication
	func executeCommand() {
		warmingUp = false
		let nothingHereMessage = "(pp \"nothing here\")"
		let currentText:String = cf.textStorage?.string ?? nothingHereMessage
		let dataToSubmit = SchemeComm.parseExecutionCommand(allText: currentText)
		handleIn.write(dataToSubmit)
		cf.moveToEndOfDocument(nil)
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
	
	func setupCodingField() {
	}
	
	override func performKeyEquivalent(with event: NSEvent) -> Bool {
		return true
	}
	
}

