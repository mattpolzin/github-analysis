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
			return OrgStat.PullRequest(repoPrStats: c.generate(), numberOfUsers: c.generate(using: Positive<Int>.arbitrary.map { $0.getPositive }))
		}
	}
}

extension OrgStat.Code: Arbitrary {
	public static var arbitrary: Gen<OrgStat.Code> {
		return Gen.compose { c in
			return OrgStat.Code(codeStats: c.generate(), numberOfUsers: c.generate(using: Positive<Int>.arbitrary.map { $0.getPositive }))
		}
	}
}
