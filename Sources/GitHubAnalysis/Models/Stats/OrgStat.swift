//
//  OrgStat.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/3/18.
//

import Foundation

struct OrgStat {
    let orgName: String
    let repoStats: [RepositoryName: RepoStat]

    var userStats: [Username: UserStat] {
        var users = [Username: UserStat]()

        for repo in repoStats.values {
            for user in repo.userStats {
                users[user.key, default: UserStat()] += user.value
            }
        }

        return users
    }

    var prOpenLengths: LimitedStat<[Double]> {
        return repoStats.values.map { $0.prOpenLengths }.reduce([], +)
    }

    /// Average is given in seconds
    var avgPROpenLength: LimitedStat<TimeInterval> {
		return prOpenLengths.map { $0.reduce(0) { $0 + $1/Double(prOpenLengths.count) } }
    }

    var prsOpened: LimitedStat<Int> {
        return repoStats.values.map { $0.prsOpened }.reduce(0, +)
    }

    var avgPrsOpened: LimitedStat<Double> {
        return repoStats.values.map { $0.prsOpened }.reduce(0, { $0 + Double($1)/Double(repoStats.count) })
    }

    var prsClosed: LimitedStat<Int> {
        return repoStats.values.map { $0.prsClosed }.reduce(0, +)
    }

    var avgPrsClosed: LimitedStat<Double> {
        return repoStats.values.map { $0.prsClosed }.reduce(0, { $0 + Double($1)/Double(repoStats.count) })
    }

    var prComments: LimitedStat<Int> {
        return repoStats.values.map { $0.prComments }.reduce(0, +)
    }

    var avgPrComments: LimitedStat<Double> {
        return repoStats.values.map { $0.prComments }.reduce(0, { $0 + Double($1)/Double(repoStats.count) })
    }

    var linesAdded: LimitlessStat<Int> {
        return repoStats.values.map { $0.linesAdded }.reduce(0, +)
    }

    var avgLinesAdded: LimitlessStat<Double> {
        return repoStats.values.map { $0.linesAdded }.reduce(0, { $0 + Double($1)/Double(repoStats.count) })
    }

    var linesDeleted: LimitlessStat<Int> {
        return repoStats.values.map { $0.linesDeleted }.reduce(0, +)
    }

    var avgLinesDeleted: LimitlessStat<Double> {
        return repoStats.values.map { $0.linesDeleted }.reduce(0, { $0 + Double($1)/Double(repoStats.count) })
    }

    var lines: LimitlessStat<Int> {
        return repoStats.values.map { $0.lines }.reduce(0, +)
    }

    var avgLines: LimitlessStat<Double> {
        return repoStats.values.map { $0.lines }.reduce(0, { $0 + Double($1)/Double(repoStats.count) })
    }

    var commits: LimitlessStat<Int> {
        return repoStats.values.map { $0.commits }.reduce(0, +)
    }

    var avgCommits: LimitlessStat<Double> {
        return repoStats.values.map { $0.commits }.reduce(0, { $0 + Double($1)/Double(repoStats.count) })
    }

    var earliestEvent: Date? {
		return repoStats.values.map { $0.earliestEvent }.reduce(nil, { a, b in
			let minEvent = a.flatMap { au in b.map { min(au, $0) } }
			let earliestEvent = minEvent ?? a ?? b
			return earliestEvent
		})
    }

    var earliestReliable: (date: Date?, limitingRepo: String) {
		// What we actually need to accomplish here is:
		// If no repos have an earliest date, nil is the earliest reliable date (aka no info on reliablity)
		// If multiple repos have earliest dates, pick the latest of those dates.
		// The code just gets complicated because the dates can be nil.
        return repoStats.reduce((date: nil, limitingRepo: "null"),
                                { earliestYet, next in
									return earliestYet.date.flatMap { earliestDateYet in
										next.value.earliestEvent.map { nextDate in
											return nextDate > earliestDateYet ? (date: nextDate, limitingRepo: next.key) : earliestYet
										}
									} ?? (date: next.value.earliestEvent, limitingRepo: next.key)
		})
    }
}
