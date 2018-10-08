//
//  GitHubAnalysisFormatter.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/6/18.
//

import Foundation

public enum GitHubAnalysisFormatter {
	public static var datetime: DateFormatter {
		let gitDatetimeFormatter = DateFormatter()
		gitDatetimeFormatter.locale = Locale.init(identifier: "en_US_POSIX")
		gitDatetimeFormatter.timeZone = TimeZone.init(identifier: "UTC")!
		gitDatetimeFormatter.dateFormat = "yyyy-MM-dd'T'HH-mm-ss'Z'"
		
		return gitDatetimeFormatter
	}
	
	public static var date: DateFormatter {
		let gitDateFormatter = DateFormatter()
		gitDateFormatter.locale = Locale.init(identifier: "en_US_POSIX")
		gitDateFormatter.dateFormat = "yyyy-MM-dd"
		
		return gitDateFormatter
	}
}
