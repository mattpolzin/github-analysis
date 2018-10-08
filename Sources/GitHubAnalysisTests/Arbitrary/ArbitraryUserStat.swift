//
//  ArbitraryUserStat.swift
//  GitHubAnalysisTests
//
//  Created by Mathew Polzin on 10/7/18.
//

import Foundation
import SwiftCheck
import GitHubAnalysisCore

extension UserStat.PullRequestStat: Arbitrary {
	public static var arbitrary: Gen<UserStat.PullRequestStat> {
		return Gen.compose { c in
			return UserStat.PullRequestStat(opened: c.generate(),
									 closed: c.generate(),
									 openLengths: c.generate(),
									 commentEvents: c.generate())
		}
	}
}

extension UserStat.CodeStat: Arbitrary {
	public static var arbitrary: Gen<UserStat.CodeStat> {
		return Gen.compose { c in
			return UserStat.CodeStat(linesAdded: c.generate(),
									 linesDeleted: c.generate(),
									 commits: c.generate())
		}
	}
}

extension UserStat: Arbitrary {
	public static var arbitrary: Gen<UserStat> {
		return Gen.compose { c in
			let earliestDate: Date? = c.generate()
			let userStat = UserStat()
				.with(c.generate() as CodeStat)
				.with(c.generate() as PullRequestStat)
			return earliestDate.map { userStat.updating(earliestEvent: $0) } ?? userStat
		}
	}
	
	public static var arbitraryWithNoEvents: Gen<UserStat> {
		return Gen.compose { c in
			// user with no events will not have PullRequestStats or an earliestDate
			return UserStat().with(c.generate() as CodeStat)
		}
	}
}
