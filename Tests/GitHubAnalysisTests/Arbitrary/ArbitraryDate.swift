//
//  ArbitraryDate.swift
//  GitHubAnalysisTests
//
//  Created by Mathew Polzin on 10/7/18.
//

import Foundation
import SwiftCheck

extension Date: Arbitrary {
	public static var arbitrary: Gen<Date> {
		return Double.arbitrary.map(Date.init(timeIntervalSince1970:))
	}
}
