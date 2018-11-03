//
//  GitHubAnalysisInputs+InputDescriptions.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/28/18.
//

extension GitHubAnalysisInputs {
	enum PersonalAccessTokenUsage: EnvironmentRule {
		static var name: String { return kGithubAccessTokenVar }
		
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
	enum VerboseUsage: FlagRule {
		static var name: String { return kVerboseFlag }
		static var usage: String { return "Print all the information about the execution of the script. NOTE this flag is in opposition to -\(kQuietFlag) and if both are used the behavior of -\(kQuietFlag) wins out." }
	}
	enum QuietUsage: FlagRule {
		static var name: String { return kQuietFlag }
		static var usage: String { return "Do not print any information about the execution of the script. This also silences the analysis printout. Specifying this in combination with -\(kOutputCSVFlag) will result in the CSV file being available by the time the script has finished executing but with no printing to the terminal." }
	}
	enum OutputCSVUsage: FlagRule {
		static var name: String { return kOutputCSVFlag }
		static var usage: String { return "Generate a github_analysis.csv file in the current working directory" }
	}
	enum PrintJSONUsage: FlagRule {
		static var name: String { return kPrintJSONFlag }
		static var usage: String { return "Print the JSON response from GitHub before printing analysis results. This is mostly just useful for troubleshooting." }
	}
	enum SkipRequestsUsage: FlagRule {
		static var name: String { return kSkipRequestsFlag }
		static var usage: String { return "Skip requests to GitHub's APIs. The script will run using only events found in the cache file." }
	}
	enum SkipAnalysisUsage: FlagRule {
		static var name: String { return kSkipAnalysisFlag }
		static var usage: String { return "Skip the analysis of data. Use this flag to download and cache event data without performing analysis. This will render much of the other flags meaningless because many other options are only applied after new event data is cached for future use. When using this flag, only information about downloading and caching events is printed to the terminal and nothing is output to a CSV file." }
	}
	enum SkipFootnotesUsage: FlagRule {
		static var name: String { return kSkipFootnotesFlag }
		static var usage: String { return "By default, analyzed values are annotated with footnotes where you should be aware of a limitation or clarification. This flag disables those footnotes. The advantage to disabling the footnotes is that the numbers in an output CSV file will be automatically parsed as numbers rather than string values given the character used to mark the value as having a footnote." }
	}
}

extension GitHubAnalysisInputs: InputDescriptions {
	/// The `dummy` is a really unfortunate side effect of my experiment here with using
	/// reflection to allow the GitHubAnalysisInputs to describe all of its inputs without
	/// needing to do more than simply add the inputs as properties. I find the actual
	/// reflection below rather elegant, but I wish I could "reflect" upon the structure of
	/// `GitHubAnalysisInputs` without creating a value of that Type.
	private static func dummy() -> GitHubAnalysisInputs {
		return .init(personalAccessToken: "",
					 repositoryOwner: "",
					 repositories: [],
					 earliestDate: nil,
					 latestDate: nil,
					 users: nil,
					 cacheFileLocation: nil,
					 verbose: false,
					 quiet: false,
					 outputCSV: false,
					 printJSON: false,
					 skipRequests: false,
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
		
		return mirror.children.compactMap { $0.value as? InputUsage }.map { type(of: $0) }.filter { $0.usage is FlagRule.Type }.prepending(VoidInput<PrintHelpUsage>.self)
	}
}
