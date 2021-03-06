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
	@IBOutlet var previewField: NSTextField!
	
	////Non-UI Variables
	var handleIn = FileHandle()
	let task = SchemeProcess.shared
	var backspace = false //is most recent char the backspace?
	var warmingUp = true  //is Scheme process still "warming up"?
	var previewFlag = false //is the user trying to complete a preview execute
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let pipeOut = Pipe()
		let pipeIn = Pipe()
		
		previewField.alphaValue = 0.0 //invisible from start
		
		outField.isEditable = false;
		outField.font = CodeField.standardFont()
		let tempStr = NSAttributedString(string: "", attributes: CodeField.stdAtrributes())
		outField.textStorage?.setAttributedString(tempStr)
		
		//Setting Delegates
		cf.delegate = self
		cf.textStorage?.delegate = self
		cf.parentVC = self
		
		//task.launchPath = "/usr/local/bin/mit-scheme"	//this should eventually be detirmined per-machine (which is working in one of the playgrounds)
		//The launchpath on my machine is "/usr/local/bin/mit-scheme", but if this is different on someone else's computer, i
		task.launchPath = SchemeHelper.findSchemeLaunchPath()
		
		//load up the startup.scm code
		let startupSCMPath = Bundle.main.path(forResource: "startup", ofType: "scm")
		task.arguments = ["--load", startupSCMPath!]
		//task set up
		task.standardOutput = pipeOut
		task.standardInput = pipeIn
		
		handleIn = pipeIn.fileHandleForWriting
		let outHandle = pipeOut.fileHandleForReading
		
		//The Results of a Scheme Execution come back from the REPL into this function:
		outHandle.readabilityHandler = self.readingPipe
		
		//notification to observe when someone pressed Cmd+Enter
		NotificationCenter.default.addObserver(self, selector: #selector(executeCommand), name: NSNotification.Name(rawValue: "executeCommand"), object: nil)
	}
	
	//The Results of a Scheme Execution come back from the REPL into this function:
	func readingPipe(_ pipe:FileHandle) {
		let inLine = String(data: pipe.availableData, encoding: .utf8)
		guard let line = inLine else { return }
		
		print("\(line)", terminator: "")
		
		//No need to show the user the REPL input text: the input can be anywhere!
		var newLine = line.replacingOccurrences(of: "1 ]=> ", with: "")
		newLine = newLine.replacingOccurrences(of: ";Unspecified return value", with: "")
		newLine.stringByRemovingRegexMatches(pattern: "\\d+ error> ") //without espcape: \d+ error>
		
		//if you shouldn't print the line, just return
		guard !self.warmingUp else { return }
		
		//adding text back to the view requires you to be on the main thread, but this readabilityHandler is async
		DispatchQueue.main.sync {
			self.addLineToOutField(newLine)
		}
	}
	
	func addLineToOutField(_ newLine:String) {
		//add the proper font to the text, and append it to the codingfield (cf)
		let fontAtt = [NSAttributedString.Key.font : CodeField.standardFont()]
		let atString = NSAttributedString.init(string: newLine, attributes: fontAtt)
		
		//KSF: the following two lines will insert the response at the cursor location
		//let insertSpot = SchemeComm.locationOfCursor(codingField: self.cf)
		//self.cf.textStorage?.insert(atString, at: insertSpot)
		
		if (self.previewFlag) {
			//preview execution here
			self.previewField.alphaValue = 1.0
			
			let newResult = NSMutableAttributedString.init(attributedString: self.previewField.attributedStringValue)
			newResult.append(atString)
			
			//try to prune uncessary things
			var processString = newResult.string
			
			//REGEX processing:
			let regex  = "(preview-env)|(;Value .+: #\\[environment .+\\])|(;Package: \\(user\\))|(;Unspecified return value)|(\n)|(;Value: )"
			processString.stringByRemovingRegexMatches(pattern: regex)
			
			self.previewField.attributedStringValue = NSAttributedString(string: processString, attributes: CodeField.stdAtrributes())
			
		} else {
			//Not a preview: standard execution
			self.outField.textStorage?.append(atString)
			let strLength = self.outField.string.count
			self.outField.scrollRangeToVisible(NSRange.init(location: strLength, length: 0))
		}
	}
	
	//When the viewcontroller appears, launch Scheme
	override func viewDidAppear() {

		if #available(OSX 10.13, *) {
			do {
				try task.run()
			} catch {
				let alert = NSAlert.init()
				alert.messageText = "Can't access Scheme"
				alert.informativeText = "Toksi can't find MIT Scheme.\nPlease install Scheme at https://www.gnu.org/software/mit-scheme/\nContact the developer if you still can't get it working."
				alert.addButton(withTitle: "OK")
				alert.runModal()
			}
		} else {
			task.launch()
		}
		
		//textfield can be edited as soon as Scheme as been launched
		cf.isEditable = true
	}
		
	//This function is called on Cmd+Enter: it executes a call to Scheme Communication
	@objc func executeCommand() {
		print("execute")
		let dataToSubmit = SchemeComm.parseExecutionCommand(codingField: cf)
		handleIn.write(dataToSubmit)
	}
	
	@IBAction func ExitNow(sender: AnyObject) {
		NSApplication.shared.terminate(self)
	}
	
	override func textStorageDidProcessEditing(_ notification: Notification) {
		warmingUp = false
	}
}

//Extension Contains the Delegate Methods
extension ViewController: NSTextViewDelegate, NSTextStorageDelegate {
	
	//this is called on every selection change, which includes typing and moving cursor
	func textViewDidChangeSelection(_ notification: Notification) {
		
		//NOTE FROM KSF: this is the beginning of the highlight to eval feature.
		//however, the necessary features aren't implemented yet, so all it does is execute and print the procedures
		//that you highlight. There's no checking or anything. Don't uncomment unless you want to play with just this feature
		
		previewFlag = false //always set to false, but change to true if it passes the guard statements
		self.previewField.alphaValue = 0.0 //always make the preview invisible. Change to visible when there is a result
		self.previewField.stringValue = "" //reset the text as soon as the selection changes
		
		//grabs range of selected text
		let sRange = cf.selectedRange()
		guard (sRange.length > 1) else {return}
		let maybeSelectedText = cf.textStorage?.string
		guard let selectedText = maybeSelectedText else { return }
		let selectedNSString = NSString(string: selectedText)
		let highlightedText = selectedNSString.substring(with: sRange)
		
		//trivially looks to match number of parens before attempting a preview execution
		let leftParenCount = highlightedText.countInstances(of: "(")
		let rightParenCount = highlightedText.countInstances(of: ")")
		guard leftParenCount == rightParenCount else { return }
		
		//ensures there is data to execute
		let maybeHighlightAsData = highlightedText.data(using: .utf8)
		guard let highlightData = maybeHighlightAsData else { return }
		
		//creates a new env with same bindings
		let createEnv = "(define preview-env (extend-top-level-environment (the-environment)))".data(using: .utf8)
		
		//enters the new binding
		let enterPreEnv = "(ge preview-env)".data(using: .utf8)
		
		//leaves the new binding (assumption: the code itself ends in the same env it began.)
		let exitPreEnv = "(ge (environment-parent (the-environment)))".data(using: .utf8)
		
		previewFlag = true
		
		handleIn.write(createEnv!)
		handleIn.write(enterPreEnv!)
		handleIn.write(highlightData)
		handleIn.write(exitPreEnv!)
	}
	
	func textView(_ textView: NSTextView, shouldChangeTextInRanges affectedRanges: [NSValue], replacementStrings: [String]?) -> Bool {
		return true
	}
}
