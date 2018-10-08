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
	
    public var prOpenLengths: LimitedStat<[TimeInterval]> {
        return userStats.values.map { $0.pullRequestStat.openLengths }.reduce([], +)
    }

    /// Average is given in seconds
    public var avgPROpenLength: LimitedStat<TimeInterval> {
		return prOpenLengths.map { $0.reduce(0) { $0 + $1/Double(prOpenLengths.count) } }
    }

    public var prsOpened: LimitedStat<Int> {
        return userStats.values.map { $0.pullRequestStat.opened }.reduce(0, +)
    }

    public var avgPrsOpened: LimitedStat<Double> {
        return userStats.values.map { $0.pullRequestStat.opened }.reduce(0) { $0 + Double($1)/Double(userStats.count) }
    }

    public var prsClosed: LimitedStat<Int> {
        return userStats.values.map { $0.pullRequestStat.closed }.reduce(0, +)
    }

    public var avgPrsClosed: LimitedStat<Double> {
        return userStats.values.map { $0.pullRequestStat.closed }.reduce(0) { $0 + Double($1)/Double(userStats.count) }
    }

    public var prComments: LimitedStat<Int> {
        return userStats.values.map { $0.pullRequestStat.commentEvents }.reduce(0, +)
    }

    public var avgPrComments: LimitedStat<Double> {
        return userStats.values.map { $0.pullRequestStat.commentEvents }.reduce(0) { $0 + Double($1)/Double(userStats.count) }
    }

    public var linesAdded: LimitlessStat<Int> {
        return userStats.values.map { $0.codeStat.linesAdded }.reduce(0, +)
    }

    public var avgLinesAdded: LimitlessStat<Double> {
        return userStats.values.map { $0.codeStat.linesAdded }.reduce(0) { $0 + Double($1)/Double(userStats.count) }
    }

    public var linesDeleted: LimitlessStat<Int> {
        return userStats.values.map { $0.codeStat.linesDeleted }.reduce(0, +)
    }

    public var avgLinesDeleted: LimitlessStat<Double> {
        return userStats.values.map { $0.codeStat.linesDeleted }.reduce(0) { $0 + Double($1)/Double(userStats.count) }
    }

    public var lines: LimitlessStat<Int> {
        return userStats.values.map { $0.codeStat.lines }.reduce(0, +)
    }

    public var avgLines: LimitlessStat<Double> {
		return userStats.values.map { $0.codeStat.lines }.reduce(0) { $0 + Double($1)/Double(userStats.count) }
    }

    public var commits: LimitlessStat<Int> {
        return userStats.values.map { $0.codeStat.commits }.reduce(0, +)
    }

    public var avgCommits: LimitlessStat<Double> {
		return userStats.values.map { $0.codeStat.commits }.reduce(0) { $0 + Double($1)/Double(userStats.count) }
    }

    public var earliestEvent: Date? {
		return userStats.values.map { $0.earliestEvent }.reduce(nil, { a, b in
			let minEvent = a.flatMap { au in b.map { min(au, $0) } }
			let earliestEvent = minEvent ?? a ?? b
			return earliestEvent
		})
    }
}
