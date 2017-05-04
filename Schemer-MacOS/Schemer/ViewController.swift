//
//  ViewController.swift
//  Schemer
//
//  Created by Kenneth Friedman on 5/2/17.
//  Copyright © 2017 Kenneth Friedman. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextViewDelegate, NSTextStorageDelegate {

	let cfOLD = CodeField()
	
	@IBOutlet var cf: CodeField!
	@IBOutlet var scrollView: NSScrollView!
	
	override func viewDidLoad() {
		super.viewDidLoad()

		//sets font to sourcecodepro and sets
		cf.font = NSFont(descriptor: NSFontDescriptor.init(name: "SourceCodePro-Regular", size: 16) , size: 16)
		
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTextDidChange:) name:NSControlTextDidChangeNotification object:nil];
		//NSUserNotificationCenter.default.addObserver(cf, forKeyPath: <#T##String#>, options: <#T##NSKeyValueObservingOptions#>, context: <#T##UnsafeMutableRawPointer?#>)
		
		cf.delegate = self
		
		cf.textStorage?.delegate = self
		
		
	}

	override var representedObject: Any? {
		didSet {
			
		}
	}
}

class CodeField : NSTextView {
	
	
}

extension ViewController {
	
	func textViewDidChangeSelection(_ notification: Notification) {
		Swift.print("at least it's something")
	}
	
	func textView(_ textView: NSTextView, shouldChangeTextInRanges affectedRanges: [NSValue], replacementStrings: [String]?) -> Bool {
		Swift.print("sign of life")
		print(replacementStrings)
		return true
	}
}
