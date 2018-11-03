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
		property("There are no repositories with later earliestEvents than the earliest reliable repository") <- forAll { (orgStat: OrgStat) in
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
	
	func test_earliestEventIsEarliestEventOfAnyRepo() {
		property("earliest org event is earliest event of any repositories in the org") <- forAll { (repoStats: [String: RepoStat], orgName: String) in
			let earliestEvent = repoStats.compactMap { $0.value.earliestEvent }.sorted(by: <).first
			
			return OrgStat(orgName: orgName, repoStats: repoStats).earliestEvent == earliestEvent
		}
	}
	
	func test_emptyReposAreUnreliableRepositories() {
		// empty in that they have no analyzed events
		
		property("Repositories with no events are 'unreliable'") <- forAll { (orgStat: OrgStat) in
			let emptyRepositories = orgStat.repoStats.filter { $0.value.earliestEvent == nil }
			
			return emptyRepositories.reduce(true) { foundSoFar, next in
				return foundSoFar && orgStat.unreliableRepositories.contains(next.key)
			}
		}
	}
	
	func test_nonEmptyReposAreNotUnreliable() {
		// non-empty in that they have some analyzed events
		
		property("Repositories with events are not 'unreliable'") <- forAll { (orgStat: OrgStat) in
			let nonEmptyRepositories = orgStat.repoStats.filter { $0.value.earliestEvent != nil }
			
			return nonEmptyRepositories.reduce(true) { notFoundSoFar, next in
				notFoundSoFar && !orgStat.unreliableRepositories.contains(next.key)
			}
		}
	}
	
	func test_aggregate() {
		property("aggregate total is always sum of all totals") <- forAllNoShrink(arbitrarySumAndAvg().proliferateNonEmpty, Positive.arbitrary) { (stats: [SumAndAvg<LimitedStat<Int>, LimitedStat<Double>>], numberOfUsers: Positive<Int>) in
			
			let total = stats.map { $0.total }.reduce(0) { $0 + $1.value }
			
			return OrgStat.aggregate(of: stats,
									 numberOfUsers: numberOfUsers.getPositive).total.value == total
		}
		
		property("aggregate repo average is total divided by number of repos") <- forAllNoShrink(arbitrarySumAndAvg().proliferateNonEmpty, Positive.arbitrary) { (stats: [SumAndAvg<LimitedStat<Int>, LimitedStat<Double>>], numberOfUsers: Positive<Int>) in
			
			let total = stats.map { $0.total }.reduce(0) { $0 + $1.value }
			let avg = Double(total) / Double(stats.count)
			
			return OrgStat.aggregate(of: stats,
									 numberOfUsers: numberOfUsers.getPositive).average.perRepo.value ~== avg
		}
		
		property("aggregate user average is total divided by number of users") <- forAllNoShrink(arbitrarySumAndAvg().proliferateNonEmpty, Positive.arbitrary) { (stats: [SumAndAvg<LimitedStat<Int>, LimitedStat<Double>>], numberOfUsers: Positive<Int>) in
			
			let total = stats.map { $0.total }.reduce(0) { $0 + $1.value }
			let avg = Double(total) / Double(numberOfUsers.getPositive)
			
			return OrgStat.aggregate(of: stats,
									 numberOfUsers: numberOfUsers.getPositive).average.perUser.value ~== avg
		}
		
		property("aggregate user average is not always equal to repo average") <- forAllNoShrink(arbitrarySumAndAvg().proliferateNonEmpty, Positive.arbitrary) { (stats: [SumAndAvg<LimitedStat<Int>, LimitedStat<Double>>], numberOfUsers: Positive<Int>) in
			
			guard stats.count != numberOfUsers.getPositive else {
				return Discard()
			}
			
			let averages = OrgStat.aggregate(of: stats,
											 numberOfUsers: numberOfUsers.getPositive).average
			
			return averages.perUser.value == 0 || !(averages.perUser.value ~== averages.perRepo.value)
		}
	}
}

