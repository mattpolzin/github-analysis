//
//  RepoStatTests.swift
//  GitHubAnalysisTests
//
//  Created by Mathew Polzin on 10/7/18.
//

import XCTest
import SwiftCheck
@testable import GitHubAnalysisCore

class RepoStatTests: XCTestCase {
	func testEarliestEvent_NoUsers() {
		XCTAssertNil(RepoStat(repoName: "test", userStats: [:]).earliestEvent)
	}
	
	func testEarliestEvent_AllUsersNoEvents() {
		let usersWithNoEventsGen = UserStat
			.arbitraryWithNoEvents
			.proliferateNonEmpty
			.map { $0.map { (String.arbitrary.generate, $0) } }
			.map { Dictionary($0, uniquingKeysWith: { k, _ in k }) }
			.map { RepoStat(repoName: String.arbitrary.generate,
							userStats: $0) }
		
		property("earliestEvent equals nil if no events were analyzed for any users.")
			<- forAll(usersWithNoEventsGen) { repoStat in
				return repoStat.earliestEvent == nil
		}
	}
	
	func testEarliestEvent_OneOrMoreUsers() {
		let nonEmptyUserStatsGen = [Username: UserStat]
			.arbitrary
			.suchThat { !$0.isEmpty }
	
		property("earliestEvent equals earliest event analyzed across all users.")
			<- forAll(nonEmptyUserStatsGen) { userStats in
				let earliestDate = userStats.values.compactMap { $0.earliestEvent }.sorted(by: <).first
				
				return earliestDate == RepoStat(repoName: String.arbitrary.generate, userStats: userStats).earliestEvent
		}
	}
}
