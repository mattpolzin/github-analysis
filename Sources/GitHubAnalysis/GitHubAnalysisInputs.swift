//
//  GitHubAnalysisInputs.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/6/18.
//

import Foundation
import Result

struct GitHubAnalysisInputs {
	let personalAccessToken: Input<String, PersonalAccessTokenUsage>
	
	let repositoryOwner: Input<String, RepositoryOwnerUsage>
	let repositories: Input<[String], RepositoriesUsage>
	let earliestDate: Input<Date?, EarliestDateUsage>
	let latestDate: Input<Date?, LatestDateUsage>
	let users: Input<[String]?, UsersUsage>
	let cacheFileLocation: Input<URL?, CacheFileLocationUsage>
	
	let outputCSV: Input<Bool, OutputCSVUsage>
	let printJSON: Input<Bool, PrintJSONUsage>
	let skipAnalysis: Input<Bool, SkipAnalysisUsage>
	let skipFootnotes: Input<Bool, SkipFootnotesUsage>
	
	enum PersonalAccessTokenUsage: EnvironmentRule {
		static var name: String { return  kGithubAccessTokenVar }

		static var usage: String { return "Generate a personal access token for GitHub and then set this environment variable to allow the script to download data for repositories for which you have access." }

		static var valueFormat: String { return "1234567890abcdef" }
	}
	
	enum RepositoryOwnerUsage: ArgumentRule {
		static var name: String { return kOrganizationArg }

		static var usage: String { return "The organization or owner of the repository. This must match the slug that you find as a component of the web address for your repositories." }

		static var valueFormat: String { return "username" }

		static var positioning: ArgumentRulePositioning { return .fixed }
	}
	enum RepositoriesUsage: ArgumentRule {
		static var name: String { return kRepositoriesArg }

		static var usage: String { return "Each repository listed will be analyzed." }

		static var valueFormat: String { return "repo1,repo2,repo3..." }

		static var positioning: ArgumentRulePositioning { return .fixed }
	}
	enum EarliestDateUsage: ArgumentRule {
		static var name: String { return kEarliestDateArg }
		static var usage: String { return "Specify a datetime or a date that should be used as the cutoff before which GitHub data will not be analyzed. Note that LOC and commit stats are available by the week, so this filter will apply to the week start date for those stats." }
		static var valueFormat: String { return "{YYYY-MM-DDTHH:MM:SSZ | YYYY-MM-DD}" }
		static var positioning: ArgumentRulePositioning { return .floating }
	}
	enum LatestDateUsage: ArgumentRule {
		static var name: String { return kLatestDateArg }
		static var usage: String { return "Specify a datetime or a date that should be used as the cutoff after which GitHub data will not be analyzed. Note that LOC and commit stats are available by the week, so this filter will apply to the week start date for those stats." }
		static var valueFormat: String { return "{YYYY-MM-DDTHH:MM:SSZ | YYYY-MM-DD}" }
		static var positioning: ArgumentRulePositioning { return .floating }
	}
	enum UsersUsage: ArgumentRule {
		static var name: String { return kUsersArg }
		static var usage: String { return "Filter down to the given list of users for analysis. If not specified, all users will be analyzed." }
		static var valueFormat: String { return "user1,user2,user3..." }
		static var positioning: ArgumentRulePositioning { return .floating }
	}
	enum CacheFileLocationUsage: ArgumentRule {
		static var name: String { return kCacheFileArg }
		static var usage: String { return "Specify a file in which to store the cached GitHub events. If not specified, github_analysis_cache.json in the current working directory will be used." }
		static var valueFormat: String { return "filepath/filename.json" }
		static var positioning: ArgumentRulePositioning { return .floating }
	}
		
