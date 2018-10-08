//
//  ArbitraryRepoStat.swift
//  GitHubAnalysisTests
//
//  Created by Mathew Polzin on 10/7/18.
//

import Foundation
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
