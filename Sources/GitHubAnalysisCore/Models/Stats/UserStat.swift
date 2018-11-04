//
//  UserStat.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/3/18.
//

import Foundation

public struct UserStat: Equatable {
    public let pullRequestStat: PullRequest
    public let codeStat: Code
    public let earliestEvent: Date? // needs to be optional rather than defaulting to distant future.

	public typealias PullRequest = PullRequestStat
	public typealias Code = CodeStat
}

public extension UserStat {
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

public extension UserStat {
	/// Returns the result of replacing this UserStat's PullRequestStat with
	/// the given one.
    func replacing(_ prStat: PullRequest) -> UserStat {
        return UserStat(pullRequestStat: prStat, codeStat: codeStat, earliestEvent: earliestEvent)
    }

	/// Returns the result of replacing this UserStat's CodeStat with the
	/// given one.
    func replacing(_ codeStat: Code) -> UserStat {
        return UserStat(pullRequestStat: pullRequestStat, codeStat: codeStat, earliestEvent: earliestEvent)
    }

	/// Returns the result of adding the given PullRequestStat to this UserStat.
    func adding(_ prStat: PullRequest) -> UserStat {
        return UserStat(pullRequestStat: pullRequestStat + prStat, codeStat: codeStat, earliestEvent: earliestEvent)
    }

	/// Returns the result of adding the given CodeStat to this UserStat.
    func adding(_ codeStat: Code) -> UserStat {
        return UserStat(pullRequestStat: pullRequestStat, codeStat: self.codeStat + codeStat, earliestEvent: earliestEvent)
    }

	/// Returns the result of updating the earliest event date for this
	/// UserStat given the new event date. This means that if the given
	/// date is earlier than this UserStat's current earliestEvent then
	/// the returned UserStat will have the new event date as its
	/// earliestEvent. Otherwise, the returned UserStat will be equal to
	/// this UserStat.
    func updating(earliestEvent: Date) -> UserStat {
		return UserStat(pullRequestStat: pullRequestStat, codeStat: codeStat, earliestEvent: self.earliestEvent.map { min(earliestEvent, $0) } ?? earliestEvent)
    }

    mutating func update(earliestEvent: Date) {
        self = self.updating(earliestEvent: earliestEvent)
    }

    static func +=(lhs: inout UserStat, rhs: UserStat.PullRequest) {
        lhs = lhs.adding(rhs)
    }

    static func +=(lhs: inout UserStat, rhs: UserStat.Code) {
        lhs = lhs.adding(rhs)
    }

    init() {
        pullRequestStat = PullRequest.empty
        codeStat = Code.empty
        earliestEvent = nil
    }
}

public struct PullRequestStat: Equatable {
	/// Limited because calculated using events API.
	public let opened: LimitedStat<Int>
	
	/// Limited because calculated using events API.
	public let closed: LimitedStat<Int>
	
	/// Limited because calculated using events API.
	public let openLengths: LimitedStat<[TimeInterval]>
	
	/// This stat means how many Pull Requests were owned (i.e. created) by the user. It is
	/// not calculated by the "created" events, because that would be a LimitedStat.
	//		let totalOwned: LimitlessStat<Int>
	
	/// Count of all comments left on Pull Requests. This is not calculated using the events
	/// API so it is limitless, but the API used for this stat is still in "preview" status.
	//		let comments: LimitlessStat<Int>
	
	/// Count of all comments left on Pull Requests. This is calculated using the events API
	/// so it is limited by how far back the API returns events.
	public let commentEvents: LimitedStat<Int>
	
	/// Limited because calculated using events API.
	public var avgOpenLength: LimitedStat<Double> {
		return openLengths.map { openLengthsUnwrapped in
			openLengthsUnwrapped.reduce(0, { $0 + $1/Double(openLengthsUnwrapped.count) })
		}
	}
}

public extension PullRequestStat {
	static func +(lhs: PullRequestStat, rhs: PullRequestStat) -> PullRequestStat {
		return .init(opened: lhs.opened + rhs.opened,
					 closed: lhs.closed + rhs.closed,
					 openLengths: lhs.openLengths + rhs.openLengths,
					 commentEvents: lhs.commentEvents + rhs.commentEvents)
	}
	
	static func +=(lhs: inout PullRequestStat, rhs: PullRequestStat) {
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
	
	static var empty: PullRequestStat {
		return PullRequestStat()
	}
}

public extension PullRequestStat {
    static var opened: PullRequestStat {
        return .init(opened: 1, closed: 0, openLengths: [], commentEvents: 0)
    }

    static func closed(at closeTime: Date, with openTime: Date? = nil) -> UserStat.PullRequest {
        let openLength: TimeInterval? = openTime.map { closeTime.timeIntervalSince($0) }
        return .init(opened: 0, closed: 1, openLengths: openLength.map { [$0] } ?? [], commentEvents: 0)
    }

    static var commented: PullRequestStat {
        return .init(opened: 0, closed: 0, openLengths: [], commentEvents: 1)
    }
}
