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

	/// The earliest reliable date/repository is the date after which
	/// all repositories have event data available and the repository
	/// for which that date is the earliest any event data is available.
	/// For the purposes of this calculation, repositories that do not
	/// have any event data available in the time window specified
	/// are not considered. See `unreliableRepositories` for a list
	/// of empty repositories.
    public var earliestReliable: (date: Date, name: String)? {
		typealias Repo = (date: Date, name: String)
		
		let repos: [Repo] = repoStats.map { repo in
				return repo.value.earliestEvent.map { (earliest: $0, name: repo.key) }
			}.compactMap { $0 }
		
		let reducer = { (earliestYet: Repo?, next: Repo) in
			return earliestYet.map { current in
				return next.date > current.date ? next : current
			} ?? next
		}
		
        return repos.reduce(nil, reducer)
    }
	
	/// A list of repositories that might not be reliable. These repositories
	/// don't have any events to analyze in the given time window. It is
	/// possible there simply were no events in the window, but it is also
	/// possible the window is farther back that the GitHub API will provide
	/// events and there are no relevant events locally cached either.
	public var unreliableRepositories: [RepositoryName] {
		return repoStats.compactMap { $0.value.userStats.compactMap { $0.value.earliestEvent }.isEmpty ? $0.key : nil }
	}
}
