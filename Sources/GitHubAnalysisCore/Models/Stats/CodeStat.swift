//
//  CodeStat.swift
//  GitHubAnalysisCore
//
//  Created by Mathew Polzin on 11/3/18.
//

import Foundation

public struct CodeStat: Equatable {
	public let weeks: LimitlessStat<Set<Week>>
	
	public var linesAdded: LimitlessStat<Int> {
		return weeks.map { unwrappedWeeks in
			return unwrappedWeeks.map { $0.linesAdded }.reduce(0) { $0 + $1.value }
		}
	}
	public var linesDeleted: LimitlessStat<Int> {
		return weeks.map { unwrappedWeeks in
			return unwrappedWeeks.map { $0.linesDeleted }.reduce(0) { $0 + $1.value }
		}
	}
	public var commits: LimitlessStat<Int> {
		return weeks.map { unwrappedWeeks in
			return unwrappedWeeks.map { $0.commits }.reduce(0) { $0 + $1.value }
		}
	}
	
	/// The total lines affected (i.e. both added and deleted).
	public var lines: LimitlessStat<Int> {
		return weeks.flatMap { $0.reduce(0) { $0 + $1.lines } }
	}
	
	public struct Week: Equatable, Hashable {
		public let startDate: Date
		public let linesAdded: LimitlessStat<Int>
		public let linesDeleted: LimitlessStat<Int>
		public let commits: LimitlessStat<Int>
		
		public var lines: LimitlessStat<Int> {
			return zip(linesAdded, linesDeleted) { $0 + $1 }
		}
		
		public var hashValue: Int {
			return startDate.hashValue
		}
	}
}

public extension CodeStat {
	static func +(lhs: CodeStat, rhs: CodeStat) -> CodeStat {
		return need to add such that if the weeks collide then the individual weeks are added
	}
	
	static func +=(lhs: inout CodeStat, rhs: CodeStat) {
		lhs = lhs + rhs
	}
	
	init(weeks: Set<Week>) {
		self.init(weeks: .init(value: weeks))
	}
	
	private init() {
		weeks = .init(value: [])
	}
	
	static var empty: CodeStat {
		return CodeStat()
	}
}

public extension CodeStat.Week {
	
}
