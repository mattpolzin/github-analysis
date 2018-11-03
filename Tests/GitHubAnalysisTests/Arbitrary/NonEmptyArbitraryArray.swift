//
//  NonEmptyArbitraryArray.swift
//  GitHubAnalysisTests
//
//  Created by Mathew Polzin on 11/2/18.
//

import SwiftCheck

struct NonEmptyArbitraryArray<Element: Arbitrary>: Arbitrary {
	let nonEmptyArray: [Element]
	
	static var arbitrary: Gen<NonEmptyArbitraryArray<Element>> {
		return Element.arbitrary.proliferateNonEmpty.map { NonEmptyArbitraryArray(nonEmptyArray: $0) }
	}
}
