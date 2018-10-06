//
//  RepoStat.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/3/18.
//

import Foundation

struct RepoStat {
    let repoName: String
    let userStats: [Username: UserStat]

    var prOpenLengths: LimitedStat<[TimeInterval]> {
        return userStats.values.map { $0.pullRequestStat.openLengths }.reduce([], +)
    }

    /// Average is given in seconds
    var avgPROpenLength: LimitedStat<TimeInterval> {
		return prOpenLengths.map { $0.reduce(0) { $0 + $1/Double(prOpenLengths.count) } }
    }

    var prsOpened: LimitedStat<Int> {
        return userStats.values.map { $0.pullRequestStat.opened }.reduce(0, +)
    }

    var avgPrsOpened: LimitedStat<Double> {
        return userStats.values.map { $0.pullRequestStat.opened }.reduce(0) { $0 + Double($1)/Double(userStats.count) }
    }

    var prsClosed: LimitedStat<Int> {
        return userStats.values.map { $0.pullRequestStat.closed }.reduce(0, +)
    }

    var avgPrsClosed: LimitedStat<Double> {
        return userStats.values.map { $0.pullRequestStat.closed }.reduce(0) { $0 + Double($1)/Double(userStats.count) }
    }

    var prComments: LimitedStat<Int> {
        return userStats.values.map { $0.pullRequestStat.commentEvents }.reduce(0, +)
    }

    var avgPrComments: LimitedStat<Double> {
        return userStats.values.map { $0.pullRequestStat.commentEvents }.reduce(0) { $0 + Double($1)/Double(userStats.count) }
    }

    var linesAdded: LimitlessStat<Int> {
        return userStats.values.map { $0.codeStat.linesAdded }.reduce(0, +)
    }

    var avgLinesAdded: LimitlessStat<Double> {
        return userStats.values.map { $0.codeStat.linesAdded }.reduce(0) { $0 + Double($1)/Double(userStats.count) }
    }

    var linesDeleted: LimitlessStat<Int> {
        return userStats.values.map { $0.codeStat.linesDeleted }.reduce(0, +)
    }

    var avgLinesDeleted: LimitlessStat<Double> {
        return userStats.values.map { $0.codeStat.linesDeleted }.reduce(0) { $0 + Double($1)/Double(userStats.count) }
    }

    var lines: LimitlessStat<Int> {
        return userStats.values.map { $0.codeStat.lines }.reduce(0, +)
    }

    var avgLines: LimitlessStat<Double> {
		return userStats.values.map { $0.codeStat.lines }.reduce(0) { $0 + Double($1)/Double(userStats.count) }
    }

    var commits: LimitlessStat<Int> {
        return userStats.values.map { $0.codeStat.commits }.reduce(0, +)
    }

    var avgCommits: LimitlessStat<Double> {
		return userStats.values.map { $0.codeStat.commits }.reduce(0) { $0 + Double($1)/Double(userStats.count) }
    }

    var earliestEvent: Date? {
		return userStats.values.map { $0.earliestEvent }.reduce(nil, { a, b in
			let minEvent = a.flatMap { au in b.map { min(au, $0) } }
			let earliestEvent = minEvent ?? a ?? b
			return earliestEvent
		})
    }
}
