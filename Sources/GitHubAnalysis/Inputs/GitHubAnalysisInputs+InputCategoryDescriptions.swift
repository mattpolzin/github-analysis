//
//  GitHubAnalysisInputs+InputCategoryDescriptions.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/28/18.
//

import Foundation

extension GitHubAnalysisInputs: InputCategoryDescriptions {
	static var scriptName: String { return "github-analysis" }
	
	static var notes: UsageCategory? {
		struct Note: NoteRule {
			static var description: String {
				return "IMPORTANT:\nThe GitHub events API that powers much of this script's analysis is limited to returning 300 events or 90 days into the past, whichever comes first. This limit is per-repository.\n\nThis script caches events for later use so that over time you can build up a bigger picture than the limitation would allow for. That being said, it is important to look at the \"Limiting lower bound\" offered up at the command line and in the CSV. This lower bound is the earliest date for which an event was found in the repository with the least history available. In other words, take the earliest event date for each repository and pick the latest of those dates.\n\nMy recommendation is to not perform analysis back farther in time than the \"Limiting lower bound\" (using -\(GitHubAnalysisInputs.kEarliestDateArg))"
			}
		}
		
		return UsageCategory(name: "NOTES",
							 note: nil,
							 rules: [Note.self])
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
