//
//  OrgStatTests.swift
//  GitHubAnalysisTests
//
//  Created by Mathew Polzin on 10/9/18.
//

import XCTest
import SwiftCheck
@testable import GitHubAnalysisCore

class OrgStatTests: XCTestCase {
	func test_earliestReliableIsLatestEarliestDate() {
		property("there are no repositories with later earliestEvents than the earliest reliable repository") <- forAll { (orgStat: OrgStat) in
			let repositories = orgStat
				.repoStats
				.map { ($0, $1.earliestEvent) }
				.compactMap { pair in
					pair.1.map { (pair.0, $0) }
				}
				.sorted { $0.1 > $1.1 }
			
			let datesAgree = orgStat.earliestReliable?.date == repositories.first?.1
			let repoNamesAgree = orgStat.earliestReliable?.name == repositories.first?.0
			
			return datesAgree && repoNamesAgree
		}
	}
}
