//
//  StatTests.swift
//  GitHubAnalysisTests
//
//  Created by Mathew Polzin on 10/13/18.
//

import XCTest
import SwiftCheck
import GitHubAnalysisCore

class StatTests: XCTestCase {
	func test_aggregateSumInt() {
		property("sum of ints aggregated is accurate") <- forAll { (ints: [Int]) in
			let sum = ints.reduce(0, +)
			let stats1 = ints.map(LimitedStat.init(value:))
			let stats2 = ints.map(LimitlessStat.init(value:))
			
			return aggregateSumAndAvg(stats1).total.value == sum
				&& aggregateSumAndAvg(stats2).total.value == sum
		}
	}
	
	func test_aggregateSumDouble() {
		property("sum of doubles aggregated is accurate") <- forAll { (doubles: [Double]) in
			let sum = doubles.reduce(0, +)
			let stats1 = doubles.map(LimitedStat.init(value:))
			let stats2 = doubles.map(LimitlessStat.init(value:))
			
			return aggregateSumAndAvg(stats1).total.value == sum
				&& aggregateSumAndAvg(stats2).total.value == sum
		}
	}
	
	func test_aggregateAvgInt() {
		property("avg of ints aggregated is accurate", arguments: .init(replay: (StdGen.init(677045031, 13744243), 0))) <- forAll { (ints: [Int]) in
			let average = ints.reduce(0) { $0 + Double($1) / Double(ints.count) }
			let stats1 = ints.map(LimitedStat.init(value:))
			let stats2 = ints.map(LimitlessStat.init(value:))
			
			return aggregateSumAndAvg(stats1).average.value == average
				&& aggregateSumAndAvg(stats2).average.value == average
		}
	}
	
	func test_aggregateAvgDouble() {
		property("avg of doubles aggregated is accurate") <- forAll { (doubles: [Double]) in
			let average = doubles.reduce(0) { $0 + $1 / Double(doubles.count) }
			let stats1 = doubles.map(LimitedStat.init(value:))
			let stats2 = doubles.map(LimitlessStat.init(value:))
			
			return aggregateSumAndAvg(stats1).average.value == average
				&& aggregateSumAndAvg(stats2).average.value == average
		}
	}
}
