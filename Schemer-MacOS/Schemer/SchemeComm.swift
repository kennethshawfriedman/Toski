//
//  SchemeComm.swift
//  Schemer
//
//  Created by Kenneth Friedman on 5/5/17.
//  Copyright © 2017 Kenneth Friedman. All rights reserved.
//

import Foundation


//SchemeComm is used for Scheme Communication.
//// All methods are static, so there is no need for instances
class SchemeComm {
	
	static func parseExecutionCommand(allText:String) -> Data {
		var result = ""
		//Figure stuff out here
		result.append(allText)
		return result.data(using: .utf8)!
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
		tempTask.launch()
		let data = pipe.fileHandleForReading.readDataToEndOfFile()
		let output:String = String(data: data, encoding: String.Encoding.utf8) ?? "can't find mit-scheme location!"
		let outTrimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)
		print(outTrimmed)
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
