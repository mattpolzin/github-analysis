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

private let kLimitedMarker = "†"

/// Organize available aggregated stats into a table
struct StatTable {
    private let orgStat: OrgStat
    private let users: [Username] // important to always order the same way
	private let limitMatters: Bool
	
    init(orgStat: OrgStat) {
        self.orgStat = orgStat
        self.users = Array(orgStat.userStats.keys)
		
		limitMatters = orgStat.earliestReliable.date.flatMap { earliestReliable in
			orgStat.earliestEvent.map { earliestAvailable in
				return earliestReliable == earliestAvailable
			}
		} ?? true
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
			total: string(describing: orgStat.prsOpened),
            average: string(describing: orgStat.avgPrsOpened),
            userValues: users.map { orgStat.userStats[$0].map { string(describing: $0.pullRequestStat.opened) } ?? "" }
        )
    }

    private var prClosedColumn: UserColumn {
        return .init(
            header: "PRs closed",
            total: string(describing: orgStat.prsClosed),
            average: string(describing: orgStat.avgPrsClosed),
            userValues: users.map { orgStat.userStats[$0].map { string(describing: $0.pullRequestStat.closed) } ?? "" }
        )
    }

    private var avgPROpenLength: UserColumn {
        return .init(
            header: "Average PR open length (days)",
            total: "\\",
            average: string(describing: orgStat.avgPROpenLength/(60 * 60 * 24)),
            userValues: users.map { orgStat.userStats[$0].map { string(describing: $0.pullRequestStat.avgOpenLength/(60 * 60 * 24)) } ?? "" }
        )
    }

    private var prCommentsColumn: UserColumn {
        return .init(
            header: "PR comments",
            total: string(describing: orgStat.prComments),
            average: string(describing: orgStat.avgPrComments),
            userValues: users.map { orgStat.userStats[$0].map { string(describing: $0.pullRequestStat.commentEvents) } ?? "" }
        )
    }

    private var linesOfCodeAddedColumn: UserColumn {
        return .init(
            header: "LOC Added",
            total: string(describing: orgStat.linesAdded),
            average: string(describing: orgStat.avgLinesAdded),
            userValues: users.map { orgStat.userStats[$0].map { string(describing: $0.codeStat.linesAdded) } ?? "" }
        )
    }

    private var linesOfCodeDeletedColumn: UserColumn {
        return .init(
            header: "LOC Deleted",
            total: string(describing: orgStat.linesDeleted),
            average: string(describing: orgStat.avgLinesDeleted),
            userValues: users.map { orgStat.userStats[$0].map { string(describing: $0.codeStat.linesDeleted) } ?? "" }
        )
    }

    private var totalLinesOfCodeColumn: UserColumn {
        return .init(
            header: "Total LOC",
            total: string(describing: orgStat.lines),
            average: string(describing: orgStat.avgLines),
            userValues: users.map { orgStat.userStats[$0].map { string(describing: $0.codeStat.lines) } ?? "" }
        )
    }

    private var commitsColumn: UserColumn {
        return .init(
            header: "Commits",
            total: string(describing: orgStat.commits),
            average: string(describing: orgStat.avgCommits),
            userValues: users.map { orgStat.userStats[$0].map { string(describing: $0.codeStat.commits) } ?? "" }
        )
    }

    // MARK: Org Columns
	// none currently

    // MARK: Misc Columns
    private var analysisLimitsIndexColumn: MiscColumn {
        return .init(
            header: "",
            rest: [
                "Repositories analyzed",
                "Earliest event analyzed",
                "Limiting lower bound",
                "Limiting repo",
				"\(kLimitedMarker) indicates value affected by limits"
        ])
    }

    private var analysisLimitsColumn: MiscColumn {
        return .init(
            header: "",
            rest: [
                "\"\(orgStat.repoStats.map { k, _ in k }.joined(separator: ", "))\"",
				orgStat.earliestEvent.map { gitDatetimeFormatter.string(from: $0) } ?? "N/A",
				orgStat.earliestReliable.date.map { gitDatetimeFormatter.string(from: $0) } ?? "N/A",
				String(describing: orgStat.earliestReliable.limitingRepo)
        ])
    }
	
	private func string<B: Bound, T: CustomStringConvertible>(describing stat: BasicStat<B, T>) -> String {
		let statValue = String(describing: stat)
		
		// The limit matters if the earliest reliable date for the aggregate data is later
		// than the earliest date.
		return limitMatters && !stat.limitless ? "\(statValue)\(kLimitedMarker)" : statValue
	}
}

extension StatTable {
    var csvString: String {
        return rows.map { $0.joined(separator: ",") }.joined(separator: "\n")
    }
}
