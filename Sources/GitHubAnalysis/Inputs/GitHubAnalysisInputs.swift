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
	
	let verbose: Input<Bool, VerboseUsage>
	let quiet: Input<Bool, QuietUsage>
	let outputCSV: Input<Bool, OutputCSVUsage>
	let printJSON: Input<Bool, PrintJSONUsage>
	let skipRequests: Input<Bool, SkipRequestsUsage>
	let skipAnalysis: Input<Bool, SkipAnalysisUsage>
	let skipFootnotes: Input<Bool, SkipFootnotesUsage>
	
	init(personalAccessToken: String,
		 repositoryOwner: String,
		 repositories: [String],
		 earliestDate: Date?,
		 latestDate: Date?,
		 users: [String]?,
		 cacheFileLocation: URL?,
		 verbose: Bool,
		 quiet: Bool,
		 outputCSV: Bool,
		 printJSON: Bool,
		 skipRequests: Bool,
		 skipAnalysis: Bool,
		 skipFootnotes: Bool) {
		
		self.personalAccessToken = .init(value: personalAccessToken)
		
		self.repositoryOwner = .init(value: repositoryOwner)
		self.repositories = .init(value: repositories)
		self.earliestDate = .init(value: earliestDate)
		self.latestDate = .init(value: latestDate)
		self.users = .init(value: users)
		self.cacheFileLocation = .init(value: cacheFileLocation)
		
		self.verbose = .init(value: verbose)
		self.quiet = .init(value: quiet)
		self.outputCSV = .init(value: outputCSV)
		self.printJSON = .init(value: printJSON)
		self.skipRequests = .init(value: skipRequests)
		self.skipAnalysis = .init(value: skipAnalysis)
		self.skipFootnotes = .init(value: skipFootnotes)
	}
}

extension GitHubAnalysisInputs {
	subscript<T, R: UsageRule>(_ input: KeyPath<GitHubAnalysisInputs, Input<T, R>>) -> T {
		return self[keyPath: input].value
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
		
		let quietFlag = inputs.isFlagSet(named: kQuietFlag)
		
		// note: we disallow both verbose and quiet by setting verbose to true only
		// if quiet is false
		let verboseFlag = inputs.isFlagSet(named: kVerboseFlag) && !quietFlag
		
		let outputCSVFlag = inputs.isFlagSet(named: kOutputCSVFlag)
		
		let printJSON = inputs.isFlagSet(named: kPrintJSONFlag)
		
		let skipRequests = inputs.isFlagSet(named: kSkipRequestsFlag)
		
		let skipAnalysis = inputs.isFlagSet(named: kSkipAnalysisFlag)
		
		let skipFootnotes = inputs.isFlagSet(named: kSkipFootnotesFlag)
		
		let cacheFileLocation = inputs.variable(named: kCacheFileArg).map(URL.init(fileURLWithPath:))
		
		return .success(GitHubAnalysisInputs(personalAccessToken: personalAccessToken,
											 repositoryOwner: repositoryOwner,
											 repositories: repositories,
											 earliestDate: earliestDateArg,
											 latestDate: latestDateArg,
											 users: usersArg,
											 cacheFileLocation: cacheFileLocation,
											 verbose: verboseFlag,
											 quiet: quietFlag,
											 outputCSV: outputCSVFlag,
											 printJSON: printJSON,
											 skipRequests: skipRequests,
											 skipAnalysis: skipAnalysis,
											 skipFootnotes: skipFootnotes))
	}
	
	enum GHAInputsError: Error {
		case needHelp
		case missingRequirement(description: String)
	}
}

extension GitHubAnalysisInputs {
	var logLevel: Log.Level {
		let levels: [Log.Level] = [
			self[\.verbose] ? .verbose : nil,
			self[\.quiet] ? .quiet : nil
		].compactMap { $0 }
		
		return Log.Level(mostRestrictiveOf: levels)
	}
}
