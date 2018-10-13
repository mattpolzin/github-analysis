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

    public let userStats: [Username: UserStat]
	
	public let pullRequestStats: PullRequest
	public let codeStats: Code
	
	public init(orgName: String, repoStats: [RepositoryName: RepoStat]) {
		self.orgName = orgName
		self.repoStats = repoStats
		
		var users = [Username: UserStat]()
		
		for repo in repoStats.values {
			for user in repo.userStats {
				users[user.key, default: UserStat()] += user.value
			}
		}
		
		userStats = users
		
		pullRequestStats = .init(prStats: repoStats.values.map { $0.pullRequestStats })
		codeStats = .init(codeStats: repoStats.values.map { $0.codeStats })
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
	
//	public typealias PullRequest = AggregatePullRequestStat
//	public typealias Code = AggregateCodeStat
}

public extension OrgStat {
	typealias StatAverages<B: Bound> = (perUser: BasicStat<B, Double>, perRepo: BasicStat<B, Double>)
	typealias StatAggregate<B: Bound, Total: CustomStringConvertible> = SumAndAvg<BasicStat<B, Total>, StatAverages<B>>
	
	struct PullRequest {
		/// Average is given in seconds
		public let openLengths: AggregateLimitedStat<[TimeInterval], Double>
		
		public let opened: StatAggregate<Limited, Int>
		
		public let closed: StatAggregate<Limited, Int>
		
		public let comments: StatAggregate<Limited, Int>
		
		init(prStats: [RepoStat.PullRequest]) {
			let allOpenLengths = prStats.map { $0.openLengths.total }.reduce([], +)
			let avgOpenLength = allOpenLengths.map { $0.reduce(0) { $0 + Double($1)/Double(allOpenLengths.count) } }
			
			openLengths = (total: allOpenLengths, average: avgOpenLength)
			
			opened = OrgStat.aggregate(of: prStats.map { $0.opened })
			closed = OrgStat.aggregate(of: prStats.map { $0.closed })
			comments = OrgStat.aggregate(of: prStats.map { $0.comments })
		}
	}
	
	struct Code {
		public let linesAdded: StatAggregate<Limitless, Int>
		
		public let linesDeleted: StatAggregate<Limitless, Int>
		
		public let lines: StatAggregate<Limitless, Int>
		
		public let commits: StatAggregate<Limitless, Int>
		
		init(codeStats: [RepoStat.Code]) {
			linesAdded = OrgStat.aggregate(of: codeStats.map { $0.linesAdded })
			linesDeleted = OrgStat.aggregate(of: codeStats.map { $0.linesDeleted })
			lines = OrgStat.aggregate(of: codeStats.map { $0.lines })
			commits = OrgStat.aggregate(of: codeStats.map { $0.commits })
		}
	}
	
	private static func aggregate<B: Bound>(of input: [SumAndAvg<BasicStat<B, Int>, BasicStat<B, Double>>]) -> StatAggregate<B, Int> {
		let repo = aggregateSumAndAvg(input.map { $0.total })
		let userAvg = aggregateSumAndAvg(input.map { $0.average }).average
		
		return (total: repo.total, average: (perUser: userAvg, perRepo: repo.average))
	}
}
