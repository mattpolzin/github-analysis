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
