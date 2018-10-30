//
//  PullRequestStatTests.swift
//  GitHubAnalysisTests
//
//  Created by Mathew Polzin on 10/28/18.
//

import XCTest
import SwiftCheck
import GitHubAnalysisCore

class PullRequestStatTests: XCTestCase {

	func test_emptyPullRequestStat() {
		let prStat = PullRequestStat.empty
		
		XCTAssertEqual(prStat.avgOpenLength, 0)
		XCTAssertEqual(prStat.closed, 0)
		XCTAssertEqual(prStat.commentEvents, 0)
		XCTAssertEqual(prStat.opened, 0)
		XCTAssertEqual(prStat.openLengths, [])
	}
	
	func test_PullRequestStatAvgOpenLength() {
		property("Average open length equals sum of open lengths divided by number of open lengths") <- forAll { (prStat: PullRequestStat) in
			let total = prStat.openLengths.reduce(0, +).value
			let avg = (prStat.openLengths.count > 0 ? Double(total)/Double(prStat.openLengths.count) : 0)
			return prStat.avgOpenLength.value ~== avg
		}
	}
	
	func test_PullRequestStatsAddTogetherCorrectly() {
		property("The components of two PullRequestStats added together are equal to the components added separately.") <- forAll { (prStat1: PullRequestStat) in
			return forAll { (prStat2: PullRequestStat) in
				let prStat3 = prStat1 + prStat2
				let allOpenLengths = prStat1.openLengths + prStat2.openLengths
				let avg = allOpenLengths.reduce(0) { $0 + Double($1)/Double(allOpenLengths.count) }
				let tests = [
					prStat3.avgOpenLength.value ~== avg.value,
					prStat3.closed == prStat1.closed + prStat2.closed,
					prStat3.commentEvents == prStat1.commentEvents + prStat2.commentEvents,
					prStat3.opened == prStat1.opened + prStat2.opened,
					prStat3.openLengths == prStat1.openLengths + prStat2.openLengths,
				]
				return !tests.contains(false)
			}
		}
	}
	
	func test_PullRequestStatMutatingAdditionEqualsNonMutatingAddition() {
		property("Mutating a pull request stat by adding another one to it is equivalent to adding two pull request stats together.") <- forAll { (prStat1: PullRequestStat) in
			return forAll { (prStat2: PullRequestStat) in
				var prStat3 = prStat1
				prStat3 += prStat2
				return prStat3 == prStat1 + prStat2
			}
		}
	}
	
	func test_OpenedPullRequestStat() {
		let opened = PullRequestStat.opened
		
		XCTAssertEqual(opened.avgOpenLength, 0)
		XCTAssertEqual(opened.closed, 0)
		XCTAssertEqual(opened.commentEvents, 0)
		XCTAssertEqual(opened.opened, 1)
		XCTAssertEqual(opened.openLengths, [])
	}
	
	func test_ClosedPullRequestStatNoOpenTime() {
		let date = Date()
		let closed = PullRequestStat.closed(at: date)
		
		XCTAssertEqual(closed.avgOpenLength, 0)
		XCTAssertEqual(closed.closed, 1)
		XCTAssertEqual(closed.commentEvents, 0)
		XCTAssertEqual(closed.opened, 0)
		XCTAssertEqual(closed.openLengths, [])
	}
	
	func test_ClosedPullRequestStatWithOpenTime() {
		let timeInterval = Positive<Int>.arbitrary.map { Double($0.getPositive) }
		property("Closed stat's open lengths contains one entry with length equal to the close time minus the open time used to construct the closed stat.") <- forAll { (openTime: Date) in
			return forAll(timeInterval) { (duration: TimeInterval) in
				let closeTime = openTime.addingTimeInterval(duration)
				
				let closedStat = PullRequestStat.closed(at: closeTime, with: openTime)
				
				return closedStat.closed == 1 && closedStat.openLengths.count == 1 && closedStat.openLengths.value[0] == duration
			}
		}
	}
	
	func test_CommentedPullRequestStat() {
		let commented = PullRequestStat.commented
		
		XCTAssertEqual(commented.avgOpenLength, 0)
		XCTAssertEqual(commented.closed, 0)
		XCTAssertEqual(commented.commentEvents, 1)
		XCTAssertEqual(commented.opened, 0)
		XCTAssertEqual(commented.openLengths, [])
	}
}
