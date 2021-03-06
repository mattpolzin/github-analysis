//
//  StatTests.swift
//  GitHubAnalysisTests
//
//  Created by Mathew Polzin on 10/13/18.
//

import XCTest
import SwiftCheck
import GitHubAnalysisCore

// MARK: Aggregation
class StatTests: XCTestCase {
	func test_aggregateSum() {
		property("sum of ints aggregated is accurate") <- forAll { (ints: [Int]) in
			let sum = ints.reduce(0, +)
			let stats1 = ints.map(LimitedStat.init(value:))
			let stats2 = ints.map(LimitlessStat.init(value:))
			
			return aggregateSumAndAvg(stats1).total.value == sum
				&& aggregateSumAndAvg(stats2).total.value == sum
		}
		
		property("sum of doubles aggregated is accurate") <- forAll { (doubles: [Double]) in
			let sum = doubles.reduce(0, +)
			let stats1 = doubles.map(LimitedStat.init(value:))
			let stats2 = doubles.map(LimitlessStat.init(value:))
			
			return aggregateSumAndAvg(stats1).total.value == sum
				&& aggregateSumAndAvg(stats2).total.value == sum
		}
	}
	
	func test_aggregateAvg() {
		property("avg of ints aggregated is accurate") <- forAll { (ints: [Int]) in
			let average = ints.reduce(0) { $0 + Double($1) / Double(ints.count) }
			let stats1 = ints.map(LimitedStat.init(value:))
			let stats2 = ints.map(LimitlessStat.init(value:))
			
			return aggregateSumAndAvg(stats1).average.value == average
				&& aggregateSumAndAvg(stats2).average.value == average
		}
		
		property("avg of doubles aggregated is accurate") <- forAll { (doubles: [Double]) in
			let average = doubles.reduce(0) { $0 + $1 / Double(doubles.count) }
			let stats1 = doubles.map(LimitedStat.init(value:))
			let stats2 = doubles.map(LimitlessStat.init(value:))
			
			return aggregateSumAndAvg(stats1).average.value == average
				&& aggregateSumAndAvg(stats2).average.value == average
		}
	}
}


// MARK: Limitlessness
extension StatTests {
	func test_LimitedStatValuesAreLimited() {
		property("Limited Types containing Int produce limited values.") <- forAll { (int: BasicStat<Limited, Int>) in
			return !int.limitless
		}
		
		property("Limited Types containing Double produce limited values.") <- forAll { (double: BasicStat<Limited, Double>) in
			return !double.limitless
		}
		
		property("Limited Types containing [Double] produce limited values.") <- forAll { (double: BasicStat<Limited, [Double]>) in
			return !double.limitless
		}
	}
	
	func test_LimitlessStatValuesAreLimitless() {
		property("Limitless Types containing Int produce limitless values.") <- forAll { (int: BasicStat<Limitless, Int>) in
			return int.limitless
		}
		
		property("Limitless Types containing Double produce limitless values.") <- forAll { (double: BasicStat<Limitless, Double>) in
			return double.limitless
		}
		
		property("Limitless Types containing [Double] produce limitless values.") <- forAll { (double: BasicStat<Limitless, [Double]>) in
			return double.limitless
		}
	}
}
