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

// MARK: RepoStat.PullRequest
extension RepoStatTests {
	// all RepoStat.PullRequest properties except for `openLengths` are aggregateSumAndAvg which is tested elsewhere
	func test_RepoStatPullRequestOpenLengths() {
		property("open length total is array containing all open legnths") <- forAll { (prStats: [PullRequestStat]) in
			let prStat = RepoStat.PullRequest(prStats: prStats)
			let allOpenLengths = prStats.flatMap { $0.openLengths.value }
			return prStat.openLengths.total.value == allOpenLengths
		}
		
		property("open length user avg is average per user") <- forAll { (prStats: [PullRequestStat]) in
			let prStat = RepoStat.PullRequest(prStats: prStats)
			let avgPerUser = prStats.map { $0.avgOpenLength }.reduce(0) { $0 + Double($1)/Double(prStats.count) }
			return prStat.openLengths.average.perUser == avgPerUser
		}
		
		property("open length pr avg is average per pull request") <- forAll { (prStats: [PullRequestStat]) in
			let prStat = RepoStat.PullRequest(prStats: prStats)
			let allOpenLengths = prStats.map { $0.openLengths }.reduce([], +)
			let avgPerPR = allOpenLengths.reduce(0) { $0 + Double($1)/Double(allOpenLengths.count) }
			return prStat.openLengths.average.perPullRequest == avgPerPR
		}
		
		// This test kind of checks both the arbitrariness of RepoStat.PullRequest and
		// also the logic of these tests. There IS a difference between the definition of
		// avg open length per user and avg open length per pull request, so we verify that
		// fact here.
		property("open length pr avg is not always equal to open length user avg") <- exists { (prStat: RepoStat.PullRequest) in
			return prStat.openLengths.average.perPullRequest != prStat.openLengths.average.perUser
		}
	}
}

// MARK: RepoStat.Code
extension RepoStatTests {
	// all RepoStat.Code properties are aggregateSumAndAvg which is tested elsewhere
}
