//
//  CodeStatTests.swift
//  GitHubAnalysisTests
//
//  Created by Mathew Polzin on 10/28/18.
//

import XCTest
import SwiftCheck
import GitHubAnalysisCore

class CodeStatTests: XCTestCase {

	func test_emptyCodeStat() {
		let codeStat = CodeStat.empty
		
		XCTAssertEqual(codeStat.commits, 0)
		XCTAssertEqual(codeStat.lines, 0)
		XCTAssertEqual(codeStat.linesAdded, 0)
		XCTAssertEqual(codeStat.linesDeleted, 0)
	}
	
	func test_CodeStatLines() {
		property("Lines equals sum of lines added and lines deleted") <- forAll { (codeStat: CodeStat) in
			return codeStat.lines == codeStat.linesAdded + codeStat.linesDeleted
		}
	}
	
	func test_CodeStatsAddTogetherCorrectly() {
		property("The components of two CodeStats added together are equal to the components added separately.") <- forAll { (codeStat1: CodeStat, codeStat2: CodeStat) in
			let codeStat3 = codeStat1 + codeStat2
			let tests = [
				codeStat3.linesAdded == codeStat1.linesAdded + codeStat2.linesAdded,
				codeStat3.linesDeleted == codeStat1.linesDeleted + codeStat2.linesDeleted,
				codeStat3.commits == codeStat1.commits + codeStat2.commits,
				codeStat3.lines == codeStat1.lines + codeStat2.lines
			]
			return !tests.contains(false)
		}
	}
	
	func test_CodeStatMutatingAdditionEqualsNonMutatingAddition() {
		property("Mutating a code stat by adding another one to it is equivalent to adding two code stats together.") <- forAll { (codeStat1: CodeStat, codeStat2: CodeStat) in
			var codeStat3 = codeStat1
			codeStat3 += codeStat2
			return codeStat3 == codeStat1 + codeStat2
		}
	}
}
