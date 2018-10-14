//
//  GitHubAnalysisInputs.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/6/18.
//

import Foundation
import Result

struct GitHubAnalysisInputs {
	let personalAccessToken: String
	let repositoryOwner: String
	let repositories: [String]
	let earliestDate: Date?
	let latestDate: Date?
	let users: [String]?
	let outputCSV: Bool
	let printJSON: Bool
	let skipAnalysis: Bool
	let cacheFileLocation: URL?
	
	static func from(scriptInputs inputs: Inputs) -> Result<GitHubAnalysisInputs, GHAInputsError> {
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
		
		let cacheFileLocation = inputs.variable(named: kCacheFileArg).map(URL.init(fileURLWithPath:))
		
		return .success(GitHubAnalysisInputs(personalAccessToken: personalAccessToken,
											 repositoryOwner: repositoryOwner,
											 repositories: repositories,
											 earliestDate: earliestDateArg,
											 latestDate: latestDateArg,
											 users: usersArg,
											 outputCSV: outputCSVFlag,
											 printJSON: printJSON,
											 skipAnalysis: skipAnalysis,
											 cacheFileLocation: cacheFileLocation))
	}
	
	enum GHAInputsError: Error {
		case needHelp
		case missingRequirement(description: String)
	}
}
