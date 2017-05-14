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
	////UI Variables
	@IBOutlet var cf: CodeField!
	@IBOutlet var outField: NSTextView!
	
	////Non-UI Variables
	var handleIn = FileHandle()
	let task = SchemeProcess.shared
	var backspace = false //is most recent char the backspace?
	var warmingUp = true  //is Scheme process still "warming up"?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let pipeOut = Pipe()
		let pipeIn = Pipe()

		cf.font = CodeField.standardFont()
		cf.isContinuousSpellCheckingEnabled = false
		cf.isAutomaticQuoteSubstitutionEnabled = false
		cf.isAutomaticQuoteSubstitutionEnabled = false
		cf.isEditable = false //don't edit until scheme launches
		cf.textContainer?.containerSize = NSSize.init(width: CGFloat.infinity, height: CGFloat.infinity)
		
		
		outField.isEditable = false;
		outField.font = CodeField.standardFont()
		let tempStr = NSAttributedString(string: "                                  ", attributes: CodeField.stdAtrributes())
		outField.textStorage?.setAttributedString(tempStr)
		
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
			
			let inLine = String(data: pipe.availableData, encoding: .utf8)
			guard let line = inLine else { return }
			
			print("\(line)", terminator: "")
			
			//No need to show the user the REPL input text: the input can be anywhere!
			let newLine = line.replacingOccurrences(of: "1 ]=> ", with: "")

			//if you shouldn't prin the line, just return
			guard !self.warmingUp else { return }
			
			//adding text back to the view requires you to be on the main thread, but this readabilityHandler is async
			DispatchQueue.main.sync {
				//add the proper font to the text, and append it to the codingfield (cf)
				let fontAttribute = [NSFontAttributeName: CodeField.standardFont()]
				let atString = NSAttributedString(string: newLine, attributes: fontAttribute)
				//let insertSpot = SchemeComm.locationOfCursor(codingField: self.cf)
				//KSF: inserting at the cursor location
				//self.cf.textStorage?.insert(atString, at: insertSpot)
				self.outField.textStorage?.append(atString)
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
		
		backspace = event.characters == "\u{7F}" //backspace is true if it was the backspace key
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
		guard !backspace else { return }
		let textStorage = notification.object as! NSTextStorage
		let allText = textStorage.string
		let formattedText = Syntaxr.highlightAllText(allText)
		textStorage.setAttributedString(formattedText)
	}
}

//Extension Contains the Delegate Methods
extension ViewController: NSTextViewDelegate, NSTextStorageDelegate {
	
	//this is called on every selection change, which includes typing and moving cursor
	func textViewDidChangeSelection(_ notification: Notification) {
		
		//NOTE FROM KSF: this is the beginning of the highlight to eval feature.
		//however, the necessary features aren't implemented yet, so all it does is execute and print the procedures
		//that you highlight. There's no checking or anything. Don't uncomment unless you want to play with just this feature
		
//		let sRange = cf.selectedRange()
//		guard (sRange.length > 1) else {return}
//		let maybeSelectedText = cf.textStorage?.string
//		guard let selectedText = maybeSelectedText else { return }
//		let selectedNSString = NSString(string: selectedText)
//		let highlightedText = selectedNSString.substring(with: sRange)
//		let maybeHighlightAsData = highlightedText.data(using: .utf8)
//		guard let highlightData = maybeHighlightAsData else { return }
//		handleIn.write(highlightData)
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
		return [NSFontAttributeName: CodeField.standardFont()]
	}
	
	static func stdFontSize() -> CGFloat {
		return 16
	}
	
}
