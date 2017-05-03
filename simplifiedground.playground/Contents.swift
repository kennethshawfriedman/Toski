////: Playground - noun: a place where people can play
//
import Foundation


@discardableResult
func shell(_ args: String...) -> Int32 {
	let task = Process()
	task.launchPath = "/usr/local/bin/mit-scheme"
	
	task.arguments = [ "mit-scheme", "--eval", "(+ 3 2)"]
	
	let inPipe = Pipe()
	let outPipe = Pipe()
	
	task.standardInput = inPipe
	task.standardOutput = outPipe
	
	let outHandle = outPipe.fileHandleForReading
	let inHandle = inPipe.fileHandleForWriting
	
	outHandle.readabilityHandler = { pipe in
		if let line = String(data: pipe.availableData, encoding: String.Encoding.utf8) {
			// Update your view with the new text here
			print("New ouput: \(line)")
			
			let inString = "(+ 7 10)"
			let inData = inString.data(using: String.Encoding.utf8)
			if let iData = inData {
				inHandle.write(iData)
			} else {
				print("oh no! KSF")
			}
			
			
		} else {
			print("Error decoding data: \(pipe.availableData)")
		}
	}

	
	//task.launch()
	
	print(task.processIdentifier)
	
//	task.arguments = ["(+ 3 2)"]
	//task.launch()
	
	task.waitUntilExit()
	
	//task.waitUntilExit()
	return task.terminationStatus
}

shell("2")

//func shell2(_ args: String...) -> Int32 {
//	let task = Process()
//	task.launchPath = "/usr/local/bin/python"
//	
//	task.arguments = ["python", "\"2+2\""]
//	task.launch()
//	
//	print(task.processIdentifier)
//	
//	//	task.arguments = ["(+ 3 2)"]
//	//	task.launch()
//	
//	task.waitUntilExit()
//	
//	return task.terminationStatus
//}
//
//shell2("2+2")

/////////////////////////////////// ANOTHER TRY //////////////////////////////////

//import Foundation
////import Cocoa
//
//
//let task = Process()
//
//task.launchPath = "/bin/sh"
//task.arguments = ["-c", "echo 2"]
//
//let pipe = Pipe()
//task.standardOutput = pipe
//let outHandle = pipe.fileHandleForReading
//
//outHandle.readabilityHandler = { pipe in
//	if let line = String(data: pipe.availableData, encoding: String.Encoding.utf8) {
//		// Update your view with the new text here
//		print("New ouput: \(line)")
//		print("yo")
//		
//	} else {
//		print("Error decoding data: \(pipe.availableData)")
//	}
//}
//
//task.launch()

//import Foundation
//
//let pipe = Pipe()
//
//let echo = Process()
//echo.launchPath = "/usr/bin/env"
//echo.arguments = ["echo", "foo\nbar\nbaz\nbaz"]
//echo.standardOutput = pipe
//
//let uniq = Process()
//uniq.launchPath = "/usr/bin/env"
//uniq.arguments = ["uniq"]
//uniq.standardInput = pipe
//
//let out = Pipe()
//uniq.standardOutput = out
//
//echo.launch()
//uniq.launch()
//uniq.waitUntilExit()
//
//let data = out.fileHandleForReading.readDataToEndOfFile()
//let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
//
//print(output ?? "no output")
//


//dispatch_queue_t taskQueue =
//	dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
//dispatch_async(taskQueue, ^{
//	
//	task = [[NSTask alloc] init];
//	[task setStandardOutput: [NSPipe pipe]];
//	[task setStandardInput: [NSPipe pipe]];
//	[task setStandardError: [task standardOutput]];
//	[task setLaunchPath: @"/Users/..."];
//	[task setArguments:@[@"--interaction"]];
//	
//	[[[task standardOutput] fileHandleForReading] waitForDataInBackgroundAndNotify];
//	
//	[[NSNotificationCenter defaultCenter]
//	addObserverForName:NSFileHandleDataAvailableNotification
//	object:[[task standardOutput] fileHandleForReading]
//	queue:nil
//	usingBlock:^(NSNotification *notification){
//	NSData *output = [[[task standardOutput] fileHandleForReading] availableData];
//	NSString *outStr = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
//	dispatch_sync(dispatch_get_main_queue(), ^{
//	NSLog(@"avaliable data: %@", outStr);
//	NSString * message = @"IOTCM \"/Users/.../Demo.agda\" None Indirect ( Cmd_show_version )";
//	[[[task standardInput] fileHandleForWriting]
//	writeData:[message dataUsingEncoding:NSUTF8StringEncoding]];
//	});
//	[[[task standardOutput] fileHandleForReading] waitForDataInBackgroundAndNotify];
//	}];
//	
//	[task launch];
//	[task waitUntilExit];
//	});

/////// another try with notification center but the notification never triggers


//import Foundation
//
//let so = Pipe()
//so.fileHandleForReading.waitForDataInBackgroundAndNotify()
//
//let task = Process()
//task.standardInput = Pipe()
//task.standardOutput = so
//task.launchPath = "/usr/local/bin/mit-scheme"
//task.arguments = ["mit-scheme", "--eval", "(+ 2 3)"]
//
//func notifyOb() {
//	print("hello")
//}
//
//
//NotificationCenter.default.addObserver(NSNotification.Name.NSFileHandleDataAvailable, selector: Selector(("notifyOb")) , name: NSNotification.Name.init("hopeful"), object: so.fileHandleForReading)
//
//
//task.launch()
//task.waitUntilExit()

