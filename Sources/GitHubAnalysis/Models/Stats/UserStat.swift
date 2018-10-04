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
    let earliestEvent: Date

    struct PullRequestStat {
        let opened: Int
        let closed: Int
        let openLengths: [TimeInterval]
        let comments: Int

        var avgOpenLength: Double {
            return openLengths.reduce(0, { $0 + $1/Double(openLengths.count) })
        }
    }

    struct CodeStat {
        let linesAdded: Int
        let linesDeleted: Int
        let commits: Int

        var lines: Int {
            return linesAdded + linesDeleted
        }
    }
}

extension UserStat {
    static func +(lhs: UserStat, rhs: UserStat) -> UserStat {
        return .init(pullRequestStat: lhs.pullRequestStat + rhs.pullRequestStat,
                     codeStat: lhs.codeStat + rhs.codeStat,
                     earliestEvent: min(lhs.earliestEvent, rhs.earliestEvent))
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
        return UserStat(pullRequestStat: pullRequestStat, codeStat: codeStat, earliestEvent: min(earliestEvent, self.earliestEvent))
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
        earliestEvent = Date.distantFuture
    }
}

extension UserStat.PullRequestStat {
    static func +(lhs: UserStat.PullRequestStat, rhs: UserStat.PullRequestStat) -> UserStat.PullRequestStat {
        return .init(opened: lhs.opened + rhs.opened,
                     closed: lhs.closed + rhs.closed,
                     openLengths: lhs.openLengths + rhs.openLengths,
                     comments: lhs.comments + rhs.comments)
    }

    static func +=(lhs: inout UserStat.PullRequestStat, rhs: UserStat.PullRequestStat) {
        lhs = lhs + rhs
    }

    private init() {
        opened = 0
        closed = 0
        openLengths = []
        comments = 0
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
        return .init(opened: 1, closed: 0, openLengths: [], comments: 0)
    }

    static func closed(at closeTime: Date, with openTime: Date? = nil) -> UserStat.PullRequestStat {
        let openLength: TimeInterval? = openTime.map { closeTime.timeIntervalSince($0) }
        return .init(opened: 0, closed: 1, openLengths: openLength.map { [$0] } ?? [], comments: 0)
    }

    static var commented: UserStat.PullRequestStat {
        return .init(opened: 0, closed: 0, openLengths: [], comments: 1)
    }
}
