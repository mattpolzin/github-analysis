//
//  GitHubAnalysisInputs+Constants.swift
//  Alamofire
//
//  Created by Mathew Polzin on 10/28/18.
//

import Foundation

extension GitHubAnalysisInputs {
	static var kGithubAccessTokenVar: String { return "GITHUB_ANALYSIS_TOKEN" }
	
	static var kOrganizationArgPos: Int { return 0 }
	static var kOrganizationArg: String { return "owner" }
	static var kRepositoriesArgPos: Int { return 1 }
	static var kRepositoriesArg: String { return "repositories" }
	
	static var kEarliestDateArg: String { return "-later-than" }
	static var kLatestDateArg: String { return "-earlier-than" }
	static var kUsersArg: String { return "-users" }
	static var kCacheFileArg: String { return "-cache-file" }
	
	static var kVerboseFlag: String { return "-verbose" }
	static var kQuietFlag: String { return "-quiet" }
	static var kPrintJSONFlag: String { return "-print-json" }
	static var kOutputCSVFlag: String { return "-csv" }
	static var kSkipRequestsFlag: String { return "-skip-requests" }
	static var kSkipAnalysisFlag: String { return "-skip-analysis" }
	static var kSkipFootnotesFlag: String { return "-skip-footnotes" }
	static var kHelpFlag: String { return "-help" }
}
