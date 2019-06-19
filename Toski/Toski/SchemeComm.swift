//
//  SchemeComm.swift
//  Schemer
//
//  Created by Kenneth Friedman on 5/5/17.
//  Copyright © 2017 Kenneth Friedman. All rights reserved.
//

import Cocoa

//SchemeComm is used for Scheme Communication.
//// All methods are static, so there is no need for instances
class SchemeComm {
	
	//returns a Data object to be sent to Scheme.
	//This Data object is actually a string of the scheme code to be sent
	static func parseExecutionCommand(codingField cf:CodeField) -> Data {
		
		//string to append code to
		var result:String = ""
		//error message: used if it can't find text in the codeField
		let nothingHereMessage = "(pp \"Something Has Gone Wrong, the text can't be found.\")"
		//get string from codeField
		let currentText:String = cf.textStorage?.string ?? nothingHereMessage
		//get curosor location:
		let cursorLoc = SchemeComm.locationOfCursor(codingField: cf)
		//grab all text before cursor location:
		let codeBeforeCursorRange = currentText.startIndex ..< currentText.index(currentText.startIndex, offsetBy: cursorLoc)
		let codeBeforeCursor = String(currentText[codeBeforeCursorRange])
		//find an executable command within the possible code before the cursor
		let executableCommand = SchemeComm.findExecutableCommandInText(incoming: codeBeforeCursor)
		result.append(executableCommand)
		//return as Data object to send to Scheme Process
		return result.data(using: .utf8)!
	}
	
	//returns Int location of the cursor, where Int is the
	/////number of characters in the codefield's text
	static func locationOfCursor(codingField cf:CodeField) -> Int {
		let range = cf.selectedRange()
		let insertSpot = range.location + range.length
		return insertSpot
	}
	
	static func findExecutableCommandInText(incoming:String) -> String {
		var chars = Array(incoming)
		chars.reverse()
		var parenCount = 0 //to keep track of parentheses!
		var indextoRevertBackTo = 0 //to keep track of where in substring should split
		for i in 0..<chars.count {
			if (chars[i] == Character(")")) {
				parenCount += 1
			} else if (chars[i] == Character("(")) {
				parenCount -= 1
			}
			if (parenCount == 0) {
				indextoRevertBackTo = i+1
				let beginSpot = incoming.index(incoming.endIndex, offsetBy: -indextoRevertBackTo)
				let substringToReturn = String(incoming[beginSpot...])
				return substringToReturn
			} else if (parenCount < 0) {
				print("Major Error: there is no command that will work!")
				return ""
			}
		}
		return "(pp \"Sorry, I couldn't find any code to execute.\")"
	}
	
	static func previewExecution(_ input:String) {
		
	}
	
}

//This is class is just extra, rarely-called functions to help SchemeComm (SchemeComm should be handling most of the logic)
class SchemeHelper {
	
	//This function finds and returns where mit-scheme is located on your current machine.
	////This is executed by telling Bash to find mit-scheme. If there's an issue here, it's probably with Bash.
	static func findSchemeLaunchPath() -> String {
		let tempTask = Process()
		tempTask.launchPath = "/bin/bash"
		let mitScheme = "mit-scheme"
		tempTask.arguments = [ "-l", "-c", "which \(mitScheme)"]
		let pipe = Pipe()
		tempTask.standardOutput = pipe
		print("trying")
		
		if #available(OSX 10.13, *) {
			do {
				try tempTask.run()
			} catch {
				let alert = NSAlert.init()
				alert.messageText = "Can't access bin/bash/"
				alert.informativeText = "Toksi can't find bin/bash. Contact developer for help!"
				alert.addButton(withTitle: "OK")
				alert.runModal()
				return ""
				
			}
		} else {
			//prior to 10.13, you had to use .launch, which can't error handle.
			//this should be removed ASAP, when 10.13 doesn't have to be supported
			tempTask.launch()
		}
		
		let data = pipe.fileHandleForReading.readDataToEndOfFile()
		let output:String = String(data: data, encoding: String.Encoding.utf8) ?? "can't find mit-scheme location!"
		let outTrimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)
		print("MIT-Scheme Location: \(outTrimmed)\n")
		return outTrimmed
	}
}

//SchemeProcess is a wrapper around the Process class, acting as a singleton
class SchemeProcess: Process {
	
	//Keep Init Private, as it should only be used by the shared
	private override init() {}
	
	//This is the shared instance
	static let shared = Process()
}

extension String {
	
	//This extends the built in String to grab lines
	var lines: [String] {
		var result: [String] = []
		enumerateLines { line, _ in result.append(line) }
		return result
	}
	
	//This extends the built in String to have a method for
	mutating func stringByRemovingRegexMatches(pattern: String, replaceWith: String = "") {
		do {
			let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
			let range = NSMakeRange(0, self.count)
			self = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
		} catch {
			return
		}
	}
	
	//Finds number of instances of particular substring
	func countInstances(of stringToFind: String) -> Int {
		var stringToSearch = self
		var count = 0
		repeat {
			guard let foundRange = stringToSearch.range(of: stringToFind, options: .diacriticInsensitive)
				else { break }
			stringToSearch = stringToSearch.replacingCharacters(in: foundRange, with: "")
			count += 1
			
		} while (true)
		
		return count
	}
	
}
