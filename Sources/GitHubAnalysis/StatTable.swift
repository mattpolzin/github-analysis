//
//  StatPrinter.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/3/18.
//

import Foundation

private protocol Column {
    var values: [String] { get }
}


/// Organize available aggregated stats into a table
struct StatTable {
    private let orgStat: OrgStat
    private let users: [Username] // important to always order the same way

    init(orgStat: OrgStat) {
        self.orgStat = orgStat
        self.users = Array(orgStat.userStats.keys)
    }

    private typealias UserValue = String

    private struct UserColumn: Column {
        let header: String
        let total: String
        let average: String
        let userValues: [UserValue]

        var values: [String] {
            return [header, total, average, ""] + userValues
        }
    }

    private struct MiscColumn: Column {
        let header: String
        let rest: [String]

        var values: [String] {
            return [header] + rest
        }
    }

    private typealias Row = [String]

    private var columns: [Column] {
        return [
            indexColumn,
            prOpenedColumn,
            prClosedColumn,
            avgPROpenLength,
            prCommentsColumn,
            linesOfCodeAddedColumn,
            linesOfCodeDeletedColumn,
            totalLinesOfCodeColumn,
            commitsColumn,
            blankColumn,
            analysisLimitsIndexColumn,
            analysisLimitsColumn
        ]
    }

    private var rows: [Row] {
        return (0 ..< indexColumn.values.count).map { rowIdx in
            return columns.map { $0.values.count > rowIdx ? $0.values[rowIdx] : "" }
        }
    }

    private var blankColumn: MiscColumn {
        return .init(header: "", rest: [])
    }

    // MARK: User Columns
    private var indexColumn: UserColumn {
        return .init(
            header: "",
            total: "Org Total",
            average: "Org Average",
            userValues: users
        )
    }

    private var prOpenedColumn: UserColumn {
        return .init(
            header: "PRs opened",
            total: String(orgStat.prsOpened),
            average: String(orgStat.avgPrsOpened),
            userValues: users.map { orgStat.userStats[$0].map { String($0.pullRequestStat.opened) } ?? "" }
        )
    }

    private var prClosedColumn: UserColumn {
        return .init(
            header: "PRs closed",
            total: String(orgStat.prsClosed),
            average: String(orgStat.avgPrsClosed),
            userValues: users.map { orgStat.userStats[$0].map { String($0.pullRequestStat.closed) } ?? "" }
        )
    }

    private var avgPROpenLength: UserColumn {
        return .init(
            header: "Average PR open length (days)",
            total: "\\",
            average: String(orgStat.avgPROpenLength/(60 * 60 * 24)),
            userValues: users.map { orgStat.userStats[$0].map { String($0.pullRequestStat.avgOpenLength/(60 * 60 * 24)) } ?? "" }
        )
    }

    private var prCommentsColumn: UserColumn {
        return .init(
            header: "PR comments",
            total: String(orgStat.prComments),
            average: String(orgStat.avgPrComments),
            userValues: users.map { orgStat.userStats[$0].map { String($0.pullRequestStat.comments) } ?? "" }
        )
    }

    private var linesOfCodeAddedColumn: UserColumn {
        return .init(
            header: "LOC Added",
            total: String(orgStat.linesAdded),
            average: String(orgStat.avgLinesAdded),
            userValues: users.map { orgStat.userStats[$0].map { String($0.codeStat.linesAdded) } ?? "" }
        )
    }

    private var linesOfCodeDeletedColumn: UserColumn {
        return .init(
            header: "LOC Deleted",
            total: String(orgStat.linesDeleted),
            average: String(orgStat.avgLinesDeleted),
            userValues: users.map { orgStat.userStats[$0].map { String($0.codeStat.linesDeleted) } ?? "" }
        )
    }

    private var totalLinesOfCodeColumn: UserColumn {
        return .init(
            header: "Total LOC",
            total: String(orgStat.lines),
            average: String(orgStat.avgLines),
            userValues: users.map { orgStat.userStats[$0].map { String($0.codeStat.lines) } ?? "" }
        )
    }

    private var commitsColumn: UserColumn {
        return .init(
            header: "Commits",
            total: String(orgStat.commits),
            average: String(orgStat.avgCommits),
            userValues: users.map { orgStat.userStats[$0].map { String($0.codeStat.commits) } ?? "" }
        )
    }

    // MARK: Org Columns

    // MARK: Misc Columns
    private var analysisLimitsIndexColumn: MiscColumn {
        return .init(
            header: "",
            rest: [
                "Repositories analyzed",
                "Earliest event analyzed",
                "Limiting lower bound",
                "Limiting repo"
        ])
    }

    private var analysisLimitsColumn: MiscColumn {
        return .init(
            header: "",
            rest: [
                "\"\(orgStat.repoStats.map { k, _ in k }.joined(separator: ", "))\"",
                gitDatetimeFormatter.string(from: orgStat.earliestEvent),
                gitDatetimeFormatter.string(from: orgStat.earliestReliable.date),
                String(orgStat.earliestReliable.limitingRepo)
        ])
    }
}

extension StatTable {
    var csvString: String {
        return rows.map { $0.joined(separator: ",") }.joined(separator: "\n")
    }
}
