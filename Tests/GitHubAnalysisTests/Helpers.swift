//
//  Helpers.swift
//  GitHubAnalysisTests
//
//  Created by Mathew Polzin on 10/28/18.
//

/// Approximate equality.
func ~==(_ lhs: Double, _ rhs: Double) -> Bool {
	return abs(lhs.distance(to: rhs)) < 0.0000001
}

infix operator ~==: ComparisonPrecedence
