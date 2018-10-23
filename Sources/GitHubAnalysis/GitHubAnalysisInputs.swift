//
//  GitHubAnalysisInputs.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/6/18.
//

import Foundation
import Result

struct GitHubAnalysisInputs {
	let personalAccessToken: Input<String, EnvironmentRule>
	
	let repositoryOwner: Input<String, ArgumentRule>
	let repositories: Input<[String], ArgumentRule>
	let earliestDate: Input<Date?, ArgumentRule>
	let latestDate: Input<Date?, ArgumentRule>
	let users: Input<[String]?, ArgumentRule>
	let cacheFileLocation: Input<URL?, ArgumentRule>
	
	let outputCSV: Input<Bool, FlagRule>
	let printJSON: Input<Bool, FlagRule>
	let skipAnalysis: Input<Bool, FlagRule>
	let skipFootnotes: Input<Bool, FlagRule>
	
	let personalAccessTokenUsage = EnvironmentRule(name: kGithubAccessTokenVar,
												   usage: "Generate a personal access token for GitHub and then set this environment variable to allow the script to download data for repositories for which you have access.",
												   valueFormat: "1234567890abcdef")
	
	let repositoryOwnerUsage = ArgumentRule(name: kOrganizationArg,
											usage: "The organization or owner of the repository. This must match the slug that you find as a component of the web address for your repositories.",
											valueFormat: "username",
											positioning: .fixed)
	let repositoriesUsage =	ArgumentRule(name: kRepositoriesArg,
											usage: "Each repository listed will be analyzed.",
											valueFormat: "repo1,repo2,repo3...",
											positioning: .fixed)
	let earliestDateUsage = ArgumentRule(name: kEarliestDateArg,
										 usage: "Specify a datetime or a date that should be used as the cutoff before which GitHub data will not be analyzed. Note that LOC and commit stats are available by the week, so this filter will apply to the week start date for those stats.",
										 valueFormat: "{YYYY-MM-DDTHH:MM:SSZ | YYYY-MM-DD}",
										 positioning: .floating)
	let latestDateUsage = ArgumentRule(name: kLatestDateArg,
									   usage: "Specify a datetime or a date that should be used as the cutoff after which GitHub data will not be analyzed. Note that LOC and commit stats are available by the week, so this filter will apply to the week start date for those stats.",
									   valueFormat: "{YYYY-MM-DDTHH:MM:SSZ | YYYY-MM-DD}",
									   positioning: .floating)
	let usersUsage = ArgumentRule(name: kUsersArg,
								  usage: "Filter down to the given list of users for analysis. If not specified, all users will be analyzed.",
								  valueFormat: "user1,user2,user3...",
								  positioning: .floating)
	let cacheFileLocationUsage = ArgumentRule(name: kCacheFileArg,
											  usage: "Specify a file in which to store the cached GitHub events. If not specified, github_analysis_cache.json in the current working directory will be used.",
											  valueFormat: "filepath/filename.json",
											  positioning: .floating)
	
	let printHelpUsage = FlagRule(name: kHelpFlag,
								  usage: "Print the usage.")
	let outputCSVUsage = FlagRule(name: kOutputCSVFlag,
								  usage: "Generate a github_analysis.csv file in the current working directory")
	let printJSONUsage = FlagRule(name: kPrintJSONFlag,
								  usage: "Print the JSON response from GitHub before printing analysis results. This is mostly just useful for troubleshooting.")
	let skipAnalysisUsage = FlagRule(name: kSkipAnalysisFlag,
									 usage: "Skip the analysis of data. Use this flag to download and cache event data without performing analysis. This will render much of the other flags meaningless because many other options are only applied after new event data is cached for future use. When using this flag, only information about downloading and caching events is printed to the terminal and nothing is output to a CSV file.")
	let skipFootnotesUsage = FlagRule(name: kSkipFootnotes,
									  usage: "By default, analyzed values are annotated with footnotes where you should be aware of a limitation or clarification. This flag disables those footnotes. The advantage to disabling the footnotes is that the numbers in an output CSV file will be automatically parsed as numbers rather than string values given the character used to mark the value as having a footnote.")
	
	init(personalAccessToken: String,
		 repositoryOwner: String,
		 repositories: [String],
		 earliestDate: Date?,
		 latestDate: Date?,
		 users: [String]?,
		 cacheFileLocation: URL?,
		 outputCSV: Bool,
		 printJSON: Bool,
		 skipAnalysis: Bool,
		 skipFootnotes: Bool) {
		
		self.personalAccessToken = .init(value: personalAccessToken,
										 usage: personalAccessTokenUsage)
		
		self.repositoryOwner = .init(value: repositoryOwner,
									 usage: repositoryOwnerUsage)
		self.repositories = .init(value: repositories,
								  usage: repositoriesUsage)
		self.earliestDate = .init(value: earliestDate,
								  usage: earliestDateUsage)
		self.latestDate = .init(value: latestDate,
								usage: latestDateUsage)
		self.users = .init(value: users,
						   usage: usersUsage)
		self.cacheFileLocation = .init(value: cacheFileLocation,
									   usage: cacheFileLocationUsage)
		
		self.outputCSV = .init(value: outputCSV,
							   usage: outputCSVUsage)
		self.printJSON = .init(value: printJSON,
							   usage: printJSONUsage)
		self.skipAnalysis = .init(value: skipAnalysis,
								  usage: skipAnalysisUsage)
		self.skipFootnotes = .init(value: skipFootnotes,
								   usage: skipFootnotesUsage)
		
	}
}

