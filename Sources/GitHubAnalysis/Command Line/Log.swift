//
//  Log.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/28/18.
//

struct Log {
	
	let destination: Destination
	let maxLevel: Level
	
	init(destination: Destination = .stdout, maxLevel: Level = .normal) {
		self.destination = destination
		self.maxLevel = maxLevel
	}
	
	enum Destination {
		case stdout
	}
	
	enum Level: Int, CaseIterable {
		case quiet = 0
		case normal = 1
		case verbose = 2
		
		/// Choose the most restriction (i.e. quietest)
		/// level from the given levels. If no levels are
		/// given, a default level of `.normal` will be used.
		init(mostRestrictiveOf levels: [Level]) {
			
			self = levels.sorted { $0.rawValue < $1.rawValue }.first ?? .normal
		}
	}
}

extension Log {
	/// Print the given String to the log IF the given `Level`
	/// (which defaults to `.normal`) is less than or equal
	/// to the `maxLevel`.
	func print(level: Level = .normal, _ string: String) {
		guard level.rawValue <= maxLevel.rawValue else { return }
		
		destination.print(string)
	}
}

extension Log.Destination {
	/// Print the given string to the destination represented by this value.
	func print(_ string: String) {
		switch self {
		case .stdout:
			Swift.print(string)
		}
	}
}
