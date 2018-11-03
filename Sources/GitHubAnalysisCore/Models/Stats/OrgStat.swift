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
		
		pullRequestStats = .init(repoPrStats: repoStats.values.map { $0.pullRequestStats },
								 numberOfUsers: userStats.count)
		codeStats = .init(codeStats: repoStats.values.map { $0.codeStats },
						  numberOfUsers: userStats.count)
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
		public let openLengths: SumAndAvg<LimitedStat<[TimeInterval]>, (perPullRequest: LimitedStat<Double>, perUser: LimitedStat<Double>, perRepo: LimitedStat<Double>)>
		
		public let opened: StatAggregate<Limited, Int>
		
		public let closed: StatAggregate<Limited, Int>
		
		public let comments: StatAggregate<Limited, Int>
		
		init(repoPrStats: [RepoStat.PullRequest], numberOfUsers: Int) {
			let allOpenLengths = repoPrStats.map { $0.openLengths.total }.reduce([], +)
			let prAvgOpenLength = allOpenLengths.reduce(0) { $0 + Double($1)/Double(allOpenLengths.count) }
			let userAvgOpenLength = repoPrStats.map { $0.openLengths.average.perUser }.reduce(0) { $0 + Double($1)/Double(numberOfUsers) }
			let repoAvgOpenLength = repoPrStats.map { $0.openLengths.average.perUser }.reduce(0) { $0 + Double($1)/Double(repoPrStats.count) }
			
			openLengths = (total: allOpenLengths,
						   average: (perPullRequest: prAvgOpenLength,
									 perUser: userAvgOpenLength,
									 perRepo: repoAvgOpenLength))
			
			opened = OrgStat.aggregate(of: repoPrStats.map { $0.opened },
									   numberOfUsers: numberOfUsers)
			closed = OrgStat.aggregate(of: repoPrStats.map { $0.closed },
									   numberOfUsers: numberOfUsers)
			comments = OrgStat.aggregate(of: repoPrStats.map { $0.comments },
										 numberOfUsers: numberOfUsers)
		}
	}
	
	struct Code {
		public let linesAdded: StatAggregate<Limitless, Int>
		
		public let linesDeleted: StatAggregate<Limitless, Int>
		
		public let lines: StatAggregate<Limitless, Int>
		
		public let commits: StatAggregate<Limitless, Int>
		
		init(codeStats: [RepoStat.Code], numberOfUsers: Int) {
			linesAdded = OrgStat.aggregate(of: codeStats.map { $0.linesAdded },
										   numberOfUsers: numberOfUsers)
			linesDeleted = OrgStat.aggregate(of: codeStats.map { $0.linesDeleted },
											 numberOfUsers: numberOfUsers)
			lines = OrgStat.aggregate(of: codeStats.map { $0.lines },
									  numberOfUsers: numberOfUsers)
			commits = OrgStat.aggregate(of: codeStats.map { $0.commits },
										numberOfUsers: numberOfUsers)
		}
	}
	
	static func aggregate<B: Bound>(of stats: [SumAndAvg<BasicStat<B, Int>, BasicStat<B, Double>>], numberOfUsers: Int) -> StatAggregate<B, Int> {
		let repo = aggregateSumAndAvg(stats.map { $0.total })
		let userAvg = repo.total.map { Double($0) / Double(numberOfUsers) }
		
		return (total: repo.total, average: (perUser: userAvg, perRepo: repo.average))
	}
}
