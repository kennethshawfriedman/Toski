//: Playground - noun: a place where people can play

import Foundation

//Extends String so that you can seperate things by lines
extension String {
	var lines: [String] {
		var result: [String] = []
		enumerateLines { line, _ in result.append(line) }
		return result
	}
}

final class Shell {
	static func outputOf(commandName: String, arguments: [String] = []) -> String? {
		return bash(commandName: commandName, arguments:arguments)
	}
	
	// MARK: private
	
	private static func bash(commandName: String, arguments: [String]) -> String? {
		guard var whichPathForCommand = executeShell(command: "/bin/bash" , arguments:[ "-l", "-c", "which \(commandName)" ]) else {
			return "\(commandName) not found"
		}
		whichPathForCommand = whichPathForCommand.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
		return executeShell(command: whichPathForCommand, arguments: arguments)
	}
	
	private static func executeShell(command: String, arguments: [String] = []) -> String? {
		let task = Process()
		task.launchPath = command
		task.arguments = arguments
		
		
		let pipe = Pipe()
		task.standardOutput = pipe
		task.launch()
		
		
		let data = pipe.fileHandleForReading.readDataToEndOfFile()
		let output: String? = String(data: data, encoding: String.Encoding.utf8)
		
		return output
	}
	
}

class Schemer {
	
	static func execute(command: String) -> String {
		let mitScheme = "mit-scheme"
		let eval = "--eval"
		let result = Shell.outputOf(commandName: mitScheme, arguments: [eval, command])
		
		if let r = result {
			return r
		} else {
			return "Execution Error"
		}
	}
	
	static func executeAndParse(command: String) -> String {
		let result = Schemer.execute(command: command)
		let resultLines = result.lines
		
		var totalResult = ""
		for i in 9...resultLines.count-1 {
			totalResult.append(resultLines[i])
		}
		
		
		
		return totalResult
	}
	
}

let startTime = Date()


let out = Schemer.executeAndParse(command: "(car (cdr '(a b c d e f)))")
print(out)


let endTime = Date()
let interval = endTime.timeIntervalSince(startTime)
print(interval)


