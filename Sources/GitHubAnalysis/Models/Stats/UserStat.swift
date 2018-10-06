//
//  UserStat.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/3/18.
//

import Foundation

struct UserStat {
    let pullRequestStat: PullRequestStat
    let codeStat: CodeStat
    let earliestEvent: Date? // needs to be optional rather than defaulting to distant future.

    struct PullRequestStat {
		/// Limited because calculated using events API.
        let opened: LimitedStat<Int>
		
		/// Limited because calculated using events API.
        let closed: LimitedStat<Int>
		
		/// Limited because calculated using events API.
        let openLengths: LimitedStat<[TimeInterval]>
		
		/// This stat means how many Pull Requests were owned (i.e. created) by the user. It is
		/// not calculated by the "created" events, because that would be a LimitedStat.
//		let totalOwned: LimitlessStat<Int>
		
		/// Count of all comments left on Pull Requests. This is not calculated using the events
		/// API so it is limitless, but the API used for this stat is still in "preview" status.
//		let comments: LimitlessStat<Int>
		
		/// Count of all comments left on Pull Requests. This is calculated using the events API
		/// so it is limited by how far back the API returns events.
		let commentEvents: LimitedStat<Int>

		/// Limited because calculated using events API.
        var avgOpenLength: LimitedStat<Double> {
			return openLengths.map { openLengthsUnwrapped in
				openLengthsUnwrapped.reduce(0, { $0 + $1/Double(openLengthsUnwrapped.count) })
			}
        }
    }

    struct CodeStat {
        let linesAdded: LimitlessStat<Int>
        let linesDeleted: LimitlessStat<Int>
        let commits: LimitlessStat<Int>

        var lines: LimitlessStat<Int> {
			return zip(linesAdded, linesDeleted) { $0 + $1 }
        }
    }
}

extension UserStat {
    static func +(lhs: UserStat, rhs: UserStat) -> UserStat {
		let minEvent = lhs.earliestEvent.flatMap { lhsu in rhs.earliestEvent.map { min(lhsu, $0) } }
		let earliestEvent = minEvent ?? lhs.earliestEvent ?? rhs.earliestEvent
		
        return .init(pullRequestStat: lhs.pullRequestStat + rhs.pullRequestStat,
                     codeStat: lhs.codeStat + rhs.codeStat,
		earliestEvent: earliestEvent)
    }

    static func +=(lhs: inout UserStat, rhs: UserStat) {
        lhs = lhs + rhs
    }
}

extension UserStat {
    func with(_ prStat: PullRequestStat) -> UserStat {
        return UserStat(pullRequestStat: prStat, codeStat: codeStat, earliestEvent: earliestEvent)
    }

    func with(_ codeStat: CodeStat) -> UserStat {
        return UserStat(pullRequestStat: pullRequestStat, codeStat: codeStat, earliestEvent: earliestEvent)
    }

    func adding(_ prStat: PullRequestStat) -> UserStat {
        return UserStat(pullRequestStat: pullRequestStat + prStat, codeStat: codeStat, earliestEvent: earliestEvent)
    }

    func adding(_ codeStat: CodeStat) -> UserStat {
        return UserStat(pullRequestStat: pullRequestStat, codeStat: self.codeStat + codeStat, earliestEvent: earliestEvent)
    }

    func updating(earliestEvent: Date) -> UserStat {
		return UserStat(pullRequestStat: pullRequestStat, codeStat: codeStat, earliestEvent: self.earliestEvent.map { min(earliestEvent, $0) } ?? earliestEvent)
    }

    mutating func update(earliestEvent: Date) {
        self = self.updating(earliestEvent: earliestEvent)
    }

    static func +=(lhs: inout UserStat, rhs: UserStat.PullRequestStat) {
        lhs = lhs.adding(rhs)
    }

    static func +=(lhs: inout UserStat, rhs: UserStat.CodeStat) {
        lhs = lhs.adding(rhs)
    }

    init() {
        pullRequestStat = PullRequestStat.empty
        codeStat = CodeStat.empty
        earliestEvent = nil
    }
}

extension UserStat.PullRequestStat {
    static func +(lhs: UserStat.PullRequestStat, rhs: UserStat.PullRequestStat) -> UserStat.PullRequestStat {
        return .init(opened: lhs.opened + rhs.opened,
                     closed: lhs.closed + rhs.closed,
                     openLengths: lhs.openLengths + rhs.openLengths,
                     commentEvents: lhs.commentEvents + rhs.commentEvents)
    }

    static func +=(lhs: inout UserStat.PullRequestStat, rhs: UserStat.PullRequestStat) {
        lhs = lhs + rhs
    }
	
	init(opened: Int, closed: Int, openLengths: [TimeInterval], commentEvents: Int) {
		self.init(opened: .init(value: opened),
				  closed: .init(value: closed),
				  openLengths: .init(value: openLengths),
				  commentEvents: .init(value: commentEvents))
	}

    private init() {
        opened = 0
        closed = 0
        openLengths = []
        commentEvents = 0
    }

    static var empty: UserStat.PullRequestStat {
        return UserStat.PullRequestStat()
    }
}

extension UserStat.CodeStat {
    static func +(lhs: UserStat.CodeStat, rhs: UserStat.CodeStat) -> UserStat.CodeStat {
        return .init(linesAdded: lhs.linesAdded + rhs.linesAdded,
                     linesDeleted: lhs.linesDeleted + rhs.linesDeleted,
                     commits: lhs.commits + rhs.commits)
    }

    static func +=(lhs: inout UserStat.CodeStat, rhs: UserStat.CodeStat) {
        lhs = lhs + rhs
    }
	
	init(linesAdded: Int, linesDeleted: Int, commits: Int) {
		self.init(linesAdded: .init(value: linesAdded),
				  linesDeleted: .init(value: linesDeleted),
				  commits: .init(value: commits))
	}

    private init() {
        linesAdded = 0
        linesDeleted = 0
        commits = 0
    }

    static var empty: UserStat.CodeStat {
        return UserStat.CodeStat()
    }
}

extension UserStat.PullRequestStat {
    static var opened: UserStat.PullRequestStat {
        return .init(opened: 1, closed: 0, openLengths: [], commentEvents: 0)
    }

    static func closed(at closeTime: Date, with openTime: Date? = nil) -> UserStat.PullRequestStat {
        let openLength: TimeInterval? = openTime.map { closeTime.timeIntervalSince($0) }
        return .init(opened: 0, closed: 1, openLengths: openLength.map { [$0] } ?? [], commentEvents: 0)
    }

    static var commented: UserStat.PullRequestStat {
        return .init(opened: 0, closed: 0, openLengths: [], commentEvents: 1)
    }
}
