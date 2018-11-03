//
//  OptionalExtensionsTests.swift
//  GitHubAnalysisTests
//
//  Created by Mathew Polzin on 11/3/18.
//

import XCTest
import GitHubAnalysisCore

class OptionalExtensionsTests: XCTestCase {

	func test_zipWithNilCases() {
		let x: Int? = 0
		let y: Int? = nil
		
		XCTAssertNil(zip(x, y, with: +))
		XCTAssertNil(zip(y, x, with: +))
	}
	
	func test_zipWith() {
		let x: Int? = 3
		let y: Int? = 2
		
		XCTAssertEqual(zip(x, y, with: +), 5)
	}
}
