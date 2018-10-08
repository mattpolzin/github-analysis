//
//  OrgStat.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/3/18.
//

import Foundation

public struct OrgStat {
    public let orgName: String
    public let repoStats: [RepositoryName: RepoStat]

    public var userStats: [Username: UserStat] {
        var users = [Username: UserStat]()

        for repo in repoStats.values {
            for user in repo.userStats {
                users[user.key, default: UserStat()] += user.value
            }
        }

        return users
    }

    public var prOpenLengths: LimitedStat<[Double]> {
        return repoStats.values.map { $0.prOpenLengths }.reduce([], +)
    }

    /// Average is given in seconds
    public var avgPROpenLength: LimitedStat<TimeInterval> {
		return prOpenLengths.map { $0.reduce(0) { $0 + $1/Double(prOpenLengths.count) } }
    }
	
    public var prsOpened: LimitedStat<Int> {
        return repoStats.values.map { $0.prsOpened }.reduce(0, +)
    }

    public var avgPrsOpenedPerRepo: LimitedStat<Double> {
        return repoStats.values.map { $0.prsOpened }.reduce(0) { $0 + Double($1)/Double(repoStats.count) }
    }
	
	public var avgPrsOpenedPerUser: LimitedStat<Double> {
		return repoStats.values.map { $0.avgPrsOpened }.reduce(0) { $0 + Double($1)/Double(repoStats.count) }
	}

    public var prsClosed: LimitedStat<Int> {
        return repoStats.values.map { $0.prsClosed }.reduce(0, +)
    }

    public var avgPrsClosedPerRepo: LimitedStat<Double> {
        return repoStats.values.map { $0.prsClosed }.reduce(0, { $0 + Double($1)/Double(repoStats.count) })
    }
	
	public var avgPrsClosedPerUser: LimitedStat<Double> {
		return repoStats.values.map { $0.avgPrsClosed }.reduce(0, { $0 + Double($1)/Double(repoStats.count) })
	}

    public var prComments: LimitedStat<Int> {
        return repoStats.values.map { $0.prComments }.reduce(0, +)
    }

    public var avgPrCommentsPerRepo: LimitedStat<Double> {
        return repoStats.values.map { $0.prComments }.reduce(0, { $0 + Double($1)/Double(repoStats.count) })
    }
	
	public var avgPrCommentsPerUser: LimitedStat<Double> {
		return repoStats.values.map { $0.avgPrComments }.reduce(0, { $0 + Double($1)/Double(repoStats.count) })
	}

    public var linesAdded: LimitlessStat<Int> {
        return repoStats.values.map { $0.linesAdded }.reduce(0, +)
    }

    public var avgLinesAddedPerRepo: LimitlessStat<Double> {
        return repoStats.values.map { $0.linesAdded }.reduce(0, { $0 + Double($1)/Double(repoStats.count) })
    }
	
	public var avgLinesAddedPerUser: LimitlessStat<Double> {
		return repoStats.values.map { $0.avgLinesAdded }.reduce(0, { $0 + Double($1)/Double(repoStats.count) })
	}

    public var linesDeleted: LimitlessStat<Int> {
        return repoStats.values.map { $0.linesDeleted }.reduce(0, +)
    }

    public var avgLinesDeletedPerRepo: LimitlessStat<Double> {
        return repoStats.values.map { $0.linesDeleted }.reduce(0, { $0 + Double($1)/Double(repoStats.count) })
    }
	
	public var avgLinesDeletedPerUser: LimitlessStat<Double> {
		return repoStats.values.map { $0.avgLinesDeleted }.reduce(0, { $0 + Double($1)/Double(repoStats.count) })
	}

    public var lines: LimitlessStat<Int> {
        return repoStats.values.map { $0.lines }.reduce(0, +)
    }

    public var avgLinesPerRepo: LimitlessStat<Double> {
        return repoStats.values.map { $0.lines }.reduce(0, { $0 + Double($1)/Double(repoStats.count) })
    }
	
	public var avgLinesPerUser: LimitlessStat<Double> {
		return repoStats.values.map { $0.avgLines }.reduce(0, { $0 + Double($1)/Double(repoStats.count) })
	}

    public var commits: LimitlessStat<Int> {
        return repoStats.values.map { $0.commits }.reduce(0, +)
    }

    public var avgCommitsPerRepo: LimitlessStat<Double> {
        return repoStats.values.map { $0.commits }.reduce(0, { $0 + Double($1)/Double(repoStats.count) })
    }
	
	public var avgCommitsPerUser: LimitlessStat<Double> {
		return repoStats.values.map { $0.avgCommits }.reduce(0, { $0 + Double($1)/Double(repoStats.count) })
	}

    public var earliestEvent: Date? {
		return repoStats.values.map { $0.earliestEvent }.reduce(nil, { a, b in
			let minEvent = a.flatMap { au in b.map { min(au, $0) } }
			let earliestEvent = minEvent ?? a ?? b
			return earliestEvent
		})
    }

    public var earliestReliable: (date: Date?, limitingRepo: String) {
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
