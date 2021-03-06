//
//  RepoStat.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/3/18.
//

import Foundation

public struct RepoStat {
    public let repoName: String
    public let userStats: [Username: UserStat]
	
	public let pullRequestStats: PullRequest
	public let codeStats: Code

    public var earliestEvent: Date? {
		return userStats.values.map { $0.earliestEvent }.reduce(nil, { a, b in
			let minEvent = a.flatMap { au in b.map { min(au, $0) } }
			let earliestEvent = minEvent ?? a ?? b
			return earliestEvent
		})
    }
	
	public init(repoName: String, userStats: [Username: UserStat]) {
		self.repoName = repoName
		self.userStats = userStats
		pullRequestStats = .init(prStats: userStats.values.map { $0.pullRequestStat })
		codeStats = .init(codeStats: userStats.values.map { $0.codeStat })
	}
}

public extension RepoStat {
	typealias AggregateLimitedStat<Total: CustomStringConvertible,Avg: CustomStringConvertible>
		= SumAndAvg<LimitedStat<Total>, LimitedStat<Avg>>
	typealias AggregateLimitlessStat<Total: CustomStringConvertible, Avg: CustomStringConvertible>
		= SumAndAvg<LimitlessStat<Total>, LimitlessStat<Avg>>
	
	public struct PullRequest {
		/// Average is given in seconds
		public let openLengths: SumAndAvg<LimitedStat<[TimeInterval]>, (perPullRequest: LimitedStat<Double>, perUser: LimitedStat<Double>)>
		
		public let opened: AggregateLimitedStat<Int, Double>
		
		public let closed: AggregateLimitedStat<Int, Double>
		
		public let comments: AggregateLimitedStat<Int, Double>
	}
	
	public struct Code {
		public let linesAdded: AggregateLimitlessStat<Int, Double>
		
		public let linesDeleted: AggregateLimitlessStat<Int, Double>
		
		public let lines: AggregateLimitlessStat<Int, Double>
		
		public let commits: AggregateLimitlessStat<Int, Double>
	}
}

extension RepoStat.PullRequest {
	init(prStats: [UserStat.PullRequest]) {
		let openLengthsArr = prStats.map { $0.openLengths }.reduce([], +)
		let userAvgOpenLength = prStats.map { $0.avgOpenLength }.reduce(0) { $0 + Double($1)/Double(prStats.count) }
		let prAvgOpenLength = openLengthsArr.reduce(0) { $0 + Double($1)/Double(openLengthsArr.count) }
		
		/// open lengths is a bit different than other metrics because
		/// total open length is not very useful, so the total
		/// is actually an array containing all open legnths.
		openLengths = (total: openLengthsArr,
					   average: (perPullRequest: prAvgOpenLength,
								 perUser: userAvgOpenLength))
		
		opened = aggregateSumAndAvg(prStats.map { $0.opened })
		
		closed = aggregateSumAndAvg(prStats.map { $0.closed })
		
		comments = aggregateSumAndAvg(prStats.map { $0.commentEvents })
	}
}

extension RepoStat.Code {
	init(codeStats: [UserStat.Code]) {
		linesAdded = aggregateSumAndAvg(codeStats.map { $0.linesAdded })
		
		linesDeleted = aggregateSumAndAvg(codeStats.map { $0.linesDeleted })
		
		lines = aggregateSumAndAvg(codeStats.map { $0.lines })
		
		commits = aggregateSumAndAvg(codeStats.map { $0.commits })
	}
}
