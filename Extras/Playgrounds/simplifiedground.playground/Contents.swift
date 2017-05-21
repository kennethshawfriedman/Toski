////: Playground - noun: a place where people can play
//
import Foundation


@discardableResult
func shell(_ args: String...) -> Int32 {
	let task = Process()
	task.launchPath = "/usr/local/bin/mit-scheme"
	
	//no part of the task is needed; you just start the repl by launching mit-scheme from the launch path. The below line is simply not needed
	
	let inPipe = Pipe()
	let outPipe = Pipe()
	
	task.standardInput = inPipe
	task.standardOutput = outPipe
	
	var firstRound = true
	
	let outHandle = outPipe.fileHandleForReading
	let inHandle = inPipe.fileHandleForWriting
	
	outHandle.readabilityHandler = { pipe in
		if let line = String(data: pipe.availableData, encoding: String.Encoding.utf8) {
			// Update your view with the new text here
//			print(line)
			print(line, terminator: "")
			
			if (firstRound) {
				firstRound = false
				let inString = "(+ 7 10)"
				let inData = inString.data(using: String.Encoding.utf8)
				if let iData = inData {
					inHandle.write(iData)
				} else {
					print("oh no! KSF")
				}
			}
		} else {
			print("Error decoding data: \(pipe.availableData)")
		}
	}
	
	task.launch()
	print(task.processIdentifier)
	task.waitUntilExit()
	return task.terminationStatus
}

shell("")