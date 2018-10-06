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
	
	init(orgStat: OrgStat, earliestDateFilter: Date?) {
        self.orgStat = orgStat
        self.users = Array(orgStat.userStats.keys)
		
		// The limit matters if the earliest reliable date for the aggregate data is later
		// than the earliest date filter (i.e. all analyzed data originates from later in
		// time than the lower limit filter).
		limitMatters = orgStat.earliestReliable.date.flatMap { earliestReliable in
			earliestDateFilter
				.flatMap { Calendar.current.date(byAdding: .day, value: 1, to: $0) }
				.map { earliestFilter in
				return earliestReliable > earliestFilter
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

	private struct Section {
		let indexColumn: Column
		let bodyColumns: [Column]
	}
	
	private var sections: [Section] {
		return [
			.init(indexColumn: indexColumn,
				  bodyColumns: [
					prOpenedColumn,
					prClosedColumn,
					avgPROpenLength,
					prCommentsColumn,
					linesOfCodeAddedColumn,
					linesOfCodeDeletedColumn,
					totalLinesOfCodeColumn,
					commitsColumn
				]
			),
			.init(indexColumn: analysisLimitsIndexColumn,
				  bodyColumns: [
					analysisLimitsColumn
				]
			)
		]
	}

    private var columns: [Column] {
		return Array(
			sections
				.map { [$0.indexColumn] + $0.bodyColumns }
				.joined(separator: [blankColumn])
		)
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
            total: "Total",
            average: "User Average",
            userValues: users
        )
    }

    private var prOpenedColumn: UserColumn {
        return .init(
            header: "PRs opened",
			total: string(describing: orgStat.prsOpened),
            average: string(describing: orgStat.avgPrsOpenedPerUser),
            userValues: users.map { orgStat.userStats[$0].map { string(describing: $0.pullRequestStat.opened) } ?? "" }
        )
    }

    private var prClosedColumn: UserColumn {
        return .init(
            header: "PRs closed",
            total: string(describing: orgStat.prsClosed),
            average: string(describing: orgStat.avgPrsClosedPerUser),
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
            average: string(describing: orgStat.avgPrCommentsPerUser),
            userValues: users.map { orgStat.userStats[$0].map { string(describing: $0.pullRequestStat.commentEvents) } ?? "" }
        )
    }

    private var linesOfCodeAddedColumn: UserColumn {
        return .init(
            header: "LOC Added",
            total: string(describing: orgStat.linesAdded),
            average: string(describing: orgStat.avgLinesAddedPerUser),
            userValues: users.map { orgStat.userStats[$0].map { string(describing: $0.codeStat.linesAdded) } ?? "" }
        )
    }

    private var linesOfCodeDeletedColumn: UserColumn {
        return .init(
            header: "LOC Deleted",
            total: string(describing: orgStat.linesDeleted),
            average: string(describing: orgStat.avgLinesDeletedPerUser),
            userValues: users.map { orgStat.userStats[$0].map { string(describing: $0.codeStat.linesDeleted) } ?? "" }
        )
    }

    private var totalLinesOfCodeColumn: UserColumn {
        return .init(
            header: "Total LOC",
            total: string(describing: orgStat.lines),
            average: string(describing: orgStat.avgLinesPerUser),
            userValues: users.map { orgStat.userStats[$0].map { string(describing: $0.codeStat.lines) } ?? "" }
        )
    }

    private var commitsColumn: UserColumn {
        return .init(
            header: "Commits",
            total: string(describing: orgStat.commits),
            average: string(describing: orgStat.avgCommitsPerUser),
            userValues: users.map { orgStat.userStats[$0].map { string(describing: $0.codeStat.commits) } ?? "" }
        )
    }

    // MARK: Repo Columns
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
				"Recommendation",
				limitMatters ? "indicates value effected by limits" : ""
        ])
    }

    private var analysisLimitsColumn: MiscColumn {
		let earliestReliableDate = orgStat.earliestReliable.date.map { gitDatetimeFormatter.string(from: $0) }
		let recommendation: String = {
			switch (limitMatters, earliestReliableDate) {
			case (false, _):
				return "Rock on!"
			case (true, let reliableDate?):
				return "use command line argument --later-than=\(reliableDate)"
			case (true, nil):
				return "Loosen up your time window restriction. At least one of the repositories does not have event data."
			}
		}()
        return .init(
            header: "",
            rest: [
                "\"\(orgStat.repoStats.map { k, _ in k }.joined(separator: ", "))\"",
				orgStat.earliestEvent.map { gitDatetimeFormatter.string(from: $0) } ?? "N/A",
				earliestReliableDate ?? "N/A",
				String(describing: orgStat.earliestReliable.limitingRepo),
				recommendation,
				limitMatters ? "\(kLimitedMarker)" : ""
        ])
    }
	
	private func string<B: Bound, T: CustomStringConvertible>(describing stat: BasicStat<B, T>) -> String {
		let statValue = String(describing: stat)
		
		// The limit matters if the earliest reliable date for the aggregate data is later
		// than the earliest date filter (i.e. all analyzed data originates from later in
		// time than the lower limit filter).
		return limitMatters && !stat.limitless ? "\(statValue)\(kLimitedMarker)" : statValue
	}
}

extension StatTable {
    public var csvString: String {
        return rows.map { $0.joined(separator: ",") }.joined(separator: "\n")
    }
	
	public typealias IndexColumn = [String]
	/// A Column Stack gives you the columns paired with their indices.
	/// One use for this is printing the columns out in a stack to the terminal.
	public var columnStack: [(IndexColumn, [String])] {
 		return sections.flatMap { section in section.bodyColumns.map { (section.indexColumn.values, $0.values) } }
	}
}
