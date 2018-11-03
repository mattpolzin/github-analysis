//
//  ArbitraryOrgStat.swift
//  GitHubAnalysisTests
//
//  Created by Mathew Polzin on 10/9/18.
//

import Foundation
@testable import GitHubAnalysisCore
import SwiftCheck

extension OrgStat: Arbitrary {
	public static var arbitrary: Gen<OrgStat> {
		return Gen.compose { c in
			return OrgStat(orgName: c.generate(),
						   repoStats: c.generate())
		}
	}
}

extension OrgStat.PullRequest: Arbitrary {
	public static var arbitrary: Gen<OrgStat.PullRequest> {
		return Gen.compose { c in
			let userPrStats = [UserStat.PullRequest].arbitrary.proliferate.generate
			let repoPrStats = userPrStats.map { RepoStat.PullRequest(prStats: $0) }
			return OrgStat.PullRequest(repoPrStats: repoPrStats, userPrStats: userPrStats.flatMap { $0 })
		}
	}
}

extension OrgStat.Code: Arbitrary {
	public static var arbitrary: Gen<OrgStat.Code> {
		return Gen.compose { c in
			let userCodeStats = [UserStat.Code].arbitrary.proliferate.generate
			let repoCodeStats = userCodeStats.map { RepoStat.Code(codeStats: $0) }
			return OrgStat.Code(codeStats: repoCodeStats, numberOfUsers: userCodeStats.flatMap { $0 }.count)
		}
	}
}