extension GitHubAnalysisInputs {
	subscript<T, R: UsageRule>(_ input: KeyPath<GitHubAnalysisInputs, Input<T, R>>) -> T {
		return self[keyPath: input].value
	}
}

extension GitHubAnalysisInputs: InputDescriptions {
	var environmentInputs: [AnyInputUsage<EnvironmentRule>] {
		return [AnyInputUsage(personalAccessToken)]
	}
	
	var argumentInputs: [AnyInputUsage<ArgumentRule>] {
		return [
			AnyInputUsage(repositoryOwner),
			AnyInputUsage(repositories),
			AnyInputUsage(earliestDate),
			AnyInputUsage(latestDate),
			AnyInputUsage(users),
			AnyInputUsage(cacheFileLocation)
		]
	}
	
	var flagInputs: [AnyInputUsage<FlagRule>] {
		return [
			AnyInputUsage(VoidInput(usage: printHelpUsage)),
			AnyInputUsage(outputCSV),
			AnyInputUsage(printJSON),
			AnyInputUsage(skipAnalysis),
			AnyInputUsage(skipFootnotes)
		]
	}
}

extension GitHubAnalysisInputs: InputCategoryDescriptions {
	var scriptName: String { return "github-analysis" }
	
	var notes: UsageCategory<NoteRule>? {
		return UsageCategory(name: "NOTES",
							 note: nil,
							 rules: [
								"IMPORTANT:\nThe GitHub events API that powers much of this script's analysis is limited to returning 300 events or 90 days into the past, whichever comes first. This limit is per-repository.\n\nThis script caches events for later use so that over time you can build up a bigger picture than the limitation would allow for. That being said, it is important to look at the \"Limiting lower bound\" offered up at the command line and in the CSV. This lower bound is the earliest date for which an event was found in the repository with the least history available. In other words, take the earliest event date for each repository and pick the latest of those dates.\n\nMy recommendation is to not perform analysis back farther in time than the \"Limiting lower bound\" (using -\(kEarliestDateArg))"
		])
	}
	
	var environmentInputUsage: InputCategory {
		return .init(name: "ENVIRONMENT VARIABLES",
					 note: "These variables can also be specified as arguments by prepending their name with a dash: \"-VARNAME=VALUE\"")
	}
	
	var argumentInputUsage: InputCategory {
		return .init(name: "ARGUMENTS",
					 note: nil)
	}
	
	var flagInputUsage: InputCategory {
		return .init(name: "FLAGS",
					 note: nil)
	}
}

extension GitHubAnalysisInputs {
	static func from(scriptInputs inputs: ScriptInputs) -> Result<GitHubAnalysisInputs, GHAInputsError> {
		guard !inputs.isFlagSet(named: kHelpFlag) else {
			return .failure(.needHelp)
		}
		
		guard let personalAccessToken = inputs.variable(named: kGithubAccessTokenVar) else {
			return .failure(.missingRequirement(description: "Missing GitHub Access Token. Please set \(kGithubAccessTokenVar) environment variable or specify on command line with -\(kGithubAccessTokenVar)={key}"))
		}

		guard let repositoryOwner = inputs.variable(at: kOrganizationArgPos) else {
			return .failure(.missingRequirement(description: "Missing required argument: \(kOrganizationArg). See --help for details."))
		}
		
		guard let repositories = inputs.array(at: kRepositoriesArgPos) else {
			return .failure(.missingRequirement(description: "Missing required argument: \(kRepositoriesArg). See --help for details."))
		}
		
		let earliestDateArg: Date?
		switch inputs.date(named: kEarliestDateArg) {
		case .success(let date):
			earliestDateArg = date
		case .failure(.missing):
			earliestDateArg = nil
		case .failure(.malformed):
			return .failure(.missingRequirement(description: "Please specify your earliest date in the UTC timezone in the format: YYYY-MM-DDTHH:MM:SSZ -- OR -- use dates of the format: YYYY-MM-DD"))
		}
		
		let latestDateArg: Date?
		switch inputs.date(named: kLatestDateArg) {
		case .success(let date):
			latestDateArg = date
		case .failure(.missing):
			latestDateArg = nil
		case .failure(.malformed):
			return .failure(.missingRequirement(description: "Please specify your earliest date in the UTC timezone in the format: YYYY-MM-DDTHH:MM:SSZ -- OR -- use dates of the format: YYYY-MM-DD"))
		}
		
		let usersArg = inputs.array(named: kUsersArg)
		
		let outputCSVFlag = inputs.isFlagSet(named: kOutputCSVFlag)
		
		let printJSON = inputs.isFlagSet(named: kPrintJSONFlag)
		
		let skipAnalysis = inputs.isFlagSet(named: kSkipAnalysisFlag)
		
		let skipFootnotes = inputs.isFlagSet(named: kSkipFootnotes)
		
		let cacheFileLocation = inputs.variable(named: kCacheFileArg).map(URL.init(fileURLWithPath:))
		
		return .success(GitHubAnalysisInputs(personalAccessToken: personalAccessToken,
											 repositoryOwner: repositoryOwner,
											 repositories: repositories,
											 earliestDate: earliestDateArg,
											 latestDate: latestDateArg,
											 users: usersArg,
											 cacheFileLocation: cacheFileLocation,
											 outputCSV: outputCSVFlag,
											 printJSON: printJSON,
											 skipAnalysis: skipAnalysis,
											 skipFootnotes: skipFootnotes))
	}
	
	enum GHAInputsError: Error {
		case needHelp
		case missingRequirement(description: String)
	}
}
