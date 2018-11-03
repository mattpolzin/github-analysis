//
//  ArrayExtensionsTests.swift
//  GitHubAnalysisTests
//
//  Created by Mathew Polzin on 11/3/18.
//

import XCTest
import GitHubAnalysisCore

class ArrayExtensionsTests: XCTestCase {

	func test_appending() {
		let array = [1,2,3,4]
		let value = 5
		
		let newArray = array.appending(value)
		
		XCTAssertNotEqual(array, newArray)
		XCTAssert(newArray.count == array.count + 1)
		XCTAssertEqual(newArray.last, value)
	}

	func test_prepending() {
		let array = [2,3,4]
		let value = 1
		
		let newArray = array.prepending(value)
		
		XCTAssertNotEqual(array, newArray)
		XCTAssert(newArray.count == array.count + 1)
		XCTAssertEqual(newArray.first, value)
	}
}
