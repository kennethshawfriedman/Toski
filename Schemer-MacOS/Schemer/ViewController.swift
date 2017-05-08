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
	@IBOutlet var outField: CodeField!
	@IBOutlet var scrollView: NSScrollView!
	//non-UI
	let task = SchemeProcess.shared
	let pipeIn = Pipe()
	var handleIn = FileHandle()
	let pipeOut = Pipe()
	
	var warmingUp = true

	
	override func viewDidLoad() {
		super.viewDidLoad()

		cf.font = CodeField.standardFont()
		cf.isContinuousSpellCheckingEnabled = false
		cf.isAutomaticQuoteSubstitutionEnabled = false
		cf.toggleContinuousSpellChecking(nil)
		cf.isAutomaticQuoteSubstitutionEnabled = false
		cf.isEditable = false //don't edit until scheme launches
		
		
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
		
		//The Results of a Scheme Execution come back from the REPL into this function:
		outHandle.readabilityHandler = { pipe in
			if let line = String(data: pipe.availableData, encoding: String.Encoding.utf8) {
				print("\(line)", terminator: "")
				
				//if no more changes happen to the checking to see if it's warmed up, it's not ncessary to have these double booleans,
				//// but there might be a case where more checking needs to be done. In which case, it can stay for now
				var shouldPrintLine = true
				
				//No need to show the user the REPL input text: the input can be anywhere!
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
						let fontAttribute = [NSFontAttributeName: CodeField.standardFont()]
						let atString = NSAttributedString(string: newLine, attributes: fontAttribute)
						let insertSpot = SchemeComm.locationOfCursor(codingField: self.cf)
						self.cf.textStorage?.insert(atString, at: insertSpot)
					}
				}
			}
		}
	}
	
	//When the viewcontroller appears, launch Scheme
	override func viewDidAppear() {
		task.launch()
		cf.isEditable = true
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
		let dataToSubmit = SchemeComm.parseExecutionCommand(codingField: cf)
		handleIn.write(dataToSubmit)
	}
	
	@IBAction func ExitNow(sender: AnyObject) {
		NSApplication.shared().terminate(self)
	}
	
	override func textStorageDidProcessEditing(_ notification: Notification) {
		let textStorage = notification.object as! NSTextStorage
		let allText = textStorage.string
		let formattedText = Syntaxr.highlightAllText(allText)
		textStorage.setAttributedString(formattedText)
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
	
	static func standardFont() -> NSFont {
		
		//tries to find source-code-pro (this *should* find the bundled font now)
		let fontDescriptor = NSFontDescriptor(name: "SourceCodePro-Regular", size: 16)
		let font = NSFont(descriptor: fontDescriptor, size: 16)
		if let f = font {
			return f
		}
		
		//if it can't find it, it uses Monaco (which *should* be default installed)
		let fontDescriptorBackup = NSFontDescriptor(name: "Monaco", size: 16)
		let fontBackup = NSFont(descriptor: fontDescriptorBackup, size: 16)
		if let fBackup = fontBackup {
			return fBackup
		}
		
		//if all else fails, it returns the system font
		return NSFont.systemFont(ofSize: 16)
	}
	
	static func standardAtrributes() -> [String : Any] {
		return [NSFontAttributeName: CodeField.standardFont()]
	}
	
}

