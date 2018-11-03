//
//  ArbitraryRepoStat.swift
//  GitHubAnalysisTests
//
//  Created by Mathew Polzin on 10/7/18.
//

@testable import GitHubAnalysisCore
import SwiftCheck

extension RepoStat: Arbitrary {
	public static var arbitrary: Gen<RepoStat> {
		return Gen.compose { c in
			return RepoStat(repoName: c.generate(),
							userStats: c.generate())
		}
	}
}

extension RepoStat.PullRequest: Arbitrary {
	public static var arbitrary: Gen<RepoStat.PullRequest> {
		return Gen.compose { c in
			return RepoStat.PullRequest(prStats: c.generate())
		}
	}
}

extension RepoStat.Code: Arbitrary {
	public static var arbitrary: Gen<RepoStat.Code> {
		return Gen.compose { c in
			return RepoStat.Code(codeStats: c.generate())
		}
	}
}