	enum PrintHelpUsage: FlagRule {
		static var name: String { return kHelpFlag }
		static var usage: String { return "Print the usage." }
	}
	enum OutputCSVUsage: FlagRule {
		static var name: String { return kOutputCSVFlag }
		static var usage: String { return "Generate a github_analysis.csv file in the current working directory" }
	}
	enum PrintJSONUsage: FlagRule {
		static var name: String { return kPrintJSONFlag }
		static var usage: String { return "Print the JSON response from GitHub before printing analysis results. This is mostly just useful for troubleshooting." }
	}
	enum SkipAnalysisUsage: FlagRule {
		static var name: String { return kSkipAnalysisFlag }
		static var usage: String { return "Skip the analysis of data. Use this flag to download and cache event data without performing analysis. This will render much of the other flags meaningless because many other options are only applied after new event data is cached for future use. When using this flag, only information about downloading and caching events is printed to the terminal and nothing is output to a CSV file." }
	}
	enum SkipFootnotesUsage: FlagRule {
		static var name: String { return kSkipFootnotes }
		static var usage: String { return "By default, analyzed values are annotated with footnotes where you should be aware of a limitation or clarification. This flag disables those footnotes. The advantage to disabling the footnotes is that the numbers in an output CSV file will be automatically parsed as numbers rather than string values given the character used to mark the value as having a footnote." }
	}
	
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
		
		self.personalAccessToken = .init(value: personalAccessToken)
		
		self.repositoryOwner = .init(value: repositoryOwner)
		self.repositories = .init(value: repositories)
		self.earliestDate = .init(value: earliestDate)
		self.latestDate = .init(value: latestDate)
		self.users = .init(value: users)
		self.cacheFileLocation = .init(value: cacheFileLocation)
		
		self.outputCSV = .init(value: outputCSV)
		self.printJSON = .init(value: printJSON)
		self.skipAnalysis = .init(value: skipAnalysis)
		self.skipFootnotes = .init(value: skipFootnotes)
	}
}

extension GitHubAnalysisInputs {
	subscript<T, R: UsageRule>(_ input: KeyPath<GitHubAnalysisInputs, Input<T, R>>) -> T {
		return self[keyPath: input].value
	}
}

extension GitHubAnalysisInputs: InputDescriptions {
	private static func dummy() -> GitHubAnalysisInputs {
		return .init(personalAccessToken: "",
					 repositoryOwner: "",
					 repositories: [],
					 earliestDate: nil,
					 latestDate: nil,
					 users: nil,
					 cacheFileLocation: nil,
					 outputCSV: false,
					 printJSON: false,
					 skipAnalysis: false,
					 skipFootnotes: false)
	}
	
	static var environmentInputs: [InputUsage.Type] {
		let mirror = Mirror(reflecting: GitHubAnalysisInputs.dummy())
		
		return mirror.children.compactMap { $0.value as? InputUsage }.map { type(of: $0) }.filter { $0.usage is EnvironmentRule.Type }
	}
	
	static var argumentInputs: [InputUsage.Type] {
		let mirror = Mirror(reflecting: GitHubAnalysisInputs.dummy())
		
		return mirror.children.compactMap { $0.value as? InputUsage }.map { type(of: $0) }.filter { $0.usage is ArgumentRule.Type }
	}
	
	static var flagInputs: [InputUsage.Type] {
		let mirror = Mirror(reflecting: GitHubAnalysisInputs.dummy())
		
		return mirror.children.compactMap { $0.value as? InputUsage }.map { type(of: $0) }.filter { $0.usage is FlagRule.Type }
	}
}

extension GitHubAnalysisInputs: InputCategoryDescriptions {
	static var scriptName: String { return "github-analysis" }
	
	static var notes: UsageCategory? {
		return UsageCategory(name: "NOTES",
							 note: nil,
							 rules: [Note.self])
		
		struct Note: NoteRule {
			static var description: String {
				return "IMPORTANT:\nThe GitHub events API that powers much of this script's analysis is limited to returning 300 events or 90 days into the past, whichever comes first. This limit is per-repository.\n\nThis script caches events for later use so that over time you can build up a bigger picture than the limitation would allow for. That being said, it is important to look at the \"Limiting lower bound\" offered up at the command line and in the CSV. This lower bound is the earliest date for which an event was found in the repository with the least history available. In other words, take the earliest event date for each repository and pick the latest of those dates.\n\nMy recommendation is to not perform analysis back farther in time than the \"Limiting lower bound\" (using -\(kEarliestDateArg))"
			}
		}
	}
	
	static var environmentInputUsage: InputCategory {
		return .init(name: "ENVIRONMENT VARIABLES",
					 note: "These variables can also be specified as arguments by prepending their name with a dash: \"-VARNAME=VALUE\"")
	}
	
	static var argumentInputUsage: InputCategory {
		return .init(name: "ARGUMENTS",
					 note: nil)
	}
	
	static var flagInputUsage: InputCategory {
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
