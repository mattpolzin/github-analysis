//
//  ArbitrarySumAndAverage.swift
//  GitHubAnalysisTests
//
//  Created by Mathew Polzin on 11/2/18.
//

import SwiftCheck
import GitHubAnalysisCore

func arbitrarySumAndAvg<Total: Arbitrary, Avg: Arbitrary>() -> Gen<SumAndAvg<Total, Avg>> {
	return Gen.zip(Total.arbitrary, Avg.arbitrary).map { (total: $0.0, average: $0.1) }
}
