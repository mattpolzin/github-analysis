//
//  ArbitraryBasicStat.swift
//  GitHubAnalysisTests
//
//  Created by Mathew Polzin on 10/7/18.
//

import Foundation
import SwiftCheck
import GitHubAnalysisCore

extension BasicStat: Arbitrary where Wrapped: Arbitrary {
	public static var arbitrary: Gen<BasicStat<B, Wrapped>> {
		return Wrapped.arbitrary.map(BasicStat.init(value:))
	}
}
