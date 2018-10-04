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

    var prOpenLengths: [Double] {
        return userStats.values.map { $0.pullRequestStat.openLengths }.reduce([], +)
    }

    /// Average is given in seconds
    var avgPROpenLength: TimeInterval {
        return prOpenLengths.reduce(0, { $0 + $1/Double(prOpenLengths.count) })
    }

    var prsOpened: Int {
        return userStats.values.map { $0.pullRequestStat.opened }.reduce(0, +)
    }

    var avgPrsOpened: Double {
        return userStats.values.map { $0.pullRequestStat.opened }.reduce(0, { $0 + Double($1)/Double(userStats.count) })
    }

    var prsClosed: Int {
        return userStats.values.map { $0.pullRequestStat.closed }.reduce(0, +)
    }

    var avgPrsClosed: Double {
        return userStats.values.map { $0.pullRequestStat.closed }.reduce(0, { $0 + Double($1)/Double(userStats.count) })
    }

    var prComments: Int {
        return userStats.values.map { $0.pullRequestStat.comments }.reduce(0, +)
    }

    var avgPrComments: Double {
        return userStats.values.map { $0.pullRequestStat.comments }.reduce(0, { $0 + Double($1)/Double(userStats.count) })
    }

    var linesAdded: Int {
        return userStats.values.map { $0.codeStat.linesAdded }.reduce(0, +)
    }

    var avgLinesAdded: Double {
        return userStats.values.map { $0.codeStat.linesAdded }.reduce(0, { $0 + Double($1)/Double(userStats.count) })
    }

    var linesDeleted: Int {
        return userStats.values.map { $0.codeStat.linesDeleted }.reduce(0, +)
    }

    var avgLinesDeleted: Double {
        return userStats.values.map { $0.codeStat.linesDeleted }.reduce(0, { $0 + Double($1)/Double(userStats.count) })
    }

    var lines: Int {
        return userStats.values.map { $0.codeStat.lines }.reduce(0, +)
    }

    var avgLines: Double {
        return userStats.values.map { $0.codeStat.lines }.reduce(0, { $0 + Double($1)/Double(userStats.count) })
    }

    var commits: Int {
        return userStats.values.map { $0.codeStat.commits }.reduce(0, +)
    }

    var avgCommits: Double {
        return userStats.values.map { $0.codeStat.commits }.reduce(0, { $0 + Double($1)/Double(userStats.count) })
    }

    var earliestEvent: Date {
        return userStats.values.map { $0.earliestEvent }.reduce(Date.distantFuture, { min($0, $1) })
    }
}
