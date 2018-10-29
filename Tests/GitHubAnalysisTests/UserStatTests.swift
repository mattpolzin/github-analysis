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
			
			return userStat.pullRequestStat == prStat && userStat.codeStat == CodeStat.empty
		}
	}
	
	func test_AddingCodeToEmptyUserStat() {
		property("Code stat component of user stat equals code stat that was added to empty user stat") <- forAll { (codeStat: CodeStat) in
			let userStat = UserStat().adding(codeStat)
			
			return userStat.codeStat == codeStat && userStat.pullRequestStat == PullRequestStat.empty
		}
	}
	
	func test_AddingPullRequestStatsToUserStat() {
		// TODO
	}
	
	func test_AddingPullRequestStatsToUserStatMutating() {
		// TODO (i.e. +=)
	}
	
	func test_AddingCodeStatsToUserStat() {
		// TODO
	}
	
	func test_AddingCodeStatsToUserStatMutating() {
		// TOOD: (i.e. +=)
	}
	
	func test_ReplacingPullRequestStatsOnUserStat() {
		// TODO
	}
	
	func test_ReplacingCodeStatsOnUserStat() {
		// TODO
	}
	
	func test_UpdatingEarliestEventOfEmptyUserStat() {
		// TODO
	}
	
	func test_UpdatingEarliestEventOfUserStat() {
		// TODO
	}
	
	func test_AddingUserStatsAddsComponents() {
		property("The components of the result of adding two user stats are equal to the results of adding the components separately.") <- forAll { (userStat1: UserStat) in
			return forAll { (userStat2: UserStat) in
				let userStat3 = userStat1 + userStat2
				let tests: [Bool] = [
					userStat3.pullRequestStat == userStat1.pullRequestStat + userStat2.pullRequestStat,
					userStat3.codeStat == userStat1.codeStat + userStat2.codeStat,
					userStat3.earliestEvent == ((zip(userStat1.earliestEvent, userStat2.earliestEvent) { min($0, $1) }) ?? userStat1.earliestEvent ?? userStat2.earliestEvent)
					]
				return !tests.contains(false)
			}
		}
	}
	
	func test_AddingUserStatComponentsMutating() {
		// TODO (i.e. +=)
	}
}