// MARK: OrgStat.PullRequest
extension OrgStatTests {
	// all OrgStat.PullRequest properties except for `openLengths` are OrgStat.aggregate() which is tested elsewhere
	func test_OrgStatPullRequestOpenLengths() {
		property("open length total is array containing all open legnths") <- forAll { (prStats: [RepoStat.PullRequest], userPrStats: NonEmptyArbitraryArray<UserStat.PullRequest>) in
			let prStat = OrgStat.PullRequest(repoPrStats: prStats, userPrStats: userPrStats.nonEmptyArray)
			let allOpenLengths = prStats.flatMap { $0.openLengths.total.value }
			return prStat.openLengths.total.value == allOpenLengths
		}
		
		property("open length repo avg is average per repo") <- forAll { (prStats: [RepoStat.PullRequest], userPrStats: NonEmptyArbitraryArray<UserStat.PullRequest>) in
			let prStat = OrgStat.PullRequest(repoPrStats: prStats, userPrStats: userPrStats.nonEmptyArray)
			let avgPerRepo = prStats.map { $0.openLengths.average.perUser }.reduce(0) { $0 + Double($1)/Double(prStats.count) }
			return prStat.openLengths.average.perRepo == avgPerRepo
		}
		
		property("open length user avg is average per user") <- forAll { (prStats: [RepoStat.PullRequest], userPrStats: NonEmptyArbitraryArray<UserStat.PullRequest>) in
			let prStat = OrgStat.PullRequest(repoPrStats: prStats, userPrStats: userPrStats.nonEmptyArray)
			let avgPerUser = userPrStats.nonEmptyArray.map { $0.avgOpenLength }.reduce(0) { $0 + Double($1)/Double(userPrStats.nonEmptyArray.count) }
			return prStat.openLengths.average.perUser == avgPerUser
		}
		
		property("open length pr avg is average per pull request") <- forAll { (prStats: [RepoStat.PullRequest], userPrStats: NonEmptyArbitraryArray<UserStat.PullRequest>) in
			let prStat = OrgStat.PullRequest(repoPrStats: prStats, userPrStats: userPrStats.nonEmptyArray)
			let allOpenLengths = prStats.map { $0.openLengths.total }.reduce([], +)
			let avgPerPR = allOpenLengths.reduce(0) { $0 + Double($1)/Double(allOpenLengths.count) }
			return prStat.openLengths.average.perPullRequest == avgPerPR
		}
		
		// This test kind of checks both the arbitrariness of OrgStat.PullRequest and
		// also the logic of these tests. There IS a difference between the definition of
		// avg open length per user and avg open length per pull request, so we verify that
		// fact here.
		property("open length pr avg is not always equal to open length user avg") <- exists { (prStat: OrgStat.PullRequest) in
			return prStat.openLengths.average.perPullRequest != prStat.openLengths.average.perUser
		}
		
		// This test kind of checks both the arbitrariness of OrgStat.PullRequest and
		// also the logic of these tests. There IS a difference between the definition of
		// avg open length per user and avg open length per repo, so we verify that
		// fact here.
		property("open length repo avg is not always equal to open length user avg") <- exists { (prStat: OrgStat.PullRequest) in
			return prStat.openLengths.average.perRepo != prStat.openLengths.average.perUser
		}
		
		// This test kind of checks both the arbitrariness of OrgStat.PullRequest and
		// also the logic of these tests. There IS a difference between the definition of
		// avg open length per pull request and avg open length per repo, so we verify that
		// fact here.
		property("open length repo avg is not always equal to open length user avg") <- exists { (prStat: OrgStat.PullRequest) in
			return prStat.openLengths.average.perRepo != prStat.openLengths.average.perPullRequest
		}
	}
}

// MARK: OrgStat.Code
extension OrgStatTests {
	// all OrgStat.Code properties are OrgStat.aggreagate() which is tested elsewhere
}
