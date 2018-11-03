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
			let opened = NonNegative<Int>
				.arbitrary
				.map { $0.getNonNegative }
				.generate
			let closed = NonNegative<Int>
				.arbitrary
				.map { $0.getNonNegative }
				.generate
			
			let numberOpenLengths = Gen
				.fromElements(in: 0...min(opened, closed))
				.generate
			
			let openLengths: [TimeInterval] = Positive<Int>
				.arbitrary
				.map { $0.getPositive }
				.map { Double($0) }
				.proliferate(withSize: numberOpenLengths)
				.generate
			
			let commentEvents = NonNegative<Int>
				.arbitrary
				.map { $0.getNonNegative }
				.generate
			
			return UserStat.PullRequest(opened: opened,
										closed: closed,
										openLengths: openLengths,
										commentEvents: commentEvents)
		}
	}
}

extension UserStat.Code: Arbitrary {
	public static var arbitrary: Gen<UserStat.Code> {
		return Gen.compose { c in
			let linesAdded = NonNegative<Int>
				.arbitrary
				.map { $0.getNonNegative }
				.generate
			let linesDeleted = NonNegative<Int>
				.arbitrary
				.map { $0.getNonNegative }
				.generate
			
			// just pick an arbitrarily large number without getting too close to Int.max
			// because we shouldn't realistically have to worry about buffer overflow with this
			// value
			let commits = Gen
				.fromElements(in: min(linesAdded, linesDeleted)...999999999)
				.generate
			return UserStat.Code(linesAdded: linesAdded,
								 linesDeleted: linesDeleted,
								 commits: commits)
		}
	}
}

extension UserStat: Arbitrary {
	public static var arbitrary: Gen<UserStat> {
		return Gen.compose { c in
			let earliestDate: Date? = c.generate()
			
			let userStat: UserStat
			if earliestDate == nil {
				userStat = arbitraryWithNoEvents.generate
			} else {
				userStat = UserStat()
					.replacing(c.generate() as Code)
					.replacing(c.generate() as PullRequest)
			}
			return earliestDate.map { userStat.updating(earliestEvent: $0) } ?? userStat
		}
	}
	
	public static var arbitraryWithNoEvents: Gen<UserStat> {
		return Gen.compose { c in
			// user with no events will not have PullRequestStats or an earliestDate
			return UserStat().replacing(c.generate() as Code)
		}
	}
}
