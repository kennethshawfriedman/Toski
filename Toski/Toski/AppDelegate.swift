//
//  AppDelegate.swift
//  Schemer
//
//  Created by Kenneth Friedman on 5/2/17.
//  Copyright © 2017 Kenneth Friedman. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBAction func executeCommand(_ sender: Any) {
		NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "executeCommand"), object: nil)
	}
	
	func applicationWillTerminate(_ aNotification: Notification) {
		//Kills the Scheme Process
		SchemeProcess.shared.terminate()
		print("Toski ended")
	}
}
