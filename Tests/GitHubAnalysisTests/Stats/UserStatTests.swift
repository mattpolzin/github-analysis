//
//  UserStatTests.swift
//  GitHubAnalysisTests
//
//  Created by Mathew Polzin on 10/7/18.
//

import XCTest
import SwiftCheck
import GitHubAnalysisCore

class UserStatTests: XCTestCase {

	func test_UserStatStartsEmpty() {
		let userStat = UserStat()
		
		XCTAssertNil(userStat.earliestEvent)
		XCTAssertEqual(userStat.pullRequestStat, PullRequestStat.empty)
		XCTAssertEqual(userStat.codeStat, CodeStat.empty)
	}
	
	func test_AddingPullRequestToEmptyUserStat() {
		property("Pull Request stat component of user stat equals pull request stat that was added to empty user stat") <- forAll { (prStat: PullRequestStat) in
			let userStat = UserStat().adding(prStat)
			
			return userStat.pullRequestStat == prStat && userStat.codeStat == CodeStat.empty && userStat.earliestEvent == nil
		}
	}
	
	func test_AddingCodeToEmptyUserStat() {
		property("Code stat component of user stat equals code stat that was added to empty user stat") <- forAll { (codeStat: CodeStat) in
			let userStat = UserStat().adding(codeStat)
			
			return userStat.codeStat == codeStat && userStat.pullRequestStat == PullRequestStat.empty && userStat.earliestEvent == nil
		}
	}
	
	func test_AddingPullRequestStatsToUserStat() {
		property("UserStat resulting from adding UserStat and Pull Request is old UserStat with pull request components added.") <- forAll { (userStat: UserStat, prStat: PullRequestStat) in
			let userStat2 = userStat.adding(prStat)
			
			let tests = [
				userStat2.codeStat == userStat.codeStat,
				userStat2.earliestEvent == userStat.earliestEvent,
				userStat2.pullRequestStat == userStat.pullRequestStat + prStat
			]
			
			return !tests.contains(false)
		}
	}
	
	func test_AddingPullRequestStatsToUserStatMutating() {
		property("UserStat += Pull Request is old UserStat with pull request components added.") <- forAll { (userStat: UserStat, prStat: PullRequestStat) in
			var userStat2 = userStat
			userStat2 += prStat
			
			let tests = [
				userStat2.codeStat == userStat.codeStat,
				userStat2.earliestEvent == userStat.earliestEvent,
				userStat2.pullRequestStat == userStat.pullRequestStat + prStat
			]
			
			return !tests.contains(false)
		}
	}
	
	func test_AddingCodeStatsToUserStat() {
		property("UserStat adding CodeStat is old UserStat with code components added.") <- forAll { (userStat: UserStat, codeStat: CodeStat) in
			let userStat2 = userStat.adding(codeStat)
			
			let tests = [
				userStat2.codeStat == userStat.codeStat + codeStat,
				userStat2.earliestEvent == userStat.earliestEvent,
				userStat2.pullRequestStat == userStat.pullRequestStat
			]
			
			return !tests.contains(false)
		}
	}
	
	func test_AddingCodeStatsToUserStatMutating() {
		property("UserStat += CodeStat is old UserStat with code components added.") <- forAll { (userStat: UserStat, codeStat: CodeStat) in
			var userStat2 = userStat
			userStat2 += codeStat
			
			let tests = [
				userStat2.codeStat == userStat.codeStat + codeStat,
				userStat2.earliestEvent == userStat.earliestEvent,
				userStat2.pullRequestStat == userStat.pullRequestStat
			]
			
			return !tests.contains(false)
		}
	}
	
	func test_ReplacingPullRequestStatsOnUserStat() {
		property("UserStat resulting from replacing Pull Request is old UserStat with pull request components replaced.") <- forAll { (userStat: UserStat, prStat: PullRequestStat) in
			let userStat2 = userStat.replacing(prStat)
			
			let tests = [
				userStat2.codeStat == userStat.codeStat,
				userStat2.earliestEvent == userStat.earliestEvent,
				userStat2.pullRequestStat == prStat
			]
			
			return !tests.contains(false)
		}
	}
	
	func test_ReplacingCodeStatsOnUserStat() {
		property("UserStat replacing CodeStat is old UserStat with code components replaced.") <- forAll { (userStat: UserStat, codeStat: CodeStat) in
			let userStat2 = userStat.replacing(codeStat)
			
			let tests = [
				userStat2.codeStat == codeStat,
				userStat2.earliestEvent == userStat.earliestEvent,
				userStat2.pullRequestStat == userStat.pullRequestStat
			]
			
			return !tests.contains(false)
		}
	}
	
	func test_UpdatingEarliestEventOfEmptyUserStat() {
		let userStat = UserStat()
		property("Empty User stat updating earliest date always takes earliest date as its own.") <- forAll { (date: Date) in
			let userStat2 = userStat.updating(earliestEvent: date)
			return userStat2.earliestEvent == date
		}
	}
	
	func test_UpdatingEarliestEventOfUserStat() {
		property("Earliest date of UserStat after updating earliest date is the minimum of the old and new earliest dates.") <- forAll { (userStat: UserStat, date: Date) in
			let userStat2 = userStat.updating(earliestEvent: date)
			return userStat2.earliestEvent == (userStat.earliestEvent.map { min($0, date) } ?? date)
		}
	}
	
	func test_UpdatingEarliestEventOfUserStatMutating() {
		property("Mutating UserStat by updating earliest event yields the same result as the non-mutating update.") <- forAll { (userStat: UserStat, date: Date) in
			var userStat2 = userStat
			userStat2.update(earliestEvent: date)
			return userStat2 == userStat.updating(earliestEvent: date)
		}
	}
	
	func test_AddingUserStatsAddsComponents() {
		property("The components of the result of adding two user stats are equal to the results of adding the components separately.") <- forAll { (userStat1: UserStat, userStat2: UserStat) in
			let userStat3 = userStat1 + userStat2
			let tests: [Bool] = [
				userStat3.pullRequestStat == userStat1.pullRequestStat + userStat2.pullRequestStat,
				userStat3.codeStat == userStat1.codeStat + userStat2.codeStat,
				userStat3.earliestEvent == ((zip(userStat1.earliestEvent, userStat2.earliestEvent) { min($0, $1) }) ?? userStat1.earliestEvent ?? userStat2.earliestEvent)
				]
			return !tests.contains(false)
		}
	}
	
	func test_AddingUserStatComponentsMutatingEqualsNonMutating() {
		property("A UserStat mutated by adding another to it equals the result of the non-mutating addition of the two user stats.") <- forAll { (userStat1: UserStat, userStat2: UserStat) in
			var userStat3 = userStat1
			userStat3 += userStat2

			return userStat3 == userStat1 + userStat2
		}
	}
}
