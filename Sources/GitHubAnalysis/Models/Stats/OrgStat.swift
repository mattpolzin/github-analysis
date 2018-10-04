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

    var prOpenLengths: [Double] {
        return repoStats.values.map { $0.prOpenLengths }.reduce([], +)
    }

    /// Average is given in seconds
    var avgPROpenLength: Double {
        return prOpenLengths.reduce(0, { $0 + $1/Double(prOpenLengths.count) })
    }

    var prsOpened: Int {
        return repoStats.values.map { $0.prsOpened }.reduce(0, +)
    }

    var avgPrsOpened: Double {
        return repoStats.values.map { $0.prsOpened }.reduce(0, { $0 + Double($1)/Double(repoStats.count) })
    }

    var prsClosed: Int {
        return repoStats.values.map { $0.prsClosed }.reduce(0, +)
    }

    var avgPrsClosed: Double {
        return repoStats.values.map { $0.prsClosed }.reduce(0, { $0 + Double($1)/Double(repoStats.count) })
    }

    var prComments: Int {
        return repoStats.values.map { $0.prComments }.reduce(0, +)
    }

    var avgPrComments: Double {
        return repoStats.values.map { $0.prComments }.reduce(0, { $0 + Double($1)/Double(repoStats.count) })
    }

    var linesAdded: Int {
        return repoStats.values.map { $0.linesAdded }.reduce(0, +)
    }

    var avgLinesAdded: Double {
        return repoStats.values.map { $0.linesAdded }.reduce(0, { $0 + Double($1)/Double(repoStats.count) })
    }

    var linesDeleted: Int {
        return repoStats.values.map { $0.linesDeleted }.reduce(0, +)
    }

    var avgLinesDeleted: Double {
        return repoStats.values.map { $0.linesDeleted }.reduce(0, { $0 + Double($1)/Double(repoStats.count) })
    }

    var lines: Int {
        return repoStats.values.map { $0.lines }.reduce(0, +)
    }

    var avgLines: Double {
        return repoStats.values.map { $0.lines }.reduce(0, { $0 + Double($1)/Double(repoStats.count) })
    }

    var commits: Int {
        return repoStats.values.map { $0.commits }.reduce(0, +)
    }

    var avgCommits: Double {
        return repoStats.values.map { $0.commits }.reduce(0, { $0 + Double($1)/Double(repoStats.count) })
    }

    var earliestEvent: Date {
        return repoStats.values.map { $0.earliestEvent }.reduce(Date.distantFuture, { min($0, $1) })
    }

    var earliestReliable: (date: Date, limitingRepo: String) {
        return repoStats.reduce((date: earliestEvent, limitingRepo: "null"),
                                { $1.value.earliestEvent > $0.date ? (date: $1.value.earliestEvent, limitingRepo: $1.key) : $0  })
    }
}
