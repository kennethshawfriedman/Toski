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
	
	
	
}

//SchemeProcess is a wrapper around the Process class, acting as a singleton
class SchemeProcess: Process {
	
	//Keep Init Private, as it should only be used by the shared
	private override init() {}
	
	//This is the shared instance
	static let shared = Process()
}
