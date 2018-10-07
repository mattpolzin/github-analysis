//
//  GitHubAnalysisFilters.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/6/18.
//

import Foundation

struct GitHubAnalysisFilters {
	/// Returns true if the given repository name is being analyzed
	let repositories: (String) -> Bool
	
	/// Returns true if the given user is being analyzed
	let users: (String) -> Bool
	
	/// Returns true if the given date is new enough to be analyzed
	let earliestDate: (Date) -> Bool
	
	/// Returns true if the given date is old enough to be analyzed
	let latestDate: (Date) -> Bool
	
	init(from inputs: GitHubAnalysisInputs) {
		repositories = inputs.repositories.contains
		
		users = { username in
			return inputs.users?.contains(username) ?? true
		}
		
		earliestDate = { date in
			return inputs.earliestDate.map { date >= $0 } ?? true
		}
		
		latestDate = { date in
			return inputs.latestDate.map { date <= $0 } ?? true
		}
	}
}
