//
//  ArbitraryUserStat.swift
//  GitHubAnalysisTests
//
//  Created by Mathew Polzin on 10/7/18.
//

import Foundation
import SwiftCheck
import GitHubAnalysisCore

extension UserStat.PullRequest: Arbitrary {
	public static var arbitrary: Gen<UserStat.PullRequest> {
		return Gen.compose { c in
			return UserStat.PullRequest(opened: c.generate(),
									 closed: c.generate(),
									 openLengths: c.generate(),
									 commentEvents: c.generate())
		}
	}
}

extension UserStat.Code: Arbitrary {
	public static var arbitrary: Gen<UserStat.Code> {
		return Gen.compose { c in
			return UserStat.Code(linesAdded: c.generate(),
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
				.with(c.generate() as Code)
				.with(c.generate() as PullRequest)
			return earliestDate.map { userStat.updating(earliestEvent: $0) } ?? userStat
		}
	}
	
	public static var arbitraryWithNoEvents: Gen<UserStat> {
		return Gen.compose { c in
			// user with no events will not have PullRequestStats or an earliestDate
			return UserStat().with(c.generate() as Code)
		}
	}
}
