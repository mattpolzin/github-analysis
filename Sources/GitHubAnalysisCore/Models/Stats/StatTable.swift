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
public struct StatTable {
    private let orgStat: OrgStat
    private let users: [Username] // important to always order the same way
	private let limitMatters: Bool
	
	public init(orgStat: OrgStat,
				laterThan earliestDate: Date?,
				insertLimitFootnote: Bool) {
        self.orgStat = orgStat
        self.users = Array(orgStat.userStats.keys)
		
		// The limit matters if the earliest reliable date for the aggregate data is later
		// than the earliest date filter (i.e. all analyzed data originates from later in
		// time than the lower limit filter).
		limitMatters = insertLimitFootnote
			&& orgStat.earliestReliable.flatMap { earliestReliable in
				earliestDate
					.flatMap { Calendar.current.date(byAdding: .day, value: 1, to: $0) }
					.map { earliestFilter in
						return earliestReliable.date > earliestFilter
				}
			} ?? true
    }

    private typealias UserValue = String

    private struct UserColumn: Column {
        let header: String
        let total: String
		let repoAverage: String
        let userAverage: String
        let userValues: [UserValue]

        var values: [String] {
            return [header, total, repoAverage, userAverage, ""] + userValues
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
			repoAverage: "Repository Average",
            userAverage: "User Average",
            userValues: users
        )
    }

    private var prOpenedColumn: UserColumn {
		let orgStat = \OrgStat.pullRequestStats.opened
		let userStat = \UserStat.pullRequestStat.opened
		return userColumn(header: "PRs opened",
						  orgPath: orgStat,
						  userPath: userStat)
    }

    private var prClosedColumn: UserColumn {
		let orgStat = \OrgStat.pullRequestStats.closed
		let userStat = \UserStat.pullRequestStat.closed
		return userColumn(header: "PRs closed",
						  orgPath: orgStat,
						  userPath: userStat)
    }

    private var avgPROpenLength: UserColumn {
        return .init(
            header: "Average PR open length (days)",
            total: "\\",
			repoAverage: string(describing: orgStat.pullRequestStats.openLengths.average.perRepo/(60 * 60 * 24)),
            userAverage: string(describing: orgStat.pullRequestStats.openLengths.average.perUser/(60 * 60 * 24)),
            userValues: users.map { orgStat.userStats[$0].map { string(describing: $0.pullRequestStat.avgOpenLength/(60 * 60 * 24)) } ?? "" }
        )
    }

    private var prCommentsColumn: UserColumn {
		let orgStat = \OrgStat.pullRequestStats.comments
		let userStat = \UserStat.pullRequestStat.commentEvents
		return userColumn(header: "PR comments",
						  orgPath: orgStat,
						  userPath: userStat)
    }

    private var linesOfCodeAddedColumn: UserColumn {
		let orgStat = \OrgStat.codeStats.linesAdded
		let userStat = \UserStat.codeStat.linesAdded
		return userColumn(header: "LOC Added",
						  orgPath: orgStat,
						  userPath: userStat)
    }

    private var linesOfCodeDeletedColumn: UserColumn {
		let orgStat = \OrgStat.codeStats.linesDeleted
		let userStat = \UserStat.codeStat.linesDeleted
		return userColumn(header: "LOC Deleted",
						  orgPath: orgStat,
						  userPath: userStat)
    }

    private var totalLinesOfCodeColumn: UserColumn {
		let orgStat = \OrgStat.codeStats.lines
		let userStat = \UserStat.codeStat.lines
		return userColumn(header: "Total LOC",
						  orgPath: orgStat,
						  userPath: userStat)
    }

    private var commitsColumn: UserColumn {
		let orgStat = \OrgStat.codeStats.commits
		let userStat = \UserStat.codeStat.commits
		return userColumn(header: "Commits",
						  orgPath: orgStat,
						  userPath: userStat)
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
				limitMatters ? "Value effected by limits" : "",
				orgStat.unreliableRepositories.count > 0 ? "Repositories with no events in time window analyzed": ""
        ])
    }

    private var analysisLimitsColumn: MiscColumn {
		let earliestReliableDate = orgStat.earliestReliable.map { GitHubAnalysisFormatter.datetime.string(from: $0.date) }
		let recommendation: String = {
			switch (limitMatters, earliestReliableDate) {
			case (false, _):
				return "Rock on!"
			case (true, let reliableDate?):
				return "use command line argument --later-than=\(reliableDate)"
			case (true, nil):
				return "Loosen up your time window restriction. None of the repositories have event data."
			}
		}()
        return .init(
            header: "",
            rest: [
                "\"\(orgStat.repoStats.map { k, _ in k }.joined(separator: ", "))\"",
				orgStat.earliestEvent.map { GitHubAnalysisFormatter.datetime.string(from: $0) } ?? "N/A",
				earliestReliableDate ?? "N/A",
				orgStat.earliestReliable?.name ?? "N/A",
				recommendation,
				limitMatters ? "\(kLimitedMarker)" : "",
				orgStat.unreliableRepositories.count > 0 ? "\"\(orgStat.unreliableRepositories.joined(separator: ", "))\"": ""
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

public extension StatTable {
    var csvString: String {
        return rows.map { $0.joined(separator: ",") }.joined(separator: "\n")
    }
	
	typealias IndexColumn = [String]
	
	/// A Column Stack gives you the columns paired with their indices.
	/// One use for this is printing the columns out in a stack to the terminal.
	var columnStack: [(IndexColumn, [String])] {
 		return sections.flatMap { section in section.bodyColumns.map { (section.indexColumn.values, $0.values) } }
	}
}

extension StatTable {
	private func userColumn<B: Bound, T: CustomStringConvertible>(header: String, orgPath: KeyPath<OrgStat, OrgStat.StatAggregate<B, T>>, userPath: KeyPath<UserStat, BasicStat<B, T>>) -> StatTable.UserColumn {
		let stat = orgStat[keyPath: orgPath]
		return UserColumn(header: header,
						  total: string(describing: stat.total),
						  repoAverage: string(describing: stat.average.perRepo),
						  userAverage: string(describing: stat.average.perUser),
						  userValues: users.map { orgStat.userStats[$0].map { string(describing: $0[keyPath: userPath]) } ?? "" })
	}
}
