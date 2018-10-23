//
//  GitHubAnalysisUsage.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/6/18.
//

import Foundation

struct GitHubAnalysisUsage: Usage {
	
	let scriptName = "github-analysis"
	
	let notes: UsageCategory<NoteRule>? = UsageCategory(name: "NOTES",
														note: nil,
														rules: [
															"IMPORTANT:\nThe GitHub events API that powers much of this script's analysis is limited to returning 300 events or 90 days into the past, whichever comes first. This limit is per-repository.\n\nThis script caches events for later use so that over time you can build up a bigger picture than the limitation would allow for. That being said, it is important to look at the \"Limiting lower bound\" offered up at the command line and in the CSV. This lower bound is the earliest date for which an event was found in the repository with the least history available. In other words, take the earliest event date for each repository and pick the latest of those dates.\n\nMy recommendation is to not perform analysis back farther in time than the \"Limiting lower bound\" (using -\(kEarliestDateArg))"
		])
	
	let environment = UsageCategory(name: "ENVIRONMENT VARIABLES",
									note: "These variables can also be specified as arguments by prepending their name with a dash: \"-VARNAME=VALUE\"",
									rules: [
										EnvironmentRule(name: kGithubAccessTokenVar,
														usage: "Generate a personal access token for GitHub and then set this environment variable to allow the script to download data for repositories for which you have access.",
														valueFormat: "1234567890abcdef")
		])
	
	let flags = UsageCategory(name: "FLAGS",
							  note: nil,
							  rules: [
								FlagRule(name: kHelpFlag,
										 usage: "Print the usage."),
								FlagRule(name: kPrintJSONFlag,
										 usage: "Print the JSON response from GitHub before printing analysis results. This is mostly just useful for troubleshooting."),
								FlagRule(name: kOutputCSVFlag,
										 usage: "Generate a github_analysis.csv file in the current working directory"),
								FlagRule(name: kSkipAnalysisFlag,
										 usage: "Skip the analysis of data. Use this flag to download and cache event data without performing analysis. This will render much of the other flags meaningless because many other options are only applied after new event data is cached for future use. When using this flag, only information about downloading and caching events is printed to the terminal and nothing is output to a CSV file."),
								FlagRule(name: kSkipFootnotes,
										 usage: "By default, analyzed values are annotated with footnotes where you should be aware of a limitation or clarification. This flag disables those footnotes. The advantage to disabling the footnotes is that the numbers in an output CSV file will be automatically parsed as numbers rather than string values given the character used to mark the value as having a footnote.")
		])
	
	let arguments = UsageCategory(name: "ARGUMENTS",
								  note: nil,
								  rules: [
									ArgumentRule(name: kOrganizationArg,
												 usage: "The organization or owner of the repository. This must match the slug that you find as a component of the web address for your repositories.",
												 valueFormat: "username",
												 positioning: .fixed),
									ArgumentRule(name: kRepositoriesArg,
												 usage: "Each repository listed will be analyzed.",
												 valueFormat: "repo1,repo2,repo3...",
												 positioning: .fixed),
									ArgumentRule(name: kEarliestDateArg,
												 usage: "Specify a datetime or a date that should be used as the cutoff before which GitHub data will not be analyzed. Note that LOC and commit stats are available by the week, so this filter will apply to the week start date for those stats.",
												 valueFormat: "{YYYY-MM-DDTHH:MM:SSZ | YYYY-MM-DD}",
												 positioning: .floating),
									ArgumentRule(name: kLatestDateArg,
												 usage: "Specify a datetime or a date that should be used as the cutoff after which GitHub data will not be analyzed. Note that LOC and commit stats are available by the week, so this filter will apply to the week start date for those stats.",
												 valueFormat: "{YYYY-MM-DDTHH:MM:SSZ | YYYY-MM-DD}",
												 positioning: .floating),
									ArgumentRule(name: kUsersArg,
												 usage: "Filter down to the given list of users for analysis. If not specified, all users will be analyzed.",
												 valueFormat: "user1,user2,user3...",
												 positioning: .floating)
		])
}
